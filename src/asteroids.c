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

// Stuff to support interrupt
#define STACK_SIZE 32
unsigned char stackSize[STACK_SIZE];
unsigned char frameTrigger;

unsigned char rasterSplitMax = 5;
unsigned char rasterSplitCount;
//unsigned char rasterSplit[10]
//unsigned char rasterSplit[] = {230, 135, 100, 65 };

unsigned char sprite0_y[] = { 190, 155, 120, 75, 40};
unsigned int sprite0_x[] =  { 60, 260, 320, 0, 75};
unsigned char sprite1_y[] = { 190, 155, 120, 75, 40};
unsigned int sprite1_x[] =  { 200, 50, 80, 140, 75};

#define MAX_SPRITE 32
unsigned int s_x[] =  { 60, 260, 320, 0, 75, 200, 50, 80, 140, 75, 66, 88, 512, 512, 512, 512, 512, 512, 512, 512, 512, 512, 512, 512, 512, 512, 512, 512, 512, 512, 512, 512};
unsigned char s_y[] = { 190, 155, 120, 75, 40, 195, 150, 125, 80, 43, 70, 80, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255};
unsigned char s_color[MAX_SPRITE];
unsigned char s_frame[MAX_SPRITE];
unsigned char s_index[MAX_SPRITE];

//xyxyxyxyxyxyxyxyHccccccccFR*****
unsigned char s_reg[10];

unsigned char s_x_reg[8];
unsigned char s_y_reg[8];
unsigned char s_color_reg[8];
unsigned char s_hix_reg;
unsigned char s_next_interrupt;

void __fastcall__ sort(void)
{
    static unsigned char sprite1;
    static unsigned char sprite2;    
    static unsigned char tmp;
    static unsigned char tmp2;

    __asm__("LDA #$00");
    __asm__("STA %v", sprite1);    
    while (1)
    {   
        // ************************************        
        // *** tmp = s_index[sprite1]     
        // *** tmp2 = s_index[sprite1 + 1] 
        // ************************************        
        //__asm__("LDX %v", sprite1);                
        //__asm__("LDA %v, X", s_index);
        //__asm__("STA %v", tmp);
        //__asm__("INX");
        //__asm__("LDA %v, X", s_index);
        //__asm__("STA %v", tmp2);

        // ************************************        
        // *** is s_y[tmp2] < s_y[tmp]        
        // ************************************        
        //__asm__("LDX %v", tmp2);        
        //__asm__("LDA %v, X", s_y);
        //__asm__("LDX %v", tmp);
        //__asm__("CMP %v, X", s_y);
        // BCC L1
        // JMP L2
        // L1:        
        if (s_y[s_index[sprite1 + 1]] < s_y[s_index[sprite1]])
        {            
            __asm__("LDA %v", sprite1);
            __asm__("STA %v", sprite2);
            while(1)
            {                
                __asm__("LDX %v", sprite2);                
                __asm__("LDA %v, X", s_index);
                __asm__("STA %v", tmp);
                __asm__("INX");
                __asm__("LDA %v, X", s_index);
                __asm__("DEX");
                __asm__("STA %v, X", s_index);
                __asm__("LDA %v", tmp);
                __asm__("INX");
                __asm__("STA %v, X", s_index);
                if (sprite2 == 0) break;                
                __asm__("DEC %v", sprite2);   
                if (s_y[s_index[sprite2 + 1]] >= s_y[s_index[sprite2]]) break;
            }
        }        
        __asm__("INC %v", sprite1);   
        if (sprite1 == MAX_SPRITE - 1) break;
    }
}

