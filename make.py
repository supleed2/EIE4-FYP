#!/usr/bin/env python3

# Modified from original gsd_orangecrab.py from LiteX-Boards.
#
# Copyright (c) Greg Davill <greg.davill@gmail.com>
# SPDX-License-Identifier: BSD-2-Clause

from migen import *
from migen.genlib.misc import WaitTimer
from migen.genlib.resetsync import AsyncResetSynchronizer

from litex.gen import LiteXModule

from litex_boards.platforms import gsd_orangecrab

from litex.build.generic_platform import IOStandard, Subsignal, Pins, Misc

from litex.soc.cores.clock import *
from litex.soc.integration.soc_core import *
from litex.soc.integration.builder import *
from litex.soc.cores.led import LedChaser

from litedram.modules import MT41K64M16, MT41K128M16, MT41K256M16, MT41K512M16
from litedram.phy import ECP5DDRPHY

# CRG ---------------------------------------------------------------------------------------------

class _CRG(LiteXModule):
    def __init__(self, platform, sys_clk_freq, with_usb_pll=False):
        self.rst    = Signal()
        self.cd_por = ClockDomain()
        self.cd_sys = ClockDomain()

        # # #

        # Clk / Rst
        clk48 = platform.request("clk48")
        rst_n = platform.request("usr_btn", loose=True)
        if rst_n is None: rst_n = 1

        # Power on reset
        por_count = Signal(16, reset=2**16-1)
        por_done  = Signal()
        self.comb += self.cd_por.clk.eq(clk48)
        self.comb += por_done.eq(por_count == 0)
        self.sync.por += If(~por_done, por_count.eq(por_count - 1))

        # PLL
        self.pll = pll = ECP5PLL()
        self.comb += pll.reset.eq(~por_done | ~rst_n | self.rst)
        pll.register_clkin(clk48, 48e6)
        pll.create_clkout(self.cd_sys, sys_clk_freq)

        # USB PLL
        if with_usb_pll:
            self.cd_usb_12 = ClockDomain()
            self.cd_usb_48 = ClockDomain()
            usb_pll = ECP5PLL()
            self.submodules += usb_pll
            self.comb += usb_pll.reset.eq(~por_done)
            usb_pll.register_clkin(clk48, 48e6)
            usb_pll.create_clkout(self.cd_usb_48, 48e6)
            usb_pll.create_clkout(self.cd_usb_12, 12e6)

        # FPGA Reset (press usr_btn for 1 second to fallback to bootloader)
        reset_timer = WaitTimer(int(48e6))
        reset_timer = ClockDomainsRenamer("por")(reset_timer)
        self.submodules += reset_timer
        self.comb += reset_timer.wait.eq(~rst_n)
        self.comb += platform.request("rst_n").eq(~reset_timer.done)


class _CRGSDRAM(LiteXModule):
    def __init__(self, platform, sys_clk_freq, with_usb_pll=False):
        self.rst = Signal()
        self.cd_init     = ClockDomain()
        self.cd_por      = ClockDomain()
        self.cd_sys      = ClockDomain()
        self.cd_sys2x    = ClockDomain()
        self.cd_sys2x_i  = ClockDomain()
        self.cd_dac      = ClockDomain() # Custom clock domain for PCM1780 DAC

        # # #

        self.stop  = Signal()
        self.reset = Signal()

        # Clk / Rst
        clk48 = platform.request("clk48")
        rst_n = platform.request("usr_btn", loose=True)
        if rst_n is None: rst_n = 1

        # Power on reset
        por_count = Signal(16, reset=2**16-1)
        por_done  = Signal()
        self.comb += self.cd_por.clk.eq(clk48)
        self.comb += por_done.eq(por_count == 0)
        self.sync.por += If(~por_done, por_count.eq(por_count - 1))

        # PLL
        sys2x_clk_ecsout = Signal()
        self.pll = pll = ECP5PLL()
        self.comb += pll.reset.eq(~por_done | ~rst_n | self.rst)
        pll.register_clkin(clk48, 48e6)
        pll.create_clkout(self.cd_sys2x_i, 2*sys_clk_freq)
        pll.create_clkout(self.cd_init, 24e6)
        pll.create_clkout(self.cd_dac, 36.864e6) # Create 36.864 MHz Clock for PCM1780 (48kHz fs * 768 as in datasheet)
        self.specials += [
            Instance("ECLKBRIDGECS",
                i_CLK0   = self.cd_sys2x_i.clk,
                i_SEL    = 0,
                o_ECSOUT = sys2x_clk_ecsout),
            Instance("ECLKSYNCB",
                i_ECLKI = sys2x_clk_ecsout,
                i_STOP  = self.stop,
                o_ECLKO = self.cd_sys2x.clk),
            Instance("CLKDIVF",
                p_DIV     = "2.0",
                i_ALIGNWD = 0,
                i_CLKI    = self.cd_sys2x.clk,
                i_RST     = self.reset,
                o_CDIVX   = self.cd_sys.clk),
            AsyncResetSynchronizer(self.cd_sys, ~pll.locked | self.reset),
        ]

        # USB PLL
        if with_usb_pll:
            self.cd_usb_12 = ClockDomain()
            self.cd_usb_48 = ClockDomain()
            usb_pll = ECP5PLL()
            self.submodules += usb_pll
            self.comb += usb_pll.reset.eq(~por_done)
            usb_pll.register_clkin(clk48, 48e6)
            usb_pll.create_clkout(self.cd_usb_48, 48e6)
            usb_pll.create_clkout(self.cd_usb_12, 12e6)

        # FPGA Reset (press usr_btn for 1 second to fallback to bootloader)
        reset_timer = WaitTimer(int(48e6))
        reset_timer = ClockDomainsRenamer("por")(reset_timer)
        self.submodules += reset_timer
        self.comb += reset_timer.wait.eq(~rst_n)
        self.comb += platform.request("rst_n").eq(~reset_timer.done)

