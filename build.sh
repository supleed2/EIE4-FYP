#!/bin/bash
set -e
rm -f analyzer.csv csr.csv gsd_orangecrab.dfu kernel.bin && echo "Cleaned up previous run files"
python3 make.py --build --doc
cp build/gsd_orangecrab/gateware/gsd_orangecrab.bit gsd_orangecrab.dfu && echo "Copied .bit to .dfu"
dfu-suffix -v 1209 -p 5af0 -a gsd_orangecrab.dfu && echo "Added DFU suffix for target (VID:PID)"
# rm -f /mnt/c/Users/suple/Desktop/dfu-util-0.9-win64/gsd.dfu && echo "Deleted old Win11 DFU"
# mv gsd_orangecrab.dfu /mnt/c/Users/suple/Desktop/dfu-util-0.9-win64/gsd.dfu && echo "Moved new DFU to Win11 Desktop"
rm -r docs/ && echo "Deleted old docs in project root"
cp -r build/gsd_orangecrab/doc/_build/html docs/ && echo "Copied docs to project root"
BUILD_DIR=`realpath -eL build/gsd_orangecrab/` WITH_CXX=1 make -C demo && echo "Built demo files"
mv demo/demo.bin kernel.bin && echo "Moved kernel binary to project root"
rm -f demo/*.o demo/*.d demo/demo.elf demo/demo.elf.map && echo "Cleaned up build artifacts"
read -p "Flash OrangeCrab? [y/N]" -n 1 -r FLASH_OC
echo # Move to next line
if [[ $FLASH_OC =~ ^[Yy]$ ]] then
    dfu-util -D gsd_orangecrab.dfu
fi
read -p "Start litex_term? [y/N]" -n 1 -r START_LT
if [[ $START_LT =~ ^[Yy]$ ]] then
    litex_term --kernel demo.bin /dev/ttyACM0
fi