unsigned char interrupt(void)
{       
    --rasterSplitCount;

    VIC.spr0_x = sprite0_x[rasterSplitCount] & 0xff;
    VIC.spr1_x = sprite1_x[rasterSplitCount] & 0xff;

    if (sprite0_x[rasterSplitCount] > 255)
    {
        VIC.spr_hi_x = VIC.spr_hi_x | 0x01;
    }
    else
    {
        VIC.spr_hi_x = VIC.spr_hi_x & 0xfe;
    }

    if (sprite1_x[rasterSplitCount] > 255)
    {
        VIC.spr_hi_x = VIC.spr_hi_x | 0x02;
    }
    else
    {
        VIC.spr_hi_x = VIC.spr_hi_x & 0xfd;
    }        

    VIC.spr0_y = sprite0_y[rasterSplitCount];
    VIC.spr1_y = sprite1_y[rasterSplitCount];    

    // Setup next line        
    VIC.rasterline = sprite0_y[rasterSplitCount] + 15;                               
    VIC.bordercolor = rasterSplitCount + 1; 
    VIC.spr0_color =  rasterSplitCount + 1; 
    VIC.spr1_color =  rasterSplitCount + 1; 

    // We're at the bottom of the page, do game logic
    if (rasterSplitCount == 0)
    {        
        // Tell main thread we drew a frame
        frameTrigger=1;

        // reset the list
        rasterSplitCount = rasterSplitMax;        
    }    
                    
    // Acknowlege the interrrupt 
    VIC.irr = 1;    

    return IRQ_HANDLED;                         
}

// Setup the interrupt handler
void initInterrupt (void)
{
    unsigned short dummy;     

    // Reset interrupt counter    
    frameTrigger = 0;    

    // Hook up the interrupt 
    SEI();    
    CIA1.icr = 0x7F;                                // Turn of CIA timer
    VIC.ctrl1 = (VIC.ctrl1 & 0x7F);                 // Clear MSB of raster
    dummy = CIA1.icr;                               // Acknowlege any outstaiding interrupts from CIA1
    dummy = CIA2.icr;                               // Acknowlege any outstaiding interrupts from CIA1        
    rasterSplitCount = rasterSplitMax;
    VIC.rasterline = 230;                           // Set raster line
    set_irq(&interrupt, stackSize, STACK_SIZE);     // Set the interrupt handler
    VIC.imr = 0x01;                                 // Enable the VIC raster interrupt    
    CLI();    
}

void initVic(void)
{
    // Pointer to 0/1, the CPU control register
    char *cpu = (char *)0x0000;

    // Page out the Basic ROM
    cpu[1] = (cpu[1] & 0xfe);
  
    // Black background
    VIC.bgcolor0 = COLOR_BLACK;
    VIC.bordercolor = COLOR_BLACK;
  
    // Change VIC banks
    CIA2.pra = 0x01;  

    // Relocate the character set
    VIC.addr = 0xec;
}

int main (void)
{   
    static unsigned int x;    
    static unsigned char i;

    for(i = 0; i < MAX_SPRITE; i++)
    {
        s_index[i] = i;
        s_color[i] = i + 1;
        s_frame[i] = 0x80;
    }
    sort();   
    for(i = 0; i < 15; i++)
    {
        printf("%u %u %u %u\r\n", i, s_index[i], s_y[s_index[i]], s_y[s_index[i]] + 21);
    }
    while(1){}
    
    for (x = 0; x < 2048; x ++)
    {
        tileData[x] = 0;
    }

    for (x = 0; x < 128; x ++)
    {
        spriteData[x] = 0xaa;        
    }

    spriteSlot[0] = 0x80;
    spriteSlot[1] = 0x81;
    
    initVic();
    initInterrupt();  

    VIC.spr_ena = 0x03;
    VIC.spr0_x = 70;
    VIC.spr1_x = 140;
    VIC.spr0_color = COLOR_WHITE;
    VIC.spr1_color = COLOR_WHITE;
   
    while(1) {
        if (frameTrigger)
        {
            for(i =0; i < rasterSplitMax; i++)
            {
                if ((i & 0x01) == 0x00)
                {
                    sprite0_x[i] --;
                    sprite1_x[i] ++;                
                }
                else
                {
                    sprite0_x[i] ++;
                    sprite1_x[i] --;                
                }                
                //++sprite0_y[i];
                //++sprite1_y[i];
                if (sprite0_x[i] == 350) sprite0_x[i] = 1;
                if (sprite1_x[i] == 350) sprite1_x[i] = 1;
                if (sprite0_x[i] == 0) sprite0_x[i] = 349;
                if (sprite1_x[i] == 0) sprite1_x[i] = 349;
            }
            frameTrigger = 0;
        }
    }

    return EXIT_SUCCESS;        
}  