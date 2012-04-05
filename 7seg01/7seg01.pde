/*
  7 segment decoder test
 */

void setup() {                
	pinMode( 2, OUTPUT );
	pinMode( 3, OUTPUT );
	pinMode( 4, OUTPUT );
	pinMode( 5, OUTPUT );
//	pinMode( 13, OUTPUT );
}

//boolean val = false;
unsigned int count = 0;

void loop() {
	digitalWrite( 5, count & 0x8 );
	digitalWrite( 4, count & 0x4 );
	digitalWrite( 3, count & 0x2 );
	digitalWrite( 2, count & 0x1 );
//	digitalWrite( 13, val );
//	val = !val;
	count++;
	if ( count > 9 ) {
		count = 0;
	}
	delay( 100 );
}
