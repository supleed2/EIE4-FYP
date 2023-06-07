#include "audio"
#include <generated/csr.h>
#include <stdint.h>

#ifdef CSR_AUDIO_BASE
// Normalise target frequency from float to (24.4 bit) fixed point
static inline uint32_t n_tf(float freq) {
	return static_cast<uint32_t>(freq * 16.0f);
}

// Set all oscillators to (0Hz, sawtooth)
void reset_audio(void) {
	for (int i = 0; i < 64; i++) {
		audio_osc_write(i);
		audio_tf_write(0);
		audio_wav_write(0);
	}
}

// Set oscillator `osc` to waveform `wave`
void set_wave(uint32_t osc, wave_t wave) {
	audio_osc_write(osc);
	audio_wav_write(wave);
}

// Set oscillator `osc` to frequency `freq`Hz
void set_freq(uint32_t osc, float freq) {
	audio_osc_write(osc);
	audio_tf_write(n_tf(freq));
}

// Set oscillator `osc` to waveform `wave` at frequency `freq`Hz
void audio(uint32_t osc, wave_t wave, float freq) {
	audio_osc_write(osc);
	audio_wav_write(wave);
	audio_tf_write(n_tf(freq));
}

// Set oscillator `osc` to waveform `wave` at frequency `freq`Hz for `ms` milliseconds
void timed_freq(uint32_t osc, float freq, unsigned int ms) {
	audio_osc_write(osc);
	audio_tf_write(n_tf(freq));
	busy_wait(ms);
	audio_tf_write(0);
}
#endif
