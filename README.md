This is the intitial prototype of the text controller. Note - the character ROM is INCOMPLETE - it only has upper case letters A-Z and numbers 0-9. Lowercase letters are replaced with upper case. To add additional characters, the character rom (ROM.coe) would need to be modified. The entries are 64-bit pixel maps, the address is the ascii value of the desired character. I gave the ROM 256 entries so custom characters can be made. 

To use this IP, connect it in IP integrator with an AXI->BRAM Controller. Configure memory size to 32kBytes.


See ex_driver.c for examples on how to control IP in software.

VGA Connector Pinout
1 - Red
2 - Green
3 - Blue
5 - HSync_Rtn
6 - Red_Rtn
7 - Green_Rtn
8 - Blue_Rtn
10 - VSync_Rtn
13 - HSync
14 - VSync

My Setup - I did not need the extra colors, so I left the two least significant color bits disconnected for RGB. 

[disconnected] RED(0) -> 2k Ohm -> red
[disconnected] RED(1) -> 1k Ohm -> red
RED(2) -> 510 Ohm -> red

[disconnected] GREEN(0) -> 2k Ohm -> green
[disconnected] GREEN(1) -> 1k Ohm -> green
GREEN(2) -> 510 Ohm -> green

[disconnected] BLUE(0) -> 2k Ohm -> blue
[disconnected] BLUE(1) -> 1k Ohm -> blue
BLUE(2) -> 510 Ohm -> blue

HSYNC -> 210 Ohm -> hsync
VSYNC -> 210 Ohm -> vsync


