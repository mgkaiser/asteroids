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
#include "maze_tiles.h"
#include "asteroids.h"

// Stuff to support interrupt
unsigned char frameTrigger;

unsigned char player;
unsigned char playerShot1;
unsigned char playerShot2;
unsigned char playerShot3;

unsigned char sprdx[MAX_SPRITE];
unsigned char sprdy[MAX_SPRITE];
unsigned char sprdctrx[MAX_SPRITE];
unsigned char sprdmaxx[MAX_SPRITE];
unsigned char sprdctry[MAX_SPRITE];
unsigned char sprdmaxy[MAX_SPRITE];
unsigned char sprfrmtolive[MAX_SPRITE];

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

    copyChars(maze_tiles_chr_len, maze_tiles_chr);    

    for (x = 0; x < 128; x ++)
    {
        spriteData[x] = 0xaa;        
    }

    for (x = 0; x < 0x3fe; x++ ) screenData[x] = 0x20;
}

void setupSprites(void)
{
    static unsigned char i;

    // All y coords start at 0xff
    for (i = 0; i <= MAX_SPRITE; i++) 
    {
        spry[i] = 0xff;
        sprfrmtolive[i] = 0xff;
        sprdmaxx[i] = 0;
        sprdmaxy[i] = 0;    
        sprdctrx[i] = sprdmaxx[i];
        sprdctry[i] = sprdmaxy[i];  
    }
    
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
    playerShot1 = numsprites - 4;    
    sprx[playerShot1] = 95;
    spry[playerShot1] = 100;
    sprc[playerShot1] = COLOR_WHITE;
    sprdx[playerShot1] = 1;
    sprfrmtolive[playerShot1] = 120;

    playerShot2 = numsprites - 3;    
    sprx[playerShot2] = 110;
    spry[playerShot2] = 100;
    sprc[playerShot2] = COLOR_WHITE;
    sprdx[playerShot2] = 1;
    sprfrmtolive[playerShot2] = 120;

    playerShot3 = numsprites - 2;
    sprx[playerShot3] = 125;
    spry[playerShot3] = 100;
    sprc[playerShot3] = COLOR_WHITE;
    sprdx[playerShot3] = 1;
    sprfrmtolive[playerShot3] = 120;
    
    // player
    player = numsprites - 1;
    sprx[player] = 80;
    spry[player] = 100;
    sprc[player] = COLOR_RED;
    sprdx[player] = -1;
    sprdmaxx[player] = 10;
    sprdctrx[player] = sprdmaxx[player];        

    sprupdateflag = 1;  
}

void doSpriteFrame(void)
{
    static unsigned char i;    

    for(i = 0; i < numsprites; i++)
    {
        if (sprdctrx[i] == 0 )
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

        if (sprfrmtolive[i] != 0xff)            
        {
            --sprfrmtolive[i];
            if (sprfrmtolive[i] == 0)
            {
                sprfrmtolive[i] = 0xff;
                sprx[i] = 0xff;
                spry[i] = 0xff;
            }
        }
    }          
}

unsigned char joyButtonFlag = 0;
unsigned char joyLeftFlag = 0;
unsigned char joyRightFlag = 0;
void readJoystick(void)
{            
    if (!(CIA1.pra & 1)) doUp(1);    
    if (!(CIA1.pra & 2)) doDown(1);    
        
    if (!(CIA1.pra & 4)) 
    {
        joyLeftFlag = 1;
        doLeft(1);
    }
    if ((CIA1.pra & 4) && joyLeftFlag) 
    {
        joyLeftFlag = 0;
        doLeft(0);
    }
    
    if (!(CIA1.pra & 8)) 
    {
        joyRightFlag = 1;
        doRight(1);    
    }
    if ((CIA1.pra & 8) && joyRightFlag) 
    {
        joyRightFlag = 0;
        doRight(0);    
    }
    
    if (!(CIA1.pra & 16)) 
    {
        joyButtonFlag = 1;
        doButton(1);      
    }
    if ((CIA1.pra & 16) && joyButtonFlag) 
    {
        joyButtonFlag = 0;
        doButton(0); 
    }     
}

void doLeft(unsigned char flag)
{     
    sprdx[player] = -1;    
}

void doRight(unsigned char flag)
{        
    sprdx[player] = 1;
}

void doUp(unsigned char flag)
{

}

void doDown(unsigned char flag)
{

}

unsigned char doButtonFlag = 0;
void doButton(unsigned char flag)
{
    static unsigned char newshot = 0;
            
    if (flag)
    {    
        if (doButtonFlag == 0)
        {
            newshot = 0;

            if (spry[playerShot1] == 0xff)
            {
                newshot = playerShot1;
            }
            else if (spry[playerShot2] == 0xff)
            {
                newshot = playerShot2;
            }
            else if (spry[playerShot3] == 0xff)
            {
                newshot = playerShot3;
            }

            if (newshot != 0)
            {
                sprx[newshot] = 95;
                spry[newshot] = 100;
                sprc[newshot] = COLOR_WHITE;
                sprdx[newshot] = 1;
                sprfrmtolive[newshot] = 120;
            }
        
            doButtonFlag = 1;
        }
    }
    else
    {
        doButtonFlag = 0;
    }
    
        
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
