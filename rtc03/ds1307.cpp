#include "ds1307.h"
#include <Wire.h>

static const byte DS1307_BUS_ADDRESS = 0x68;
static const byte DS1307_SECONDS_REG = 0x00;
static const byte DS1307_MINUTES_REG = 0x01;
static const byte DS1307_HOURS_REG = 0x02;
static const byte DS1307_CONTROL_REG = 0x07;

static byte bcd2BDec( byte bcd ) {
	return ( bcd >> 4 ) * 10 + bcd & 0x0F;
}

static byte dec2Bcd( byte b ) {
	return ( ( b / 10 ) << 4 ) | ( ( b % 10 ) & 0x0F );
}

void DS1307_GetDateTime( ds1307_datetime* dt ) {
	Wire.beginTransmission( DS1307_BUS_ADDRESS );
	Wire.send( DS1307_SECONDS_REG );
	Wire.endTransmission();
	Wire.requestFrom( DS1307_BUS_ADDRESS, 7 );
	dt->second = bcd2BDec( Wire.receive() & 0x7F );
	dt->minute = bcd2BDec( Wire.receive() & 0x7F );
	dt->hour = bcd2BDec( Wire.receive() & 0x3F );
	dt->wkday = bcd2BDec( Wire.receive() & 0x07 );
	dt->day = bcd2BDec( Wire.receive() & 0x3F );
	dt->month = bcd2BDec( Wire.receive() & 0x1F );
	dt->year = 2000 + bcd2BDec( Wire.receive() );
}

void DS1307_GetDateTimeBcd( ds1307_datetime* dt ) {
	Wire.beginTransmission( DS1307_BUS_ADDRESS );
	Wire.send( DS1307_SECONDS_REG );
	Wire.endTransmission();
	Wire.requestFrom( DS1307_BUS_ADDRESS, 7 );
	dt->second = Wire.receive() & 0x7F;
	dt->minute = Wire.receive() & 0x7F;
	dt->hour = Wire.receive() & 0x3F;
	dt->wkday = Wire.receive() & 0x07;
	dt->day = Wire.receive() & 0x3F;
	dt->month = Wire.receive() & 0x1F;
	dt->year = 0x2000 + Wire.receive();
}

void DS1307_SetDateTime( ds1307_datetime* dt ) {
	Wire.beginTransmission( DS1307_BUS_ADDRESS );
	Wire.send( DS1307_SECONDS_REG );
	Wire.send( dec2Bcd( dt->second ) );
	Wire.send( dec2Bcd( dt->minute ) );
	Wire.send( dec2Bcd( dt->hour ) );
	Wire.send( dec2Bcd( dt->wkday ) );
	Wire.send( dec2Bcd( dt->day ) );
	Wire.send( dec2Bcd( dt->month ) );
	Wire.send( dec2Bcd( ( byte )( dt->year - 2000 ) ) );
	Wire.endTransmission();
}

void DS1307_SetControl( boolean out, boolean sqwe, int sqwf ) {
	byte ctrl = 0x00;
	if ( out ) {
		ctrl |= 0x80;
	}
	if ( sqwe ) {
		ctrl |= 0x10;
	}
	out |= ( sqwf & 0x03 );
	Wire.beginTransmission( DS1307_BUS_ADDRESS );
	Wire.send( DS1307_CONTROL_REG );
	Wire.send( ctrl );
	Wire.endTransmission();
}
