/*
  SPI 01 - SPI Test
 */

#include <SPI.h>

const int SS = 10;

const byte MAX7219_ADDR_NOOP = 0x00;
const byte MAX7219_ADDR_DIG0 = 0x01;
const byte MAX7219_ADDR_DIG1 = 0x02;
const byte MAX7219_ADDR_DIG2 = 0x03;
const byte MAX7219_ADDR_DIG3 = 0x04;
const byte MAX7219_ADDR_DIG4 = 0x05;
const byte MAX7219_ADDR_DIG5 = 0x06;
const byte MAX7219_ADDR_DIG6 = 0x07;
const byte MAX7219_ADDR_DIG7 = 0x08;
const byte MAX7219_ADDR_DECM = 0x09;
const byte MAX7219_ADDR_INTN = 0x0A;
const byte MAX7219_ADDR_SCLM = 0x0B;
const byte MAX7219_ADDR_SHDN = 0x0C;
const byte MAX7219_ADDR_TEST = 0x0F;

void MAX7219_Send( byte addr, byte data ) {
	digitalWrite( SS, LOW );
	SPI.transfer( addr );
	SPI.transfer( data );
	digitalWrite( SS, HIGH );
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

int counter = 0;
byte digits[4];

void setup() {
	pinMode( SS, OUTPUT );
	SPI.begin();
	SPI.setDataMode( SPI_MODE0 );
	SPI.setClockDivider( SPI_CLOCK_DIV16 );
	SPI.setBitOrder( MSBFIRST );
	delay( 1 );
	MAX7219_SetScanLimit( 0x3 );
	MAX7219_SetDecodeMode( 0xF );
	MAX7219_SetIntensity( 0xB );
	MAX7219_Start();
	delay( 1 );
}

void loop() {
	int temp = counter;
	for ( int i = 3; i >= 0; i-- ) {
		digits[i] = temp % 10;
		temp /= 10;
	}

	for ( int i = 0; i < 4; i++ ) {
		MAX7219_SetDigit( i, digits[i] );
	}

	counter++;
	if ( counter > 9999 ) {
		counter = 0;
	}
	delay( 1000 );
}
