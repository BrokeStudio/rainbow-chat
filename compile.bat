@echo off

:: sources
bin\ca65 -t nes -g --debug-info -I src -o obj/main.o src/main.s

:: libraries

:: link
bin\cl65 -t nes -C nes.cfg -Wl --dbgfile,"roms/rainbow-chat.dbg" obj/main.o -o "roms/rainbow-chat.nes"
