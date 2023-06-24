#include "amp"
#include <generated/csr.h>
#include <libbase/i2c.h>
#include <stdint.h>

#ifdef CONFIG_HAS_I2C
#define I2C_DELAY(n) busy_wait_us(n * (250000 / I2C_FREQ_HZ))

static inline void i2c_oe_scl_sda(bool oe, bool scl, bool sda) {
	i2c_w_write(
		((oe & 1) << CSR_I2C_W_OE_OFFSET) |
		((scl & 1) << CSR_I2C_W_SCL_OFFSET) |
		((sda & 1) << CSR_I2C_W_SDA_OFFSET));
}

// START condition: 1-to-0 transition of SDA when SCL is 1
static void i2c_start(void) {
	i2c_oe_scl_sda(1, 1, 1);
	I2C_DELAY(1);
	i2c_oe_scl_sda(1, 1, 0);
	I2C_DELAY(1);
	i2c_oe_scl_sda(1, 0, 0);
	I2C_DELAY(1);
}

// STOP condition: 0-to-1 transition of SDA when SCL is 1
static void i2c_stop(void) {
	i2c_oe_scl_sda(1, 0, 0);
	I2C_DELAY(1);
	i2c_oe_scl_sda(1, 1, 0);
	I2C_DELAY(1);
	i2c_oe_scl_sda(1, 1, 1);
	I2C_DELAY(1);
	i2c_oe_scl_sda(0, 1, 1);
}

// Call when in the middle of SCL low, advances one clk period
static void i2c_transmit_bit(int value) {
	i2c_oe_scl_sda(1, 0, value);
	I2C_DELAY(1);
	i2c_oe_scl_sda(1, 1, value);
	I2C_DELAY(2);
	i2c_oe_scl_sda(1, 0, value);
	I2C_DELAY(1);
}

// Call when in the middle of SCL low, advances one clk period
static int i2c_receive_bit(void) {
	int value;
	i2c_oe_scl_sda(0, 0, 0);
	I2C_DELAY(1);
	i2c_oe_scl_sda(0, 1, 0);
	I2C_DELAY(1);
	// read in the middle of SCL high
	value = i2c_r_read() & 1;
	I2C_DELAY(1);
	i2c_oe_scl_sda(0, 0, 0);
	I2C_DELAY(1);
	return value;
}

// Send data byte and return 1 if slave sends ACK
static bool i2c_transmit_byte(unsigned char data) {
	int i;
	int ack;

	// SCL should have already been low for 1/4 cycle
	// Keep SDA low to avoid short spikes from the pull-ups
	i2c_oe_scl_sda(1, 0, 0);
	for (i = 0; i < 8; ++i) {
		// MSB first
		i2c_transmit_bit((data & (1 << 7)) != 0);
		data <<= 1;
	}
	i2c_oe_scl_sda(0, 0, 0); // release line
	ack = i2c_receive_bit();

	// 0 from slave means ack
	return ack == 0;
}

// Read data byte and send ACK if ack=1
static unsigned char i2c_receive_byte(bool ack) {
	int i;
	unsigned char data = 0;

	for (i = 0; i < 8; ++i) {
		data <<= 1;
		data |= i2c_receive_bit();
	}
	i2c_transmit_bit(!ack);
	i2c_oe_scl_sda(0, 0, 0); // release line

	return data;
}

bool amp_init(void) {
	return amp_write({0x00, 0x00, 0x07});
}

bool amp_read(amp_i2c &rcv) {
	i2c_start();
	if (!i2c_transmit_byte(I2C_ADDR_RD(0x28))) {
		i2c_stop();
		return false;
	}
	rcv.pot0 = i2c_receive_byte(true) & 0x3F;
	rcv.pot1 = i2c_receive_byte(true) & 0x3F;
	rcv.conf = i2c_receive_byte(false) & 0x3F;
	i2c_stop();
	return true;
}

bool amp_read_pot0(uint8_t &pot0) {
	amp_i2c temp;
	bool success = amp_read(temp);
	pot0 = temp.pot0;
	return success;
}

bool amp_read_pot1(uint8_t &pot1) {
	amp_i2c temp;
	bool success = amp_read(temp);
	pot1 = temp.pot1;
	return success;
}

bool amp_read_conf(uint8_t &conf) {
	amp_i2c temp;
	bool success = amp_read(temp);
	conf = temp.conf;
	return success;
}

bool amp_write(amp_i2c value) {
	i2c_start();
	if (!i2c_transmit_byte(I2C_ADDR_WR(0x28))) {
		i2c_stop();
		return true;
	}
	if (!i2c_transmit_byte(value.pot0)) {
		i2c_stop();
		return false;
	}
	if (!i2c_transmit_byte(value.pot1 | 0x40)) {
		i2c_stop();
		return false;
	}
	if (!i2c_transmit_byte(value.conf | 0x80)) {
		i2c_stop();
		return false;
	}
	i2c_stop();
	return true;
}

bool amp_write_pot0(uint8_t value) {
	amp_i2c temp;
	bool success = amp_read(temp);
	temp.pot0 = value;
	return success & amp_write(temp);
}

bool amp_write_pot1(uint8_t value) {
	amp_i2c temp;
	bool success = amp_read(temp);
	temp.pot1 = value;
	return success & amp_write(temp);
}

bool amp_write_conf(uint8_t value) {
	amp_i2c temp;
	bool success = amp_read(temp);
	temp.conf = value;
	return success & amp_write(temp);
}

#endif
