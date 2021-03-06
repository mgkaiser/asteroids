#include <6502.h>
#include <stdlib.h>
#include <stdio.h>
#include <cc65.h>
#include <c64.h>
#include "graphlib.h"

// First sprite page in our sprite data
#define SPRITE_BASE 0x80

char *screenData    = (char *)0xb800;   
char *tileData      = (char *)0xb000; 
char *colorData     = (char *)0xd800;
char *spriteData    = (char *)0xa000;
char *spriteSlot    = (char *)0xbbf8;

char buf[20];

unsigned int times40[] = {0x0,0x28,0x50,0x78,0xA0,0xC8,0xF0,0x118,0x140,0x168,0x190,0x1B8,0x1E0,0x208,0x230,0x258,0x280,0x2A8,0x2D0,0x2F8,0x320,0x348,0x370,0x398,0x3C0};
unsigned char screenyTospriteyTable[] = {0x2F,0x37,0x3F,0x47,0x4F,0x57,0x5F,0x67,0x6F,0x77,0x7F,0x87,0x8F,0x97,0x9F,0xA7,0xAF,0xB7,0xBF,0xC7,0xCF,0xD7,0xDF,0xE7,0xEF};
unsigned char screenxTospritexTable[] = {0x15,0x1D,0x25,0x2D,0x35,0x3D,0x45,0x4D,0x55,0x5D,0x65,0x6D,0x75,0x7D,0x85,0x8D,0x95,0x9D,0xA5,0xAD,0xB5,0xBD,0xC5,0xCD,0xD5,0xDD,0xE5,0xED,0xF5,0xFD};
unsigned char spriteyToscreenyTable[] = {0xFB,0xFB,0xFB,0xFB,0xFB,0xFB,0xFB,0xFB,0xFC,0xFC,0xFC,0xFC,0xFC,0xFC,0xFC,0xFC,0xFD,0xFD,0xFD,0xFD,0xFD,0xFD,0xFD,0xFD,0xFE,0xFE,0xFE,0xFE,0xFE,0xFE,0xFE,0xFE,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x1,0x1,0x1,0x1,0x1,0x1,0x1,0x1,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x4,0x4,0x4,0x4,0x4,0x4,0x4,0x4,0x5,0x5,0x5,0x5,0x5,0x5,0x5,0x5,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x8,0x8,0x8,0x8,0x8,0x8,0x8,0x8,0x9,0x9,0x9,0x9,0x9,0x9,0x9,0x9,0xA,0xA,0xA,0xA,0xA,0xA,0xA,0xA,0xB,0xB,0xB,0xB,0xB,0xB,0xB,0xB,0xC,0xC,0xC,0xC,0xC,0xC,0xC,0xC,0xD,0xD,0xD,0xD,0xD,0xD,0xD,0xD,0xE,0xE,0xE,0xE,0xE,0xE,0xE,0xE,0xF,0xF,0xF,0xF,0xF,0xF,0xF,0xF,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x12,0x12,0x12,0x12,0x12,0x12,0x12,0x12,0x13,0x13,0x13,0x13,0x13,0x13,0x13,0x13,0x14,0x14,0x14,0x14,0x14,0x14,0x14,0x14,0x15,0x15,0x15,0x15,0x15,0x15,0x15,0x15,0x16,0x16,0x16,0x16,0x16,0x16,0x16,0x16,0x17,0x17,0x17,0x17,0x17,0x17,0x17,0x17,0x18,0x18,0x18,0x18,0x18,0x18,0x18,0x18,0x19,0x19,0x19,0x19,0x19,0x19,0x19,0x19,0x1A};
unsigned char spritexToscreenxTable[] = {0xFE,0xFE,0xFE,0xFE,0xFE,0xFE,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x1,0x1,0x1,0x1,0x1,0x1,0x1,0x1,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x4,0x4,0x4,0x4,0x4,0x4,0x4,0x4,0x5,0x5,0x5,0x5,0x5,0x5,0x5,0x5,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x8,0x8,0x8,0x8,0x8,0x8,0x8,0x8,0x9,0x9,0x9,0x9,0x9,0x9,0x9,0x9,0xA,0xA,0xA,0xA,0xA,0xA,0xA,0xA,0xB,0xB,0xB,0xB,0xB,0xB,0xB,0xB,0xC,0xC,0xC,0xC,0xC,0xC,0xC,0xC,0xD,0xD,0xD,0xD,0xD,0xD,0xD,0xD,0xE,0xE,0xE,0xE,0xE,0xE,0xE,0xE,0xF,0xF,0xF,0xF,0xF,0xF,0xF,0xF,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x11,0x12,0x12,0x12,0x12,0x12,0x12,0x12,0x12,0x13,0x13,0x13,0x13,0x13,0x13,0x13,0x13,0x14,0x14,0x14,0x14,0x14,0x14,0x14,0x14,0x15,0x15,0x15,0x15,0x15,0x15,0x15,0x15,0x16,0x16,0x16,0x16,0x16,0x16,0x16,0x16,0x17,0x17,0x17,0x17,0x17,0x17,0x17,0x17,0x18,0x18,0x18,0x18,0x18,0x18,0x18,0x18,0x19,0x19,0x19,0x19,0x19,0x19,0x19,0x19,0x1A,0x1A,0x1A,0x1A,0x1A,0x1A,0x1A,0x1A,0x1B,0x1B,0x1B,0x1B,0x1B,0x1B,0x1B,0x1B,0x1C,0x1C,0x1C,0x1C,0x1C,0x1C,0x1C,0x1C,0x1D,0x1D};

