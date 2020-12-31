#include <6502.h>
#include <stdlib.h>
#include <time.h>
#include <conio.h>
#include <stdio.h>
#include <cc65.h>
#include <c64.h>
#include "multi.h"

unsigned char sprdx[MAX_SPRITE];
unsigned char sprdy[MAX_SPRITE];
unsigned char sprdctrx[MAX_SPRITE];
unsigned char sprdmaxx[MAX_SPRITE];
unsigned char sprdctry[MAX_SPRITE];
unsigned char sprdmaxy[MAX_SPRITE];
unsigned char sprfrmtolive[MAX_SPRITE];

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
                sprdx[i] = 0;
                sprdy[i] = 0;                
            }
        }
    }          
}