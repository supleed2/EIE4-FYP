from migen import *

from litex.soc.interconnect.csr import *
from litex.soc.integration.doc import ModuleDoc

# Test RGB Module ----------------------------------------------------------------------------------

class TestRgb(Module, AutoCSR, ModuleDoc):
    """
    RGB LED Test Module

    Set an RGB value and this SystemVerilog block will handle PWM pulse generation to set the on-board LED to that colour.
    """
    def __init__(self, platform, pads):
        self.pads = pads
        self._out = CSRStorage(size = 24, reset = 11206472, description="Led Output(s) Value (24-bit RGB)",
        fields = [
            CSRField("ledb", size = 8, description = "LED Blue Brightness"),
            CSRField("ledg", size = 8, description = "LED Green Brightness"),
            CSRField("ledr", size = 8, description = "LED Red Brightness"),
        ])

        # # #

        leds = Signal(3)
        self.comb += pads.eq(~leds)
        self.specials += Instance("flipPwm",
            i_clk = ClockSignal(),
            i_rgb = self._out.storage,
            o_ledr = leds[0],
            o_ledg = leds[1],
            o_ledb = leds[2]
        )
        platform.add_source("rtl/flipPwm.sv")

