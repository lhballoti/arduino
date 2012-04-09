/*
  button matrix test
 */

#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/sleep.h>

const int BUTTON_RESET = 0xff;
const int BUTTON_PRESSED = 0xf0;

const int rowCount = 3;
const int columnCount = 3;
const int rows[] = { A1, A0, A2 };
const int columns[] = { 7, 8, 9 };

const int LED_PIN = 2;

byte buttons[rowCount * columnCount];
boolean buttonStates[rowCount * columnCount];

// Empty timer ISR
EMPTY_INTERRUPT( TIMER0_COMPA_vect );

void resetButtons() {
	int i;
	for ( i = 0; i < rowCount * columnCount; i++ ) {
		buttons[i] = BUTTON_RESET;
	}
}

void setup() {
	// Timer (fires every 4ms)
	TCCR0A = 2;		// OC0A and OC0B disconnected, CTC mode
	// TCCR0B will be written last, since it is used to enable the timer
	OCR0A = 124;	// 8ms period @ 16MHz with a 1024 prescaler
					// setting
	TCNT0 = 0;
	TIMSK0 |= _BV( OCIE0A );// enable output compare A interrupt

	// initial state: rows as inputs
	pinMode( A1, INPUT );
	pinMode( A0, INPUT );
	pinMode( A2, INPUT );
	// enable internal pull-ups
	digitalWrite( A1, HIGH );
	digitalWrite( A0, HIGH );
	digitalWrite( A2, HIGH );
	// columns as inputs
	pinMode( 7, INPUT );
	pinMode( 8, INPUT );
	pinMode( 9, INPUT );
	// enable internal pull-ups
	digitalWrite( 7, HIGH );
	digitalWrite( 8, HIGH );
	digitalWrite( 9, HIGH );

	pinMode( 2, OUTPUT );
	digitalWrite( 2, LOW );

	Serial.begin( 57600 );

	resetButtons();

	int i;
	for ( i = 0; i < rowCount * columnCount; i++ ) {
		buttonStates[i] = false;
	}
	sei();
	TCCR0B = 5;	// start timer using a 1:1024 prescaler
}

int state = 0;

void loop() {
	sleep_enable();
	sleep_cpu();
	sleep_disable();

	digitalWrite( 2, HIGH );

	int i, j;
	int newState = 0;

	// select (pull down) each row
	for ( i = 0; i < rowCount; i++ ) {
		pinMode( rows[i], OUTPUT );
		digitalWrite( rows[i], LOW );
		delayMicroseconds( 10 );
		// read the column values
		for ( j = 0; j < columnCount; j++ ) {
			int idx = i * columnCount + j;
			buttons[idx] = buttons[idx] << 1 | ( digitalRead( columns[j] ) & 1 );
			boolean st = ( buttons[idx] | BUTTON_PRESSED ) == BUTTON_PRESSED;
			newState |= ( st ? 1 : 0 ) << idx;
			//~ if ( st ) {
				//~ Serial.print( idx );
				//~ Serial.write( '\n' );
				//~ Serial.flush();
			//~ }
		}
		// unselect the row
		pinMode( rows[i], INPUT );
		digitalWrite( rows[i], HIGH );
		delayMicroseconds( 10 );
	}

	if ( newState != state ) {
		state = newState;
		Serial.print( state );
		Serial.write( '\n' );
		Serial.flush();
	}

	digitalWrite( 2, LOW );
}
