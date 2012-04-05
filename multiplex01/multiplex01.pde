/*
  7 segment decoder test
 */

void setup() {
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
int count = 1234;
int value;
int digit = 0;
int powersOfTen[] = { 1000, 100, 10, 1 };

void loop() {
	int value = count / powersOfTen[digit];
	if ( value > 9 ) {
		value %= 10;
	}
	writeValue( value, digit );
	delay( 4 );
	digit++;
	if ( digit > 3 ) {
		digit = 0;
	}
}