# BaseSoC ------------------------------------------------------------------------------------------

class BaseSoC(SoCCore):
    def __init__(self, revision="0.2", device="25F", sys_clk_freq=48e6, toolchain="trellis",
        sdram_device    = "MT41K64M16",
        with_led_chaser = True,
        **kwargs):
        platform = gsd_orangecrab.Platform(revision=revision, device=device ,toolchain=toolchain)

        # CRG --------------------------------------------------------------------------------------
        crg_cls      = _CRGSDRAM if kwargs.get("integrated_main_ram_size", 0) == 0 else _CRG
        self.crg = crg_cls(platform, sys_clk_freq, with_usb_pll=True)

        # SoCCore ----------------------------------------------------------------------------------
        # Defaults to USB ACM through ValentyUSB.
        kwargs["uart_name"] = "usb_acm"
        SoCCore.__init__(self, platform, sys_clk_freq, ident="LiteX SoC on OrangeCrab", **kwargs)

        # DDR3 SDRAM -------------------------------------------------------------------------------
        if not self.integrated_main_ram_size:
            available_sdram_modules = {
                "MT41K64M16":  MT41K64M16,
                "MT41K128M16": MT41K128M16,
                "MT41K256M16": MT41K256M16,
                "MT41K512M16": MT41K512M16,
            }
            sdram_module = available_sdram_modules.get(sdram_device)

            ddram_pads = platform.request("ddram")
            self.ddrphy = ECP5DDRPHY(
                pads         = ddram_pads,
                sys_clk_freq = sys_clk_freq,
                dm_remapping = {0:1, 1:0},
                cmd_delay    = 0 if sys_clk_freq > 64e6 else 100)
            self.ddrphy.settings.rtt_nom = "disabled"
            if hasattr(ddram_pads, "vccio"):
                self.comb += ddram_pads.vccio.eq(0b111111)
            if hasattr(ddram_pads, "gnd"):
                self.comb += ddram_pads.gnd.eq(0)
            self.comb += self.crg.stop.eq(self.ddrphy.init.stop)
            self.comb += self.crg.reset.eq(self.ddrphy.init.reset)
            self.add_sdram("sdram",
                phy           = self.ddrphy,
                module        = sdram_module(sys_clk_freq, "1:2"),
                l2_cache_size = kwargs.get("l2_size", 8192)
            )

        # Leds -------------------------------------------------------------------------------------
        if with_led_chaser:
            # self.ledchaser = LedChaser(
            #     pads         = platform.request_all("user_led"),
            #     sys_clk_freq = sys_clk_freq
            # )
            from modules.testRGB import TestRgb
            self.leds = TestRgb(
                platform = platform,
                pads     = platform.request_all("user_led")
            )

        # GPIO Pins --------------------------------------------------------------------------------
        platform.add_extension([
            ("i2c", 0,
                Subsignal("scl", Pins("C9"), Misc("PULLMODE=UP")), # IO_SCL
                Subsignal("sda", Pins("C10"), Misc("PULLMODE=UP")), # IO_SDA
                IOStandard("LVCMOS33")
            ),
            ("can", 0,
                Subsignal("tx", Pins("J2")), # IO_13
                Subsignal("rx", Pins("H2")), # IO_12
                IOStandard("LVCMOS33")
            ),
            ("dac_pcm", 0,
                Subsignal("sck", Pins("G4")), # IO_A4
                Subsignal("bck", Pins("N17")), # IO_0
                Subsignal("lrck", Pins("M18")), # IO_1
                Subsignal("data", Pins("T17")), # IO_A5
                IOStandard("LVCMOS33")
            ),
            ("dac_ctrl", 0,
                Subsignal("ms", Pins("N15")), # IO_MISO
                Subsignal("mc", Pins("R17")), # IO_SCK
                Subsignal("md", Pins("N16")), # IO_MOSI
                IOStandard("LVCMOS33")
            ),
            ("debug_uart", 0,
                Subsignal("tx", Pins("B8")), # IO_10
                Subsignal("rx", Pins("C8")), # IO_9
                IOStandard("LVCMOS33")
            )
        ])

        # CAN Receiver Block -----------------------------------------------------------------------
        from modules.canReceiver import CanReceiver
        self.can = CanReceiver(
            platform = platform,
            pads     = platform.request("can")
        )
        self.irq.add("can", use_loc_if_exists=True)

        # DAC Control / Audio Blocks ---------------------------------------------------------------
        from modules.genWave import GenerateWave
        self.audio = GenerateWave(
            platform = platform,
            pads     = platform.request("dac_pcm")
        )
        # from modules.dacAttenuation import DacAttenuation
        # self.dac_atten = DacAttenuation(
        #     platform = platform,
        #     pads     = platform.request("dac_ctrl")
        # )

        # Volume Control ---------------------------------------------------------------------------
        from litex.soc.cores.bitbang import I2CMaster
        self.i2c = I2CMaster(pads = platform.request("i2c"))

        # Propagation Delay Test -------------------------------------------------------------------
        # from modules.testPropagation import TestPropagation
        # self.proptest = TestPropagation(platform = platform)

        # LiteScope Analyzer -----------------------------------------------------------------------
        # self.add_uartbone(name="debug_uart", baudrate=921600)
        # from litescope import LiteScopeAnalyzer
        # analyzer_signals = [
        #     # self.proptest.i_saw,
        #     # self.proptest.o_sin,
        #     self.can.can_rx,
        #     self.can.can_tx,
        #     # self.dac_atten.atten.re,
        #     # self.dac_atten.atten.storage,
        #     # self.dac_atten.m_sel_n,
        #     # self.dac_atten.m_clock,
        #     # self.dac_atten.m_data,
        #     self.audio.osc.re,
        #     # self.audio.osc.storage,
        #     self.audio.tf.re,
        #     # self.audio.tf.storage,
        #     self.audio.wav.re,
        #     # self.audio.wav.storage,
        #     self.audio.backpressure_48,
        #     # self.audio.sample_48,
        #     self.audio.audioready_48,
        #     self.audio.readrequest_36,
        #     # self.audio.sample_36,
        #     self.audio.fifoempty_36,
        #     self.audio.dac_lrck,
        #     self.audio.dac_bck,
        #     self.audio.dac_data,
        # ]
        # from math import ceil, floor
        # analyzer_depth = floor(190_000 / ((ceil(sum([s.nbits for s in analyzer_signals]) / 16)) * 16))
        # self.submodules.analyzer = LiteScopeAnalyzer(
        #     analyzer_signals,
        #     depth        = analyzer_depth,
        #     # clock_domain = "dac",
        #     clock_domain = "sys",
        #     # samplerate   = 36.92e6, # Actual clock frequency of DAC clock domain
        #     samplerate   = sys_clk_freq,
        #     csr_csv      = "analyzer.csv",
        # )

