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
#include "sort.h"
#include "interrupt.h"
#include "asteroids.h"

// Stuff to support interrupt
unsigned char frameTrigger;
unsigned char rasterSplitMax = 5;
unsigned char rasterSplitCount;

unsigned int s_x[MAX_SPRITE] =  { 60, 260, 320, 83, 70, 200, 50, 80, 140, 75, 66, 88, 270, 512, 512, 512, 512, 512, 512, 512, 512, 512, 512, 512, 512, 512, 512, 512, 512, 512, 512, 512};
unsigned char s_y[MAX_SPRITE] = { 190, 155, 120, 75, 40, 195, 150, 125, 80, 43, 70, 80, 88, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255};
unsigned char s_dx[MAX_SPRITE];
unsigned char s_dy[MAX_SPRITE];
unsigned char s_color[MAX_SPRITE];
unsigned char s_frame[MAX_SPRITE];
unsigned char s_index[MAX_SPRITE];

// Data to be loaded into registers
unsigned char s_splitcurr = 0;
unsigned char s_splitmax = 2;
unsigned char s0_x_reg[MAX_SPLITS] = { 0x50, 0xa0};
unsigned char s0_y_reg[MAX_SPLITS] = { 0x60, 0x95};
unsigned char s0_color_reg[MAX_SPLITS] = { 0x01, 0x02};
unsigned char s0_frame[MAX_SPLITS] = { 0x80, 0x81};
unsigned char s1_x_reg[MAX_SPLITS] = { 0x60, 0x80};
unsigned char s1_y_reg[MAX_SPLITS] = { 0x60, 0x90};
unsigned char s1_color_reg[MAX_SPLITS] = { 0x03, 0x04};
unsigned char s1_frame[MAX_SPLITS] = { 0x80, 0x81};
unsigned char s2_x_reg[MAX_SPLITS] = { 0xff, 0xff};
unsigned char s2_y_reg[MAX_SPLITS] = { 0xff, 0xff};
unsigned char s2_color_reg[MAX_SPLITS] = { 0x05, 0x06};
unsigned char s2_frame[MAX_SPLITS] = { 0x80, 0x81};
unsigned char s3_x_reg[MAX_SPLITS] = { 0xff, 0xff};
unsigned char s3_y_reg[MAX_SPLITS] = { 0xff, 0xff};
unsigned char s3_color_reg[MAX_SPLITS] = { 0x07, 0x08};
unsigned char s3_frame[MAX_SPLITS] = { 0x80, 0x81};
unsigned char s4_x_reg[MAX_SPLITS] = { 0xff, 0xff};
unsigned char s4_y_reg[MAX_SPLITS] = { 0xff, 0xff};
unsigned char s4_color_reg[MAX_SPLITS] = { 0x09, 0x0a};
unsigned char s4_frame[MAX_SPLITS] = { 0x80, 0x81};
unsigned char s5_x_reg[MAX_SPLITS] = { 0xff, 0xff};
unsigned char s5_y_reg[MAX_SPLITS] = { 0xff, 0xff};
unsigned char s5_color_reg[MAX_SPLITS] = { 0x0b, 0x0c};
unsigned char s5_frame[MAX_SPLITS] = { 0x80, 0x81};
unsigned char s6_x_reg[MAX_SPLITS] = { 0xff, 0xff};
unsigned char s6_y_reg[MAX_SPLITS] = { 0xff, 0xff};
unsigned char s6_color_reg[MAX_SPLITS] = { 0x0d, 0x0e};
unsigned char s6_frame[MAX_SPLITS] = { 0x80, 0x81};
unsigned char s7_x_reg[MAX_SPLITS] = { 0xff, 0xff};
unsigned char s7_y_reg[MAX_SPLITS] = { 0xff, 0xff};
unsigned char s7_color_reg[MAX_SPLITS] = { 0x0f, 0x01};
unsigned char s7_frame[MAX_SPLITS] = { 0x80, 0x81};
unsigned char s_hix_reg[MAX_SPLITS] = { 0x00, 0x00};
unsigned char s_next_interrupt[MAX_SPLITS] = { 0x7f, 0xff, 0x00, 0x0B};
unsigned char s_filler1[MAX_SPLITS];
unsigned char s_filler2[MAX_SPLITS];
unsigned char s_filler3[MAX_SPLITS];
unsigned char s_filler4[MAX_SPLITS];
unsigned char s_filler5[MAX_SPLITS];

