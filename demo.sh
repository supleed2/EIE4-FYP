#!/bin/bash
set -e
python3 demo/demo.py --build-path build/gsd_orangecrab/ --with-cxx
rm -f demo/*.o demo/*.d demo/demo.bin demo/demo.elf demo/demo.elf.map && echo "Cleaned up build artifacts"
rm -f /mnt/c/Users/suple/Desktop/dfu-util-0.9-win64/gsd.bin && echo "Deleted old Win11 BIN"
mv demo.bin /mnt/c/Users/suple/Desktop/dfu-util-0.9-win64/gsd.bin && echo "Moved new BIN to Win11 Desktop"
