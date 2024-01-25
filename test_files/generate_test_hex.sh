#!/bin/bash
for i in 32 64 128 256 512 768 1024 2048 4096 8192 10240 16384 20480 32768 36864 40960 49152 65536 69632 131072 139264 204800 262144 270336 401408 524288
do
  ###
  # Files for EEPROM testing
  srec_cat -generate 0x00 $i -repeat-data 0xff -o 0xff_${i}B.hex -Intel
  srec_cat -generate 0x00 $i -repeat-string "LOREM IPSUM DOLOR SIT AMET. " -o lorem_ipsum_${i}B.srec
  echo "S9030000FC" >> lorem_ipsum_${i}B.srec
  srec_cat -generate 0x00 $i -repeat-string "THE QUICK BROWN FOX JUMPS OVER THE LAZY DOG. " -o the_quick_brown_fox_${i}B.hex -Intel
  # Difficult files that starts at i/8+2, ends at i-i/8-2 but remove the space from i/4 to i-i/4 as a "hole"
  srec_cat -generate $((i/8+2)) $((i-i/8-2)) -repeat-string "PACK MY BOX WITH FIVE DOZEN LIQUOR JUGS" -exclude $((i/4)) $((i-i/4)) -o holes_pack_my_box_${i}B.hex -Intel
  srec_cat -generate $((i/8+2)) $((i-i/8-2)) -repeat-string "THE FIVE BOXING WIZARDS JUMP QUICKLY" -exclude $((i/4)) $((i-i/4)) -o holes_the_five_boxing_wizards_${i}B.hex -Intel

  ###
  # Files suitable for flash containing code with endless loops
  # Almost full flash leaving space for bootloaders either end
  srec_cat -generate $((i/8)) $((i-i/8)) -repeat-data $(for i in {255..0}; do printf "0x%02x 0xcf " $i; done) \
           -o flash_for_bootloaders_rjmp_loops_${i}B.hex -Intel
  if [[ $i -gt 32 ]]; then
    # A "difficult" sketch file with two code blocks and a data block of one byte with holes in between
    srec_cat -generate $((i/8+2)) $((i/4)) -repeat-data $(for i in {255..0}; do printf "0x%02x 0xcf " $i; done) \
      -generate $((i-i/4)) $((i-i/8-4)) -repeat-data $(for i in {255..0}; do printf "0x%02x 0xcf " $i; done) \
      -generate $((i-i/8-3)) $((i-i/8-2)) -repeat-data 0xcf \
      -o holes_rjmp_loops_${i}B.hex -Intel
    # A partial file to spot check a chip erase
    srec_cat -generate $((i/8+2)) $((i/4)) -repeat-data 0xff \
      -generate $((i-i/4)) $((i-i/8-4)) -repeat-data 0xff \
      -generate $((i-i/8-3)) $((i-i/8-2)) -repeat-data 0xff \
      -o holes_0xff_${i}B.hex -Intel
  fi
  # Full flash for parts without bootloaders
  srec_cat -generate 0 $i -repeat-data $(for i in {255..0}; do printf "0x%02x 0xcf " $i; done) \
           -o rjmp_loops_${i}B.hex -Intel

  ###
  # Random data for usersig memory
  dd if=/dev/urandom of=random_data_${i}B.bin bs=$i count=1 >& /dev/null
done
