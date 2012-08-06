#include <Wire.h>
#include "ds1307.h"
//#include <avr/io.h>
//#include <avr/interrupt.h>
#include <avr/sleep.h>

const int LED_PIN = 13;
const int SQW_PIN = 4;

volatile int sqw_count = 0;
//
//typedef void (*timer_int)();
//
//void rtc_sync_timer0_compa_vect() {
//  sqw_count++;
//  if ( sqw_count == 64 ) {
//    sqw_count = 0;
//    digitalWrite( LED_PIN, !digitalRead( LED_PIN ) );
//  }
//}
//
//timer_int timer0_compa_vect = &rtc_sync_timer0_compa_vect;

EMPTY_INTERRUPT( TIMER0_COMPA_vect );
//ISR( TIMER0_COMPA_vect ) {
//  (*timer0_compa_vect)();
//}

void setup() {

//  ds1307_datetime oldDt;
  ds1307_datetime dt;

  // Timer (fires @ 64 Hz)
  TCCR0A = 2;		// OC0A and OC0B disconnected, CTC mode
  // TCCR0B will be written last, since it is used to enable the timer
  OCR0A = 63;	// 64 Hz frequency using external 4096 Hz clock
  TCNT0 = 0;
  TIMSK0 |= _BV( OCIE0A );// enable output compare A interrupt

  // I/O setup
  pinMode( LED_PIN, OUTPUT );
  digitalWrite( LED_PIN, LOW );
  pinMode( SQW_PIN, INPUT );

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

//  dt.wkday = 0xFF;
//  dt.hour = 0xFF;
//  dt.minute = 0xFF;

  Serial.begin( 57600 );
 
  // enable square wave output @ 4096 Hz
  DS1307_SetControl( false, true, DS1307_SQW_4096HZ );

  DS1307_GetDateTimeBcd( &dt );
  byte sec = dt.second;

//	sei();
  TCCR0B = 7;	// start timer using external clock

  while ( sec == dt.second ) {
    // sleep until the timer overflows
    sleep_enable();
    sleep_cpu();
    sleep_disable();

    sqw_count++;

    // get the time
    DS1307_GetDateTimeBcd( &dt );
  }

  Serial.println( sqw_count );
}

void loop() {

	// sleep until interrupted
//	sleep_enable();
//	sleep_cpu();
//	sleep_disable();

}

