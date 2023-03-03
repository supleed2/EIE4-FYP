from migen import *
from migen.genlib.misc import WaitTimer

from litex.soc.interconnect.csr import *

# Test LED Module ----------------------------------------------------------------------------------

class TestLed(Module, AutoCSR):
    def __init__(self, platform, pads):
        self.pads     = pads
        leds   = Signal(3)

        # # #

        self.comb += pads.eq(leds)
        self.specials += Instance("flip",
            i_i_clk = ClockSignal("dac"),
            o_o_ledr = leds[0],
            o_o_ledg = leds[1],
            o_o_ledb = leds[2]
        )
        platform.add_source("rtl/flip.sv")

