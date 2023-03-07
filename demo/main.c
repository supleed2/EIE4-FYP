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

static void help(void) {
	puts("\nLiteX custom demo app built "__DATE__
		 " "__TIME__
		 "\n");
	puts("Available commands:");
	puts("help               - Show this command");
	puts("reboot             - Reboot CPU");
#ifdef CSR_LEDS_BASE
	puts("led                - Led demo");
#endif
	puts("donut              - Spinning Donut demo");
	puts("helloc             - Hello C");
#ifdef WITH_CXX
	puts("hellocpp           - Hello C++");
#ifdef CSR_LEDS_BASE
	puts("leds               - Led set demo");
#endif
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

#ifdef WITH_CXX
#ifdef CSR_LEDS_BASE
extern void leds(int);

static void leds_cmd(char **val) {
	int value = (int)strtol(get_token(val), NULL, 0);
	printf("Setting LED to %6x\n", value);
	leds(value);
}
#endif
#endif

extern void donut(void);

static void donut_cmd(void) {
	printf("Donut demo...\n");
	donut();
}

extern void helloc(void);

static void helloc_cmd(void) {
	printf("Hello C demo...\n");
	helloc();
}

#ifdef WITH_CXX
extern void hellocpp(void);

static void hellocpp_cmd(void) {
	printf("Hello C++ demo...\n");
	hellocpp();
}
#endif

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
#ifdef WITH_CXX
#ifdef CSR_LEDS_BASE
	else if (strcmp(token, "hellocpp") == 0)
		hellocpp_cmd();
	else if (strcmp(token, "leds") == 0)
		leds_cmd(&str);
#endif
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
