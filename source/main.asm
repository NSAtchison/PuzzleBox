;
; Final Project: Puzzle Box
;
; Created: 11/29/2022
; Author : natchison25
;
; compile with:
; gavrasm.exe -b main.asm
; 
; upload with:
; avrdude -c arduino -p atmega328p -P COM4 -U main.hex

.DEVICE ATmega328p ;Define the correct device

;Setting a pre-designated Code for Keypad Puzzle 1
.EQU Puz1Num1 = '1'
.EQU Puz1Num2 = '2'
.EQU Puz1Num3 = '3'
.EQU Puz1Num4 = '4'
.EQU Puz1Num5 = '5'
.EQU Puz1Num6 = '6'



Prog_Start:

    ; Set up the stack pointer (for calling subroutines)
    ldi r31, $08 ; Set high part of stack pointer
    out SPH, r31
    ldi r31, $ff ; set low part of stack pointer
    out SPL, r31

    ;PORTD (Inputs for columns of Keypad, Outputs for LEDs and Servo)
    ldi r20, $E0 ; PORTD (Pull Up Resistors for Input)
    ldi r21, $0F ; DDRD (Pins 0-3 Output, 0-2 are puzzle status LEDs, pin 3 is servo)
    out DDRD, r21
    out PORTD, r20

    ;PORTB (Outputs for rows of Keypad)
    ldi r20, $00 ; PORTB (all Off)
    ldi r21, $0F ; DDRB (Ports 0-3 Output)
    out PORTB, r20
    out DDRB, r21

    ;PORTC (Inputs for tempSensor and Servo Button, Outputs for Puzzle 3 LEDs)
    ldi r20, $02 ; PORTC (Pull up resistor for servo button)
    ldi r21, $3C ; DDRC (Ports 2-5 are outputs for puzzle 3 LEDs)
    out DDRC, r21
    out PORTC, r20

    call PWM_Start ; Setting up PWM

    call randomizeValue ; Randomizing a value for puzzle 3

    ;Setting up spaces in SRAM for Puzzle 1 Array
    ldi XH, $01
    ldi XL, $00 ;Start of Array at x0100

    mov YH, XH
    mov YL, XL ; Iterator through array set at Start

    ldi ZH, $01
    ldi ZL, $06 ;end of Array at x0105, so when we reach x0106 we have got all values



MainLoop:
    call KeypadPuzzle1 ;Starting with the first Puzzle
    call TempPuzzle2 ; Moving on to second Puzzle
    call BinarySumPuzzle3 ; Go to last Puzzle of the Box
    jmp ServoLoop ; We've finished the puzzles, move to final stages of box

;;; HERE IS WHERE PUZZLE 1 CODE STARTS ;;;
;;; HERE IS WHERE PUZZLE 1 CODE STARTS ;;;
;;; HERE IS WHERE PUZZLE 1 CODE STARTS ;;;

;;; REGISTERS USED FOR THIS PUZZLE ;;;
; r20: Resetting PORTB
; r18: Pulling in PIND status
; r16: Holding keypad Inputs
; r17: Loading in values from Array

KeypadPuzzle1:

    ldi r20, $00 ; Making sure PORTB is set to zero for checking if a button is pressed
    out PORTB, r20

    call inputDelay

    ;Checking if a button is pressed by pulling in PIND and checking the last 3 Pins
    in r18, PIND
    ori r18, $1F
    cpi r18, $FF
    brne keyPressed ; If there is a 0 in the last 3 pins of PIND, a button was pressed

    rjmp KeypadPuzzle1

keyPressed:
    call findKey ;Find the key that was pressed

    call inputDelay

    cpi r16, '*'
    breq KeypadPuzzle1 ; They pushed a key we want to do nothing, go back to Puzzle 1 loop

    st Y+, r16 ; Store the button pushed at current spot in array, increment Iterator

    cp YH, ZH
    cpc YL, ZL ;Check if we reached the end of the array
    breq checkCode ; We've reached end of array, let's see if the code is correct

    rjmp KeypadPuzzle1

checkCode:
    
    mov YH, XH ;Moving iterator to beginning of the array
    mov YL, XL

    ld r17, Y+ ; Load in value where iterator is pointing and increment iterator
    cpi r17, Puz1Num1 ;Check if first value of the array matches the first number in the six digit code
    brne incorrectCode

    ld r17, Y+ ; Load in value where iterator is pointing and increment iterator
    cpi r17, Puz1Num2 ;Check if second value of the array matches the second number in the six digit code
    brne incorrectCode

    ld r17, Y+ ; Load in value where iterator is pointing and increment iterator
    cpi r17, Puz1Num3 ;Check if third value of the array matches the third number in the six digit code
    brne incorrectCode

    ld r17, Y+ ; Load in value where iterator is pointing and increment iterator
    cpi r17, Puz1Num4 ;Check if fourth value of the array matches the fourth number in the six digit code
    brne incorrectCode

    ld r17, Y+ ; Load in value where iterator is pointing and increment iterator
    cpi r17, Puz1Num5 ;Check if fifth value of the array matches the fifth number in the six digit code
    brne incorrectCode

    ld r17, Y+ ; Load in value where iterator is pointing and increment iterator
    cpi r17, Puz1Num6 ;Check if sixth value of the array matches the sixth number in the six digit code
    brne incorrectCode

    ;If we've reached this point, we have the correct code!
    sbi PORTD, 0 ; Turn on the LED for the first Puzzle
    
    ret ; Return to Main

