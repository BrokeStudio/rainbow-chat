; ################################################################################
; RAINBOW CONSTANTS

; Rainbow mapper registers
RNBW_CONFIG    EQU $4170
RNBW_RX        EQU $4171
RNBW_TX        EQU $4172
RNBW_RX_ADD    EQU $4173
RNBW_TX_ADD    EQU $4174

; commands to ESP

; ESP CMDS
TOESP_ESP_GET_STATUS                  EQU 0   ; Get ESP status
TOESP_DEBUG_GET_LEVEL                 EQU 1   ; Get debug level
TOESP_DEBUG_SET_LEVEL                 EQU 2   ; Set debug level
TOESP_DEBUG_LOG                       EQU 3   ; Debug / Log data
TOESP_CLEAR_BUFFERS                   EQU 4   ; Clear RX/TX buffers
TOESP_FROMESP_BUFFER_DROP_FROM_ESP    EQU 5   ; Drop messages from ESP buffer (TX)
TOESP_ESP_GET_FIRMWARE_VERSION        EQU 6   ; Get ESP/Rainbow firmware version
TOESP_ESP_FACTORY_RESET               EQU 7   ; Reset ESP to factory settings
TOESP_ESP_RESTART                     EQU 8   ; Restart ESP

; WIFI CMDS
TOESP_WIFI_GET_STATUS                 EQU 9   ; Get Wi-Fi connection status
TOESP_WIFI_GET_SSID                   EQU 10  ; Get Wi-Fi network SSID
TOESP_WIFI_GET_IP                     EQU 11  ; Get Wi-Fi IP address
TOESP_WIFI_GET_CONFIG                 EQU 12  ; Get Wi-Fi station / Access Point / Web Server config
TOESP_WIFI_SET_CONFIG                 EQU 13  ; Set Wi-Fi station / Access Point / Web Server config

; ACESS POINT CMDS
TOESP_AP_GET_SSID                     EQU 14  ; Get Access Point network SSID
TOESP_AP_GET_IP                       EQU 15  ; Get Access Point IP address

; RND CMDS
TOESP_RND_GET_BYTE                    EQU 16  ; Get random byte
TOESP_RND_GET_BYTE_RANGE              EQU 17  ; Get random byte between custom min/max
TOESP_RND_GET_WORD                    EQU 18  ; Get random word
TOESP_RND_GET_WORD_RANGE              EQU 19  ; Get random word between custom min/max

; SERVER CMDS
TOESP_SERVER_GET_STATUS               EQU 20  ; Get server connection status
TOESP_SERVER_PING                     EQU 21  ; Get ping between ESP and server
TOESP_SERVER_SET_PROTOCOL             EQU 22  ; Set protocol to be used to communicate (WS/UDP/TCP)
TOESP_SERVER_GET_SETTINGS             EQU 23  ; Get current server host name and port
TOESP_SERVER_SET_SETTINGS             EQU 24  ; Set current server host name and port
TOESP_SERVER_GET_SAVED_SETTINGS       EQU 25  ; Get server host name and port values saved in the Rainbow config file
TOESP_SERVER_SET_SAVED_SETTINGS       EQU 26  ; Set server host name and port values saved in the Rainbow config file
TOESP_SERVER_RESTORE_SETTINGS         EQU 27  ; Restore server host name and port to values defined in the Rainbow config
TOESP_SERVER_CONNECT                  EQU 28  ; Connect to server
TOESP_SERVER_DISCONNECT               EQU 29  ; Disconnect from server
TOESP_SERVER_SEND_MSG                 EQU 30  ; Send message to rainbow server

; NETWORK CMDS
TOESP_NETWORK_SCAN                    EQU 31  ; Scan networks around and return count
TOESP_NETWORK_GET_SCANNED_DETAILS     EQU 32  ; Get scanned network details
TOESP_NETWORK_GET_REGISTERED          EQU 33  ; Get registered networks status
TOESP_NETWORK_GET_REGISTERED_DETAILS  EQU 34  ; Get registered network SSID
TOESP_NETWORK_REGISTER                EQU 35  ; Register network
TOESP_NETWORK_UNREGISTER              EQU 36  ; Unregister network
TOESP_NETWORK_SET_ACTIVE              EQU 37  ; Set active network

