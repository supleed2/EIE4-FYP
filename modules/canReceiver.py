from migen import *

from litex.soc.interconnect.csr import *
from litex.soc.interconnect.csr_eventmanager import EventManager, EventSourcePulse
from litex.soc.integration.doc import ModuleDoc

# CAN Receiver Module ------------------------------------------------------------------------------

class CanReceiver(Module, AutoCSR, ModuleDoc):
    """
    CAN Receiver Module

    Interface for the Microchip ATA6561-GAQW-N CAN Transceiver
    """
    def __init__(self, platform, pads):
        platform.add_source("rtl/can.sv")

        self.pads = pads
        self.can_id = CSRStorage(size = 11, reset = 0x123, description = "CAN ID to receive messages from")
        self.id_mask = CSRStorage(size = 11, reset = 0x7FF, description = "Mask for CAN ID")

        self.rcv_id = CSRStatus(size = 11, description = "Received message CAN ID")
        self.rcv_data0 = CSRStatus(size = 8, description = "Received message data byte 0")
        self.rcv_data1 = CSRStatus(size = 8, description = "Received message data byte 1")
        self.rcv_data2 = CSRStatus(size = 8, description = "Received message data byte 2")
        self.rcv_data3 = CSRStatus(size = 8, description = "Received message data byte 3")
        self.rcv_data4 = CSRStatus(size = 8, description = "Received message data byte 4")
        self.rcv_data5 = CSRStatus(size = 8, description = "Received message data byte 5")
        self.rcv_data6 = CSRStatus(size = 8, description = "Received message data byte 6")
        self.rcv_data7 = CSRStatus(size = 8, description = "Received message data byte 7")
        self.rcv_pulse = Signal()

        # Pin Connections
        self.can_rx = Signal()
        self.can_tx = Signal()

        # Interrupts
        self.submodules.ev = EventManager()
        self.ev.frame = EventSourcePulse(description = "CAN frame received, sets pending bit")
        self.ev.finalize()
        self.comb += self.ev.frame.trigger.eq(self.rcv_pulse)

        # # #

        self.specials += Instance("can",
            i_i_clk   = ClockSignal(),
            i_i_rst_n = ~ResetSignal(),
            i_i_id    = self.can_id.storage,
            i_i_mask  = self.id_mask.storage,
            i_i_rx    = self.can_rx,
            o_o_tx    = self.can_tx,
            o_o_id    = self.rcv_id.status,
            o_o_data0 = self.rcv_data0.status,
            o_o_data1 = self.rcv_data1.status,
            o_o_data2 = self.rcv_data2.status,
            o_o_data3 = self.rcv_data3.status,
            o_o_data4 = self.rcv_data4.status,
            o_o_data5 = self.rcv_data5.status,
            o_o_data6 = self.rcv_data6.status,
            o_o_data7 = self.rcv_data7.status,
            o_o_pulse = self.rcv_pulse,
        )

        self.comb += self.can_rx.eq(self.pads.rx)
        self.comb += self.pads.tx.eq(self.can_tx)
