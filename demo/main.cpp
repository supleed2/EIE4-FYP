// This file is Copyright (c) 2020 Florent Kermarrec <florent@enjoy-digital.fr>
// License: BSD

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <generated/csr.h>
#include <irq.h>
#include <libbase/console.h>
#include <libbase/uart.h>

/*-----------------------------------------------------------------------*/
/* Uart                                                                  */
/*-----------------------------------------------------------------------*/

static char *readstr(void) {
	char c[2];
	static char s[64];
	static int ptr = 0;

	if (readchar_nonblock()) {
		c[0] = getchar();
		c[1] = 0;
		switch (c[0]) {
			case 0x7f:
			case 0x08:
				if (ptr > 0) {
					ptr--;
					fputs("\x08 \x08", stdout);
				}
				break;
			case 0x07:
				break;
			case '\r':
			case '\n':
				s[ptr] = 0x00;
				fputs("\n", stdout);
				ptr = 0;
				return s;
			default:
				if (ptr >= (sizeof(s) - 1))
					break;
				fputs(c, stdout);
				s[ptr] = c[0];
				ptr++;
				break;
		}
	}

	return NULL;
}

static char *get_token(char **str) {
	char *c, *d;

	c = (char *)strchr(*str, ' ');
	if (c == NULL) {
		d = *str;
		*str = *str + strlen(*str);
		return d;
	}
	*c = 0;
	d = *str;
	*str = c + 1;
	return d;
}

static void prompt(void) {
	printf("\e[92;1mStackSynth\e[0m> ");
}

/*-----------------------------------------------------------------------*/
/* Help                                                                  */
/*-----------------------------------------------------------------------*/
// void audio_targ_write(uint32_t v)
static void help(void) {
	puts("\nLiteX custom demo app built " __DATE__
		 " " __TIME__
		 "\n");
	puts("Available commands:");
	puts("help               - Show this command");
	puts("reboot             - Reboot CPU");
#ifdef CSR_LEDS_BASE
	puts("led                - Led demo");
#endif
	puts("donut              - Spinning Donut demo");
	puts("helloc             - Hello C");
	puts("hellocpp           - Hello C++");
#ifdef CSR_LEDS_BASE
	puts("leds               - Led set demo");
#endif
#ifdef CSR_AUDIO_BASE
	puts("audio              - Sawtooth Audio demo");
#endif
}

/*-----------------------------------------------------------------------*/
/* Commands                                                              */
/*-----------------------------------------------------------------------*/

static void reboot_cmd(void) {
	ctrl_reset_write(1);
}

#ifdef CSR_LEDS_BASE
static void led_cmd(void) {
	int i;
	int j;
	int k;
	printf("Led demo...\n");

	printf("Counter mode...\n");
	for (i = 0; i < 4; i++) {
		for (j = 0; j < 4; j++) {
			for (k = 0; k < 4; k++) {
				leds_out_write(0x3F0000 * i + 0x003F00 * j + 0x00003F * k);
				busy_wait(100);
			}
		}
	}

	printf("Shift mode...\n");
	for (i = 0; i < 24; i++) {
		leds_out_write(1 << i);
		busy_wait(100);
	}
	for (i = 0; i < 24; i++) {
		leds_out_write(1 << (23 - i));
		busy_wait(100);
	}

	printf("Dance mode...\n");
	for (i = 0; i < 16; i++) {
		leds_out_write(0x000055);
		busy_wait(200);
		leds_out_write(0xAAAA00);
		busy_wait(200);
	}

	printf("Clearing led...\n");
	leds_out_write(0);
}
#endif

#ifdef CSR_LEDS_BASE
extern "C" void leds(int);

static void leds_cmd(char **val) {
	int value = (int)strtol(get_token(val), NULL, 0);
	printf("Setting LED to %6x\n", value);
	leds(value);
}
#endif
#ifdef CSR_AUDIO_BASE
extern "C" void audio(int);

static void audio_cmd(char **val) {
	int value = (int)strtol(get_token(val), NULL, 0);
	printf("Setting Sawtooth to %dHz\n", value);
	audio(value);
}
#endif

extern "C" void donut(void);

static void donut_cmd(void) {
	printf("Donut demo...\n");
	donut();
}

extern "C" void helloc(void);

static void helloc_cmd(void) {
	printf("Hello C demo...\n");
	helloc();
}

extern "C" void hellocpp(void);

static void hellocpp_cmd(void) {
	printf("Hello C++ demo...\n");
	hellocpp();
}

/*-----------------------------------------------------------------------*/
/* Console service / Main                                                */
/*-----------------------------------------------------------------------*/

static void console_service(void) {
	char *str;
	char *token;

	str = readstr();
	if (str == NULL)
		return;
	token = get_token(&str);
	if (strcmp(token, "help") == 0)
		help();
	else if (strcmp(token, "reboot") == 0)
		reboot_cmd();
#ifdef CSR_LEDS_BASE
	else if (strcmp(token, "led") == 0)
		led_cmd();
#endif
	else if (strcmp(token, "donut") == 0)
		donut_cmd();
	else if (strcmp(token, "helloc") == 0)
		helloc_cmd();
	else if (strcmp(token, "hellocpp") == 0)
		hellocpp_cmd();
#ifdef CSR_LEDS_BASE
	else if (strcmp(token, "leds") == 0)
		leds_cmd(&str);
#endif
#ifdef CSR_AUDIO_BASE
	else if (strcmp(token, "audio") == 0)
		audio_cmd(&str);
#endif
	prompt();
}

int main(void) {
#ifdef CONFIG_CPU_HAS_INTERRUPT
	irq_setmask(0);
	irq_setie(1);
#endif
	uart_init();

	help();
	prompt();

	while (1) {
		console_service();
	}
}
