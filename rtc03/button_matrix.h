#ifndef __BUTTON_MATRIX__
#define __BUTTON_MATRIX__

#define BUTTON_MATRIX_ROW_COUNT 3
#define BUTTON_MATRIX_COLUMN_COUNT 3

#define BUTTON_MATRIX_ROWS A1, A0, A2
#define BUTTON_MATRIX_COLUMNS 7, 8, 9

#include <Arduino.h>

void ButtonMatrix_Init();

boolean ButtonMatrix_stateChanged();

boolean ButtonMaxtrix_buttonStateChanged( int button );

boolean ButtonMatrix_isPressed( int button );

#endif
