/*
  encoder test
 */

// encoder inputs
const int ENCODER_A = 2;
const int ENCODER_B = 3;

//boolean val = false;
volatile int count = 0;
volatile unsigned long lastAevt = 0;
volatile unsigned long lastBevt = 0;

int encoderUp( int value ) {
	value++;
	if ( value > 9 ) {
		value = 0;
	}
	return value;
}

int encoderDown( int value ) {
	value--;
	if ( value < 0 ) {
		value = 9;
	}
	return value;
}

void writeDigit( int value ) {
	if ( value >= 0 && value <= 9 ) {
		digitalWrite( 7, value & 0x8 );
		digitalWrite( 6, value & 0x4 );
		digitalWrite( 5, value & 0x2 );
		digitalWrite( 4, value & 0x1 );
	}
}

// pin 2 (enc A) interrupt routine
void pin2isr() {
	unsigned long now = millis();
	if ( now - lastAevt > 10 ) {
		if ( digitalRead( ENCODER_B ) == LOW ) {
			count = encoderUp( count );
			writeDigit( count );
		}
	}
	lastAevt = now;
}

// pin 3 (enc B) interrupt routine
void pin3isr() {
	unsigned long now = millis();
	if ( now - lastBevt > 10 ) {
		if ( digitalRead( ENCODER_A ) == LOW ) {
			count = encoderDown( count );
			writeDigit( count );
		}
	}
	lastBevt = now;
}

void setup() {
	// 7 segment decoder outputs
	pinMode( 4, OUTPUT );
	pinMode( 5, OUTPUT );
	pinMode( 6, OUTPUT );
	pinMode( 7, OUTPUT );

	// encoder interrupt/input pins
	pinMode( ENCODER_A, INPUT );
	attachInterrupt( 0, pin2isr, RISING );
	pinMode( ENCODER_B, INPUT );
	attachInterrupt( 1, pin3isr, RISING );

//	pinMode( 13, OUTPUT );

	writeDigit( 0 );
}

void loop() {
	delay( 1000 );
}
