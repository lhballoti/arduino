/*
  Audio frequency test
 */

#include "pitches.h"

const int TONE_PIN = 3;
const int LED_PIN = 13;

int notes[] = { NOTE_A4, NOTE_B4,NOTE_C3 };

void setup() {
	pinMode( TONE_PIN, OUTPUT );
	pinMode( LED_PIN, OUTPUT );
}

void loop() {
	for ( int i = 0; i < 3; i++ ) {
		digitalWrite( LED_PIN, HIGH );
		tone( TONE_PIN, notes[i] );
		delay( 1000 );
		digitalWrite( LED_PIN, LOW );
		noTone( TONE_PIN );
		delay( 1000 );
	}
}
