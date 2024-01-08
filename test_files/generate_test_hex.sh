#!/bin/bash
for i in 16 32 64 128 256 512 768 1024 2048 4096 8192 16384 32768 49152 65536 131072 139264 262144
do
  srec_cat -generate 0x00 $i -repeat-data 0xff -o 0xff_${i}B.hex -Intel
  srec_cat -generate 0x00 $i -repeat-string "LOREM IPSUM DOLOR SIT AMET. " -o lorem_ipsum_${i}B.srec
  echo "S9030000FC" >> lorem_ipsum_${i}B.srec
  srec_cat -generate 0x00 $i -repeat-string "THE QUICK BROWN FOX JUMPS OVER THE LAZY DOG. " -o the_quick_brown_fox_${i}B.hex -Intel
  dd if=/dev/urandom of=random_data_${i}B.bin bs=$i count=1 >& /dev/null
  # Generate files that starts at i/8, and ends at i-(i/8). And the space from i/4 to i-i/4 are left empty, as a "hole" in the generated file
  srec_cat -generate $((i/8)) $((i-(i/8))) -repeat-string "PACK MY BOX WITH FIVE DOZEN LIQUOR JUGS" -exclude $((i/4)) $((i-(i/4))) -o holes_pack_my_box_${i}B.hex -Intel
  srec_cat -generate $((i/8)) $((i-(i/8))) -repeat-string "THE FIVE BOXING WIZARDS JUMP QUICKLY" -exclude $((i/4)) $((i-(i/4))) -o holes_the_five_boxing_wizards_${i}B.hex -Intel
done
