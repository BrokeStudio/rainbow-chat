@echo off

:: sources
bin\ca65 -g --debug-info -I src -o obj/main.o src/main.s 

:: libraries

:: link
bin\ld65 -o "roms/rainbow-chat.nes" -C nes.cfg --dbgfile "roms/rainbow-chat.dbg" obj/main.o
