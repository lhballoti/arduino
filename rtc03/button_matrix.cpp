#include "button_matrix.h"

#if !defined( BUTTON_MATRIX_ROW_COUNT ) || !defined( BUTTON_MATRIX_COLUMN_COUNT ) || !defined( BUTTON_MATRIX_ROWS ) || !defined( BUTTON_MATRIX_COLUMNS )
#error "One or more BUTTON_MATRIX macros are not defined, edit button_matrix.h"
#endif

static const int BUTTON_RESET = 0xff;
static const int BUTTON_PRESSED = 0xf0;

static int rows[] = { BUTTON_MATRIX_ROWS };
static int columns[] = { BUTTON_MATRIX_COLUMNS };

// on each scan operation, we'll shift the button input
// values into each byte; when four consecutive readings
// return LOW, we'll consider the button was pressed
static byte buttons[BUTTON_MATRIX_ROW_COUNT * BUTTON_MATRIX_COLUMN_COUNT];

static int oldButtonStates;
static int buttonStates;

void ButtonMatrix_Init() {
	int i;
	for ( int i = 0; i < BUTTON_MATRIX_ROW_COUNT * BUTTON_MATRIX_COLUMN_COUNT; i++ ) {
		buttons[i] = BUTTON_RESET;
	}
	for ( i = 0; i < BUTTON_MATRIX_ROW_COUNT; i++ ) {
		// initial state: rows as inputs
		pinMode( rows[i], INPUT );
		// enable internal pull-ups
		digitalWrite( rows[i], HIGH );
	}

	for ( i = 0; i < BUTTON_MATRIX_COLUMN_COUNT; i++ ) {
		// columns as inputs
		pinMode( columns[i], INPUT );
		// enable internal pull-ups
		digitalWrite( columns[i], HIGH );
	}	
}

static int scan() {
	int states = 0;
	int i, j;
	// select (pull down) each row
	for ( i = 0; i < BUTTON_MATRIX_ROW_COUNT; i++ ) {
		pinMode( rows[i], OUTPUT );
		digitalWrite( rows[i], LOW );
		delayMicroseconds( 10 );
		// read the column values
		for ( j = 0; j < BUTTON_MATRIX_COLUMN_COUNT; j++ ) {
			int idx = i * BUTTON_MATRIX_COLUMN_COUNT + j;
			buttons[idx] = buttons[idx] << 1 | ( digitalRead( columns[j] ) & 1 );
			boolean st = ( buttons[idx] | BUTTON_PRESSED ) == BUTTON_PRESSED;
			states |= ( st ? 1 : 0 ) << idx;
		}
		// unselect the row
		pinMode( rows[i], INPUT );
		digitalWrite( rows[i], HIGH );
		delayMicroseconds( 10 );
	}
	return states;
}

boolean ButtonMatrix_stateChanged() {
	oldButtonStates = buttonStates;
	buttonStates = scan();
	return buttonStates != oldButtonStates;
}

boolean ButtonMatrix_isPressed( int button ) {
	return ( buttonStates & ( 1 << button )  ) != 0;
}

boolean ButtonMaxtrix_buttonStateChanged( int button ) {
	return ( ( buttonStates ^ oldButtonStates ) & ( 1 << button ) ) != 0;
}
