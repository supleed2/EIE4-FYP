#include "can"
#include <generated/csr.h>
#include <stdint.h>

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
#endif
