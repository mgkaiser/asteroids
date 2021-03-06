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
#include "asteroids_sprites.h"
#include "asteroids.h"

// Stuff to support interrupt
unsigned char frameTrigger;

unsigned char player;
unsigned char playerShot1;
unsigned char playerShot2;
unsigned char playerShot3;
signed char playerRotation;

unsigned char playershot_dx[] = { 0, 1, 1, 1, 1, 1, 1, 1, 0, -1, -1, -1, -1, -1, -1, -1 };
unsigned char playershot_dctrx[] = { 31, 19, 9, 2, 0, 2, 9, 19, 31, 19, 9, 2, 0, 2, 9, 19 };
unsigned char playershot_dy[] = { 1, 1, 1, 1, 0, -1, -1, -1, -1, -1, -1, -1, 0, 1, 1, 1 };
unsigned char playershot_dctry[] = { 0, 2, 9, 19, 31, 19, 9, 2, 0, 2, 9, 19, 31, 19, 9, 2 };

unsigned char alien;
unsigned char alienShot1;
unsigned char alienShot2;
unsigned char alienShot3;

void clearTileAndSprite()
{    
    // Load the character set
    copyChars(charset_chr_len, charset_chr);    

    // Clear the screen    
    clearScreen();

    // Load the sprite data
    copySprites(asteroids_sprites_spr_len, asteroids_sprites_spr);
}

// addRock = new rock at specified location.  Randomly pick one of the 4 images for the rock size specified.
// splitRock = Big -> 2x Medium, Medium -> 2x Small, Small -> Gone
// randomVector = set new random vector for rock
// randomLocation = set new random location for rock
// addPlayerShot = if shots are available add new shot at player location using player vector.
// playerRotationToSprite = MACRO. Translate the 0-15 rotation of the player to a sprite image.
// startLevelRocks = place 2-6 rocks into starting location with initial vectors
// startLevelPlayer = player in center with zero momentum.

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
        sprf[i] = 0x89;

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
    sprx[playerShot1] = 0xff;
    spry[playerShot1] = 0xff;
    sprc[playerShot1] = COLOR_WHITE;
    sprdx[playerShot1] = 1;
    sprfrmtolive[playerShot1] = 120;
    sprf[playerShot1] = 0x8d;
    
    sprx[playerShot2] = 0xff;
    spry[playerShot2] = 0xff;
    sprc[playerShot2] = COLOR_WHITE;
    sprdx[playerShot2] = 1;
    sprfrmtolive[playerShot2] = 120;
    sprf[playerShot2] = 0x8d;
    
    sprx[playerShot3] = 0xff;
    spry[playerShot3] = 0xff;
    sprc[playerShot3] = COLOR_WHITE;
    sprdx[playerShot3] = 1;
    sprfrmtolive[playerShot3] = 120;
    sprf[playerShot3] = 0x8d;
    
    // player    
    sprx[player] = 80;
    spry[player] = 100;
    sprc[player] = COLOR_RED;
    //sprdx[player] = -1;
    //sprdmaxx[player] = 5;
    //sprdctrx[player] = sprdmaxx[player];  
    sprf[player] = 0x8e;      

    sprupdateflag = 1;  
}

void doLeft(unsigned char flag)
{   
    static unsigned char doLeftFlag = 0;  
    
    if (doLeftFlag == 0)
    {
        ++playerRotation;
        if (playerRotation > 15) playerRotation = 0;
        sprf[player] = 0x8e + playerRotation;    

        doLeftFlag = ROTATE_SPEED;
    }

    --doLeftFlag;
    
}

void doRight(unsigned char flag)
{   
    static unsigned char doRightFlag = 0;
    
    if (doRightFlag == 0)
    {
        --playerRotation;
        if (playerRotation < 0) playerRotation = 15;
        sprf[player] = 0x8e + playerRotation;                

        doRightFlag = ROTATE_SPEED;
    }

    --doRightFlag ;
    
}

void doUp(unsigned char flag)
{
    // Do thrust
}

void doDown(unsigned char flag)
{
    // Hyperspace
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

            // Shot should appear in front of player's ship and move on the same vector as the ship as fast as possible.

            // If we found one set a new shot
            if (newshot != 0)
            {
                sprx[newshot] = sprx[player];
                spry[newshot] = spry[player];
                sprc[newshot] = COLOR_WHITE;
                sprdx[newshot] = playershot_dx[playerRotation];
                sprdmaxx[newshot] = playershot_dctrx[playerRotation];
                sprdy[newshot] = playershot_dy[playerRotation];
                sprdmaxy[newshot] = playershot_dctry[playerRotation];                
                sprdctrx[newshot] = sprdmaxx[newshot];
                sprdctry[newshot] = sprdmaxy[newshot];        
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