incorrectCode:
    mov YH, XH ;Move iterator back to beginning of array and start again
    mov YL, XL

    rjmp KeypadPuzzle1

findKey:
    ;Checking first Row
    ldi r20, $07 ; setting row 1 to low in PORTB
    out PORTB, r20

    call inputDelay

    in r18, PIND
    ori r18, $1F
    cpi r18, $FF
    brne row1Key

    ;Checking Second Row
    ldi r20, $0B ; setting row 2 to low in PORTB
    out PORTB, r20

    call inputDelay

    in r18, PIND
    ori r18, $1F
    cpi r18, $FF
    brne row2Key

    ;Checking Third Row
    ldi r20, $0D ; setting row 3 to low in PORTB
    out PORTB, r20


    call inputDelay

    in r18, PIND
    ori r18, $1F
    cpi r18, $FF
    brne row3Key

    ;Checking Fourth Row
    ldi r20, $0E ; setting row 4 to low in PORTB
    out PORTB, r20

    call inputDelay

    in r18, PIND
    ori r18, $1F
    cpi r18, $FF
    brne row4Key

    ret ; Should never reach here, but do nothing if we do

row1Key:
    SBIS PIND, 7
    ldi r16, '1'
    SBIS PIND, 6
    ldi r16, '2'
    SBIS PIND, 5
    ldi r16, '3'


    rjmp buttonHold

row2Key:
    SBIS PIND, 7
    ldi r16, '4'
    SBIS PIND, 6
    ldi r16, '5'
    SBIS PIND, 5
    ldi r16, '6'

    rjmp buttonHold

row3Key:
    SBIS PIND, 7
    ldi r16, '7'
    SBIS PIND, 6
    ldi r16, '8'
    SBIS PIND, 5
    ldi r16, '9'

    rjmp buttonHold

row4Key:
    SBIS PIND, 7 ; They pushed a key that doesn't do anything, set a key so program knows
    ldi r16, '*'
    SBIS PIND, 6
    ldi r16, '0'
    SBIS PIND, 5
    jmp Puzzle1Reset ; The user pressed the Hashtag, which is the reset button

    rjmp buttonHold


buttonHold:
    SBIS PIND, 7 ;Sit in this branch until the button is let go
    rjmp buttonHold
    SBIS PIND, 6
    rjmp buttonHold
    SBIS PIND, 5
    rjmp buttonHold

    ret

Puzzle1Reset:
    SBIS PIND, 5 ; Stay here until the button for reset is released (we want reset to finish after button is released)
    rjmp Puzzle1Reset

    cbi PORTD, 0 ;Clear first puzzle LED if on
    ldi r16, 100 ; Turn servo to locked position
    sts OCR2B, r16
    jmp Prog_Start ; Reset the program


;;; HERE IS WHERE PUZZLE 2 CODE STARTS ;;;
;;; HERE IS WHERE PUZZLE 2 CODE STARTS ;;;
;;; HERE IS WHERE PUZZLE 2 CODE STARTS ;;;

;;; REGISTERS USED FOR THIS PUZZLE ;;;
; r18: Reading in ADCL / Reading in PIND status
; r17: Reading in ADCH
; r20-r21: Comparison value for temperature
; r16: Resetting PORTB

TempPuzzle2:
    call Puzzle2Setup ; Set up registers for temperature sensor

Puzzle2Loop:

    call inputDelay
    lds r18, ADCL ;Load in the current temperature
    lds r17, ADCH

    cp r20, r17
    cpc r21, r18 ;Check if we have reached below 41 degrees Farenheit in temp
    BRLT finishPuzzle2 ; If less than 41 degrees Farenheit, we're done with puzzle 2!

    ;This code is checking if a button was pushed, to see if someone pressed the reset button
    ldi r16, $00
    out PORTB, r20

    call inputDelay

    in r18, PIND
    ori r18, $1F
    cpi r18, $FF
    brne checkForReset_Puzzle2

    rjmp Puzzle2Loop

finishPuzzle2:
    sbi PORTD, 1 ; Turn on LED indicating Puzzle 2 is finished
    ret ; return to main

