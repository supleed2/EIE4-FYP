from migen import *

from litex.soc.interconnect.csr import *
from litex.soc.integration.doc import ModuleDoc

# CDC FIFO Module for PCM Data ---------------------------------------------------------------------

class pcmFifo(Module, AutoCSR, ModuleDoc):
    """
    DAC Driver Module

    Connect output pins of the DAC
    """
    def __init__(self, platform, pads):
        self.pads = pads
        self.i_clk48 = Signal()
        self.i_rst48_n = Signal()
        self.i_dvalid = Signal()
        self.i_din = Signal(2)
        self.o_full = Signal()
        self.i_clk36 = Signal()
        self.i_rst36_n = Signal()
        self.i_rdreq = Signal()
        self.o_dout = Signal(2)
        self.o_empty = Signal()

        # # #

        self.specials += Instance("pcmfifo",
            i_i_clk48=self.i_clk48,
            i_i_rst48_n=self.i_rst48_n,
            i_i_dvalid=self.i_dvalid,
            i_i_din=self.i_din,
            o_o_full=self.o_full,
            i_i_clk36=self.i_clk36,
            i_i_rst36_n=self.i_rst36_n,
            i_i_rdreq=self.i_rdreq,
            o_o_dout=self.o_dout,
            o_o_empty=self.o_empty,
        )
        platform.add_source("rtl/pcmfifo.sv")