# Build --------------------------------------------------------------------------------------------

def main():
    from litex.build.parser import LiteXArgumentParser
    parser = LiteXArgumentParser(platform=gsd_orangecrab.Platform, description="LiteX SoC on OrangeCrab.")
    parser.add_target_argument("--sys-clk-freq",    default=48e6, type=float, help="System clock frequency.")
    parser.add_target_argument("--revision",        default="0.2",            help="Board Revision (0.1 or 0.2).")
    parser.add_target_argument("--device",          default="25F",            help="ECP5 device (25F, 45F or 85F).")
    parser.add_target_argument("--sdram-device",    default="MT41K64M16",     help="SDRAM device (MT41K64M16, MT41K128M16, MT41K256M16 or MT41K512M16).")
    parser.add_target_argument("--with-spi-sdcard", action="store_true",      help="Enable SPI-mode SDCard support.")
    args = parser.parse_args()

    soc = BaseSoC(
        toolchain    = args.toolchain,
        revision     = args.revision,
        device       = args.device,
        sdram_device = args.sdram_device,
        sys_clk_freq = args.sys_clk_freq,
        **parser.soc_argdict)
    if args.with_spi_sdcard:
        soc.add_spi_sdcard()
    builder = Builder(soc, **parser.builder_argdict)
    if args.build:
        builder.build(**parser.toolchain_argdict)

    if args.load:
        prog = soc.platform.create_programmer()
        prog.load_bitstream(builder.get_bitstream_filename(mode="sram"))

if __name__ == "__main__":
    main()
