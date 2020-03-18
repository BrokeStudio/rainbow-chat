# Rainbow documentation

> **Disclaimer**
> 
> This document and the project are still WIP and are subject to modifications.  
> &nbsp;

# Credits

The Rainbow project is developed by Antoine "glutock" Gohin / Broke Studio.  

Thanks to :
- Paul / InfiniteNesLives for taking time to explain me lots of hardware stuff
- Christian Gohin, my father, who helped me designing the board
- Sylvain Gadrat aka RogerBidon for updating FCEUX to emulate the Rainbow mapper
- The NES WiFi Club (cheers guys :)
- NESdev community

*last update : 2020/03/14*

# Table of content

- [Rainbow documentation](#rainbow-documentation)
- [Credits](#credits)
- [Table of content](#table-of-content)
- [What is Rainbow ?](#what-is-rainbow)
- [Why 'Rainbow' ?](#why-rainbow)
- [Mapper registers](#mapper-registers)
- [Rainbow registers](#rainbow-registers)
  - [UART (\$5000 - R/W)](#uart-5000---rw)
  - [Status (\$5001 - R/W)](#status-5001---rw)
- [Buffers](#buffers)
- [Messages format](#messages-format)
- [Commands](#commands)
  - [GET_ESP_STATUS](#getespstatus)
  - [DEBUG_LOG](#debuglog)
  - [CLEAR_BUFFERS](#clearbuffers)
  - [GET_WIFI_STATUS](#getwifistatus)
  - [GET_RND_BYTE](#getrndbyte)
  - [GET_RND_BYTE_RANGE](#getrndbyterange)
  - [GET_RND_WORD](#getrndword)
  - [GET_RND_WORD_RANGE](#getrndwordrange)
  - [GET_SERVER_STATUS](#getserverstatus)
  - [SET_SERVER_PROTOCOL](#setserverprotocol)
  - [GET_SERVER_SETTINGS](#getserversettings)
  - [SET_SERVER_SETTINGS](#setserversettings)
  - [CONNECT_SERVER](#connectserver)
  - [DISCONNECT_SERVER](#disconnectserver)
  - [SEND_MSG_TO_SERVER](#sendmsgtoserver)
  - [FILE_OPEN](#fileopen)
  - [FILE_CLOSE](#fileclose)
  - [FILE_EXISTS](#fileexists)
  - [FILE_DELETE](#filedelete)
  - [FILE_SET_CUR](#filesetcur)
  - [FILE_READ](#fileread)
  - [FILE_WRITE](#filewrite)
  - [FILE_APPEND](#fileappend)
  - [GET_FILE_LIST](#getfilelist)
  - [GET_FREE_FILE_ID](#getfreefileid)
- [Bootloader](#bootloader)
- [TODO](#todo)

---

# What is Rainbow ?

**Rainbow** is a mapper for the **NES** that allows to connect the console to the Internet. It uses a WiFi chip (**ESP8266**, called **ESP** in this doc) embedded on the cart.

# Why 'Rainbow' ?

There are two reasons for this name.  

The first one is because when I was learning Verilog and was playing with my CPLD dev board, I wired it with a lot of colored floating wires as you can see in this [Tweet](https://twitter.com/Broke_Studio/status/1031836021976170497), and it looked a lot like a rainbow.  

Second reason is because Kevin Hanley from KHAN games is working on a game called Unicorn, which is based on an old BBS game called Legend of the Red Dragon, and therefore needs a connection to the outside world to be played online. This project would be a great oppurtunity to help him, and as everyone knows, Unicorns love Rainbows :)

# Mapper registers

For now, the Rainbow mapper is based on UNROM-512 mapper to make the development easier.  

# Rainbow registers

\$5000-5001 registers can be read and written to in order to communicate with the ESP.

## UART (\$5000 - R/W)

Read register $5000 to get next byte from the ESP.  
```
  ; this is how to read an incomming message
  ; and store it in a buffer

  lda $5000         ; dummy read
  nop               ; let it breathe
  lda $5000         ; read first byte (message length)...
  sta buffer+0      ; ... and store it
  
  ; get the rest of the message

  ldx #0            ; set X to 0
:
  lda $5000         ; read next byte...
  sta buffer+1,x    ; ... and store it
  inx               ; increment X
  cpx buffer+0      ; compare X to message length
  bne :-            ; loop if not equal
```
**Note:** Because of the mapper buffer, the first read of a new message will always return the last read of the previous message. So a dummy read is required in this case. (*this is subject to change*)

Write to register $5000 to send byte to the ESP.  
```
  ; this is how to send a message from a buffer

  ldx #0            ; set X to 0
  lda buffer+0      ; get message length...
  sta $5000         ; ... and send it
:
  lda buffer+1,x    ; get next message byte...
  sta $5000         ; ... and send it
  inx               ; increment X
  cpx buffer+0      ; compare X to message length
  bne :-            ; loop if not equal

  ; this is how to send a short message or fixed values message

  lda #3                      ; message length
  sta $5000
  lda #N2E::FILE_DELETE  ; opcode / command
  sta $5000
  lda #FILE_PATHS::ROMS       ; paramater (path id)
  sta $5000
  lda #0                      ; parameter (file id)
  sta $5000

  ; this is possible too

  lda #2
  ldx #N2E::GET_FILE_LIST
  ldy #FILE_PATHS::ROMS
  sta $5000
  stx $5000
  sty $5000

```
**Note:** After you send the first byte of a new message, you have one second to send the rest of the message before the RX buffer is reset. This is to prevent the ESP to be stuck, waiting for a message that could never come. (*this is subject to change*)

## Status (\$5001 - R/W)

```
DI.....E
||.....|
||.....+ ESP enable ( 0 : disable | 1 : enable ) R/W
|+------ IRQ enable ( 0 : disable | 1 : enable ) R/W
+------- Data ready ( 0 : disable | 1 : enable ) R
         this flag is set to 1 when the ESP has data to transmit to the NES
         if the I flag is set, NES IRQ will be triggered
```

Note : the D flag won't be set to 0 immediately once the NES read the last byte from the ESP.
Therefore, it's recommended to process the data immediately after receiving it if you use the IRQ feature.

# Buffers

The ESP has 2 FIFO buffers :  

- **TX**: data from the ESP to the NES buffer  
- **RX**: data from the NES to the ESP buffer  

Both buffers can store up to 20 messages.

# Messages format

Messages always have the same format.  
First byte is the message length (number of bytes following this first byte).  
The minimum message length is 2 bytes, and maximum is 256.  

# Commands

**NES to ESP commands:**

| Value | N2E commands / opcodes                      | Description                                                   |
| ----- | ------------------------------------------- | ------------------------------------------------------------- |
| 0     | [GET_ESP_STATUS](#GET_ESP_STATUS)           | Get ESP status                                                |
| 1     | [DEBUG_LOG](#DEBUG_LOG)                     | Debug / Log data                                              |
| 2     | [CLEAR_BUFFERS](#CLEAR_BUFFERS)             | Clear RX/TX buffers                                           |
| 3     | [GET_WIFI_STATUS](#GET_WIFI_STATUS)         | Get WiFi connection status                                    |
| 4     | [GET_RND_BYTE](#GET_RND_BYTE)               | Get random byte                                               |
| 5     | [GET_RND_BYTE_RANGE](#GET_RND_BYTE_RANGE)   | Get random byte between custom min/max                        |
| 6     | [GET_RND_WORD](#GET_RND_WORD)               | Get random word                                               |
| 7     | [GET_RND_WORD_RANGE](#GET_RND_WORD_RANGE)   | Get random word between custom min/max                        |
| 8     | [GET_SERVER_STATUS](#GET_SERVER_STATUS)     | Get server connection status                                  |
| 9     | [SET_SERVER_PROTOCOL](#SET_SERVER_PROTOCOL) | Set protocol to be used to communicate (WS/UDP)               |
| 10    | [GET_SERVER_SETTINGS](#GET_SERVER_SETTINGS) | Get host name and port defined in the ESP config |
| 11    | [SET_SERVER_SETTINGS](#SET_SERVER_SETTINGS) | Set host name and port                           |
| 12    | [CONNECT_SERVER](#CONNECT_SERVER)           | Connect to server                                             |
| 13    | [DISCONNECT_SERVER](#DISCONNECT_SERVER)     | Disconnect from server                                        |
| 14    | [SEND_MSG_TO_SERVER](#SEND_MSG_TO_SERVER)   | Send message to rainbow server                                |
| 15    | [FILE_OPEN](#FILE_OPEN)                     | Open working file                                             |
| 16    | [FILE_CLOSE](#FILE_CLOSE)                   | Close working file                                            |
| 17    | [FILE_EXISTS](#FILE_EXISTS)                 | Check if file exists                                          |
| 18    | [FILE_DELETE](#FILE_DELETE)                 | Delete a file                                                 |
| 19    | [FILE_SET_CUR](#FILE_SET_CUR)               | Set working file cursor position a file                       |
| 20    | [FILE_READ](#FILE_READ)                     | Read working file (at specific position)                      |
| 21    | [FILE_WRITE](#FILE_WRITE)                   | Write working file (at specific position)                     |
| 22    | [FILE_APPEND](#FILE_APPEND)                 | Append data to working file                                   |
| 23    | [GET_FILE_LIST](#GET_FILE_LIST)             | Get list of existing files in a specific path                 |
| 24    | [GET_FREE_FILE_ID](#GET_FREE_FILE_ID)       | Get an unexisting file ID in a specific path.                 |

**ESP to NES commands:**

| Value | E2N commands / opcodes                     | Description                                             |
| ----- | ------------------------------------------ | ------------------------------------------------------- |
| 0     | [READY](#GET_ESP_STATUS)                   | ESP is ready                                            |
| 1     | [FILE_EXISTS](#FILE_EXISTS)                | Returns if file exists or not                           |
| 2     | [FILE_LIST](#GET_FILE_LIST)                | Returns path file list                                  |
| 3     | [FILE_DATA](#FILE_READ)                    | Returns file data (FILE_READ)                           |
| 4     | [FILE_ID](#GET_FREE_FILE_ID)               | Returns a free file ID (GET_FREE_FILE_ID)               |
| 5     | [WIFI_STATUS](#GET_WIFI_STATUS)            | Returns WiFi connection status                          |
| 6     | [SERVER_STATUS](#GET_SERVER_STATUS)        | Returns server connection status                        |
| 7     | [HOST_SETTINGS](#GET_SERVER_SETTINGS)      | Returns server settings (host name + port) |
| 8     | [RND_BYTE](#GET_RND_BYTE)                  | Returns random byte value                               |
| 9     | [RND_WORD](#GET_RND_WORD)                  | Returns random word value                               |
| 10    | [MESSAGE_FROM_SERVER](#SEND_MSG_TO_SERVER) | Message from server                                     |
| 254   | SUCCESS                                    |                                                         |
| 255   | ERROR                                      | See ERRORS                                              |


## GET_ESP_STATUS

This command asks the WiFi module if it's ready.  
The ESP will only answer when ready, so once you sent the message, just wait for the answer.

| Byte | Description                                 | Example               |
| ---- | ------------------------------------------- | --------------------- |
| 0    | Length of the message (excluding this byte) | `1`                   |
| 1    | Command ID (see NES to ESP commands list)   | `N2E::GET_ESP_STATUS` |

**Returns:**

| Byte | Description                                 | Example      |
| ---- | ------------------------------------------- | ------------ |
| 0    | Length of the message (excluding this byte) | `1`          |
| 1    | Command ID (see ESP to NES commands list)   | `E2N::READY` |

[Back to command list](#commands)

---

## DEBUG_LOG

This command logs data on the serial port of the ESP. (pin 5 of the ESP board edge connector)

| Byte | Description                                 | Example          |
| ---- | ------------------------------------------- | ---------------- |
| 0    | Length of the message (excluding this byte) | `4`              |
| 1    | Command ID (see NES 2 ESP commands list)    | `N2E::DEBUG_LOG` |
| 2    | Data length                                 | `2`              |
| 3    | Data                                        | `0x41`           |
| 4    | Data                                        | `0xAC`           |

[Back to command list](#commands)

---

## CLEAR_BUFFERS

This command clears TX/RX buffers.  
Can be use on startup to make sure that we start with a clean setup.

| Byte | Description                                 | Example              |
| ---- | ------------------------------------------- | -------------------- |
| 0    | Length of the message (excluding this byte) | `1`                  |
| 1    | Command ID (see NES 2 ESP commands list)    | `N2E::CLEAR_BUFFERS` |

[Back to command list](#commands)

---

## GET_WIFI_STATUS

This command asks the WiFi status.

| Byte | Description                                 | Example                |
| ---- | ------------------------------------------- | ---------------------- |
| 0    | Length of the message (excluding this byte) | `1`                    |
| 1    | Command ID (see NES 2 ESP commands list)    | `N2E::GET_WIFI_STATUS` |

**Returns:**

| Byte | Description                                 | Example                  |
| ---- | ------------------------------------------- | ------------------------ |
| 0    | Length of the message (excluding this byte) | `2`                      |
| 1    | Command ID (see ESP to NES commands list)   | `E2N::WIFI_STATUS`       |
| 2    | WiFi status (see below)                     | `WIFI_STATUS::CONNECTED` |

**WiFi status:**

| Value | WIFI_STATUS     | Description            |
| ----- | --------------- | ---------------------- |
| 255   | NO_SHIELD       | -                      |
| 0     | IDLE_STATUS     | -                      |
| 1     | NO_SSID_AVAIL   | -                      |
| 2     | SCAN_COMPLETED  | Network scan completed |
| 3     | CONNECTED       | WiFi connected         |
| 4     | CONNECT_FAILED  | WiFi connection failed |
| 5     | CONNECTION_LOST | WiFi connection lost   |
| 6     | DISCONNECTED    | WiFi disconnected      |

[Back to command list](#commands)

---

## GET_RND_BYTE

This command returns a random byte between 0 and 255.

| Byte | Description                                 | Example             |
| ---- | ------------------------------------------- | ------------------- |
| 0    | Length of the message (excluding this byte) | `1`                 |
| 1    | Command ID (see NES 2 ESP commands list)    | `N2E::GET_RND_BYTE` |

**Returns:**

| Byte | Description                                 | Example                 |
| ---- | ------------------------------------------- | ----------------------- |
| 0    | Length of the message (excluding this byte) | `2`                     |
| 1    | Command ID (see ESP to NES commands list)   | `E2N::RND_BYTE`         |
| 2    | Random value between 0 and 255              | Random value (0 to 255) |

[Back to command list](#commands)

---

## GET_RND_BYTE_RANGE

This command returns a random byte between custom min and max values.  

| Byte | Description                                 | Example                   |
| ---- | ------------------------------------------- | ------------------------- |
| 0    | Length of the message (excluding this byte) | `3`                       |
| 1    | Command ID (see NES 2 ESP commands list)    | `N2E::GET_RND_BYTE_RANGE` |
| 2    | Custom min value (0 to 254)                 | Min value                 |
| 3    | Custom max value (1 to 255)                 | Max value                 |

**Returns:**

| Byte | Description                                 | Example                 |
| ---- | ------------------------------------------- | ----------------------- |
| 0    | Length of the message (excluding this byte) | `2`                     |
| 1    | Command ID (see ESP to NES commands list)   | `E2N::RND_BYTE`         |
| 2    | Random value between 0 and 255              | Random value (0 to 255) |

[Back to command list](#commands)

---

## GET_RND_WORD

This command returns a random word between 0 and 65535.

| Byte | Description                                 | Example             |
| ---- | ------------------------------------------- | ------------------- |
| 0    | Length of the message (excluding this byte) | `1`                 |
| 1    | Command ID (see NES 2 ESP commands list)    | `N2E::GET_RND_WORD` |

**Returns:**

| Byte | Description                                 | Example         |
| ---- | ------------------------------------------- | --------------- |
| 0    | Length of the message (excluding this byte) | `3`             |
| 1    | Command ID (see ESP to NES commands list)   | `E2N::RND_WORD` |
| 2    | Random value HI byte                        | HI byte         |
| 3    | Random value LO byte                        | LO byte         |

[Back to command list](#commands)

---

## GET_RND_WORD_RANGE

This command returns a random word between custom min and max values.

| Byte | Description                                 | Example                   |
| ---- | ------------------------------------------- | ------------------------- |
| 0    | Length of the message (excluding this byte) | `5`                       |
| 1    | Command ID (see NES 2 ESP commands list)    | `N2E::GET_RND_WORD_RANGE` |
| 2    | Custom min value (0 to 65534)               | Min value HI byte         |
| 3    | Custom min value (0 to 65534)               | Min value LO byte         |
| 4    | Custom max value (1 to 65535)               | Max value HI byte         |
| 5    | Custom max value (1 to 65535)               | Max value LO byte         |

**Returns:**

| Byte | Description                                 | Example         |
| ---- | ------------------------------------------- | --------------- |
| 0    | Length of the message (excluding this byte) | `3`             |
| 1    | Command ID (see ESP to NES commands list)   | `EN2::RND_WORD` |
| 2    | Random value HI byte                        | HI byte         |
| 3    | Random value LO byte                        | LO byte         |

[Back to command list](#commands)

---

## GET_SERVER_STATUS

This command asks the server status.

| Byte | Description                                 | Example                  |
| ---- | ------------------------------------------- | ------------------------ |
| 0    | Length of the message (excluding this byte) | `1`                      |
| 1    | Command ID (see NES 2 ESP commands list)    | `N2E::GET_SERVER_STATUS` |

**Returns:**

| Byte | Description                                 | Example                    |
| ---- | ------------------------------------------- | -------------------------- |
| 0    | Length of the message (excluding this byte) | `2`                        |
| 1    | Command ID (see ESP to NES commands list)   | `E2N::SERVER_STATUS`       |
| 2    | Server status (see below)                   | `SERVER_STATUS::CONNECTED` |

**Server status:**

| Value | SERVER_STATUS | Description  |
| ----- | ------------- | ------------ |
| 0     | DISCONNECTED  | Disconnected |
| 1     | CONNECTED     | Connected    |

[Back to command list](#commands)

---

## SET_SERVER_PROTOCOL

This command sets the protocol to be use when talking to game server.

| Byte | Description                                 | Example                    |
| ---- | ------------------------------------------- | -------------------------- |
| 0    | Length of the message (excluding this byte) | `2`                        |
| 1    | Command ID (see NES 2 ESP commands list)    | `N2E::SET_SERVER_PROTOCOL` |
| 2    | Protocol value (see below)                  | `PROTOCOL::WS`             |

**Protocol values:**

| Value | PROTOCOL | Description |
| ----- | -------- | ----------- |
| 0     | WS       | WebSocket   |
| 1     | UDP      | UDP         |

[Back to command list](#commands)

---

## GET_SERVER_SETTINGS

This command gets the server settings (IP address and port).

| Byte | Description                                 | Example                    |
| ---- | ------------------------------------------- | -------------------------- |
| 0    | Length of the message (excluding this byte) | `1`                        |
| 1    | Command ID (see NES 2 ESP commands list)    | `N2E::GET_SERVER_SETTINGS` |

**Returns:**
<!--
If an IP address is used, you'll get 8 bytes, like this:

| Byte | Description                                 | Example              |
| ---- | ------------------------------------------- | -------------------- |
| 0    | Length of the message (excluding this byte) | `7`                  |
| 1    | Command ID (see ESP to NES commands list)   | `E2N::HOST_SETTINGS` |
| 2    | Port MSB                                    | `0x0B`               |
| 3    | Port LSB                                    | `0xB8`               |
| 4    | IP address first byte                       | `192`                |
| 5    | IP address second byte                      | `168`                |
| 6    | IP address third byte                       | `1`                  |
| 7    | IP address fourth byte                      | `20`                 |
If a host name is used instead of an IP address, you'll get 8+ bytes, like this:
-->

| Byte | Description                                 | Example                          |
| ---- | ------------------------------------------- | -------------------------------- |
| 0    | Length of the message (excluding this byte) | `18` (depends on message length) |
| 1    | Command ID (see ESP to NES commands list)   | `E2N::HOST_SETTINGS`             |
| 2    | Port MSB                                    | `0x0B`                           |
| 3    | Port LSB                                    | `0xB8`                           |
| 4    | Hostname string                             | `G`                              |
| 5    | ...                                         | `A`                              |
| 6    | ...                                         | `M`                              |
| 7    | ...                                         | `E`                              |
| 8    | ...                                         | `.`                              |
| 9    | ...                                         | `S`                              |
| 10   | ...                                         | `E`                              |
| 11   | ...                                         | `R`                              |
| 12   | ...                                         | `V`                              |
| 13   | ...                                         | `E`                              |
| 14   | ...                                         | `R`                              |
| 15   | ...                                         | `.`                              |
| 16   | ...                                         | `N`                              |
| 17   | ...                                         | `E`                              |
| 18   | ...                                         | `T`                              |

If no server host OR port are set then the response will be:

| Byte | Description                                 | Example              |
| ---- | ------------------------------------------- | -------------------- |
| 0    | Length of the message (excluding this byte) | `3`                  |
| 1    | Command ID (see ESP to NES commands list)   | `E2N::HOST_SETTINGS` |
| 2    | No settings available                       | `0xFF`               |

[Back to command list](#commands)

---

## SET_SERVER_SETTINGS

This command sets the server settings (IP address and port).  
It doesn't overwrite values set via the ESP web interface.  
<!--
If you want to use an IP address, message will look like this:

| Byte | Description                                 | Example                    |
| ---- | ------------------------------------------- | -------------------------- |
| 0    | Length of the message (excluding this byte) | `7`                        |
| 1    | Command ID (see NES 2 ESP commands list)    | `N2E::SET_SERVER_SETTINGS` |
| 6    | Port MSB                                    | `0x0B`                     |
| 7    | Port LSB                                    | `0xB8`                     |
| 2    | IP address first byte                       | `192`                      |
| 3    | IP address second byte                      | `168`                      |
| 4    | IP address third byte                       | `1`                        |
| 5    | IP address fourth byte                      | `20`                       |

If you want to use a host name, message will look like this:
-->

| Byte | Description                                 | Example                          |
| ---- | ------------------------------------------- | -------------------------------- |
| 0    | Length of the message (excluding this byte) | `18` (depends on message length) |
| 1    | Command ID (see NES 2 ESP commands list)    | `N2E::SET_SERVER_SETTINGS`       |
| 2    | Port MSB                                    | `0x0B`                           |
| 3    | Port LSB                                    | `0xB8`                           |
| 4    | Hostname string                             | `G`                              |
| 5    | ...                                         | `A`                              |
| 6    | ...                                         | `M`                              |
| 7    | ...                                         | `E`                              |
| 8    | ...                                         | `.`                              |
| 9    | ...                                         | `S`                              |
| 10   | ...                                         | `E`                              |
| 11   | ...                                         | `R`                              |
| 12   | ...                                         | `V`                              |
| 13   | ...                                         | `E`                              |
| 14   | ...                                         | `R`                              |
| 15   | ...                                         | `.`                              |
| 16   | ...                                         | `N`                              |
| 17   | ...                                         | `E`                              |
| 18   | ...                                         | `T`                              |

[Back to command list](#commands)

---

## CONNECT_SERVER

When using WS protocol, this command connects to server.  
When using UDP protocol, this command starts the UDP server on the ESP side.  

| Byte | Description                                 | Example               |
| ---- | ------------------------------------------- | --------------------- |
| 0    | Length of the message (excluding this byte) | `1`                   |
| 1    | Command ID (see NES 2 ESP commands list)    | `N2E::CONNECT_SERVER` |

[Back to command list](#commands)

---

## DISCONNECT_SERVER

When using WS protocol, this command disconnects from server.  
When using UDP protocol, this command stops the UDP server on the ESP side.  

| Byte | Description                                 | Example                  |
| ---- | ------------------------------------------- | ------------------------ |
| 0    | Length of the message (excluding this byte) | `1`                      |
| 1    | Command ID (see NES 2 ESP commands list)    | `N2E::DISCONNECT_SERVER` |

[Back to command list](#commands)

---

## SEND_MSG_TO_SERVER

This command sends a message to the server.  

| Byte | Description                                                    | Example                         |
| ---- | -------------------------------------------------------------- | ------------------------------- |
| 0    | Length of the message (excluding this byte)                    | `6` (depends on message length) |
| 1    | Command ID (see NES 2 ESP commands list)                       | `N2E::SEND_MSG_TO_SERVER`       |
|      | *from here, it depends on the server message you want to send* |                                 |
|      | *it could be something like this:*                             |                                 |
| 2    | Server command                                                 | `depends on the server`         |
| 3    | Data length                                                    | `3`                             |
| 4    | Data                                                           | `0x12`                          |
| 5    | Data                                                           | `0xFF`                          |
| 6    | Data                                                           | `0xE9`                          |

[Back to command list](#commands)

---

## FILE_OPEN

This command opens the working file.  
If the file does not exists, an empty one will be created.  
If the same file is already open, then the file cursor will be reset to 0.  
If another file is already open, it will be closed.  

| Byte | Description                                 | Example            |
| ---- | ------------------------------------------- | ------------------ |
| 0    | Length of the message (excluding this byte) | `3`                |
| 1    | Command ID (see NES to ESP commands list)   | `N2E::FILE_OPEN`   |
| 2    | File path (see FILE_PATHS)                  | `FILE_PATHS::SAVE` |
| 3    | File index                                  | `5 (0 to 63)`      |

**File paths:**

| Value | FILE_PATHS | Description                                     |
| ----- | ---------- | ----------------------------------------------- |
| 0     | SAVE       | Use this folder to load/save game data          |
| 1     | ROMS       | Use this folder to dump/flash ROMS              |
| 2     | USER       | Use this folder to read/write data for the user |

[Back to command list](#commands)

---

## FILE_CLOSE

This command closes the working file.  

| Byte | Description                                 | Example           |
| ---- | ------------------------------------------- | ----------------- |
| 0    | Length of the message (excluding this byte) | `1`               |
| 1    | Command ID (see NES to ESP commands list)   | `N2E::FILE_CLOSE` |

[Back to command list](#commands)

---

## FILE_EXISTS

This command checks if a file exists.  
This command returns 1 if the file exists, or 0 if it doesn't.  

| Byte | Description                                 | Example            |
| ---- | ------------------------------------------- | ------------------ |
| 0    | Length of the message (excluding this byte) | `3`                |
| 1    | Command ID (see NES to ESP commands list)   | `N2E::FILE_EXISTS` |
| 2    | File path (see FILE_PATHS)                  | `FILE_PATHS::SAVE` |
| 3    | File index                                  | `5 (0 to 63)`      |

**Returns:**

| Byte | Description                                 | Example            |
| ---- | ------------------------------------------- | ------------------ |
| 0    | Length of the message (excluding this byte) | `2`                |
| 1    | Command ID (see ESP to NES commands list)   | `N2E::FILE_EXISTS` |
| 2    | File exists                                 | `0 | 1`            |

[Back to command list](#commands)

---

## FILE_DELETE

This command deletes (if exists) the file corresponding of the passed index.  

| Byte | Description                                 | Example            |
| ---- | ------------------------------------------- | ------------------ |
| 0    | Length of the message (excluding this byte) | `3`                |
| 1    | Command ID (see NES to ESP commands list)   | `N2E::FILE_DELETE` |
| 2    | File path (see FILE_PATHS)                  | `FILE_PATHS::SAVE` |
| 3    | File index                                  | `5 (0 to 63)`      |

**Returns:**

| Byte    | Description                                 | Example                        |
| ------- | ------------------------------------------- | ------------------------------ |
| 0       | Length of the message (excluding this byte) | `1` or `2`                     |
| 1       | Command ID (see ESP to NES commands list)   | `N2E::SUCCESS` or `N2E::ERROR` |
| 2 (opt) | Error code                                  | `ERRORS::...`                  |

[Back to command list](#commands)

---

## FILE_SET_CUR

This command sets the position of the working file cursor.  
If the file is smaller than the passed offset, it'll be filled with 0x00.  

| Byte    | Description                                 | Example             |
| ------- | ------------------------------------------- | ------------------- |
| 0       | Length of the message (excluding this byte) | `2 to 5`            |
| 1       | Command ID (see NES to ESP commands list)   | `N2E::FILE_SET_CUR` |
| 2       | Offset LSB                                  | `0x00`              |
| 3 (opt) | Offset                                      | `0x00`              |
| 4 (opt) | Offset                                      | `0x10`              |
| 5 (opt) | Offset MSB                                  | `0x00`              |

[Back to command list](#commands)

---

## FILE_READ

This command reads and sends data from the working file. You have to pass the number of bytes you want to read.  
If there is working file currently open, number of bytes will be 0.

| Byte | Description                                 | Example          |
| ---- | ------------------------------------------- | ---------------- |
| 0    | Length of the message (excluding this byte) | `2`              |
| 1    | Command ID (see NES to ESP commands list)   | `N2E::FILE_READ` |
| 2    | Number of bytes to read                     | `64 (minimum 1)` |

**Returns:**

| Byte | Description                                 | Example          |
| ---- | ------------------------------------------- | ---------------- |
| 0    | Length of the message (excluding this byte) | `4`              |
| 1    | Command ID (see ESP to NES commands list)   | `N2E::FILE_DATA` |
| 2    | Data                                        | `0x12`           |
| 3    | Data                                        | `0xDA`           |
| 4    | Data                                        | `0x4C`           |

[Back to command list](#commands)

---

## FILE_WRITE

This command writes data to the working file.  

| Byte | Description                                 | Example           |
| ---- | ------------------------------------------- | ----------------- |
| 0    | Length of the message (excluding this byte) | `66`              |
| 1    | Command ID (see NES to ESP commands list)   | `N2E::FILE_WRITE` |
| 2    | Data                                        | `0x5F`            |
| ...  | Data                                        | `...`             |
| 66   | Data                                        | `0xAF`            |

**Note:** Data length is byte 0 minus 1.

[Back to command list](#commands)

---

## FILE_APPEND

This command appends data to the working file.  
The current cursor position is not affected.  

| Byte | Description                                 | Example            |
| ---- | ------------------------------------------- | ------------------ |
| 0    | Length of the message (excluding this byte) | `66`               |
| 1    | Command ID (see NES to ESP commands list)   | `N2E::FILE_APPEND` |
| 2    | Data                                        | `0x5F`             |
| ...  | Data                                        | `...`              |
| 66   | Data                                        | `0xAF`             |

**Note:** Data length is byte 0 minus 1.

[Back to command list](#commands)

---

## GET_FILE_LIST

Get list of existing files in a specific path.  

| Byte | Description                                 | Example              |
| ---- | ------------------------------------------- | -------------------- |
| 0    | Length of the message (excluding this byte) | `2`                  |
| 1    | Command ID (see NES to ESP commands list)   | `N2E::GET_FILE_LIST` |
| 2    | File path (see FILE_PATHS)                  | `FILE_PATHS::SAVE`   |

**Returns:**

| Byte | Description                                 | Example            |
| ---- | ------------------------------------------- | ------------------ |
| 0    | Length of the message (excluding this byte) | `5`                |
| 1    | Command ID (see ESP to NES commands list)   | `E2N::FILE_LIST`   |
| 2    | Number of files                             | `3 (0 : no files)` |
| 3    | File index                                  | `1`                |
| 4    | File index                                  | `5`                |
| 5    | File index                                  | `10`               |

[Back to command list](#commands)

---

## GET_FREE_FILE_ID

Get an unexisting file ID in a specific path.

| Byte | Description                                 | Example                 |
| ---- | ------------------------------------------- | ----------------------- |
| 0    | Length of the message (excluding this byte) | `2`                     |
| 1    | Command ID (see NES to ESP commands list)   | `N2E::GET_FREE_FILE_ID` |
| 2    | File path (see FILE_PATHS)                  | `FILE_PATHS::SAVE`      |

**Returns:**

| Byte | Description                                 | Example              |
| ---- | ------------------------------------------- | -------------------- |
| 0    | Length of the message (excluding this byte) | `2`                  |
| 1    | Command ID (see ESP to NES commands list)   | `E2N::FILE_ID`       |
| 2    | File ID                                     | `3 (128 : no files)` |

[Back to command list](#commands)

---

# Bootloader

We encourage developers to add a bootloader to their ROM. It could be accessed via a combination of buttons at startup. This could allow the user to perform some low level actions. For Example, if the game allow self-flashing for online updates, the bootloader menu could offer the possibility to backup the current ROM before updating, or even restoring the backed up ROM if the update failed.
Those are basic ideas, but more are to come ...

---

# TODO
