#include <6502.h>
#include <stdlib.h>
#include <time.h>
#include <conio.h>
#include <stdio.h>
#include <cc65.h>
#include <c64.h>
#include "joystick.h"

void readJoystick(void)
{   
    static unsigned char joyButtonFlag = 0;
    static unsigned char joyLeftFlag = 0;
    static unsigned char joyRightFlag = 0;
    static unsigned char joyUpFlag = 0;
    static unsigned char joyDownFlag = 0;

    if (!(CIA1.pra & 1)) 
    {
        joyUpFlag = 1;
        doUp(1);    
    }
    if ((CIA1.pra & 1) && joyUpFlag) 
    {
        joyUpFlag = 0;
        doUp(0);    
    }
    
    if (!(CIA1.pra & 2)) 
    {
        joyDownFlag = 1;
        doDown(1);    
    }
    if ((CIA1.pra & 2) && joyDownFlag) 
    {
        joyDownFlag = 0;
        doDown(0);    
    }
        
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