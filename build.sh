#!/bin/bash
set -e
python3 make.py --build --doc
cp build/gsd_orangecrab/gateware/gsd_orangecrab.bit gsd_orangecrab.dfu && echo "Copied .bit to .dfu"
dfu-suffix -v 1209 -p 5af0 -a gsd_orangecrab.dfu
rm -f /mnt/c/Users/suple/Desktop/dfu-util-0.9-win64/gsd.dfu && echo "Deleted old Win11 DFU"
mv gsd_orangecrab.dfu /mnt/c/Users/suple/Desktop/dfu-util-0.9-win64/gsd.dfu && echo "Moved new DFU to Win11 Desktop"
rm -f docs/ && echo "Deleted old docs in project root"
cp -r build/gsd_orangecrab/doc/_build/html docs/ && echo "Copied docs to project root"
