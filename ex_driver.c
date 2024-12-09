#include <inttypes.h>
#include <string.h>
#include "xil_io.h"

// XRES - number of chars per line
#define XRES 80
// YRES - number of chars per col
#define YRES 60

enum {
    OFF=0,
    RED=1,
    GREEN=2,
    YELLOW=3,
    BLUE=4,
    MAGENTA=5,
    CYAN=6,
    WHITE=7,
};

void clearScreen(volatile uint32_t *display){
    for (int i=0; i<0x2000; i++){
        display[i] = 0;
    }
}

void writeLine(volatile u32 *display, const char *msg, uint32_t linenum, uint8_t color){
    // I am just going to set the color bits in dout to the lower 3-bits of the color field
    uint32_t dout; //lower 8-bits ascii, bits 9-11 are the color bits (9=red, 10=green, 11=blue)
    uint32_t line_offset = 4 + (linenum * 128);
    for (int i=0; i<strlen(msg); i++) {
        dout = (uint32_t) (msg[i]);
        dout |= (color << 8);
        display[line_offset + i] = dout;
    }
}

void writeString(volatile u32 *display, const char *msg, uint32_t linenum, uint32_t col, uint8_t color){
    // I am just going to set the color bits in dout to the lower 3-bits of the color field
    uint32_t dout; //lower 8-bits ascii, bits 9-11 are the color bits (9=red, 10=green, 11=blue)
    uint32_t line_offset = 4 + (linenum * 128);
    for (int i=0; i<strlen(msg); i++) {
        dout = (uint32_t) (msg[i]);
        dout |= (color << 8);
        display[col + line_offset + i] = dout;
    }
}

void fillLine(volatile u32 *display, char letter, uint32_t linenum, uint8_t color){
    uint32_t dout =  (uint32_t) (letter); //lower 8-bits ascii, bits 9-11 are the color bits (9=red, 10=green, 11=blue)
    dout |= (color << 8);
    uint32_t line_offset = 4 + (linenum * 128);
    for (int i=0; i<72; i++) {        
        display[line_offset + i] = dout;
    }    
}

int main(){
    volatile u32 *LocalAddr = (volatile u32 *)0x40000000; //TODO - get this base addr from xparamters.h
    writeLine(LocalAddr, "HELLO WORLD", 0, WHITE);
    fillLine(LocalAddr, '$', 0, RED);
    writeString(LocalAddr, "THIS IS A TEST", 0, 28, WHITE);
    writeLine(LocalAddr, "DATA ON LINE 1", 1, WHITE);
    writeLine(LocalAddr, "DATA ON LINE 2", 2, MAGENTA);
    //clearScreen(LocalAddr);
    writeLine(LocalAddr, "RED DATA ON LINE 10", 10, RED);
    writeLine(LocalAddr, "GREEN DATA ON LINE 11", 11, GREEN);
    writeLine(LocalAddr, "BLUE DATA ON LINE 12", 12, BLUE);
    writeLine(LocalAddr, "HELLO WORLD", 13, YELLOW);
    writeLine(LocalAddr, "AAAAAAAAAAAAAAAAAAAAAAAAAAAAA", 14, WHITE);
    writeLine(LocalAddr, "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789", 30, CYAN);
    // clearScreen();


    while (1) {
        ;
    }
    return 0;
}