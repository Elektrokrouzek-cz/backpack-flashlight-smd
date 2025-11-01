
start:
	ldi r16,low(RAMEND)			// Init stack pointer
	out SPL,r16
power_on_wait_button:
	ldi r16, 5					// Wait 50ms
	rcall sleep_10ms
	in r16, PINB
	andi r16, 0x02				// Check if button is still pressed
	breq power_on_wait_button
	inc r17						// Increment counter
	cpi r17, 40					// Holding button for 2 seconds?
	brge power_on				// Yes -> turn on
	rjmp power_on_wait_button
power_on:
	ldi r16, 0x05				// Init PORTB (outputs)
	out DDRB, r16
	ldi r16, 0x01				// Power on (turn on transistor)
	out PORTB, r16
	ldi r16, 0x8f				// Init PORTA (outputs)
	out DDRA, r16
	ldi r16, 0x0
	out PORTA, r16

	ldi r17, 0					// Selected program
	ldi r18, 0					// LED content
	ldi r19, 0					// Program step
	ldi r20, 0					// Button hold counter
	ldi r21, 0					// Wait for button release
loop:
	in r16, PINB
	andi r16, 0x02				// Check if button is pressed
	brne loop_inc_button		
	clr r20						// Button not pressed - reset timers
	clr r21
	rjmp loop_skip_button
loop_inc_button:
	inc r20						// Button pressed - increment hold timer
	cpi r20, 40					// Check if it is held for 2 seconds
	brlo loop_check_prog_change // No -> check for program change
	rjmp power_off				// Turn off
loop_check_prog_change:
	cpi r20, 2					// Check if held for 100ms
	brlo loop_skip_button		// No -> skip
	cpi r21, 1					// Wait for button release
	breq loop_skip_button		// Button not released -> skip
	ldi r21, 1					// Set "wait for button release" flag
	inc r17						// Increment program
	cpi r17, 6					// Check maximal program count
	brne loop_skip_button
	clr r17						// Set program 0

loop_skip_button:
	cpi r17, 0					// Program 0?
	brne loop_1
	rcall prog_1
loop_1:
	cpi r17, 1					// Program 1?
	brne loop_2
	rcall prog_2
loop_2:
	cpi r17, 2					// Program 2?
	brne loop_3
	rcall prog_3
loop_3:
	cpi r17, 3					// Program 3?
	brne loop_4
	rcall prog_4
loop_4:
	cpi r17, 4					// Program 4?
	brne loop_5
	rcall prog_5
loop_5:
	cpi r17, 5					// Program 5?
	brne loop_6
	rcall prog_6
loop_6:
	mov r16, r18				// Show LEDs
	rcall show
	ldi r16, 5					// Wait 50ms
	rcall sleep_10ms
	rjmp loop					// And again!

power_off:
	ldi r16, 0x21				// Display turn off LED sequence
	rcall show
	ldi r16, 50
	rcall sleep_10ms
	ldi r16, 0x12
	rcall show
	ldi r16, 50
	rcall sleep_10ms
	ldi r16, 0x0c
	rcall show
	ldi r16, 50
	rcall sleep_10ms
	ldi r16, 0x0
	rcall show
	ldi r16, 50
	rcall sleep_10ms
	clr r17
power_off_wait_button:
	ldi r16, 5					// Wait 50ms
	rcall sleep_10ms
	in r16, PINB
	andi r16, 0x02				// Check button release
	brne power_off_wait_button_reset // No -> reset counter
	inc r17
	cpi r17, 4					// Button must be released for 40ms
	brlo power_off_wait_button
power_off_loop:
	ldi r16, 0					// Turn off
	out PORTB, r16
	rjmp power_off_loop
power_off_wait_button_reset:
	clr r17						// Reset counter
	rjmp power_off_wait_button  // And wait again

// Program 1 - blink all LEDs
prog_1:
	cpi r19, 0
	brne prog_1_1
	ldi r18, 0
	rjmp prog_1_inc
prog_1_1:
	cpi r19, 5
	brne prog_1_2
	ldi r18, 0x3f
	rjmp prog_1_inc
prog_1_2:
prog_1_inc:
	inc r19
	cpi r19, 7
	brlo prog_1_end
	clr r19
prog_1_end:
	ret

// Program 2 - blink left, blink right
prog_2:
	cpi r19, 0
	brne prog_2_1
	ldi r18, 0
	rjmp prog_2_inc
prog_2_1:
	cpi r19, 3
	brne prog_2_2
	ldi r18, 0x07
	rjmp prog_2_inc
prog_2_2:
	cpi r19, 4
	brne prog_2_3
	ldi r18, 0
	rjmp prog_2_inc
prog_2_3:
	cpi r19, 5
	brne prog_2_4
	ldi r18, 0x07
	rjmp prog_2_inc
prog_2_4:
	cpi r19, 6
	brne prog_2_5
	ldi r18, 0
	rjmp prog_2_inc
prog_2_5:
	cpi r19, 9
	brne prog_2_6
	ldi r18, 0x38
	rjmp prog_2_inc
prog_2_6:
	cpi r19, 10
	brne prog_2_7
	ldi r18, 0
	rjmp prog_2_inc
prog_2_7:
	cpi r19, 11
	brne prog_2_8
	ldi r18, 0x38
	rjmp prog_2_inc
