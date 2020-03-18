@echo off

:: compile
call compile.bat

:: wait for 1 second
ping -n 2 127.0.0.1 >nul

:: start ROM
start roms/rainbow-chat.nes
