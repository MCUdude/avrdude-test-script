#!/bin/sh

declare -a pgm_and_target=(
  "-cpowerdebugger_isp -B0.5 -patmega2560"
  "-cpowerdebugger -B0.5 -patmega2560"
  "-cpkobn_updi -B1 -patmega3208"
  "-cpkobn_updi -B1 -patmega3209"
  "-cpkobn_updi -B1 -patmega4808"
  "-cpkobn_updi -B1 -pattiny3217"
  "-cpkobn_updi -B1 -pavr128da48"
  "-cpkobn_updi -B1 -pavr128db48"
  "-cpkobn_updi -B1 -pavr64dd32"
  "-cpkobn_updi -B1 -pavr64ea48"
  "-cpkobn_updi -B1 -pavr16eb32"
  "-cxplainedmini_isp -patmega328pb"
  "-cxplainedmini_updi -pattiny1616"
  "-cxplainedmini_updi -pattiny3217"
  "-cxplainedpro_updi -B1 -pattiny817"
  "-cxplainedpro_pdi -B0.5 -patxmega128a1u"
  "-cxplainedpro -B4MHz -patmega256rfr2"
)

while true; do
  for p in "${pgm_and_target[@]}"
  do
    #read -p "Prepare \"$p\" and press enter to continue"
    echo "Prepare \"$p\" and press 'enter' or 'space' to continue. Press any other key to skip"
    read -n1 -s -r -p $'' key
    sleep 1
  
    if [ "$key" == '' ]; then
      FAIL=false
  
      # Get flash and EEPROM size in bytes and make sure the numbers are in dec form
      FLASH_SIZE=$(avrdude $p -cdryrun -qq -T 'part -m' | grep flash | awk '{print $2}')
      EE_SIZE=$(avrdude $p -cdryrun -qq -T 'part -m' | grep eeprom | awk '{print $2}')
    
      # Memories that may or may not be present
      USERSIG_SIZE=$(avrdude $p -cdryrun -qq -T 'part -m' | grep usersig | awk '{print $2}') # R/W


    
      # The quick brown fox -T eeprom
      OUTPUT=$(avrdude -qq $p -T "write eeprom test_files/the_quick_brown_fox_${EE_SIZE}B.hex:a" 2>&1)
      if [[ $OUTPUT == '' ]]; then
        echo ✅ the_quick_brown_fox_${EE_SIZE}B.hex:a eeprom -T write/verify
      else
        echo $OUTPUT
        echo ❌ the_quick_brown_fox_${EE_SIZE}B.hex:a eeprom -T write/verify
        FAIL=true
      fi

      # Lorem ipsum -T flash
      OUTPUT=$(avrdude -qq $p -T "write flash test_files/lorem_ipsum_${FLASH_SIZE}B.srec" 2>&1)
      if [[ $OUTPUT == '' ]]; then
        echo ✅ lorem_ipsum_${FLASH_SIZE}B.srec flash -T write/verify
      else
        echo $OUTPUT
        echo ❌ lorem_ipsum_${FLASH_SIZE}B.srec flash -T write/verify
        FAIL=true
      fi

      # Lorem ipsum -T eeprom
      OUTPUT=$(avrdude -qq $p -T "write eeprom test_files/lorem_ipsum_${EE_SIZE}B.srec" 2>&1)
      if [[ $OUTPUT == '' ]]; then
        echo ✅ lorem_ipsum_${EE_SIZE}B.srec eeprom -T write/verify
      else
        echo $OUTPUT
        echo ❌ lorem_ipsum_${EE_SIZE}B.srec eeprom -T write/verify
        FAIL=true
      fi
  
      # Raw test
      OUTPUT=$(avrdude -qq $p \
        -T 'erase flash; write flash -512 0xc0cac01a 0xcafe "secret Coca .bin recipe"' \
        -U flash:w:test_files/cola-vending-machine.raw \
        -T 'write flash -1024 "Hello World"' 2>&1)
      if [[ $OUTPUT == '' ]]; then
        echo ✅ cola-vending-machine.raw flash -T/-U write/verify
      else
        echo $OUTPUT
        echo ❌ cola-vending-machine.raw flash -T/-U write/verify
        FAIL=true
      fi
    
      # Pack my box -U flash (writes to the first 1/8 and the last 1/8)
      avrdude -qq $p \
        -Uflash:w:test_files/holes_pack_my_box_${FLASH_SIZE}B.hex:a
      if [ $? == 0 ]; then
        echo ✅ holes_pack_my_box_${FLASH_SIZE}B.hex:a flash -U write
      else
        echo ❌ holes_pack_my_box_${FLASH_SIZE}B.hex:a flash -U write
        FAIL=true
      fi

      # The five boxing wizards -T flash (writes to the first 1/8 and the last 1/8)
      OUTPUT=$(avrdude -qq $p -T "write flash test_files/holes_the_five_boxing_wizards_${FLASH_SIZE}B.hex" 2>&1)
      if [[ $OUTPUT == '' ]]; then
        echo ✅ holes_the_five_boxing_wizards_${FLASH_SIZE}B.hex flash -T write
      else
        echo $OUTPUT
        echo ❌ holes_the_five_boxing_wizards_${FLASH_SIZE}B.hex flash -T write
        FAIL=true
      fi

      # Pack my box -U eeprom (writes to the first 1/8 and the last 1/8)
      avrdude -qq $p \
        -Ueeprom:w:test_files/holes_pack_my_box_${EE_SIZE}B.hex:a
      if [ $? == 0 ]; then
        echo ✅ holes_pack_my_box_${EE_SIZE}B.hex:a eeprom -U write
      else
        echo ❌ holes_pack_my_box_${EE_SIZE}B.hex:a eeprom -U write
        FAIL=true
      fi

      # The five boxing wizards -T eeprom (writes to the first 1/8 and the last 1/8)
      OUTPUT=$(avrdude -qq $p -T "write flash test_files/holes_the_five_boxing_wizards_${EE_SIZE}B.hex" 2>&1)
      if [[ $OUTPUT == '' ]]; then
        echo ✅ holes_the_five_boxing_wizards_${EE_SIZE}B.hex eeprom -T write
      else
        echo $OUTPUT
        echo ❌ holes_the_five_boxing_wizards_${EE_SIZE}B.hex eeprom -T write
        FAIL=true
      fi

      # Write and verify random data to usersig if present
      if [[ $USERSIG_SIZE != '' ]]; then
        avrdude -qq $p -T "erase usersig; write usersig test_files/random_data_${USERSIG_SIZE}B.bin"
        avrdude -qq $p -Uusersig:r:test_files/usersig_dump_${USERSIG_SIZE}B.bin:r
        cmp test_files/random_data_${USERSIG_SIZE}B.bin test_files/usersig_dump_${USERSIG_SIZE}B.bin
        if [ $? == 0 ]; then
          echo ✅ random_data_${USERSIG_SIZE}B.bin usersig -T/-U write/read
        else
          echo ❌ random_data_${USERSIG_SIZE}B.bin usersig -T/-U write/read
          FAIL=true
        fi
        rm test_files/usersig_dump_${USERSIG_SIZE}B.bin
      fi

      if [ $FAIL == true ]; then
        echo ''
        read -rep "One or more avrdude \"$p\" tests failed. Do you want to retry this particular test? (y/n): " choice
        case "$choice" in
          [yY])
            continue 2 # Re-run the same for-loop iterator
            ;;
          *)
            # Continue with the next hardware setup in the list
            ;;
        esac
      fi

    fi #key

  done #for

  break
done #while
