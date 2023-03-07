#include <generated/csr.h>
#include <stdio.h>

extern "C" void leds(int);
void leds(int v) {
	leds_out_write(v);
}