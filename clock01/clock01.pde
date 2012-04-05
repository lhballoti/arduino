/*
  counter and multiplexer test
 */

#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/sleep.h>

// Timer ISR
//ISR( TIMER0_COMPA_vect ) {
//	
//}
EMPTY_INTERRUPT( TIMER0_COMPA_vect );

void setup() {
	// Timer (fires every 4ms)
	TCCR0A = 2;		// OC0A and OC0B disconnected, CTC mode
	// TCCR0B will be written last, since it is used to enable the timer
	OCR0A = 249;		// 4ms period @ 16MHz with a 256 prescaler
				// setting
	TCNT0 = 0;
	TIMSK0 |= _BV( OCIE0A );// enable output compare A interrupt

	// BCD to 7 seg decoder outputs
	pinMode( 3, OUTPUT );
	pinMode( 4, OUTPUT );
	pinMode( 5, OUTPUT );
	pinMode( 6, OUTPUT );
	pinMode( 11, OUTPUT ); // blanking
	// Darlington driver outputs
	pinMode( 7, OUTPUT );
	pinMode( 8, OUTPUT );
	pinMode( 9, OUTPUT );
	pinMode( 10, OUTPUT );

	sei();
	TCCR0B = 4;	// start timer using a 1:256 prescaler
}

void writeValue( int value, int digit ) {
	digitalWrite( 11, LOW );
	// number to write...
	digitalWrite( 6, value & 0x8 );
	digitalWrite( 5, value & 0x4 );
	digitalWrite( 4, value & 0x2 );
	digitalWrite( 3, value & 0x1 );
	// ...to which digit
	int out = 1 << digit;
	digitalWrite( 10, out & 0x8 );
	digitalWrite( 9, out & 0x4 );
	digitalWrite( 8, out & 0x2 );
	digitalWrite( 7, out & 0x1 );
//	delayMicroseconds( 500 );
	digitalWrite( 11, HIGH );
}

//boolean val = false;
int count = 0;
int value;
int digit = 0;
int powersOfTen[] = { 1000, 100, 10, 1 };
int interrupts = 0;

void loop() {
	sleep_enable();
	sleep_cpu();
	sleep_disable();

	interrupts++;
	if ( interrupts == 250 ) {
		interrupts = 0;
		count++;
		if ( count == 9999 ) {
			count = 0;
		}
	}
	int value = count / powersOfTen[digit];
	if ( value > 9 ) {
		value %= 10;
	}
	writeValue( value, digit );
	digit++;
	if ( digit > 3 ) {
		digit = 0;
	}
}
