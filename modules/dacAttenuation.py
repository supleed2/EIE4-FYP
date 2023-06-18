from migen import *

from litex.soc.interconnect.csr import *
from litex.soc.integration.doc import ModuleDoc

# Test RGB Module ----------------------------------------------------------------------------------

class DacAttenuation(Module, AutoCSR, ModuleDoc):
    """
    DAC Attenuation Control Module

    Set the Attenuation of the PCM1780 DAC
    """
    def __init__(self, platform, pads):
        platform.add_source("rtl/dacAttenuation.sv")

        self.pads = pads
        self.atten = CSRStorage(size = 8, reset = 128, description = "PCM1780: Attenuation Control")

        self.m_sel_n = Signal()
        self.m_clock = Signal()
        self.m_data  = Signal()

        # # #

        self.specials += Instance("dacAttenuation",
            i_i_clk48   = ClockSignal(),
            i_i_rst48_n = ~ResetSignal(),
            i_i_valid   = self.atten.re,
            i_i_atten   = self.atten.storage,
            o_o_sel_n   = self.m_sel_n,
            o_o_clock   = self.m_clock,
            o_o_data    = self.m_data,
        )

        self.comb += self.pads.ms.eq(self.m_sel_n) # Mode Bus: Select (Active Low)
        self.comb += self.pads.mc.eq(self.m_clock) # Mode Bus: Clock
        self.comb += self.pads.md.eq(self.m_data) # Mode Bus: Data
