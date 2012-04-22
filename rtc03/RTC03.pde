/*
  clock with adjust
 */

#include <SPI.h>
#include <Wire.h>
#include "max7219.h"
#include "ds1307.h"
#include "button_matrix.h"
#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/sleep.h>

const int LED_PIN = 2;
const int SQW_PIN = 3;
const int SS_PIN = 10;

volatile boolean sqw = false;

void SQW_Interrupt() {
	static boolean led = false;
	digitalWrite( LED_PIN, led );
	led = !led;
	sqw = true;
}

// Empty timer ISR
EMPTY_INTERRUPT( TIMER0_COMPA_vect );

ds1307_datetime oldDt;
ds1307_datetime dt;

void setup() {

	// Timer (fires every 8ms)
	TCCR0A = 2;		// OC0A and OC0B disconnected, CTC mode
	// TCCR0B will be written last, since it is used to enable the timer
	OCR0A = 124;	// 8ms period @ 16MHz with a 1024 prescaler
					// setting
	TCNT0 = 0;
	TIMSK0 |= _BV( OCIE0A );// enable output compare A interrupt

	ButtonMatrix_Init();

	// I/O setup
	pinMode( SS_PIN, OUTPUT );
	pinMode( LED_PIN, OUTPUT );
	digitalWrite( LED_PIN, LOW );
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

	//~ dt.year = 2012;
	//~ dt.month = 4;
	//~ dt.day = 21;
	//~ dt.wkday = 6;
	//~ dt.hour = 17;
	//~ dt.minute = 32;
	//~ dt.second = 0;
	//~ DS1307_SetDateTime( &dt );

	dt.wkday = 0xFF;
	dt.hour = 0xFF;
	dt.minute = 0xFF;

	// enable square wave output @ 1Hz
	DS1307_SetControl( false, true, DS1307_SQW_1HZ );

	Serial.begin( 57600 );

	sei();
	attachInterrupt( 1, SQW_Interrupt, RISING );
	//~ TCCR0B = 5;	// start timer using a 1:1024 prescaler
}

void loop() {

	// sleep until interrupted
	sleep_enable();
	sleep_cpu();
	sleep_disable();

	if ( sqw ) {
		oldDt = dt;
		DS1307_GetDateTimeBcd( &dt );
		if ( dt.hour != oldDt.hour || dt.minute != oldDt.minute ) {
			MAX7219_SetDigit( 0, ( dt.hour & 0x30 ) >> 4 );
			MAX7219_SetDigit( 1, dt.hour & 0x0F );
			MAX7219_SetDigit( 2, dt.minute >> 4 );
			MAX7219_SetDigit( 3, dt.minute & 0x0F );
		}
		sqw = false;
	} else if ( ButtonMatrix_stateChanged() ) {
		//~ Serial.println( "*" );
		int i;
		for ( i = 0; i < BUTTON_MATRIX_ROW_COUNT * BUTTON_MATRIX_COLUMN_COUNT; i++ ) {
			if ( ButtonMaxtrix_buttonStateChanged( i ) ) {
				Serial.print( "Button " );
				Serial.print( i + 1 );
				if ( ButtonMatrix_isPressed( i ) ) {
					Serial.println( " pressed" );
				} else {
					Serial.println( " released" );
				}
			}
		}
	}
}

