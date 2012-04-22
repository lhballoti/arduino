#include "max7219.h"
#include <SPI.h>

#ifndef MAX7219_SS_PIN
#error "Slave select pin for MAX7219 is not defined"
#endif

static const byte MAX7219_ADDR_NOOP = 0x00;
static const byte MAX7219_ADDR_DIG0 = 0x01;
static const byte MAX7219_ADDR_DECM = 0x09;
static const byte MAX7219_ADDR_INTN = 0x0A;
static const byte MAX7219_ADDR_SCLM = 0x0B;
static const byte MAX7219_ADDR_SHDN = 0x0C;
static const byte MAX7219_ADDR_TEST = 0x0F;

static void MAX7219_Send( byte addr, byte data ) {
	digitalWrite( MAX7219_SS_PIN, LOW );
	SPI.transfer( addr );
	SPI.transfer( data );
	digitalWrite( MAX7219_SS_PIN, HIGH );
}

void MAX7219_SetScanLimit( byte scan ) {
	MAX7219_Send( MAX7219_ADDR_SCLM, scan );
}

void MAX7219_SetDecodeMode( byte dec ) {
	MAX7219_Send( MAX7219_ADDR_DECM, dec );
}

void MAX7219_SetIntensity( byte inten ) {
	MAX7219_Send( MAX7219_ADDR_INTN, inten );
}

void MAX7219_SetDigit( byte digit, byte value ) {
	MAX7219_Send( MAX7219_ADDR_DIG0 + digit, value );
}

void MAX7219_Start() {
	MAX7219_Send( MAX7219_ADDR_SHDN, 1 );
}

void MAX7219_Shutdown() {
	MAX7219_Send( MAX7219_ADDR_SHDN, 0 );
}