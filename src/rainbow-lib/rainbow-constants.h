; ################################################################################
; RAINBOW CONSTANTS

BUF_IN        = $0300
BUF_OUT       = $0380

; NES to ESP opcodes
.enum N2E

; ESP CMDS
  GET_ESP_STATUS
  DEBUG_LOG
  CLEAR_BUFFERS
  GET_WIFI_STATUS
  GET_RND_BYTE
  GET_RND_BYTE_RANGE ; min / max
  GET_RND_WORD
  GET_RND_WORD_RANGE ; min / max

; SERVER CMDS
  GET_SERVER_STATUS
  SET_SERVER_PROTOCOL
  GET_SERVER_SETTINGS
  SET_SERVER_SETTINGS
  CONNECT_SERVER
  DISCONNECT_SERVER
  SEND_MSG_TO_SERVER

; FILE COMMANDS
  FILE_OPEN
  FILE_CLOSE
  FILE_EXISTS
  FILE_DELETE
  FILE_SET_CUR
  FILE_READ
  FILE_WRITE
  FILE_APPEND
  GET_FILE_LIST
  GET_FREE_FILE_ID

; DEBUG
  GET_N_BYTES = 254

.endenum

; ESP to NES opcodes
.enum E2N
  READY

  FILE_EXISTS
  FILE_LIST
  FILE_DATA
  FILE_ID

  WIFI_STATUS
  SERVER_STATUS
  HOST_SETTINGS

  RND_BYTE
  RND_WORD
  
  MESSAGE_FROM_SERVER

  SUCCESS = 254
  ERROR = 255
.endenum

; WiFi status
.enum WIFI_STATUS
  NO_SHIELD       = 255
  IDLE_STATUS     = 0
  NO_SSID_AVAIL
  SCAN_COMPLETED
  CONNECTED
  CONNECT_FAILED
  CONNECTION_LOST
  DISCONNECTED
.endenum

; Server protocols
.enum SERVER_PROTOCOLS
  WS
  UDP
.endenum

; Server status
.enum SERVER_STATUS
  DISCONNECTED
  CONNECTED
  AUTH_SUCCESS
  AUTH_FAILED
.endenum

; File paths
.enum FILE_PATHS
  SAVE
  ROMS
  USER
.endenum

; Errors
.enum ERRORS
  FILE_DELETE
  FILE_DOES_NOT_EXIST
.endenum