unsigned char _s_splitcurr = 0;
unsigned char _s_splitmax = 2;
unsigned char _s0_x_reg[MAX_SPLITS] = { 0x50, 0xa0};
unsigned char _s0_y_reg[MAX_SPLITS] = { 0x60, 0x95};
unsigned char _s0_color_reg[MAX_SPLITS] = { 0x01, 0x02};
unsigned char _s0_frame[MAX_SPLITS] = { 0x80, 0x81};
unsigned char _s1_x_reg[MAX_SPLITS] = { 0x60, 0x80};
unsigned char _s1_y_reg[MAX_SPLITS] = { 0x60, 0x90};
unsigned char _s1_color_reg[MAX_SPLITS] = { 0x03, 0x04};
unsigned char _s1_frame[MAX_SPLITS] = { 0x80, 0x81};
unsigned char _s2_x_reg[MAX_SPLITS] = { 0xff, 0xff};
unsigned char _s2_y_reg[MAX_SPLITS] = { 0xff, 0xff};
unsigned char _s2_color_reg[MAX_SPLITS] = { 0x05, 0x06};
unsigned char _s2_frame[MAX_SPLITS] = { 0x80, 0x81};
unsigned char _s3_x_reg[MAX_SPLITS] = { 0xff, 0xff};
unsigned char _s3_y_reg[MAX_SPLITS] = { 0xff, 0xff};
unsigned char _s3_color_reg[MAX_SPLITS] = { 0x07, 0x08};
unsigned char _s3_frame[MAX_SPLITS] = { 0x80, 0x81};
unsigned char _s4_x_reg[MAX_SPLITS] = { 0xff, 0xff};
unsigned char _s4_y_reg[MAX_SPLITS] = { 0xff, 0xff};
unsigned char _s4_color_reg[MAX_SPLITS] = { 0x09, 0x0a};
unsigned char _s4_frame[MAX_SPLITS] = { 0x80, 0x81};
unsigned char _s5_x_reg[MAX_SPLITS] = { 0xff, 0xff};
unsigned char _s5_y_reg[MAX_SPLITS] = { 0xff, 0xff};
unsigned char _s5_color_reg[MAX_SPLITS] = { 0x0b, 0x0c};
unsigned char _s5_frame[MAX_SPLITS] = { 0x80, 0x81};
unsigned char _s6_x_reg[MAX_SPLITS] = { 0xff, 0xff};
unsigned char _s6_y_reg[MAX_SPLITS] = { 0xff, 0xff};
unsigned char _s6_color_reg[MAX_SPLITS] = { 0x0d, 0x0e};
unsigned char _s6_frame[MAX_SPLITS] = { 0x80, 0x81};
unsigned char _s7_x_reg[MAX_SPLITS] = { 0xff, 0xff};
unsigned char _s7_y_reg[MAX_SPLITS] = { 0xff, 0xff};
unsigned char _s7_color_reg[MAX_SPLITS] = { 0x0f, 0x01};
unsigned char _s7_frame[MAX_SPLITS] = { 0x80, 0x81};
unsigned char _s_hix_reg[MAX_SPLITS] = { 0x00, 0x00};
unsigned char _s_next_interrupt[MAX_SPLITS] = { 0x7f, 0xff, 0x00, 0x0B};
unsigned char _s_filler1[MAX_SPLITS];
unsigned char _s_filler2[MAX_SPLITS];
unsigned char _s_filler3[MAX_SPLITS];
unsigned char _s_filler4[MAX_SPLITS];
unsigned char _s_filler5[MAX_SPLITS];

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
    __asm__("LDA #<%v", interrupt2);
    __asm__("STA $0314");
    __asm__("LDA #>%v", interrupt2);
    __asm__("STA $0315");    
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

    // Enable all sprites
    VIC.spr_ena = 0xff;
  
    // Change VIC banks
    CIA2.pra = 0x01;  

    // Relocate the character set
    VIC.addr = 0xec;
}

