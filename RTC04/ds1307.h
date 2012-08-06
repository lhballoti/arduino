#ifndef __DS1307__
#define __DS1307__

#include <Arduino.h>

typedef struct {
	int year;
	byte month;
	byte day;
	byte wkday;
	byte hour;
	byte minute;
	byte second;
} ds1307_datetime;

#define DS1307_SQW_1HZ		0
#define DS1307_SQW_4096HZ	1
#define DS1307_SQW_8192HZ	2
#define DS1307_SQW_32768HZ	3

void DS1307_GetDateTime( ds1307_datetime* dt );

void DS1307_GetDateTimeBcd( ds1307_datetime* dt );

void DS1307_SetDateTime( ds1307_datetime* dt );

void DS1307_SetControl( boolean out, boolean sqwe, int sqwf );

#endif
