*accumulator A increments lights
*accumulator B is short delay
*accumulator Y is long delay
*X points to the stack

lights  EQU     $1404
switch  EQU     $1403
toc2    EQU     $1018
toc3	EQU	$101A
tcnt    EQU     $100E
tflg1   EQU     $1023
tmsk1	EQU	$1022
shortdelay   EQU  #100
longdelay   EQU  #5
interuptdelay   EQU     #20000

		ORG             $0000
		
flashflag       RMB             1
*interrupt jump table*
		ORG		$00D9
		JMP		interrupt  ;causes interrupt when OC3 is triggered
		
		ORG             $D000
*program starts here***
		ORG             $D000
		LDS             #$DFFF
		LDAB            #shortdelay
		LDY             #longdelay
		LDAA            #$20
		staa            tmsk1 ;start interrupts in OC3
		LDD             tcnt
		ADDD            #interuptdelay
		STD             toc3
		LDAA            #$00
		STAA            flashflag
		CLI
		
		
***main program, increments lights once per second**
loop            TST             flashflag
		BNE             allflash
back		STAA            lights
		BRA             loop
		
***flash all lights***
allflash        PSHA
		PSHB
		LDAB    #50
again		LDAA    #$00
		STAA    lights
		BSR     delay
		LDAA    #$FF
		STAA    lights
		BSR     delay
		DECB
		BNE     again
		LDAA    #$00
		STAA    flashflag
  		PULB
  		PULA
  		JMP     back
***delay program***
delay           PSHA
		PSHB
		LDD     tcnt
		STD     toc2
		PSHX
		LDAA     #$40
		STAA    tflg1
		LDX     #tflg1
wait            BRCLR   0,X $40 wait  ;wait until timer flag is set

		PULX
		PULB
		PULA
		RTS


		
		
interrupt       LDD             tcnt
		ADDD            #interuptdelay
		STD             toc3 ;reset interupt counter
		TSX             ;transfer stack ponter to X so variables can be changed in the stack
		LDAA            2,X
		LDAB            1,X
		LDY             5,X ;load accumulators back from stack
		DECB
		BNE             noincrement    ;dont increment lights if not 1 second
		INCA
		LDAB            #shortdelay
    		DEY
		BNE             noincrement   ;not 5 seconds, please wait longer
  		PSHA
  		LDAA            #$01
  		STAA            flashflag
  		PULA
		LDY             #longdelay
noincrement 		STAA    2,X
		STAB    1,X
		STY     5,X
		LDAA    #$20
		STAA    tflg1
		CLI
		RTI


