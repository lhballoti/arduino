/*
  encoder test
 */

/* Rotary encoder read example */
#define ENC_A 2
#define ENC_B 3
#define ENC_PORT PIND

#define COMM_A 9
#define COMM_B 8

boolean comm_a = true;
boolean comm_b = false;

volatile int8_t encval = 0;

void writeDigit( int value ) {
	digitalWrite( 7, value & 0x8 );
	digitalWrite( 6, value & 0x4 );
	digitalWrite( 5, value & 0x2 );
	digitalWrite( 4, value & 0x1 );
}

/* returns change in encoder state (-1,0,1) */
void read_encoder()
{
	static int8_t enc_states[] = { 0, -1, 1, 0, 1, 0, 0, -1, -1, 0, 0, 1, 0, 1, -1, 0 };
	static uint8_t old_AB = 3;
	//~ old_AB <<= 2;                   //remember previous state
	//~ old_AB |= ( ENC_PORT & 0x03 );  //add current state
	old_AB <<= 1;
	old_AB |= digitalRead( ENC_A );
	old_AB <<= 1;
	old_AB |= digitalRead( ENC_B );
	encval += enc_states[( old_AB & 0x0f )];
	if ( encval > 99 ) {
		encval = 0;
	} else if ( encval < 0 ) {
		encval = 99;
	}
	//~ writeDigit( encval );
}

void setup()
{
	/* Setup encoder pins as inputs */
	pinMode( ENC_A, INPUT );
	attachInterrupt( 0, read_encoder, CHANGE );
	digitalWrite( ENC_A, HIGH );
	pinMode( ENC_B, INPUT );
	attachInterrupt( 1, read_encoder, CHANGE );
	digitalWrite( ENC_B, HIGH );
	
	// 7 segment decoder outputs
	pinMode( 4, OUTPUT );
	pinMode( 5, OUTPUT );
	pinMode( 6, OUTPUT );
	pinMode( 7, OUTPUT );

	// display common pins
	pinMode( COMM_A, OUTPUT );
	pinMode( COMM_B, OUTPUT );

	digitalWrite( COMM_A, LOW );
	//~ writeDigit( 0 );
}

void loop()
{
	digitalWrite( COMM_A, LOW );
	digitalWrite( COMM_B, LOW );
	delayMicroseconds( 1000 );

	int tens = encval / 10;
	int units = encval % 10;
	//~ comm_a = !comm_a;
	writeDigit( tens );
	digitalWrite( COMM_A, HIGH );
	delay( 3 );
	digitalWrite( COMM_A, LOW );
	delay( 9 );

	writeDigit( units );
	digitalWrite( COMM_B, HIGH );
	delay( 3 );
	digitalWrite( COMM_B, LOW );
	delay( 9 );
	//~ comm_b = !comm_b;
}