void initVic(void)
{
    // Pointer to 0/1, the CPU control register
    char *cpu = (char *)0x0000;

    // Page out the Basic ROM
    cpu[1] = (cpu[1] & 0xfe);
  
    // Black background
    VIC.bgcolor0 = COLOR_BLACK;
    VIC.bordercolor = COLOR_BLACK;

    // Enable all sprites
    VIC.spr_ena = 0xff;
  
    // Change VIC banks
    CIA2.pra = 0x01;  

    // Relocate the character set
    VIC.addr = 0xec;
}

void clearScreen(void)
{
    static unsigned int x; 
    for (x = 0; x < 0x3fe; x++ ) screenData[x] = 0x20;
}

// Copy the screen data to the buffers
void copyScreen(unsigned int screenDataLen, char* scrnData, char* colData)
{
    static unsigned int x;

    for (x = 0; x < screenDataLen; x ++)
    {
        screenData[x] = scrnData[x];
        colorData[x] = colData[x];                
    }
}

// Copy the custom characters to the buffers
void copyChars(unsigned int charDataLen, char* charData) 
{
    static unsigned int x;

    for (x = 0; x < charDataLen; x ++)
    {
        tileData[x] = charData[x];        
    }
}

// Copy the sprite data to the buffers 
void copySprites(unsigned int sprDataLen, char* sprData) 
{
    static unsigned int x;
    for (x = 0; x < sprDataLen; x ++)
    {
        spriteData[x] = sprData[x];        
    }
}

void  draw_string(unsigned char x, unsigned char y, unsigned char w, char *ch)
{
	static unsigned char xctr;		
			
	char ch2;
		
	for(xctr = 0; xctr < w; ++xctr)
	{	
		ch2 = ch[xctr];
        if (ch2 == 0x00) break;
		
		if (ch[xctr] <= 0x1f) ch2 = ch2 + 0x80;
		if (ch[xctr] >= 0x20 & ch[xctr] <= 0x3f) ch2 = ch2 + 0x00;
		if (ch[xctr] >= 0x40 & ch[xctr] <= 0x5f) ch2 = ch2 + 0xc0;
		if (ch[xctr] >= 0x60 & ch[xctr] <= 0x7f) ch2 = ch2 + 0xe0;
		if (ch[xctr] >= 0x80 & ch[xctr] <= 0x9f) ch2 = ch2 + 0x40;
		if (ch[xctr] >= 0xa0 & ch[xctr] <= 0xbf) ch2 = ch2 + 0xc0;
		if (ch[xctr] >= 0xc0 & ch[xctr] <= 0xdf) ch2 = ch2 + 0x80;
		if (ch[xctr] >= 0xe0 & ch[xctr] <= 0xfe) ch2 = ch2 + 0x80;
		if (ch[xctr] == 0xff) ch2 = 0x5e;
		
        screenData[screenxyToAddress(x + xctr,y)] = ch2;		
	}
	
}

void  draw_string_char(unsigned char x, unsigned char y, unsigned char ch)
{
    sprintf(buf, "%d", ch);
    draw_string(x, y , 0x04, buf);
}