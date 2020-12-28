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
#include "joystick.h"
#include "charset.h"
#include "spriteframe.h"
#include "asteroids.h"

// Stuff to support interrupt
unsigned char frameTrigger;

unsigned char player;
unsigned char playerShot1;
unsigned char playerShot2;
unsigned char playerShot3;

unsigned char alien;
unsigned char alienShot1;
unsigned char alienShot2;
unsigned char alienShot3;

void clearTileAndSprite()
{
    static unsigned int x; 

    // Load the character set
    copyChars(charset_chr_len, charset_chr);    

    // Clear the screen
    for (x = 0; x < 0x3fe; x++ ) screenData[x] = 0x20;

    // Load the sprite data
    for (x = 0; x < 128; x ++)
    {
        spriteData[x] = 0xaa;        
    }    
}

void startLevel(void)
{
    static unsigned char i;

    // We may use as many as 32 sprites 
    numsprites = 32;

    // Rocks (0 - 23) = 6 big rocks, 12 medium rocks, 24 small rocks

    // Define the contants
    alienShot1 = numsprites - 8;        // 24   
    alienShot2 = numsprites - 7;        // 25
    alienShot3 = numsprites - 6;        // 26
    alien = numsprites - 5;             // 27

    playerShot1 = numsprites - 4;       // 28    
    playerShot2 = numsprites - 3;       // 29    
    playerShot3 = numsprites - 2;       // 30
    player = numsprites - 1;            // 31

    // Player in center, no movement
    // No player shots
    // No alien
    // No alient shots
    // Start with "n" big rocks

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
    sprx[playerShot1] = 95;
    spry[playerShot1] = 100;
    sprc[playerShot1] = COLOR_WHITE;
    sprdx[playerShot1] = 1;
    sprfrmtolive[playerShot1] = 120;
    
    sprx[playerShot2] = 110;
    spry[playerShot2] = 100;
    sprc[playerShot2] = COLOR_WHITE;
    sprdx[playerShot2] = 1;
    sprfrmtolive[playerShot2] = 120;
    
    sprx[playerShot3] = 125;
    spry[playerShot3] = 100;
    sprc[playerShot3] = COLOR_WHITE;
    sprdx[playerShot3] = 1;
    sprfrmtolive[playerShot3] = 120;
    
    // player    
    sprx[player] = 80;
    spry[player] = 100;
    sprc[player] = COLOR_RED;
    sprdx[player] = -1;
    sprdmaxx[player] = 10;
    sprdctrx[player] = sprdmaxx[player];        

    sprupdateflag = 1;  
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

void doButton(unsigned char flag)
{
    static unsigned char newshot = 0;
    static unsigned char doButtonFlag = 0;

    // Button down?  Do the shot, set the flag
    if (flag)
    {
        // Only one shot per button press    
        if (doButtonFlag == 0)
        {

            // Find an available shot sprite
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

            // If we found one set a new shot
            if (newshot != 0)
            {
                sprx[newshot] = 95;
                spry[newshot] = 100;
                sprc[newshot] = COLOR_WHITE;
                sprdx[newshot] = 1;
                sprfrmtolive[newshot] = 120;
            }
        
            // Set the shot flag
            doButtonFlag = 1;
        }
    }

    // Button up? clear the flag
    else
    {
        doButtonFlag = 0;
    }            
}

int main (void)
{             
    // Load the graphic data     
    clearTileAndSprite();   

    // Set up vid chip      
    initVic();

    // Setup sprite multiplexer
    initsprites();    
    initraster();

    // Set the level to it's intial state
    startLevel();

    // Infinite loop                            
    while(1) 
    {             
        // Do this once per frame
        if (frameflag)
        {    
            // Read the joystick
            readJoystick();     

            // Do the animation   
            doSpriteFrame();

            // Acknowldege the frame
            frameflag = 0;
        }
    }
        
    return EXIT_SUCCESS;        
}  