void initSprites()
{
    static unsigned char i;

    for(i = 0; i < MAX_SPRITE; i++)
    {
        s_index[i] = i;
        s_color[i] = i + 1;
        s_frame[i] = 0x80;        
    }
}

void debugSprites()
{
    static unsigned char i;
    for(i = 0; i < 15; i++)
    {
        printf("%u %u %u %u\r\n", i, s_index[i], s_y[s_index[i]], s_y[s_index[i]] + 21);
    }
    getchar();
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


void loadFrames()
{
    static signed char i;        
    static unsigned char splitcurr = 0;
    static unsigned char splitmax = 0;
    static unsigned char spritecurr = 0;

    for (i = 0; i < MAX_SPRITE; i++)
    {
        
        // If this sprite is too close to 
        if (i - 8 >= 0)
        {
            if (s_y[s_index[i]] - s_y[s_index[i-8]] < 24) continue;
        }        

        switch (spritecurr)
        {
            
            case 0:
                _s0_y_reg[splitcurr] = s_y[s_index[i]];
                _s0_x_reg[splitcurr] = s_x[s_index[i]] & 0xff;
                if (s_x[s_index[i]] > 0xff)
                {
                    _s_hix_reg[splitcurr] = _s_hix_reg[splitcurr] | 0x01;
                }
                else
                {
                    _s_hix_reg[splitcurr] = _s_hix_reg[splitcurr] & 0xfe;
                }
                _s0_color_reg[splitcurr] = s_color[s_index[i]];                
                _s0_frame[splitcurr] = s_frame[s_index[i]];                
                break;
            case 1:
                _s1_y_reg[splitcurr] = s_y[s_index[i]];
                _s1_x_reg[splitcurr] = s_x[s_index[i]] & 0xff;
                if (s_x[s_index[i]] > 0xff)
                {
                    _s_hix_reg[splitcurr] = _s_hix_reg[splitcurr] | 0x02;
                }
                else
                {
                    _s_hix_reg[splitcurr] = _s_hix_reg[splitcurr] & 0xfd;
                }
                _s1_color_reg[splitcurr] = s_color[s_index[i]];                
                _s1_frame[splitcurr] = s_frame[s_index[i]];
                break;
            case 2:
                _s2_y_reg[splitcurr] = s_y[s_index[i]];
                _s2_x_reg[splitcurr] = s_x[s_index[i]] & 0xff;
                if (s_x[s_index[i]] > 0xff)
                {
                    _s_hix_reg[splitcurr] = _s_hix_reg[splitcurr] | 0x04;
                }
                else
                {
                    _s_hix_reg[splitcurr] = _s_hix_reg[splitcurr] & 0xfb;
                }
                _s2_color_reg[splitcurr] = s_color[s_index[i]];                
                _s2_frame[splitcurr] = s_frame[s_index[i]];
                break;
            case 3:
                _s3_y_reg[splitcurr] = s_y[s_index[i]];
                _s3_x_reg[splitcurr] = s_x[s_index[i]] & 0xff;
                if (s_x[s_index[i]] > 0xff)
                {
                    _s_hix_reg[splitcurr] = _s_hix_reg[splitcurr] | 0x08;
                }
                else
                {
                    _s_hix_reg[splitcurr] = _s_hix_reg[splitcurr] & 0xf7;
                }
                _s3_color_reg[splitcurr] = s_color[s_index[i]];                
                _s3_frame[splitcurr] = s_frame[s_index[i]];
                break;
            case 4:
                _s4_y_reg[splitcurr] = s_y[s_index[i]];
                _s4_x_reg[splitcurr] = s_x[s_index[i]] & 0xff;
                if (s_x[s_index[i]] > 0xff)
                {
                    _s_hix_reg[splitcurr] = _s_hix_reg[splitcurr] | 0x10;
                }
                else
                {
                    _s_hix_reg[splitcurr] = _s_hix_reg[splitcurr] & 0xef;
                }
                _s4_color_reg[splitcurr] = s_color[s_index[i]];                
                _s4_frame[splitcurr] = s_frame[s_index[i]];
                break;
            case 5:
                _s5_y_reg[splitcurr] = s_y[s_index[i]];
                _s5_x_reg[splitcurr] = s_x[s_index[i]] & 0xff;
                if (s_x[s_index[i]] > 0xff)
                {
                    _s_hix_reg[splitcurr] = _s_hix_reg[splitcurr] | 0x20;
                }
                else
                {
                    _s_hix_reg[splitcurr] = _s_hix_reg[splitcurr] & 0xdf;
                }
                _s5_color_reg[splitcurr] = s_color[s_index[i]];                
                _s5_frame[splitcurr] = s_frame[s_index[i]];
                break;
            case 6:
                _s6_y_reg[splitcurr] = s_y[s_index[i]];
                _s6_x_reg[splitcurr] = s_x[s_index[i]] & 0xff;
                if (s_x[s_index[i]] > 0xff)
                {
                    _s_hix_reg[splitcurr] = _s_hix_reg[splitcurr] | 0x40;
                }
                else
                {
                    _s_hix_reg[splitcurr] = _s_hix_reg[splitcurr] & 0xbf;
                }
                _s6_color_reg[splitcurr] = s_color[s_index[i]];                
                _s6_frame[splitcurr] = s_frame[s_index[i]];
                break;
            case 7:
                _s7_y_reg[splitcurr] = s_y[s_index[i]];
                _s7_x_reg[splitcurr] = s_x[s_index[i]] & 0xff;
                if (s_x[s_index[i]] > 0xff)
                {
                    _s_hix_reg[splitcurr] = _s_hix_reg[splitcurr] | 0x80;
                }
                else
                {
                    _s_hix_reg[splitcurr] = _s_hix_reg[splitcurr] & 0x7f;
                }
                _s7_color_reg[splitcurr] = s_color[s_index[i]];                
                _s7_frame[splitcurr] = s_frame[s_index[i]];
                break;                
        }
        
        // if sprite isn't in use, don't mess with the raster
        if (s_x[s_index[i]] == 0x1ff) continue;
        
        if (splitcurr != 0)
        {
            _s_next_interrupt[splitcurr - 1] = _s0_y_reg[splitcurr] - 16;
        }        

        if (++spritecurr > 7)
        {
            // kill the loop if there are no more lve sprites
            if (s_x[s_index[i]] == 0x1ff) break;

            // Reset the loop and start a new split
            spritecurr = 0;
            ++splitcurr;
            ++splitmax;
        }        
    }

    // Last line is always 0xff
    _s_next_interrupt[s_splitmax] = 0xff;
    _s_splitcurr = splitcurr;
    _s_splitmax = splitmax;
}

int main (void)
{          
    static unsigned char i;
    
    initSprites();    
    sort();   
    loadFrames();
    //debugSprites();
    clearTileAndSprite();        
    initVic();
    initInterrupt();  
    
    while(1) {
        if (frameTrigger)
        {   
            /*         
            for(i =0; i < 5; i++)
            {
                if (i & 1 == 1)
                {
                    s_x[i]--;
                    s_y[i]++;
                }
                else
                {
                    s_x[i]++;
                    s_y[i]--;
                }                
            } 
            */           
            sort();            
            loadFrames();            
            frameTrigger = 0;
        }
    }

    return EXIT_SUCCESS;        
}  