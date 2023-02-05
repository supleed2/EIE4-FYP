[-h]
[--toolchain {trellis,diamond}]
[--build]
[--load]
[--log-filename LOG_FILENAME]
[--log-level LOG_LEVEL]
[--sys-clk-freq SYS_CLK_FREQ]
[--revision REVISION]
[--device DEVICE]
[--sdram-device SDRAM_DEVICE]
[--with-spi-sdcard]
[--output-dir OUTPUT_DIR]
[--gateware-dir GATEWARE_DIR]
[--software-dir SOFTWARE_DIR]
[--include-dir INCLUDE_DIR]
[--generated-dir GENERATED_DIR]
[--build-backend BUILD_BACKEND]
[--no-compile]
[--no-compile-software]
[--no-compile-gateware]
[--csr-csv CSR_CSV]
[--csr-json CSR_JSON]
[--csr-svd CSR_SVD]
[--memory-x MEMORY_X]
[--doc]
[--bios-lto]
[--bios-console {full,no-history,no-autocomplete,lite,disable}]
[--bus-standard BUS_STANDARD]
[--bus-data-width BUS_DATA_WIDTH]
[--bus-address-width BUS_ADDRESS_WIDTH]
[--bus-timeout BUS_TIMEOUT]
[--bus-bursting]
[--bus-interconnect BUS_INTERCONNECT]
[--cpu-type CPU_TYPE]
[--cpu-variant CPU_VARIANT]
[--cpu-reset-address CPU_RESET_ADDRESS]
[--cpu-cfu CPU_CFU]
[--no-ctrl]
[--integrated-rom-size INTEGRATED_ROM_SIZE]
[--integrated-rom-init INTEGRATED_ROM_INIT]
[--integrated-sram-size INTEGRATED_SRAM_SIZE]
[--integrated-main-ram-size INTEGRATED_MAIN_RAM_SIZE]
[--csr-data-width CSR_DATA_WIDTH]
[--csr-address-width CSR_ADDRESS_WIDTH]
[--csr-paging CSR_PAGING]
[--csr-ordering CSR_ORDERING]
[--ident IDENT]
[--no-ident-version]
[--no-uart]
[--uart-name UART_NAME]
[--uart-baudrate UART_BAUDRATE]
[--uart-fifo-depth UART_FIFO_DEPTH]
[--no-timer]
[--timer-uptime]
[--l2-size L2_SIZE]
[--yosys-nowidelut]
[--yosys-abc9]
[--yosys-flow3]
[--nextpnr-timingstrict]
[--nextpnr-ignoreloops]
[--nextpnr-seed NEXTPNR_SEED]
[--ecppack-bootaddr ECPPACK_BOOTADDR]
[--ecppack-spimode ECPPACK_SPIMODE]
[--ecppack-freq ECPPACK_FREQ]
[--ecppack-compress]


# Target options:
  --build # Build design. (default: False)
  --load  # Load bitstream. (default: False)
  --sys-clk-freq SYS_CLK_FREQ
        #   System clock frequency. (default: 48000000.0)
  --revision 0.2
  --device 25F
  --sdram-device MT41K64M16
  --with-spi-sdcard
        #   Enable SPI-mode SDCard support. (default: False)

# Logging options:
  --log-filename build.log
  --log-level warning # (or debug, info (default), error or critical)

# Builder options:
  --no-compile
        #   Disable Software and Gateware compilation. (default: False)
  --no-compile-software
        #   Disable Software compilation only. (default: False)
  --no-compile-gateware
        #   Disable Gateware compilation only. (default: False)
  --doc #   Generate SoC Documentation. (default: False)

# SoC options:
  --bus-standard axi-lite
        #   Select bus standard: wishbone, axi-lite, axi. (default: wishbone)
  --bus-data-width BUS_DATA_WIDTH
        #   Bus data-width. (default: 32)
  --bus-address-width BUS_ADDRESS_WIDTH
        #   Bus address-width. (default: 32)
  --bus-bursting
        #   Enable burst cycles on the bus if supported. (default: False)
  --bus-interconnect BUS_INTERCONNECT
        #   Select bus interconnect: shared (default) or crossbar. (default: shared)
  --cpu-type CPU_TYPE
        #   Select CPU: None, marocchino, zynq7000, mor1kx, zynqmp, cv32e41p, openc906, cortex_m1, cva6, eos_s3, ibex,
        #   cortex_m3, blackparrot, femtorv, vexriscv, rocket, picorv32, vexriscv_smp, lm32, firev, serv, naxriscv, cva5,
        #   microwatt, neorv32, cv32e40p, gowin_emcu, minerva. (default: vexriscv)
  --cpu-variant CPU_VARIANT
        #   CPU variant. (default: None)
  --no-ctrl
        #   Disable Controller. (default: False)
  --integrated-rom-size INTEGRATED_ROM_SIZE
        #   Size/Enable the integrated (BIOS) ROM (Automatically resized to BIOS size when smaller). (default: 131072)
  --integrated-rom-init INTEGRATED_ROM_INIT
        #   Integrated ROM binary initialization file (override the BIOS when specified). (default: None)
  --no-uart
        #   Disable UART. (default: False)
  --uart-name UART_NAME
        #   UART type/name. (default: serial)
  --uart-baudrate UART_BAUDRATE
        #   UART baudrate. (default: 115200)

# Trellis toolchain options:
  --yosys-nowidelut
        #   Use Yosys's nowidelut mode. (default: False)
  --yosys-abc9
        #   Use Yosys's abc9 mode. (default: False)
  --yosys-flow3
        #   Use Yosys's abc9 mode with the flow3 script. (default: False)
  --nextpnr-timingstrict
        #   Use strict Timing mode (Build will fail when Timings are not met). (default: False)
  --nextpnr-ignoreloops
        #   Ignore combinatorial loops in Timing Analysis. (default: False)
  --nextpnr-seed NEXTPNR_SEED
        #   Set Nextpnr's seed. (default: 1)
  --ecppack-bootaddr ECPPACK_BOOTADDR
        #   Set boot address for next image. (default: 0)
  --ecppack-spimode ECPPACK_SPIMODE
        #   Set slave SPI programming mode. (default: None)
  --ecppack-freq ECPPACK_FREQ
        #   Set SPI MCLK frequency. (default: None)
  --ecppack-compress
        #   Use Bitstream compression. (default: False)