checkForReset_Puzzle2:
    ;Only look at 4th row (since button for reset is there)
    ldi r20, $0E
    out PORTB, r20

    call inputDelay

    in r18, PIND
    ori r18, $1F
    cpi r18, $FF
    brne checkForKey_Puzzle2

checkForKey_Puzzle2:
    SBIS PIND, 5
    jmp Puzzle2Reset ; The user pressed the Hashtag, which is the reset button
    rjmp buttonHold

Puzzle2Reset:
    SBIS PIND, 5 ; Stay here until the button for reset is released (we want reset to finish after button is released)
    rjmp Puzzle2Reset

    cbi PORTD, 0 ;Clear the LEDs that show puzzle status
    cbi PORTD, 1
    ldi r16, 100 ;Put the servo back to original position (even though it should already be there)
    sts OCR2B, r16
    jmp Prog_Start

Puzzle2Setup:
    ldi r16, $00 ; Sets V_ref, sets correct PORTC:0 to be analog input for ADC (MUX:0-3 set low, found from Datasheet)
    sts ADMUX, r16
    ldi r16, $C0
    sts ADCSRA, r16 ; Set ADC Enable and ADC Start Conversion. Set division factor for ADC to minimum
    ldi r20, $00 ;Load in comparison values (i.e. below what temperature we want the puzzle to finish)
    ldi r21, $71
    ret


;;; HERE IS WHERE PUZZLE 3 CODE STARTS ;;;
;;; HERE IS WHERE PUZZLE 3 CODE STARTS ;;;
;;; HERE IS WHERE PUZZLE 3 CODE STARTS ;;;

BinarySumPuzzle3:
    out PORTC, r22 ; Turn on LEDs that match binary number taken from temp at start of puzzle
    ldi r19, 0 ; set counter to 0
    ldi r17, 0 ; set sum to zero

Puzzle3Loop:
    ;This code is checking for if a button has been pushed
    ldi r21, $00
    out PORTB, r21

    call inputDelay

    in r18, PIND
    ori r18, $1F
    cpi r18, $FF
    brne keyPressed_Puz3

    rjmp Puzzle3Loop

keyPressed_Puz3:
    call findKey_Puz3 ;Find the key that was pressed

    call inputDelay

    inc r19 ; Increment our counter

    cpi r19, $02 ; Check if we have 2 inputs
    brsh checkSum_Puz3

    rjmp Puzzle3Loop

checkSum_Puz3:
    cp r23, r17 ; Check if the sum of our input matches the binary number
    brne incorrectSum_Puz3

    ;Binary number input correctly from sum of inputs
    sbi PORTD, 2 ; Turn on LED for third Puzzle

    ret

incorrectSum_Puz3:
    ldi r17, $00 ; Reset Sum
    ldi r19, $00 ; Reset Counter

    rjmp Puzzle3Loop

findKey_Puz3:
    ;Checking first Row
    ldi r20, $07 
    out PORTB, r20

    call inputDelay

    in r18, PIND
    ori r18, $1F
    cpi r18, $FF
    brne row1Key_Puz3

    ;Checking Second Row
    ldi r20, $0B
    out PORTB, r20

    call inputDelay

    in r18, PIND
    ori r18, $1F
    cpi r18, $FF
    brne row2Key_Puz3

    ;Checking Third Row
    ldi r20, $0D
    out PORTB, r20


    call inputDelay

    in r18, PIND
    ori r18, $1F
    cpi r18, $FF
    brne row3Key_Puz3

    ;Checking Fourth Row
    ldi r20, $0E
    out PORTB, r20

    call inputDelay

    in r18, PIND
    ori r18, $1F
    cpi r18, $FF
    brne row4Key_Puz3

    ret ; Should never reach here, but do nothing if we do

row1Key_Puz3:
    ;This code is checking for which button in this row is pushed and add the corresponding value for that button
    SBIS PIND, 7 
    subi r17, -1 
    SBIS PIND, 6
    subi r17, -2
    SBIS PIND, 5
    subi r17, -3


    rjmp buttonHold_Puz3

row2Key_Puz3:
    ;This code is checking for which button in this row is pushed and add the corresponding value for that button
    SBIS PIND, 7
    subi r17, -4
    SBIS PIND, 6
    subi r17, -5
    SBIS PIND, 5
    subi r17, -6

    rjmp buttonHold_Puz3

row3Key_Puz3:
    ;This code is checking for which button in this row is pushed and add the corresponding value for that button
    SBIS PIND, 7
    subi r17, -7
    SBIS PIND, 6
    subi r17, -8
    SBIS PIND, 5
    subi r17, -9

    rjmp buttonHold_Puz3