; FILE COMMANDS
TOESP_FILE_OPEN                       EQU 38  ; Open working file
TOESP_FILE_CLOSE                      EQU 39  ; Close working file
TOESP_FILE_STATUS                     EQU 40  ; Get working file status
TOESP_FILE_EXISTS                     EQU 41  ; Check if file exists
TOESP_FILE_DELETE                     EQU 42  ; Delete a file
TOESP_FILE_SET_CUR                    EQU 43  ; Set working file cursor position a file
TOESP_FILE_READ                       EQU 44  ; Read working file (at specific position)
TOESP_FILE_WRITE                      EQU 45  ; Write working file (at specific position)
TOESP_FILE_APPEND                     EQU 46  ; Append data to working file
TOESP_FILE_COUNT                      EQU 47  ; Count files in a specific path
TOESP_FILE_GET_LIST                   EQU 48  ; Get list of existing files in a path
TOESP_FILE_GET_FREE_ID                EQU 49  ; Get an unexisting file ID in a specific path
TOESP_FILE_GET_FS_INFO                EQU 50  ; Get file system details (ESP flash or SD card)
TOESP_FILE_GET_INFO                   EQU 51  ; Get file info (size + crc32)
TOESP_FILE_DOWNLOAD                   EQU 52  ; Download a file
TOESP_FILE_FORMAT                     EQU 53  ; Format file system and save current config

; commands from ESP

; ESP CMDS
FROMESP_READY                         EQU 0   ; ESP is ready
FROMESP_DEBUG_LEVEL                   EQU 1   ; Returns debug configuration
FROMESP_ESP_FIRMWARE_VERSION          EQU 2   ; Returns ESP/Rainbow firmware version
FROMESP_ESP_FACTORY_RESET             EQU 3   ; See ESP_FACTORY_RESET_RES constants for details on returned value

; WIFI / ACCESS POINT CMDS
FROMESP_WIFI_STATUS                   EQU 4   ; Returns Wi-Fi connection status
FROMESP_SSID                          EQU 5   ; Returns Wi-Fi / Access Point SSID
FROMESP_IP                            EQU 6   ; Returns Wi-Fi / Access Point IP address
FROMESP_WIFI_CONFIG                   EQU 7   ; Returns Wi-Fi station / Access Point / Web Server

; RND CMDS
FROMESP_RND_BYTE                      EQU 8   ; Returns random byte value
FROMESP_RND_WORD                      EQU 9   ; Returns random word value

; SERVER CMDS
FROMESP_SERVER_STATUS                 EQU 10   ; Returns server connection status
FROMESP_SERVER_PING                   EQU 11  ; Returns min, max and average round-trip time and number of lost packets
FROMESP_SERVER_SETTINGS               EQU 12  ; Returns server settings (host name + port)
FROMESP_MESSAGE_FROM_SERVER           EQU 13  ; Message from server

; NETWORK CMDS
FROMESP_NETWORK_COUNT                 EQU 14  ; Returns number of networks found
FROMESP_NETWORK_SCANNED_DETAILS       EQU 15  ; Returns details for a scanned network
FROMESP_NETWORK_REGISTERED_DETAILS    EQU 16  ; Returns SSID for a registered network
FROMESP_NETWORK_REGISTERED            EQU 17  ; Returns registered networks status

; FILE CMDS
FROMESP_FILE_STATUS                   EQU 18  ; Returns working file status
FROMESP_FILE_EXISTS                   EQU 19  ; Returns if file exists or not
FROMESP_FILE_DELETE                   EQU 20  ; See RNBW_FILE_DELETE_xxx constants for details on returned value
FROMESP_FILE_LIST                     EQU 21  ; Returns path file list (FILE_GET_LIST)
FROMESP_FILE_DATA                     EQU 22  ; Returns file data (FILE_READ)
FROMESP_FILE_COUNT                    EQU 23  ; Returns file count in a specific path
FROMESP_FILE_ID                       EQU 24  ; Returns a free file ID (FILE_GET_FREE_ID)
FROMESP_FILE_FS_INFO                  EQU 25  ; Returns file system info (FILE_GET_FS_INFO)
FROMESP_FILE_INFO                     EQU 26  ; Returns file info (size + CRC32) (FILE_GET_INFO)
FROMESP_FILE_DOWNLOAD                 EQU 27  ; See RNBW_FILE_DOWNLOAD_xxx constants for details on returned value

; ESP factory reset result codes
RNBW_CONFIG_FACTORY_RESET_SUCCESS EQU 0
RNBW_CONFIG_FACTORY_RESET_ERROR_WHILE_RESETTING_CONFIG EQU 1
RNBW_CONFIG_FACTORY_RESET_ERROR_WHILE_DELETING_TWEB EQU 2
RNBW_CONFIG_FACTORY_RESET_ERROR_WHILE_DELETING_WEB EQU 3

; Wi-Fi status
RNBW_WIFI_TIMEOUT EQU 255
RNBW_WIFI_IDLE_STATUS EQU 0
RNBW_WIFI_NO_SSID_AVAIL EQU 1
RNBW_WIFI_SCAN_COMPLETED EQU 2
RNBW_WIFI_CONNECTED EQU 3
RNBW_WIFI_CONNECTION_FAILED EQU 4
RNBW_WIFI_CONNECTION_LOST EQU 5
RNBW_WIFI_WRONG_PASSWORD EQU 6
RNBW_WIFI_DISCONNECTED EQU 7


