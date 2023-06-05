from migen import *

from litex.soc.interconnect.csr import *
from litex.soc.integration.doc import ModuleDoc

# Test RGB Module ----------------------------------------------------------------------------------

class TestProp(Module, AutoCSR, ModuleDoc):
    """
    Propagation Test Module

    Test propagation delay of the genSaw block
    """
    def __init__(self, platform):
        platform.add_source("rtl/cordic.sv")
        platform.add_source("rtl/saw2sin.sv")

        self.targ0 = CSRStorage(size = 24, description = "Oscillator 0: Target Frequency of the Sawtooth Wave")
        self.wave0 = CSRStorage(size =  8, description = "Oscillator 0: Waveform to Output")

        self.delay = Signal(3) # Update i_saw after 2^3 = 8 cycles
        self.i_saw = Signal(16)
        self.o_sin = Signal(16)

        # # #

        self.sync += self.delay.eq(self.delay + 1)
        self.sync += If(self.delay == 0, self.i_saw.eq(self.i_saw + 1))

        self.specials += Instance("saw2sin",
            i_i_clk = ClockSignal(),
            i_i_saw = self.i_saw,
            o_o_sin = self.o_sin,
        )
