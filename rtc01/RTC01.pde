#include <Wire.h>

const int LED_PIN = 2;
const int SQW_PIN = 3;

const byte DS1307_ADDRESS = B01101000;

const int CMD_LEN = 4 + 2 + 2 + 1 + 2 + 2 + 2; // YYYY + MM + DD + W + HH + mm + ss

void SQW_Interrupt() {
	static boolean led = false;
	digitalWrite( LED_PIN, led );
	led = !led;
}

String input = "";
byte parsed[7];
byte datetime[7];

byte twoCharToBCD( String s, int index ) {
	byte b = ( s[index] - '0' ) << 4;
	b |= s[index + 1] - '0';
	return b;
}

// sample input: 2012|03|25|1|14|02|00
//        index: 0123|45|67|8|90|12|34
void stringToTime( String input, byte* output ) {
	output[6] = twoCharToBCD( input, 2 );
	output[5] = twoCharToBCD( input, 4 );
	output[4] = twoCharToBCD( input, 6 );
	output[3] = input[8] - '0';
	output[2] = twoCharToBCD( input, 9 );
	output[1] = twoCharToBCD( input, 11 );
	output[0] = twoCharToBCD( input, 13 );
}

void setTime( byte* time ) {
	Wire.beginTransmission( DS1307_ADDRESS );
	Wire.send( 0 );
	for ( int i = 0; i < 7; i++ )
		Wire.send( time[i] );
	Wire.endTransmission();
}

void setup() {
	pinMode( LED_PIN, OUTPUT );
	pinMode( SQW_PIN, INPUT );
	//~ attachInterrupt( 1, SQW_Interrupt, CHANGE );
	Wire.begin();

	// enable oscillator:
	// 1. read address 00h
	Wire.beginTransmission( DS1307_ADDRESS );
	Wire.send( 0 );
	Wire.endTransmission();
	// 2. check if the oscillator is stopped
	Wire.requestFrom( DS1307_ADDRESS, 1 );
	if ( Wire.available() ) {
		byte b = Wire.receive();
		if ( b & 0x80 ) {
			// 3. clear bit 7 of the received byte
			//    and write it back to 00h
			Wire.beginTransmission( DS1307_ADDRESS );
			Wire.send( 0 );
			Wire.send( b & 0x7F );
			Wire.endTransmission();
		}
	}

	// enable square wave output @ 1Hz
	//~ Wire.beginTransmission( DS1307_ADDRESS );
	//~ Wire.send( 7 );
	//~ Wire.send( B00010000 );
	//~ Wire.endTransmission();

	Serial.begin( 57600 );
}

void loop() {
	
	while ( Serial.available() ) {
		char c = ( char ) Serial.read();
		input += c;
		if ( input.length() == CMD_LEN ) {
			digitalWrite( LED_PIN, HIGH );
			stringToTime( input, parsed );
			setTime( parsed );
			input = "";
		}
	}
	
	int i = 0;
	Wire.beginTransmission( DS1307_ADDRESS );
	Wire.send( 0 );
	Wire.endTransmission();
	Wire.requestFrom( DS1307_ADDRESS, 7 );
	while ( Wire.available() ) {
		datetime[i++] = Wire.receive();
	}

	// year
	Serial.print( "20" );
	Serial.print( datetime[6] >> 4 );
	Serial.print( datetime[6] & 0x0F );
	// month
	Serial.print( datetime[5] >> 4 );
	Serial.print( datetime[5] & 0x0F );
	// day of month
	Serial.print( datetime[4] >> 4 );
	Serial.print( datetime[4] & 0x0F );
	// day of week
	Serial.print( datetime[3] & 0x07 );
	// hour
	Serial.print( datetime[2] >> 4 );
	Serial.print( datetime[2] & 0x0F );
	// minute
	Serial.print( datetime[1] >> 4 );
	Serial.print( datetime[1] & 0x0F );
	// second
	Serial.print( ( datetime[0] & 0x7F ) >> 4 );
	Serial.println( datetime[0] & 0x0F );

	delay( 1000 );

	digitalWrite( LED_PIN, LOW );
}
