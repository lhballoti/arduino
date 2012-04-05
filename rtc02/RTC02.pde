/*
  SPI 01 - SPI Test
 */

#include <SPI.h>
#include <Wire.h>
#include <avr/sleep.h>

const int LED_PIN = 2;
const int SQW_PIN = 3;
const int SS_PIN = 10;

const byte MAX7219_ADDR_NOOP = 0x00;
const byte MAX7219_ADDR_DIG0 = 0x01;
const byte MAX7219_ADDR_DECM = 0x09;
const byte MAX7219_ADDR_INTN = 0x0A;
const byte MAX7219_ADDR_SCLM = 0x0B;
const byte MAX7219_ADDR_SHDN = 0x0C;
const byte MAX7219_ADDR_TEST = 0x0F;

void MAX7219_Send( byte addr, byte data ) {
	digitalWrite( SS_PIN, LOW );
	SPI.transfer( addr );
	SPI.transfer( data );
	digitalWrite( SS_PIN, HIGH );
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

const byte DS1307_BUS_ADDRESS = B01101000;
const byte DS1307_SECONDS_REG = 0x00;
const byte DS1307_MINUTES_REG = 0x01;
const byte DS1307_HOURS_REG = 0x02;
const byte DS1307_SQWAVE_REG = 0x07;

void SQW_Interrupt() {
	static boolean led = false;
	digitalWrite( LED_PIN, led );
	led = !led;
}

void setup() {
	// I/O setup
	pinMode( SS_PIN, OUTPUT );
	pinMode( LED_PIN, OUTPUT );
	pinMode( SQW_PIN, INPUT );

	// SPI setup
	SPI.begin();
	SPI.setDataMode( SPI_MODE0 );
	SPI.setClockDivider( SPI_CLOCK_DIV16 );
	SPI.setBitOrder( MSBFIRST );

	// MAX7219 setup
	delay( 1 );
	MAX7219_SetScanLimit( 0x3 );
	MAX7219_SetDecodeMode( 0xF );
	MAX7219_SetIntensity( 0x4 );
	MAX7219_Start();
	delay( 1 );

	// I2C setup
	Wire.begin();

	// DS1307 setup
	// enable oscillator:
	// 1. read address 00h
	Wire.beginTransmission( DS1307_BUS_ADDRESS );
	Wire.send( 0 );
	Wire.endTransmission();
	// 2. check if the oscillator is stopped
	Wire.requestFrom( DS1307_BUS_ADDRESS, 1 );
	if ( Wire.available() ) {
		byte b = Wire.receive();
		if ( b & 0x80 ) {
			// 3. clear bit 7 of the received byte
			//    and write it back to 00h
			Wire.beginTransmission( DS1307_BUS_ADDRESS );
			Wire.send( 0 );
			Wire.send( b & 0x7F );
			Wire.endTransmission();
		}
	}

	// enable square wave output @ 1Hz
	Wire.beginTransmission( DS1307_BUS_ADDRESS );
	Wire.send( DS1307_SQWAVE_REG );
	Wire.send( B00010000 );
	Wire.endTransmission();

	attachInterrupt( 1, SQW_Interrupt, RISING );
}

byte datetime[2];

void loop() {

	// sleep until interrupted
	sleep_enable();
	sleep_cpu();
	sleep_disable();

	// read date from RTC
	Wire.beginTransmission( DS1307_BUS_ADDRESS );
	Wire.send( DS1307_MINUTES_REG );
	Wire.endTransmission();
	// read minutes and hours
	Wire.requestFrom( DS1307_BUS_ADDRESS, 2 );
	int i = 0;
	while ( Wire.available() ) {
		datetime[i++] = Wire.receive();
	}

	//~ for ( int i = 0; i < 4; i++ ) {
		//~ MAX7219_SetDigit( i, digits[i] );
	//~ }

	MAX7219_SetDigit( 0, ( datetime[1] & 0x30 ) >> 4 );
	MAX7219_SetDigit( 1, datetime[1] & 0x0F );
	MAX7219_SetDigit( 2, datetime[0] >> 4 );
	MAX7219_SetDigit( 3, datetime[0] & 0x0F );

}

