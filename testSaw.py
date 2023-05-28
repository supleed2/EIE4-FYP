from migen import *

from litex.soc.interconnect.csr import *
from litex.soc.interconnect.stream import AsyncFIFO
from migen.genlib.fifo import AsyncFIFO as MigenAsyncFIFO
from litex.soc.integration.doc import ModuleDoc

# Test RGB Module ----------------------------------------------------------------------------------

class TestSaw(Module, AutoCSR, ModuleDoc):
    """
    Sawtooth Wave Test Module

    Set the expected frequency sawtooth wave to be output via the headphone port.
    """
    def __init__(self, platform, pads):
        platform.add_source("rtl/cordic.sv")
        platform.add_source("rtl/saw2sin.sv")
        platform.add_source("rtl/genSaw.sv")
        platform.add_source("rtl/dacDriver.sv")

        self.pads = pads
        self.targ0 = CSRStorage(size = 24, description = "Oscillator 0: Target Frequency of the Sawtooth Wave")
        self.wave0 = CSRStorage(size =  8, description = "Oscillator 0: Waveform to Output")
        self.targ1 = CSRStorage(size = 24, description = "Oscillator 1: Target Frequency of the Sawtooth Wave")
        self.wave1 = CSRStorage(size =  8, description = "Oscillator 1: Waveform to Output")
        self.targ2 = CSRStorage(size = 24, description = "Oscillator 2: Target Frequency of the Sawtooth Wave")
        self.wave2 = CSRStorage(size =  8, description = "Oscillator 2: Waveform to Output")
        self.targ3 = CSRStorage(size = 24, description = "Oscillator 3: Target Frequency of the Sawtooth Wave")
        self.wave3 = CSRStorage(size =  8, description = "Oscillator 3: Waveform to Output")
        self.targ4 = CSRStorage(size = 24, description = "Oscillator 4: Target Frequency of the Sawtooth Wave")
        self.wave4 = CSRStorage(size =  8, description = "Oscillator 4: Waveform to Output")
        self.targ5 = CSRStorage(size = 24, description = "Oscillator 5: Target Frequency of the Sawtooth Wave")
        self.wave5 = CSRStorage(size =  8, description = "Oscillator 5: Waveform to Output")
        self.targ6 = CSRStorage(size = 24, description = "Oscillator 6: Target Frequency of the Sawtooth Wave")
        self.wave6 = CSRStorage(size =  8, description = "Oscillator 6: Waveform to Output")
        self.targ7 = CSRStorage(size = 24, description = "Oscillator 7: Target Frequency of the Sawtooth Wave")
        self.wave7 = CSRStorage(size =  8, description = "Oscillator 7: Waveform to Output")
        self.targ8 = CSRStorage(size = 24, description = "Oscillator 8: Target Frequency of the Sawtooth Wave")
        self.wave8 = CSRStorage(size =  8, description = "Oscillator 8: Waveform to Output")
        self.targ9 = CSRStorage(size = 24, description = "Oscillator 9: Target Frequency of the Sawtooth Wave")
        self.wave9 = CSRStorage(size =  8, description = "Oscillator 9: Waveform to Output")

        # 48MHz Domain Signals
        self.backpressure_48 = Signal()
        self.sample_48       = Signal(16)
        self.audioready_48   = Signal()

        # 36.864MHz Domain Signals
        self.readrequest_36  = Signal()
        self.sample_36       = Signal(16)
        self.fifoempty_36    = Signal()
        self.dac_lrck        = Signal()
        self.dac_bck         = Signal()
        self.dac_data        = Signal()

        # # #

        self.specials += Instance("genSaw",
            i_i_clk48   = ClockSignal(),
            i_i_rst48_n = ~ResetSignal(),
            i_i_pause   = self.backpressure_48,
            i_i_targetf = self.targ0.storage,
            i_i_wave    = self.wave0.storage,
            o_o_sample  = self.sample_48,
            o_o_pulse   = self.audioready_48,
        )

        sample_fifo = ClockDomainsRenamer({"write": "sys", "read": "dac"})(MigenAsyncFIFO(48, 4))
        self.comb += self.backpressure_48.eq(~sample_fifo.writable)
        self.comb += sample_fifo.we.eq(self.audioready_48)
        self.comb += sample_fifo.din.eq(self.sample_48)
        self.comb += self.fifoempty_36.eq(~sample_fifo.readable)
        self.comb += sample_fifo.re.eq(self.readrequest_36)
        self.comb += self.sample_36.eq(sample_fifo.dout)
        self.submodules += sample_fifo

        self.specials += Instance("dacDriver",
            i_i_clk36   = ClockSignal("dac"),
            i_i_rst36_n = ~ResetSignal("dac"),
            i_i_wait    = self.fifoempty_36,
            i_i_sample  = self.sample_36,
            o_o_rdreq   = self.readrequest_36,
            o_o_lrck    = self.dac_lrck,
            o_o_bck     = self.dac_bck,
            o_o_data    = self.dac_data,
        )

        self.comb += self.pads.sck.eq(ClockSignal("dac"))
        self.comb += self.pads.bck.eq(self.dac_bck)
        self.comb += self.pads.lrck.eq(self.dac_lrck)
        self.comb += self.pads.data.eq(self.dac_data)
