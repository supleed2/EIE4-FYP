#include "can"
#include <generated/csr.h>
#include <irq.h>
#include <stdint.h>
#include <stdio.h>

char *readstr(bool);

#ifdef CSR_CAN_BASE
uint32_t can_id_read(void) {
	return can_can_id_read();
}

void can_id_write(uint32_t value) {
	can_can_id_write(value);
}

uint32_t can_mask_read(void) {
	return can_id_mask_read();
}

void can_mask_write(uint32_t value) {
	can_id_mask_write(value);
}

can_frame can_read(void) {
	can_frame frame;
	frame.id = can_can_id_read();
	frame.data[0] = can_rcv_data0_read();
	frame.data[1] = can_rcv_data1_read();
	frame.data[2] = can_rcv_data2_read();
	frame.data[3] = can_rcv_data3_read();
	frame.data[4] = can_rcv_data4_read();
	frame.data[5] = can_rcv_data5_read();
	frame.data[6] = can_rcv_data6_read();
	frame.data[7] = can_rcv_data7_read();
	return frame;
}

void can_isr(void) {
	static uint32_t count = 0;
	can_ev_pending_frame_write(1);				// Should use `can_ev_pending_read()` and check which interrupt, but there is only 1
	leds_out_write(leds_out_read() ^ 0xFF0000); // Toggle Red LED
	count++;
	can_frame frame = can_read();
	printf("\033[F\033[F\33[2K\nCAN frame % 5d received, ID: 0x%03X, data: 0x%02X 0x%02X 0x%02X 0x%02X 0x%02X 0x%02X 0x%02X 0x%02X\n",
		   count, frame.id, frame.data[0], frame.data[1], frame.data[2], frame.data[3], frame.data[4], frame.data[5],
		   frame.data[6], frame.data[7]); // Print CAN frame to UART
	can_ev_enable_frame_write(1);		  // Re-enable event handler, same as in `can_init()`
	printf("\e[92;1mStackSynth\e[0m> ");  // Print prompt to UART
	readstr(true);						  // Print current user input (if any)
}

void can_init(void) {
	irq_setmask(irq_getmask() | (1 << CAN_INTERRUPT)); // Enable CAN interrupt
	can_ev_enable_frame_write(1);					   // Should be `can_ev_enable_frame_write(1)` but it is equivalent
	printf("CAN INIT\n");							   // Print debug message to UART
}
#endif