; Wi-Fi error
RNBW_WIFI_ERROR_UNKNOWN EQU 255
RNBW_WIFI_ERROR_NO_ERROR EQU 0
RNBW_WIFI_ERROR_NO_SSID_AVAIL EQU 1
RNBW_WIFI_ERROR_CONNECTION_FAILED EQU 4
RNBW_WIFI_ERROR_CONNECTION_LOST EQU 5
RNBW_WIFI_ERROR_WRONG_PASSWORD EQU 6

; Server protocols
RNBW_PROTOCOL_TCP EQU 0
RNBW_PROTOCOL_TCP_SECURED EQU 1
RNBW_PROTOCOL_UDP EQU 2

; Server status
RNBW_SERVER_DISCONNECTED EQU 0
RNBW_SERVER_CONNECTED EQU 1

; Wi-Fi config flags
RNBW_WIFI_CONFIG_FLAGS_WIFI_STATION_ENABLE EQU 1
RNBW_WIFI_CONFIG_FLAGS_ACCESS_POINT_ENABLE EQU 2
RNBW_WIFI_CONFIG_FLAGS_WEB_SERVER_ENABLE EQU 4

; File paths
RNBW_FILE_PATH_SAVE EQU 0
RNBW_FILE_PATH_ROMS EQU 1
RNBW_FILE_PATH_USER EQU 2

; File constants
RNBW_NUM_PATHS EQU 3
RNBW_NUM_FILES EQU 64

; Network encryption types
RNBW_NETWORK_ENCTYPE_WEP EQU 5
RNBW_NETWORK_ENCTYPE_WPA_PSK EQU 2
RNBW_NETWORK_ENCTYPE_WPA2_PSK EQU 4
RNBW_NETWORK_ENCTYPE_OPEN_NETWORK EQU 7
RNBW_NETWORK_ENCTYPE_WPA_WPA2_PSK EQU 8

; File config masks/flags
RNBW_FILE_CONFIG_FLAGS_ACCESS_MODE_MASK EQU %00000001
RNBW_FILE_CONFIG_FLAGS_ACCESS_MODE_AUTO EQU 0
RNBW_FILE_CONFIG_FLAGS_ACCESS_MODE_MANUAL EQU 1
RNBW_FILE_CONFIG_FLAGS_DESTINATION_MASK EQU %00000010
RNBW_FILE_CONFIG_FLAGS_DESTINATION_ESP EQU 0
RNBW_FILE_CONFIG_FLAGS_DESTINATION_SD EQU 2

; FILE_DELETE result codes
RNBW_FILE_DELETE_SUCCESS EQU 0
RNBW_FILE_DELETE_ERROR_WHILE_DELETING_FILE EQU 1
RNBW_FILE_DELETE_FILE_NOT_FOUND EQU 2
RNBW_FILE_DELETE_INVALID_PATH_OR_FILE EQU 3

; FILE_DOWNLOAD result codes
RNBW_FILE_DOWNLOAD_SUCCESS EQU 0
RNBW_FILE_DOWNLOAD_INVALID_DESTINATION EQU 1
RNBW_FILE_DOWNLOAD_ERROR_WHILE_DELETING_FILE EQU 2
RNBW_FILE_DOWNLOAD_UNKNOWN_OR_UNSUPPORTED_PROTOCOL EQU 3
RNBW_FILE_DOWNLOAD_NETWORK_ERROR EQU 4
RNBW_FILE_DOWNLOAD_HTTP_STATUS_NOT_IN_2XX EQU 5

; FILE_DOWNLOAD network error codes
RNBW_FILE_DOWNLOAD_NETWORK_ERR_CONNECTION_FAILED EQU -1
RNBW_FILE_DOWNLOAD_NETWORK_ERR_SEND_HEADER_FAILED EQU -2
RNBW_FILE_DOWNLOAD_NETWORK_ERR_SEND_PAYLOAD_FAILED EQU -3
RNBW_FILE_DOWNLOAD_NETWORK_ERR_NOT_CONNECTED EQU -4
RNBW_FILE_DOWNLOAD_NETWORK_ERR_CONNECTION_LOST EQU -5
RNBW_FILE_DOWNLOAD_NETWORK_ERR_NO_STREAM EQU -6
RNBW_FILE_DOWNLOAD_NETWORK_ERR_NO_HTTP_SERVER EQU -7
RNBW_FILE_DOWNLOAD_NETWORK_ERR_TOO_LESS_RAM EQU -8
RNBW_FILE_DOWNLOAD_NETWORK_ERR_ENCODING EQU -9
RNBW_FILE_DOWNLOAD_NETWORK_ERR_STREAM_WRITE EQU -10
RNBW_FILE_DOWNLOAD_NETWORK_ERR_READ_TIMEOUT EQU -11
