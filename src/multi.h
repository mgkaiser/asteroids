#define MAX_SPRITE 32

extern unsigned char numsprites;
#pragma zpsym ("numsprites");

extern unsigned char sprupdateflag;
#pragma zpsym ("sprupdateflag");

extern unsigned char sprx[MAX_SPRITE];
extern unsigned char spry[MAX_SPRITE];
extern unsigned char sprc[MAX_SPRITE];
extern unsigned char sprf[MAX_SPRITE];
extern unsigned char frameflag;

extern void initraster(void);
extern void initsprites(void);