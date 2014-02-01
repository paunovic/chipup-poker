#ifndef __COMMON_H__
#define __COMMON_H__

#include <stdio.h>
#include <stdlib.h>

/** Helper macros */
#define min(A,B) (((A)<(B))?(A):(B))

/** Card specific constants */
#define HANDTYPECLASSCOUNT 9
static const char CARD[13] = {'2', '3', '4' ,'5', '6', '7', '8', '9', 'T' , 'J', 'Q', 'K', 'A'};
static const char COLOR[4] = {'H', 'S', 'C', 'D'};
//static const char *HANDTYPE[HANDTYPECLASSCOUNT] = {"HC", "1P", "2P", "3K", "S", "F", "FH", "4K", "SF"};

#endif
