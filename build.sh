#!/bin/bash
set -e
read -p "Rebuild gateware? [y/N]" -n 1 -r REBUILD
if [[ $REBUILD =~ ^[Yy]$ ]]; then
    echo # Move to next line
    rm -f analyzer.csv csr.csv gsd_orangecrab.dfu kernel.bin && echo "Cleaned up previous run files"
    python3 make.py --build --doc --cpu-type picorv32 --cpu-variant standard --nextpnr-ignoreloops --csr-csv csr.csv
    cp build/gsd_orangecrab/gateware/gsd_orangecrab.bit gsd_orangecrab.dfu && echo "Copied .bit to .dfu"
    dfu-suffix -v 1209 -p 5af0 -a gsd_orangecrab.dfu && echo "Added DFU suffix for target (VID:PID)"
    rm -r docs/ && echo "Deleted old docs in project root"
    cp -r build/gsd_orangecrab/doc/_build/html docs/ && echo "Copied docs to project root"
else echo "Skipping Rebuild"
fi
make -C demo && echo "Built demo files"
mv demo/demo.bin kernel.bin && echo "Moved kernel binary to project root"
rm -f demo/*.o demo/*.d demo/demo.elf demo/demo.elf.map && echo "Cleaned up build artifacts"
read -p "Flash OrangeCrab? [y/N]" -n 1 -r FLASH_OC
if [[ $FLASH_OC =~ ^[Yy]$ ]]; then
    echo # Move to next line
    set +e
    dfu-util -w -D gsd_orangecrab.dfu
    set -e
else echo "Skipping Reflash"
fi
read -p "Start litex_term? [y/N]" -n 1 -r START_LT
if [[ $START_LT =~ ^[Yy]$ ]]; then
    litex_term --kernel kernel.bin /dev/ttyACM0
fi
