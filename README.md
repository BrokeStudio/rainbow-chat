# RAINBOW CHAT for the NES

> &nbsp;  
> Here's a quick tutorial on how to use this online chat demo for the NES.  
> &nbsp;

#### changelog

_2020/03/17_ - v1.0 - initial release

## SERVER

You need NodeJS installed on your computer to run the chat server.  
Skip this part if you already have NodeJS installed and know how to use it.

- Download **NodeJS** at https://nodejs.org/ and install it (you'll need to restart)
- In the 'server' folder, run the command : _npm install_
- Then run _npm start_

Congratulations, the server should now be up!

**NOTE:**  
You can modify http server port in the **_index.js_** file.  
Look for HTTP_PORT (8000 by default) and change their values (don't forget to restart the server).

## WEB CLIENT

Now that the server is up, you can open your browser and visit http://127.0.0.1:8000 or http://localhost:8000.  
This will allow you to check if everything works correctly and to communicate with the NES later.

UI is pretty straightforward, enter a user name, leave the port text field empty to use the default value (3000) or enter a new one if you changed it, and click on **Connect**.

Then at the bottom, in the message field, enter a message and press **ENTER** or click on **Send** to send the message.

## NES CLIENT

To use the NES client, you need a custom version of FCEUX including the online functionnalities.

You can download a compiled build for Windows here: http://brokestudio.fr/rainbow/fceux_wifi.zip

Or you can build it yourself by cloning this GIT repository: https://github.com/sgadrat/fceux (branch rainbow, not master)

Just load the ROM **rainbow-chat.nes** file into FCEUX, enter the IP address of the server, the port, a username, and that should do it :)  
You should be able to exchange messages with the WEB client now. You can even add another (or more) WEB client(s) to the game for more fun. I didn't tested it with more than 3 clients in total so...

## ROM COMPILATION

The _compile.bat_ file expects some executable frome the **cc65** suite in the _bin_ folder (see _readme.txt_ file in the _bin_ folder).

**_OR_**

just update the _compile.bat_ file to point to your files directly.

## INFO / DOCUMENTATION

Thanks to Sylvain Gadrat aka _RogerBidon_ for his awesome work on FCEUX. Thanks for adding Rainbow mapper support ! <3

For more information on the Rainbow project, you can check its documentation (look for the 'rainbow-doc.md' file) or directly online: https://hackmd.io/@BrokeStudio/B1nU790HI

## /!\ IMPORTANT NOTE /!\

While this is a demo using an emulator, the thing works perfectly fine on the original hardware with my Rainbow cartridge.

The project is still a WIP, but it's quite stable now, that's why I wanted to share this litte demo.

## CONTACT

Feel free to give your feedback, and don't hesitate to create your own ROM and server too! I'd be happy to test it on real hardware if you want.

You can email me at contact@brokestudio.fr or via the contact form at https://www.brokestudio.fr/contact/

Also, you can join Broke Studio's Discord server https://discord.gg/ccDS9Au, and discuss about the Rainbow project or other things :)

> &nbsp;  
> _Antoine GOHIN / Broke Studio_  
> **mail**: contact@brokestudio.fr  
> **web**: https://www.brokestudio.fr  
> **twitter**: @Broke_Studio  
> **facebook**: Broke Studio  
> **instagram**: @broke_studio
>
> _Sylvain Gadrat / RogerBidon_  
> **web**: https://sgadrat.itch.io/  
> **twitter**: @RogerBidon  
> &nbsp;
