# Avrdude test script
This is a simple bash script for testing various hardware with Avrdude:

```
$ test-avrdude -h

Syntax: test-avrdude {<opts>}
Function: test avrdude for certain programmer and part combinations
Options:
    -c <configuration spec>     additional configuration options used for all runs
    -d <sec>                    delay between test commands (default 4 seconds)
    -e <avrdude path>           set path of avrdude executable (default avrdude)
    -p <programmer/part specs>  can be used multiple times, overrides default tests
    -s                          skip EEPROM tests for bootloaders
    -? or -h                    show this help text
Example:
    $ test-avrdude -d 0 -p "-c dryrun -p t13" -p "-c dryrun -p m4809"
```

Calling the test script without options runs a series of pre-set tests for which you may or may not have programmers and parts.

