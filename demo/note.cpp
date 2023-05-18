#include <generated/csr.h>
#include <stdint.h>

void note(uint32_t frequency, unsigned int duration_ms) {
	audio_targ0_write(frequency);
	busy_wait(duration_ms);
	audio_targ0_write(0);
}

void wave(uint32_t wave) {
	audio_wave0_write(wave);
}
