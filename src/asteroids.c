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

void setupSprites(void)
{
    static unsigned char i;

    // All y coords start at 0xff
    for (i = 0; i <= MAX_SPRITE; i++) spry[i] = 0xff;
    
    numsprites = 20;
    for (i = 0; i < numsprites; i++)
    {
        // Set the coords
        sprx[i] = 0xff;
        spry[i] = 0xff;

        // Set the colors, don't use black
        sprc[i] = i;
        if(sprc[i] == 0) sprc[i]++;   

        // Nothing moving yet
        sprdx[i] = 0;
        sprdy[i] = 0;        

        // Set the frame
        sprf[i] = 0x80;

        // Movement speed is 1 step each frame
        sprdmaxx[i] = 0;
        sprdmaxy[i] = 0;    
        sprdctrx[i] = sprdmaxx[i];
        sprdctry[i] = sprdmaxy[i];             
    }
    
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
    sprx[numsprites - 4] = 95;
    spry[numsprites - 4] = 100;
    sprc[numsprites - 4] = COLOR_WHITE;
    sprx[numsprites - 3] = 110;
    spry[numsprites - 3] = 100;
    sprc[numsprites - 3] = COLOR_WHITE;
    sprx[numsprites - 2] = 125;
    spry[numsprites - 2] = 100;
    sprc[numsprites - 2] = COLOR_WHITE;
    
    // player
    sprx[numsprites - 1] = 80;
    spry[numsprites - 1] = 100;
    sprc[numsprites - 1] = COLOR_RED;
    //sprdx[numsprites - 1] = -1;
    //sprdmaxx[numsprites - 1] = 30;
    //sprdctrx[numsprites - 1] = sprdmaxx[numsprites - 1];
    

    sprupdateflag = 1;  
}

void doSpriteFrame(void)
{
    static unsigned char i;    

    for(i = 0; i < numsprites; i++)
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
}

void readJoystick(void)
{        
    if (!(CIA1.pra & 1)) doUp();    
    if (!(CIA1.pra & 2)) doDown();    
    if (!(CIA1.pra & 4)) doLeft();
    if (!(CIA1.pra & 8)) doRight();    
    if (!(CIA1.pra & 16)) doButton();      
}

void doLeft(void)
{
    sprdx[18] = -1;
}

void doRight(void)
{
    sprdx[18] = 1;
}

void doUp(void)
{

}

void doDown(void)
{

}

void doButton(void)
{
    sprdx[18] = 0;
}

int main (void)
{                  
    clearTileAndSprite();        
    initVic();
    initsprites();
    initraster();

    setupSprites();
                            
    while(1) 
    {             
        if (frameflag)
        {    
            readJoystick();        
            doSpriteFrame();
            frameflag = 0;
        }
    }
        
    return EXIT_SUCCESS;        
}  
