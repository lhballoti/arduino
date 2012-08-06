const int interrupt_num = 0;

volatile int counter = 0;

void interrupt() {
  counter++;
}

void setup() {
  pinMode( 2, INPUT );
  attachInterrupt( interrupt_num, interrupt, RISING );
  Serial.begin( 57600 );
}

void loop() {
  delay( 1000 );
  Serial.println( counter );
}
