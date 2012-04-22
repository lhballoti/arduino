#ifndef __MAX7219__
#define __MAX7219__

#include <WProgram.h>

#define MAX7219_SS_PIN 10

void MAX7219_SetScanLimit( byte scan );

void MAX7219_SetDecodeMode( byte dec );

void MAX7219_SetIntensity( byte inten );

void MAX7219_SetDigit( byte digit, byte value );

void MAX7219_Start();

void MAX7219_Shutdown();

#endif