row4Key_Puz3:
    ;This code is checking for which button in this row is pushed and add the corresponding value for that button
    SBIS PIND, 7 ; They pushed a key that doesn't do anything, set a key so program knows
    ldi r16, '*'
    SBIS PIND, 6
    subi r17, 0
    SBIS PIND, 5
    jmp Puzzle3Reset ; The user pressed the Hashtag, which is the reset button

    rjmp buttonHold_Puz3

Puzzle3Reset:
    SBIS PIND, 5 ; Stay here until the button for reset is released (we want reset to finish after button is released)
    rjmp Puzzle3Reset

    cbi PORTD, 0 ;Clear the LEDs that show puzzle status
    cbi PORTD, 1
    cbi PORTD, 2
    ldi r16, 100 ;Put the servo back to original position (even though it should already be there)
    sts OCR2B, r16
    jmp Prog_Start


buttonHold_Puz3:
    SBIS PIND, 7
    rjmp buttonHold_Puz3
    SBIS PIND, 6
    rjmp buttonHold_Puz3
    SBIS PIND, 5
    rjmp buttonHold_Puz3

    ret



;;; HERE IS WHERE SERVO CODE/OPENING BOX CODE STARTS ;;;
;;; HERE IS WHERE SERVO CODE/OPENING BOX CODE STARTS ;;;
;;; HERE IS WHERE SERVO CODE/OPENING BOX CODE STARTS ;;;
ServoLoop:
    call inputDelay ;Waiting until the user pushes the button to open the box
    SBIS PINC, 1
    rjmp openBox
    rjmp ServoLoop

openBox:
    ldi r16, 221 ;Sets the comparison value for position that opens the box
    sts OCR2B, r16
    rjmp waitForReset

waitForReset:
    ;Waiting to see if a button is pushed
    ldi r20, $00
    out PORTB, r20

    call inputDelay

    in r18, PIND
    ori r18, $1F
    cpi r18, $FF
    brne checkForReset_End

    rjmp waitForReset

checkForReset_End:
    ;Only look at 4th row (since button for reset is there)
    ldi r20, $0E
    out PORTB, r20

    call inputDelay

    in r18, PIND
    ori r18, $1F
    cpi r18, $FF
    brne checkForKey_End

checkForKey_End:
    SBIS PIND, 5 ;Check if the user pushed the button for reset
    jmp EndReset ; The user pressed the Hashtag, which is the reset button
    rjmp buttonHold

EndReset:
    SBIS PIND, 5 ; Stay here until the button for reset is released (we want reset to finish after button is released)
    rjmp EndReset

    cbi PORTD, 0 ;Clear the status LEDs
    cbi PORTD, 1
    cbi PORTD, 2
    ldi r16, 100 ;Putting the servo back into its original position
    sts OCR2B, r16
    jmp Prog_Start

;;; HERE IS WHERE GLOBAL CODE/CODE NOT DIRECTLY USED FOR PUZZLE IS STORED ;;;
;;; HERE IS WHERE GLOBAL CODE/CODE NOT DIRECTLY USED FOR PUZZLE IS STORED ;;;
;;; HERE IS WHERE GLOBAL CODE/CODE NOT DIRECTLY USED FOR PUZZLE IS STORED ;;;

PWM_Start:
    ldi r16, $33 ; Set COM2B1 (Fast PWM inverting), WGM20:21 (Sets it to fast PWM)
    sts TCCR2A, r16
    ldi r16, $06 ; Set Scaler for clock
    sts TCCR2B, r16
    ldi r16, 100 ;Setting comparison value for closed position (since that is where we want the servo to start)
    sts OCR2B, r16
    ret

randomizeValue:
    lds r22, ADCL ;Pull in the current temperature at time of program Starting
    lds r23, ADCH

    ;Do a bunch of random commands to somewhat generate a random value from the temperature
    com r22
    subi r22, -4
    lsl r22
    lsl r22
    subi r22, 3
    com r22

    ;This is generating the decimal value for the binary number that we generated from the temperature
    ldi r23, $00 ; Actual value of binary number for value held in r23
    SBRC r22, 2
    subi r23, -1
    SBRC r22, 3
    subi r23, -2
    SBRC r22, 4
    subi r23, -4
    SBRC r22, 5
    subi r23, -8
    
    sbr r22, 1 ; Make sure pull up resistor set for button

    ret

;The following code is just to put space between commands throughout the code. Prevents errors from happening that otherwise
;would without this chunk of code. It essentially has the computer count to 1000 before continuing with the code.
inputDelay:
    push r16
    push r17
    ldi r17, $00

inputDelayOuterLoop:
    ldi r16, $00
    inc r17

inputDelayInnerLoop:
    inc r16
    cpi r16, $64
    brne inputDelayInnerLoop

    cpi r17, $0A
    brne inputDelayOuterLoop 

    pop r17
    pop r16
    ret

    
