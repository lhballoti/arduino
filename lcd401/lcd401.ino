int led_pin = 13;
int clk_pin = 11;
int di_pin = 10;
int do_pin = 9;
int load_pin = 8;

long data;

void setup() {
  pinMode( led_pin, OUTPUT );
  pinMode( clk_pin, OUTPUT );
  pinMode( di_pin, OUTPUT );
  pinMode( do_pin, INPUT );
  pinMode( load_pin, OUTPUT );
  digitalWrite( led_pin, LOW );
  digitalWrite( clk_pin, LOW );
  digitalWrite( di_pin, LOW );
  digitalWrite( load_pin, LOW );
}

void loop() {
//  data = 1;
//  
//  for ( int i = 0; i < 32; i++ ) {
  data = 0x55555555L;
    shiftOut( di_pin, clk_pin, MSBFIRST, data >> 24 );
    shiftOut( di_pin, clk_pin, MSBFIRST, data >> 16 );
    shiftOut( di_pin, clk_pin, MSBFIRST, data >> 8 );
    shiftOut( di_pin, clk_pin, MSBFIRST, data );
    digitalWrite( load_pin, HIGH );
    delayMicroseconds( 50 );
    digitalWrite( load_pin, LOW );
//
//    data <<= 1;
//    data |= 1;

//    digitalWrite( led_pin, HIGH );
    delay( 1000 );
//    digitalWrite( led_pin, LOW );

  data = ~data;
    shiftOut( di_pin, clk_pin, MSBFIRST, data >> 24 );
    shiftOut( di_pin, clk_pin, MSBFIRST, data >> 16 );
    shiftOut( di_pin, clk_pin, MSBFIRST, data >> 8 );
    shiftOut( di_pin, clk_pin, MSBFIRST, data );
    digitalWrite( load_pin, HIGH );
    delayMicroseconds( 50 );
    digitalWrite( load_pin, LOW );
    
    delay( 1000 );
//  }
}
