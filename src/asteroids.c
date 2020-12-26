/*****************************************************************************\
** asteroids                                                                 **
** (c)2020 by mkaiser                                                        **
\*****************************************************************************/

#include <6502.h>
#include <stdlib.h>
#include <time.h>
#include <conio.h>
#include <stdio.h>
#include <cc65.h>
#include <c64.h>
#include "graphlib.h"
#include "multi.h"
#include "asteroids.h"

// Stuff to support interrupt
unsigned char frameTrigger;

unsigned char sprdx[MAX_SPRITE];
unsigned char sprdy[MAX_SPRITE];
unsigned char sprdctrx[MAX_SPRITE];
unsigned char sprdmaxx[MAX_SPRITE];
unsigned char sprdctry[MAX_SPRITE];
unsigned char sprdmaxy[MAX_SPRITE];

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

void clearTileAndSprite()
{
    static unsigned int x; 

    for (x = 0; x < 2048; x ++)
    {
        tileData[x] = 0;
    }

    for (x = 0; x < 128; x ++)
    {
        spriteData[x] = 0xaa;        
    }
}

int main (void)
{          
    static unsigned char i;    
    
    clearTileAndSprite();        
    initVic();
    initsprites();
    initraster();
        
    numsprites = 20;
    for (i = 0; i < numsprites; i++)
    {
        sprx[i] = 0xff;
        spry[i] = 0xff;
        sprc[i] = i;
        sprdx[i] = 0;
        sprdy[i] = 0;        
        sprf[i] = 0x80;
        sprdmaxx[i] = 0;
        sprdmaxy[i] = 0;    
        sprdctrx[i] = sprdmaxx[i];
        sprdctry[i] = sprdmaxy[i];     
        if(sprc[i] == 0) sprc[i]++;   
    }
    spry[MAX_SPRITE + 1] = 0xff;
    for (i = 0; i < 4; i++)
    {
        // Starting X/Y coordinates 
        sprx[i] = 30;        
        spry[i] = i;        
        
        // X/Y movement
        sprdx[i] = 1;
        sprdy[i] = 1;

        // X/Y speed.  Bigger is slower
        sprdmaxx[i] = i;
        sprdmaxy[i] = 1;    
        sprdctrx[i] = sprdmaxx[i];
        sprdctry[i] = sprdmaxy[i];        
    }
    for (i = 4; i < 8; i++)
    {
        // Starting X/Y coordinates 
        sprx[i] = 90;                
        
        // X/Y movement
        sprdx[i] = -1;
        sprdy[i] = -1;

        // X/Y speed.  Bigger is slower
        sprdmaxx[i] = i - 4;
        sprdmaxy[i] = 1;
        sprdctrx[i] = sprdmaxx[i];
        sprdctry[i] = sprdmaxy[i];        
    }

    // Rocks
    spry[0] = 0;
    spry[1] = 50;
    spry[2] = 80;
    spry[3] = 120;
    spry[4] = 20;
    spry[5] = 72;
    spry[6] = 110;
    spry[7] = 133;

    // shots
    sprx[numsprites - 4] = 85;
    spry[numsprites - 4] = 100;
    sprc[numsprites - 4] = COLOR_WHITE;
    sprx[numsprites - 3] = 90;
    spry[numsprites - 3] = 100;
    sprc[numsprites - 3] = COLOR_WHITE;
    sprx[numsprites - 2] = 95;
    spry[numsprites - 2] = 100;
    sprc[numsprites - 2] = COLOR_WHITE;
    
    // player
    sprx[numsprites - 1] = 80;
    spry[numsprites - 1] = 100;
    sprc[numsprites - 1] = COLOR_RED;

    sprupdateflag = 1;  
            
    while(1) 
    {             
        if (frameflag)
        {            
            for(i=0; i<numsprites; i++)
            {
                if (sprdctrx[i] == 0)
                {
                    sprdctrx[i] = sprdmaxx[i];
                    sprx[i] += sprdx[i];
                    if (sprx[i] > 190)
                    { 
                        sprx[i] = 3;
                    }
                    else if (sprx[i] < 3)
                    {
                        sprx[i] = 190;
                    }
                    sprupdateflag = 1;  
                }
                else
                {
                    --sprdctrx[i];
                }
                
                if (sprdctry[i] == 0)
                {
                    sprdctry[i] = sprdmaxy[i];
                    spry[i] += sprdy[i];
                    sprupdateflag = 1;  
                }
                else
                {
                    --sprdctry[i];
                }                
            }          
            frameflag = 0;
        }
    }
        
    return EXIT_SUCCESS;        
}  