prog_2_8:
prog_2_inc:
	inc r19
	cpi r19, 12
	brlo prog_2_end
	clr r19
prog_2_end:
	ret

// Program 3 - knight rider
prog_3:
	mov r16, r19
	cpi r19, 6
	brge prog_3_1
	ldi r18, 1
prog_3_lsl:
	cpi r16, 0
	breq prog_3_inc
	lsl r18
	dec r16
	rjmp prog_3_lsl
prog_3_1:
	ldi r18, 0x20
	subi r16, 6
prog_3_lsr:
	cpi r16, 0
	breq prog_3_inc
	lsr r18
	dec r16
	rjmp prog_3_lsr
prog_3_2:
prog_3_inc:
	inc r19
	cpi r19, 12
	brlo prog_3_end
	clr r19
prog_3_end:
	ret

// Program 4 - blink center, blink outer
prog_4:
	cpi r19, 0
	brne prog_4_1
	ldi r18, 0
	rjmp prog_4_inc
prog_4_1:
	cpi r19, 3
	brne prog_4_2
	ldi r18, 0x0c
	rjmp prog_4_inc
prog_4_2:
	cpi r19, 4
	brne prog_4_3
	ldi r18, 0
	rjmp prog_4_inc
prog_4_3:
	cpi r19, 5
	brne prog_4_4
	ldi r18, 0x0c
	rjmp prog_4_inc
prog_4_4:
	cpi r19, 6
	brne prog_4_5
	ldi r18, 0
	rjmp prog_4_inc
prog_4_5:
	cpi r19, 9
	brne prog_4_6
	ldi r18, 0x33
	rjmp prog_4_inc
prog_4_6:
	cpi r19, 10
	brne prog_4_7
	ldi r18, 0
	rjmp prog_4_inc
prog_4_7:
	cpi r19, 11
	brne prog_4_8
	ldi r18, 0x33
	rjmp prog_4_inc
prog_4_8:
prog_4_inc:
	inc r19
	cpi r19, 12
	brlo prog_4_end
	clr r19
prog_4_end:
	ret

// Program 5 - blink left, center, right
prog_5:
	cpi r19, 0
	brne prog_5_1
	ldi r18, 0
	rjmp prog_5_inc
prog_5_1:
	cpi r19, 5
	brne prog_5_2
	ldi r18, 0x30
	rjmp prog_5_inc
prog_5_2:
	cpi r19, 7
	brne prog_5_3
	ldi r18, 0x00
	rjmp prog_5_inc
prog_5_3:
	cpi r19, 12
	brne prog_5_4
	ldi r18, 0x0c
	rjmp prog_5_inc
prog_5_4:
	cpi r19, 14
	brne prog_5_5
	ldi r18, 0x00
	rjmp prog_5_inc
prog_5_5:
	cpi r19, 19
	brne prog_5_6
	ldi r18, 0x03
	rjmp prog_5_inc
prog_5_6:
	cpi r19, 21
	brne prog_5_7
	ldi r18, 0x00
	rjmp prog_5_inc
prog_5_7:
	cpi r19, 26
	brne prog_5_8
	ldi r18, 0x0c
	rjmp prog_5_inc
prog_5_8:
prog_5_inc:
	inc r19
	cpi r19, 28
	brlo prog_5_end
	clr r19
prog_5_end:
	ret

// Program 6 - knight rider symetrical
prog_6:
	cpi r19, 0
	brne prog_6_1
	ldi r18, 0x21
	rjmp prog_6_inc
prog_6_1:
	cpi r19, 1
	brne prog_6_2
	ldi r18, 0x12
	rjmp prog_6_inc
prog_6_2:
	cpi r19, 2
	brne prog_6_3
	ldi r18, 0x0c
	rjmp prog_6_inc
prog_6_3:
	cpi r19, 3
	brne prog_6_4
	ldi r18, 0x12
	rjmp prog_6_inc
prog_6_4:
	cpi r19, 4
	brne prog_6_5
	ldi r18, 0x21
	rjmp prog_6_inc
prog_6_5:
prog_6_inc:
	inc r19
	cpi r19, 5
	brlo prog_6_end
	clr r19
prog_6_end:
	ret

// Show LED content (r16 as input, bits 0 to 5)
show:
	cbi PORTA, 0
	cbi PORTA, 1
	cbi PORTA, 2
	cbi PORTA, 3
	cbi PORTA, 7
	cbi PORTB, 2
	sbrc r16, 0
	sbi PORTA, 0
	sbrc r16, 1
	sbi PORTA, 1
	sbrc r16, 2
	sbi PORTA, 2
	sbrc r16, 2
	sbi PORTA, 2
	sbrc r16, 3
	sbi PORTA, 3
	sbrc r16, 4
	sbi PORTA, 7
	sbrc r16, 5
	sbi PORTB, 2
	ret

sleep_10ms:					// Wait N x 10ms (r16 is input - N)
	push r16
	push r17
	push r18
	clr r17
	ldi r18, 12
sleep_loop:
	dec r17
	brne sleep_loop
	dec r18
	brne sleep_loop
	ldi r18, 12
	dec r16
	brne sleep_loop
	pop r18
	pop r17
	pop r16
	ret
