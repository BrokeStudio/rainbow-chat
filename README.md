# RAINBOW CHAT demo for the NES

> &nbsp;  
> Here's a quick tutorial on how to use this online chat demo for the NES.  
> &nbsp;

#### changelog

2023/06/21

- code updated to match last rainbow wifi protocol update
- removed HTML client

2022/02/23

- code updated to match last rainbow wifi protocol update
- asm6 version added

2020/07/15

- code updated to match last rainbow wifi protocol update
- doc updated

2020/05/10

- code updated to support new rainbow mapper
- doc updated

2020/03/17

- initial release

## SERVER

You need NodeJS installed on your computer to run the chat server.  
Skip this part if you already have NodeJS installed and know how to use it.

- Download **NodeJS** at https://nodejs.org/ and install it (you'll need to restart)
- In the `server` folder, run the command : `npm install`
- Then run `npm start`

Congratulations, the server should now be up!

**NOTE:**  
You can modify http server port in the `index.js` file.  
Look for `HTTP_PORT` (1234 by default) and change its value (don't forget to restart the server).

## NES CLIENT

To use the NES client, you need a custom version of FCEUX including the online functionnalities.

You can download a compiled build for Windows here: http://brokestudio.fr/rainbow

Or you can build it yourself by cloning this GIT repository: https://github.com/BrokeStudio/fceux (branch rainbow, not master).

Just load the ROM **rainbow-chat.nes** file into FCEUX, enter the IP address of the server (127.0.0.1 should work if you didn't change anything), the port (1234 should work if you didn't change anything), a username, and that should do it :)  
You can now exchange messages with the WEB client. You can even add another (or more) WEB client(s) / FCEUX emu to the game for more fun. I didn't tested it with more than 3 clients in total so...

## ROM COMPILATION

### ASM6

At the top of the `chat.asm` file, you can comment/uncomment 1 lines to hardcode IP address and port.  
Values can be changed in `chat-connection.asm` at lines ~27-56.

The `compile.bat` file expects some **asm6.exe** executable in the same folder.

### CC65

At the top of the `chat.s` file, you can comment/uncomment 2 lines to hardcode IP address and port.

The `compile.bat` file expects some executable from the **cc65** suite in the _bin_ folder (see `readme.txt` file in the `bin` folder)

_OR_

just update the `compile.bat` file to point to your files directly.

## INFO / DOCUMENTATION

For more information on the Rainbow project, you can check its documentation here: https://github.com/BrokeStudio/rainbow-lib

While this is a demo using an emulator, the thing works perfectly fine on the original hardware with the Rainbow cartridge.

## CONTACT

Feel free to give your feedback, and don't hesitate to create your own ROM and server too!

You can email me at contact@brokestudio.fr or via the contact form at https://www.brokestudio.fr/contact/

Also, you can join Broke Studio's Discord server https://discord.gg/ccDS9Au, and discuss about the Rainbow project or other things :)

> &nbsp;  
> _Antoine GOHIN / Broke Studio_  
> **mail**: contact@brokestudio.fr  
> **web**: https://www.brokestudio.fr  
> **twitter**: @Broke_Studio  
> **facebook**: Broke Studio  
> **instagram**: @broke_studio
> &nbsp;  
> &nbsp;
