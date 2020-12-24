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
        
    numsprites = 12;
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
    for (i = 0; i < 4; i++)
    {
        // Starting X/Y coordinates 
        sprx[i] = 70;        
        spry[i] = i;        
        
        // X/Y movement
        sprdx[i] = 1;
        sprdy[i] = 1;

        // X/Y speed.  Bigger is slower
        sprdmaxx[i] = 3;
        sprdmaxy[i] = 2;    
        sprdctrx[i] = sprdmaxx[i];
        sprdctry[i] = sprdmaxy[i];        
    }
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
