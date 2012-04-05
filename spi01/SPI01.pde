/*
  SPI 01 - SPI Test
 */

#include <SPI.h>

const int LED_OUT = 10;
const int REG_CLK = 2;

byte rd;

void setup() {
	pinMode( LED_OUT, OUTPUT );
	digitalWrite( LED_OUT, LOW );
	SPI.begin();
	SPI.setDataMode( SPI_MODE0 );
	SPI.setClockDivider( SPI_CLOCK_DIV16 );
}

void loop() {
	rd = 0;
	SPI.transfer( B01010101 );
	digitalWrite( REG_CLK, HIGH );
	delay( 1 );
	digitalWrite( REG_CLK, LOW );
	// rd = SPI.transfer( 0 );
	// if ( rd == B01010101 ) {
	//	digitalWrite( LED_OUT, HIGH );
	//}
	delay( 1000 );
	//digitalWrite( LED_OUT, LOW );
	//delay( 1000 );
}
