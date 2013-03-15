;author : gedex
;date   : June 21, 2007
$MOD52	
;----------------------------------------
; var keypad				|
;----------------------------------------
	b4	bit	p2.7
	b3	bit	p2.6
	b2	bit	p2.5
	b1	bit	p2.4
	k1	bit	p2.0
	k2	bit	p2.1
	k3	bit	p2.2

;----------------------------------------
; var LCD				|
;----------------------------------------
	EN      bit	P3.2
	RS      bit	P3.0
	RW      bit	P3.1
	DAT    	EQU	P3

;----------------------------------------
; var LED & Buzzer			|
;----------------------------------------
	led1	bit	p0.0	;aktif low
	led2	bit	p0.1
	buzzer	bit	p0.3

;----------------------------------------
; var RTC & EEPROM			|
;----------------------------------------
; P1.0 : SCLK				|
; P1.1 : I/O				|
; P1.3 : RST				|
;----------------------------------------
	SEC		EQU	00H
	MIN		EQU	02H
	HR		EQU	04H
	DATE		EQU	06H
	MONTH		EQU	08H
	DAY		EQU	0AH
	YEAR		EQU	0CH
	CTR		EQU	0EH		;control register
	TCR		EQU	10H		;trickle charge register

	Flag		DATA	0020H
	Fail		BIT	Flag.0

	AFlag	BIT	21H.1	;flag alarm
	AFlagBuzz bit	21H.2	;flag alarm buzzer
	AFlagLed  bit	21H.3	;flag alarm Led
	alarmBuzz equ	22H	;22,23,24
	alarmLed  equ	25H	;25,26,27
	alarm??	 equ	28H	;28,29,30
	Temp2	equ	31H

	

CSEG
	org	0h
	jmp	mulai

	org	1bH
	jmp	timer1

DSEG
	org	32h	
	RTCBuffer:	
	DS	8			;Buffer untuk RTC data

	Alarm:		
	DS	3			;3 alarm

	Prescaler:	
	DS	1			;Pembagi timer

	Temp:		
	DS	1

	puluhan:			;utk stopwatch
	DS	1

	
	satuan:			;utk stopwatch
	DS	1

CSEG
	org	100h
;----------------------------------------
; timer1 int				|
;----------------------------------------
timer1:
	push	Acc
	djnz	Prescaler,ExitTimer1
	mov	Prescaler,#2

	call	displaySW
	cjne	r7,#100,upMsec
	;msec	ov
	mov	r7,#0
	cjne	r6,#60,upSec
	;sec	ov
	mov	r6,#0
	cjne	r5,#100,upMen
	mov	r5,#0
	sjmp	ExitTimer1
upMen:
	inc	r5
	sjmp	ExitTimer1
upSec:
	inc	r6
	sjmp	ExitTimer1
upMsec:
	inc	r7
	
ExitTimer1:
	
	mov	TH1,#0FEH
	mov	TL1,#00H
	pop	Acc
	reti

;----------------------------------------
;displaySW				|
;----------------------------------------
displaySW:
	call	cursorOff
	call	baris2

	mov	A,r5
	call	dec2hex
	mov	A,#':'
	call	tulisData

	mov	A,r6
	call	dec2hex
	mov	A,#':'
	call	tulisData

	mov	A,r7
	call	dec2hex
ret

;----------------------------------------
;dec2hex for displaySW, utk 0-99	|
;----------------------------------------
dec2hex:
	mov	B,#10
	div	AB
	add	A,#30h
	call	tulisData
	mov	A,B
	add	A,#30h
	call	tulisData
ret



;----------------------------------------
; rst ser. eeprom & rtc			|
;----------------------------------------
RESET:		
	clr	p1.0		;sk=0
	setb	P1.3		;CS=1
	clr	P1.3		;CS=0
	ret
	
;----------------------------------------
; SERIAL EEPROM 93C66 ROUTINE		|
;----------------------------------------
;----------------------------------------
;'WRITE BIT TO SERIAL EEPROM		|
;'IN : A=DATA TO WRITE			|
;----------------------------------------
WRSEREE:	
	push	ACC
	push	07H
	mov	R7,#8
NxtWRBit:	
	rlc	A
	jc	WRBitH
WRBitL:		
	clr	P1.1
	ajmp	WRClk
WRBitH:		
	setb	P1.1
WRClk:		
	clr	P1.0
	setb	P1.0
	djnz	R7,NxtWRBit
	pop	07H
	pop	ACC
	ret

;----------------------------------------
;'READ BIT FROM SERIAL EEPROM		|
;'OUT : A=READ DATA			|
;----------------------------------------
RDSEREE:	
	push	07H
	clr	A
	mov	R7,#8
	setb	P1.1
RDClk:		
	clr	P1.0
	setb	P1.0
	jb	P1.1,RDBitH
RDBitL:		
	clr	C
	ajmp	ShiftInBit
RDBitH:		
	setb	C
ShiftInBit:	
	rlc	A
	djnz	R7,RDClk
	pop	07H
	ret
;----------------------------------------
;CHECK READY\BUSY SERIAL EEPROM		|
;----------------------------------------
CHKCONSEREE:	
	push	07H
	push	06H
	push	05H
	mov	R5,#2
	mov	R7,#0FFH
	mov	R6,#0FFH
	clr	Fail
	setb	P1.1
StrbCS:		
	clr	P1.3			;CS=0	
	setb	P1.3			;CS=1
W4Con:		
	clr	P1.0
	setb	P1.0
	jb	P1.1,WaitTimer1
	mov	R5,#2
	ajmp	Busy
WaitTimer1:	
	djnz	R7,W4Con
	mov	R7,#0FFH
	djnz	R5,W4Con
	setb	Fail
	ajmp	Ready
Busy:		
	clr	P1.0
	setb	P1.0
	jnb	P1.1,WaitTimer2
	ajmp	Ready
WaitTimer2:	
	djnz	R6,Busy	
	mov	R6,#0FFH
	djnz	R5,Busy
	setb	Fail
Ready:		
	pop	05H
	pop	06H
	pop	07H
	ret
;----------------------------------------
;'READ DATA FROM SERIAL EEPROM		|
;'IN : DPTR = ADDRESS			|
;'OUT : A = READ DATA			|
;----------------------------------------
READEE:		
	push	07H
	push	06H
	mov	R6,#2
	mov	R7,#0FFH
	clr	Fail
	setb	P1.3			;CS=1
	mov	A,DPH
	anl	A,#01H
	orl	A,#00001100B		;Bit3=SB Bit2,1=OPCODE
	call	WRSEREE			;      1    1 0
	mov	A,DPL
	call	WRSEREE
	setb	P1.1
Dummy:		
	jb	P1.1,WaitTimer3
	ajmp	DataReady
WaitTimer3:	
	djnz	R7,Dummy	
	mov	R7,#0FFH
	djnz	R6,Dummy
	setb	Fail
	ajmp	EOREADEE
DataReady:	
	acall	RDSEREE
EOREADEE:	
	clr	P1.3			;CS=0
	pop	06H
	pop	07H
	ret
;---------------------------------------
;ERASE AND WRITE TO SERIAL EEPROM ENABLE|	
;---------------------------------------
EWEN:		
	push	ACC
	setb	P1.3			;CS=1				
	mov	A,#00001001B		;Bit 3=SB Bit2,1,0=OPCODE
	call	WRSEREE			;       1    0 0 1 
	mov	A,#10000000B		;Bit7=OPCODE
	call	WRSEREE			;   1  
	clr	P1.3			;CS=0
	pop	ACC
	ret
;----------------------------------------
;ERASE AND WRITE TO SERIAL EEPROM DISABLE|
;----------------------------------------
EWDS:		
	push	ACC
	setb	P1.3			;CS=1				
	mov	A,#00001000B		;Bit 3=SB Bit2,1,0=OPCODE
	acall	WRSEREE			;       1    0 0 0 
	mov	A,#00000000B		;Bit7=OPCODE
	acall	WRSEREE			;   0  
	clr	P1.3			;CS=0
	pop	ACC
	ret
;----------------------------------------
;'WRITE DATA TO SERIAL EEPROM		|
;'IN : DPTR = ADDRESS			|
; '    A = DATA TO WRITE		|
;----------------------------------------	
WRITEEE:	
	push	ACC
	setb	P1.3			;CS=1
	mov	A,DPH
	anl	A,#01H
	orl	A,#00001010B		;Bit3=SB Bit2,1=OPCODE
	acall	WRSEREE			;      1    0 1
	mov	A,DPL
	acall	WRSEREE
	pop	ACC
	acall	WRSEREE
	acall	CHKCONSEREE
	clr	P1.3			;CS=0	
	ret
;----------------------------------------
;'WRITE DATA AT ALL SERIAL EEPROM	|
;'IN : A=DATA TO WRITE			|
;----------------------------------------
WRAL:		
	push	ACC
	setb	P1.3			;CS=1
	mov	A,#00001000B		;Bit3=SB Bit2,1,0=OPCODE
	acall	WRSEREE			;      1    0 0 0
	mov	A,#10000000B		;Bit7=OPCODE
	acall	WRSEREE			;   1
	pop	ACC
	acall	WRSEREE
	acall	CHKCONSEREE 
	clr	P1.3			;CS=0
	ret
;----------------------------------------
;'erase data at serial eeprom		|	
;'in : dptr=address to erased		|
;----------------------------------------
ERASEEE:	
	push	ACC
	setb	P1.3			;CS=1
	mov	A,DPH
	anl	A,#01H
	orl	A,#00001110B		;Bit3=SB Bit2,1=OPCODE
	acall	WRSEREE			;      1    1 1
	mov	A,DPL
	acall	WRSEREE
	acall	CHKCONSEREE
	clr	P1.3			;CS=0
	pop	ACC
	ret
;----------------------------------------
;erase all data at serial eeprom	|	
;----------------------------------------
ERAL:		
	push	ACC
	setb	P1.3			;CS=1
	mov	A,#00001001B		;Bit3=SB Bit2,1,0=OPCODE
	acall	WRSEREE			;      1    0 0 1
	mov	A,#00000000B		;Bit7=OPCODE
	acall	WRSEREE			;   0
	acall	CHKCONSEREE 
	clr	P1.3			;CS=0		
	pop	ACC
	ret
;----------------------------------------
;	RTC DS1302 ROUTINE		|
;					|
;----------------------------------------
;'WRITE BIT TO RTC			|
;'IN : A = DATA/ADDRESS TO BE WRITE	|
;----------------------------------------
WRBITRTC:	
	push	07H
	mov	R7,#8
ShfOutBit:	
	rrc	A
	jnc	WrBitLow
WrBitHigh:	
	setb	P1.1
	ajmp	ClkIn
WrBitLow:	
	clr	P1.1
ClkIn:		
	clr	P1.0
	setb	P1.0
	djnz	R7,ShfOutBit
	rrc	A
	pop	07H
	ret
;----------------------------------------
;'READ BIT FROM RTC			|
;'OUT : A = READ DATA			|
;----------------------------------------
RDBITRTC:	
	push	07H
	clr	A			;Init ACC to zero
	setb	P1.1			;P1.1 set as input
	mov	R7,#8
ClkOut:		
	setb	P1.0
	clr	P1.0
	jnb	P1.1,RdBitLow
RdBitHigh:	
	setb	C
	ajmp	ShfInBit
RdBitLow:	
	clr	C
ShfInBit:	
	rrc	A
	djnz	R7,ClkOut
	pop	07H
	ret 
;----------------------------------------
;'WRITE BYTE TO CLOCK REGISTER		|
;'IN : B = REGISTER ADDRESS		|
;'     A = DATA TO WRITE		|
;----------------------------------------
BYTEWRCLKREG:	
	push	ACC
	push	B
	acall	RESET
	xch	A,B			;A=Address
	orl	A,#80H			;Bit7=1
	anl	A,#0FEH			;Bit0=0=WR
	acall	WRBITRTC		;Write address
	xch	A,B			;A=Data
	acall	WRBITRTC		;Write Data
	acall	RESET
	pop	B
	pop	ACC
	ret		
;----------------------------------------
;'READ BYTE FROM CLOCK REGISTER		|
;'IN  : B = Register Address		|
;'OUT : A = Data read			|
;----------------------------------------
BYTERDCLKREG:	
	push	B
	acall	RESET
	xch	A,B			;A=Address
	orl	A,#81H			;Bit7,Bit0=1
	acall	WRBITRTC		;Write Address
	acall	RDBITRTC		;A=Read Data
	acall	RESET
	pop	B
	ret
;----------------------------------------
;WRITE DISABLE ROUTINE			|
;----------------------------------------
WRDIS:		
	push	ACC
	push	B
	mov	A,#80H
	mov	B,#CTR
	acall	BYTEWRCLKREG
	pop	B
	pop	ACC
	ret
;----------------------------------------
;WRITE ENABLE ROUTINE			|
;----------------------------------------
WRENB:		
	push	ACC
	push	B
	mov	A,#00H
	mov	B,#CTR
	acall	BYTEWRCLKREG
	pop	B
	pop	ACC
	ret
;----------------------------------------
;RUN CLOCK ROUTINE			|
;----------------------------------------
RUNCLK:		
	push	ACC
	push	B
	mov	B,#SEC
	acall	BYTERDCLKREG
	anl	A,#7FH			;0XXXXXXXB
	acall	BYTEWRCLKREG
	pop	B
	pop	ACC
	ret		
;----------------------------------------
;STOP CLOCK ROUTINE			|
;----------------------------------------
STOPCLK:	
	push	ACC
	push	B
	mov	B,#SEC
	acall	BYTERDCLKREG
	orl	A,#80H			;1XXXXXXXB
	acall	BYTEWRCLKREG
	pop	B
	pop	ACC
	ret		
;----------------------------------------
;'WRITE BYTE TO RAM REGISTER		|
;'IN : B = RAM ADDRESS			|
;'     A = DATA TO WRITE		|
;----------------------------------------
BYTEWRRAM:	
	push	ACC
	push	B
	acall	RESET
	xch	A,B			;A=Address
	orl	A,#0C0H			;Bit7,Bit6=1
	anl	A,#0FEH			;Bit0=0=WR
	acall	WRBITRTC		;Write address
	xch	A,B			;A=Data
	acall	WRBITRTC		;Write Data
	acall	RESET
	pop	B
	pop	ACC
	ret		
;----------------------------------------
;'READ BYTE FROM RAM			|
;'IN  : B = RAM Address			|	
;'OUT : A = Data read			|
;----------------------------------------
BYTERDRAM:	
	push	B
	acall	RESET
	xch	A,B			;A=Address
	orl	A,#0C1H			;Bit7,Bit6,Bit0=1
	acall	WRBITRTC		;Write adrress
	acall	RDBITRTC		;A=Data read
	acall	RESET
	pop	B
	ret
;-------------------------------------------
;'WRITE BURST TO CLOCK REGISTER		   |	
;'IN : R0 = Point to first buffer addr     |
;'Remark : - Prepare 8 clock register data |
;'	    start @ addr point by R0	   |	
;'	  - Write start @bit 0 address 0   |	
;-------------------------------------------
BURSTWRCLKREG:	
	push	ACC
	push	00H
	push	07H
	acall	RESET
	mov	A,#0BEH			;Clock Burst Reg. (WR)
	acall	WRBITRTC
	mov	R7,#8
NxtByteWR:	
	mov	A,@R0
	acall	WRBITRTC
	inc	R0
	djnz	R7,NxtByteWR	
	acall	RESET
	pop	07H
	pop	00H
	pop	ACC
	ret	
;----------------------------------------
;'READ BURST TO CLOCK REGISTER		|
;'IN : R0 Point to first buffer addr	|
;'OUT : 8 clock register data		|
;'      start @ addr point by R0	|	
;'REMARK : Read start @bit 0 address 0	|			
;----------------------------------------
BURSTRDCLKREG:	
	push	ACC
	push	00H
	push	07H
	acall	RESET
	mov	A,#0BFH			;Clock Burst Reg. (RD)
	acall	WRBITRTC
	mov	R7,#8
NxtByteRD:	
	acall	RDBITRTC
	mov	@R0,A
	inc	R0
	djnz	R7,NxtByteRD
	acall	RESET
	pop	07H
	pop	00H
	pop	ACC
	ret
;----------------------------------------
;'WRITE BURST TO RAM			|
;'IN : R0 = point to first buffer addr	|
;'     R7 = N data to be write		|	
;'Remark : - Prepare N RAM data		|
;'	    start @ addr point by R0	|
;'	  - Write start @bit 0 address 0|  	
;-'---------------------------------------
BURSTWRRAM:	
	push	ACC
	push	00H
	push	07H
	acall	RESET
	mov	A,#0FEH			;RAM Burst Reg. (WR)
	acall	WRBITRTC
NxtRAMWR:	
	mov	A,@R0
	acall	WRBITRTC
	inc	R0
	djnz	R7,NxtRAMWR
	acall	RESET
	pop	07H
	pop	00H
	pop	ACC
	ret
;-------------------------------------------
;'READ BURST FROM RAM			   | 
;'IN : R0 = Point to first buffer addr	   |	
;'     R7 = N data to be read		   |
;'OUT : N RAM data start @ addr point by R0|
;'REMARK : Read start @bit 0 address 0     |	
;-------------------------------------------
BURSTRDRAM:	
	push	ACC
	push	00H
	PUSH	07H
	acall	RESET
	mov	A,#0FFH			;RAM Burst Reg. (RD)
	acall	WRBITRTC
NxtRAMRD:	
	acall	RDBITRTC
	mov	@R0,A
	inc	R0
	djnz	R7,NxtRAMRD
	acall	RESET
	pop	07H
	pop	00H
	pop	ACC
	ret

;----------------------------------------
; Data awal RTC				|
;----------------------------------------
Now:		
	inc	A
	movc	A,@A+PC
	ret    

	db	00H,45H,16H		;16:45:00
		;S  ,M  ,H	
	db	07H,06H,20H,01H		;20-06-07 
		;D  ,M  ,Day,Y
	db	00H
		;Control word	
	
;----------------------------------------
; Hex to ASCII				|
;----------------------------------------
Hex2Asc:	
	push	ACC
	swap	A
	anl	A,#0FH
	orl	A,#30H
	call	tulisData
	pop	ACC
	anl	A,#0FH
	orl	A,#30H
	call	tulisData
	ret

;----------------------------------------
; Ambil Data & Tampilkan		|
;----------------------------------------
displayRTC:
	push	00h
	mov	R0,#RTCBuffer+2		;Jam
	mov	A,@R0
	call	Hex2Asc
	mov	A,#':'			
	call	tulisData
	mov	R0,#RTCBuffer+1		;Menit
	mov	A,@R0
	call	Hex2Asc
	mov	A,#':'
	call	tulisData		
	mov	R0,#RTCBuffer		;Detik
	mov	A,@R0
	call	Hex2Asc
	pop	00h
	ret

;----------------------------------------
; Menampilkan data di RTCBuffer		|
; ke LCD				|
;----------------------------------------
DisplayData:	
	call	baris1
	call	displayRTC
	jnb	AFlagLed,cekAlarmLed		;cek flag alarm Led
alarmLedOn:
	clr	led1
	clr	led2

	jnb	AFlagBuzz,cekAlarmBuzz
alarmBuzzOn:
	clr	buzzer
	sjmp	exitAlarm

cekAlarmLed:
	jb	AFlagBuzz,alarmBuzzOn
	mov	A,RTCBuffer
	cjne	A,alarmLed,cekAlarmBuzz		;cek detik
	mov	A,RTCBuffer+1
	cjne	A,alarmLed+1,cekAlarmBuzz	;cek menit
	mov	A,RTCBuffer+2
	cjne	A,alarmLed+2,cekAlarmBuzz	;cek jam
	setb	AFLagLed			;give flag

cekAlarmBuzz:
	mov	A,RTCBuffer
	cjne	A,alarmBuzz,noAlarm		;cek detik
	mov	A,RTCBuffer+1
	cjne	A,alarmBuzz+1,noAlarm		;cek menit
	mov	A,RTCBuffer+2
	cjne	A,alarmBuzz+2,noAlarm		;cek jam
	setb	AFLagBuzz			;give flag
noAlarm:
	jb	AFlagBuzz,exitAlarm
	setb	buzzer
	jb	AFlagLed,exitAlarm
	setb	led1
	setb	led2
exitAlarm:
	ret

;----------------------------------------
; Input waktu alarm			|
;----------------------------------------
inputAlarm:
	call	baris2
	mov	dptr,#kalimat5	;00:00:00
	call	tulisString
	call	inputWaktu
ret
;----------------------------------------
; Ubah waktu				|
;----------------------------------------
ubahWaktu:
	call	baris2
	call	displayRTC	;xx:xx:xx jam saat itu
	call	inputWaktu
ret

;----------------------------------------
; Input waktu dari keypad		|
;----------------------------------------
inputWaktu:
	mov	A,#0C0H
	call	tulisInstr	;baris 2 kolom 1
	call	cursorBlink	;aktifkan kursor blink
passwd1: ;digit ke-1
	mov	A,#0C0h
	call	tulisInstr
	call	scanKeypad
	cjne	A,#'x',passwd1_
	sjmp	passwd1
passwd1_:
	cjne	A, #'*', pass1_
passwd1__:
	call	clearLCD
	ret
pass1_:
	cjne	A,#'#',pass1
	sjmp	passwd1
pass1: ;digit ke-1 bukan '*' & '#'
	cjne	A,#'3',pass1__
pass1__:
	jc	pass1OK		; A < 3 ?
	call	baris1
	mov	dptr,#kalimat6	; A >= 3
	call	tulisString
	call	delayLama
	call	delayLama
	call	baris1

	mov	dpl,r0
	mov	dph,r1
	call	tulisString
	sjmp	passwd1
pass1OK:			;A < 3
	push	Acc
	mov	A,#0C0h
	call	tulisInstr
	pop	Acc
	push	Acc
	clr	C
	subb	A,#30h
	mov	Temp2,A		;simpan digit puluhan jam
	pop	Acc
	call	tulisData

	mov	A, #50		;di LSB
	call	delay_Xms ;50ms

passwd2: ;digit ke-2
	mov	A,#0C1h
	call	tulisInstr
	call	scanKeypad
	cjne	A, #'x', passwd2_
	sjmp	passwd2
passwd2_:
	cjne	A,#'*',pass2_
passwd2__:
	mov	A,#0C0h
	call	tulisInstr
	mov	A,#'0'
	call	tulisData
	sjmp	passwd1
pass2_:
	cjne	A,#'#',pass2
	sjmp	passwd2
pass2:	;digit ke-2 bukan '*' & '#'
	push	Acc
	mov	A,Temp2
	cjne	A,#02,pass2fin
pass2fin:
	pop	Acc
	jc	pass2fin_	;Temp < 2 ?
	cjne	A,#'4',pass2fin__;Temp = 2
pass2fin__:
	jc	pass2fin_	;A < 4 ?

	call	baris1		;A > 4
	mov	dptr,#kalimat8
	call	tulisString
	call	delayLama
	call	delayLama
	call	baris1
	mov	dpl,r0
	mov	dph,r1
	call	tulisString
	sjmp	passwd2
pass2fin_:			;Temp < 2 / A < 4
	push	Acc
	mov	A,#0C1h
	call	tulisInstr
	pop	Acc
	push	Acc
	clr	c
	subb	A,#30h
	mov	alarm??+2,A	;simpan digit satuan jam
	mov	A,Temp2		;di LSB alarm
	swap	A
	orl	alarm??+2,A	;simpan jam
	pop	Acc
	call	tulisData
	mov	A, #50
	call	delay_Xms ;50ms

;c2 ':'
passwd3: ;digit ke-3
	mov	A,#0C3h
	call	tulisInstr
	call	scanKeypad
	cjne	A, #'x', passwd3_
	sjmp	passwd3
passwd3_:
	cjne	A,#'*',pass3_
passwd3__:
	mov	A,#0C1h
	call	tulisInstr
	mov	A,#'0'
	call	tulisData
	ajmp	passwd2
pass3_:
	cjne	A,#'#',pass3
	sjmp	passwd3
pass3:	;digit ke-3 bukan '*' & '#'
	cjne	A,#'6',pass3__
pass3__:
	jc	pass3OK		; A < 6 ?
	call	baris1
	mov	dptr,#kalimat7
	call	tulisString
	call	delayLama
	call	delayLama
	call	baris1
	mov	dpl,r0
	mov	dph,r1	
	call	tulisString
	sjmp	passwd3
pass3OK:
	push	Acc
	mov	A,#0C3h
	call	tulisInstr
	pop	Acc
	push	Acc
	clr	c
	subb	A,#30h
	swap	A
	mov	alarm??+1,A	;simpan digit puluhan menit
	pop	Acc
	call	tulisData
	mov	A, #50
	call	delay_Xms ;50ms

passwd4: ;digit ke-4
	mov	A,#0C4h
	call	tulisInstr
	call	scanKeypad
	cjne	A, #'x', passwd4_
	sjmp	passwd4
passwd4_:
	cjne	A,#'*',pass4_
passwd4__:
	mov	A,#0C3h
	call	tulisInstr
	mov	A,#'0'
	call	tulisData
	sjmp	passwd3
pass4_:
	cjne	A,#'#',pass4
	sjmp	passwd4
pass4:	;digit ke-4 bukan '*' & '#'
	push	Acc
	mov	A,#0C4h
	call	tulisInstr
	pop	Acc
	push	Acc
	clr	c
	subb	A,#30h
	orl	alarm??+1,A
	pop	Acc
	call	tulisData
	mov A, #50
	call delay_Xms ;50ms

;c5 ':'
passwd5: ;digit ke-5
	mov	A,#0C6h
	call	tulisInstr
	call	scanKeypad
	cjne	A, #'x', passwd5_
	sjmp	passwd5
passwd5_:
	cjne	A,#'*',pass5_
passwd5__:
	mov	A,#0C4h
	call	tulisInstr
	mov	A,#'0'
	call	tulisData
	sjmp	passwd4
pass5_:
	cjne	A,#'#',pass5
	sjmp	passwd5
pass5:	;digit ke-5 bukan '*' & '#'
	cjne	A,#'6',pass5__
pass5__:
	jc	pass5OK		; A < 6 ?
	call	baris1		
	mov	dptr,#kalimat7	; A > 6
	call	tulisString	; kasih warning
	call	delayLama
	call	delayLama
	call	baris1
	mov	dpl,r0
	mov	dph,r1
	call	tulisString
	sjmp	passwd5
pass5OK:			; A < 5, max kan 59
	push	Acc
	mov	A,#0C6h
	call	tulisInstr
	pop	Acc
	push	Acc
	clr	c
	subb	A,#30h
	swap	A
	mov	alarm??,A
	pop	Acc
	call	tulisData
	mov A, #50
	call delay_Xms ;50ms

passwd6: ;digit ke-6
	mov	A,#0C7h
	call	tulisInstr
	call	scanKeypad
	cjne	A, #'x', passwd6_
	sjmp	passwd6
passwd6_:
	cjne	A,#'*',pass6_
passwd6__:
	mov	A,#0C6h
	call	tulisInstr
	mov	A,#'0'
	call	tulisData
	sjmp	passwd5
pass6_:
	cjne	A,#'#',pass6
	sjmp	passwd6
pass6:	;digit ke-6 bukan '*' & '#'
	push	Acc
	mov	A,#0C7h
	call	tulisInstr
	pop	Acc
	push	Acc
	clr	c
	subb	A,#30h
	orl	A,alarm??
	mov	alarm??,A
	pop	Acc
	call	tulisData

	call	cursorOff
	call	delayLama
	call	delayLama
	call	delayLama

	setb	AFlag		;alarm di set / ubah waktu
ret
;----------------------------------------
; Program utama				|
;----------------------------------------
mulai:
	mov	p0,#0ffh
	mov	p1,#0ffh

	;Initialisasi timer 1 dan interrupt
	;mov	TMOD,#00010000B		;Timer1 mode1
	;mov	TH1,#0EEH		;5ms
	;mov	TL1,#00H
	;mov	Prescaler,#100		;5x150=750ms
	;mov	TCON,#00001010B
	;mov	IE,#00001000B		;ET1 Enabled
	;setb	EA			;Enabled EA
	
	;clear all flags
	clr	AFlag
	clr	AFlagLed
	clr	AFlagBuzz

	;Pindahkan data dari data setting ke RTCBuffer		
	mov	R7,#8
	mov	A,#0
	mov	R0,#RTCBuffer
NxtMovDataRTC:	
	push	ACC
	acall	Now		
	mov	@R0,A
	pop	ACC
	inc	A
	inc	R0
	djnz	R7,NxtMovDataRTC
	
	call	RESET			;Reset RTC
	call	RUNCLK			;Enable RTC Clock

	;Pindahkan data dari data alarm alarm ke RAM
	mov	alarmLed+2,#12h
	mov	alarmLed+1,#0h
	mov	alarmLed,#59h
	mov	alarmBuzz+2,#12h
	mov	alarmBuzz+1,#0h
	mov	alarmBuzz,#59h

	call	WRENB
	
	mov	B,#TCR			
	mov	A,#10100101B		;Enable Trickle Charger
	call	BYTEWRCLKREG

	mov	R0,#RTCBuffer		;Setting RTC
	call	BURSTWRCLKREG

	;ga bs menulis
	call	WRDIS			
	
	;inisialisasi LCD
	call	initLCD
	call	clearLCD
	;tampilan awal
	
		
	;setb	TR1			;timer 1 aktif
	;call	clearLCD

	;tampilan awal
	call	baris1
	mov	dptr,#kalimat1
	call	tulisString

	call	baris2
	mov	dptr,#kalimat2
	call	tulisString

	mov r1,#02
tahanbentar:
	call	delayLama
	call	delayLama
	call	delayLama
	call	clearLCD
	djnz	r1,tahanbentar

	call	baris1
	mov	dptr,#empty
	call	tulisString
	
	call	baris2			;ke baris 2
	mov	dptr,#kalimat9		;tampilkan info
	call	tulisString
loop:	
	call	baris1			;ke baris 1
	mov	R0,#RTCBuffer	
	call	BURSTRDCLKREG		;baca waktu
	call	DisplayData		;tampilkan waktu

	call	scanKeypad		
	cjne	A,#'x',setAlarm
	sjmp	loop
setAlarm:
	cjne	A,#'*',setBuzzer
setLed:					;set alarm LEd
	call	baris1
	mov	dptr,#kalimat3
	mov	r0,dpl
	mov	r1,dph
	call	tulisString
	call	inputAlarm
	call	baris1
	mov	dptr,#empty
	call	tulisString
	call	baris2			;ke baris 2
	mov	dptr,#kalimat9		;tampilkan info
	call	tulisString
	jnb	AFlag,loop
	mov	alarmLed+2,alarm??+2
	mov	alarmLed+1,alarm??+1
	mov	alarmLed,alarm??
	clr	AFlag
	sjmp	loop

setBuzzer:				;set alarm buzzer
	cjne	A,#'#',info
	call	baris1
	mov	dptr,#kalimat4
	mov	r0,dpl
	mov	r1,dph
	call	tulisString
	call	inputAlarm
	call	baris1
	mov	dptr,#empty
	call	tulisString
	call	baris2			;ke baris 2
	mov	dptr,#kalimat9		;tampilkan info
	call	tulisString
	jnb	AFlag,loop
	mov	alarmBuzz+2,alarm??+2
	mov	alarmBuzz+1,alarm??+1
	mov	alarmBuzz,alarm??
	clr	AFlag
	sjmp	loop

info:					;info
	cjne	A,#'4',infoLed
	call	baris2
	mov	dptr,#kalimat9
	call	tulisString
	jmp	loop
infoLed:				;info waktu alarm Led
	cjne	A,#'5',infoBuzzer
	call	baris2
	mov	dptr,#kalimat10
	call	tulisString
	mov	A,#0C6h
	call	tulisInstr		;baris 2 kolom 6
	mov	A,alarmLed+2
	call	Hex2Asc
	mov	A,#':'
	call	tulisData
	mov	A,alarmLed+1
	call	Hex2Asc
	mov	A,#':'
	call	tulisData
	mov	A,alarmLed
	call	Hex2Asc
	jmp	loop

infoBuzzer:				;info waktu alarm Buzzer
	cjne	A,#'6',stopwatch
	call	baris2
	mov	dptr,#kalimat11
	call	tulisString
	mov	A,#0C6h
	call	tulisInstr		;baris 2 kolom 6
	mov	A,alarmBuzz+2
	call	Hex2Asc
	mov	A,#':'
	call	tulisData
	mov	A,alarmBuzz+1
	call	Hex2Asc
	mov	A,#':'
	call	tulisData
	mov	A,alarmBuzz
	call	Hex2Asc
	jmp	loop

stopwatch:	;r5->MN, r6->SEC, r7->mSEC 99
	cjne	A,#'1',setWaktu
	mov	r5,#0
	mov	r6,#0
	mov	r7,#0

	mov	TMOD,#00010000B		;Timer1 mode1
	mov	TH1,#0FEH		;5ms
	mov	TL1,#00H
	mov	Prescaler,#2		;5x2=10ms
	mov	TCON,#00001010B
	mov	IE,#00001000B		;ET1 Enabled
	setb	EA			;Enabled EA
	
	call	baris1
	mov	dptr,#kalimat13
	call	tulisString
	call	baris2
	mov	dptr,#kalimat5
	call	tulisString

cekPlaySW:
	call	scanKeypad
	cjne	A,#'3',cekPlaySW_
	sjmp	exitSW
cekPlaySW_:
	cjne	A,#'2',cekPlaySW
PlaySW:
	setb	tr1			;play SW	
cekStopSW:
	call	scanKeypad
	cjne	A,#'2',cekStopSW
StopSW:
	clr	tr1			;stop SW
cekRstSW:
	call	scanKeypad
	cjne	A,#'1',cekPlaySW2
	mov	r5,#0			;rst SW
	mov	r6,#0
	mov	r7,#0
	call	displaySW
	sjmp	cekPlaySW
cekPlaySW2:
	cjne	A,#'2',exitSW
	sjmp	playSW
exitSW:
	cjne	A,#'3',cekRstSW
	call	baris1
	mov	dptr,#empty
	call	tulisString
	call	baris2			;ke baris 2
	mov	dptr,#kalimat9		;tampilkan info
	call	tulisString
	jmp	loop



setWaktu:
	cjne	A,#'3',clearFlag
	call	baris1
	mov	dptr,#kalimat12
	mov	r0,dpl
	mov	r1,dph
	call	tulisString
	call	baris2
	mov	dptr,#empty
	call	tulisString
	call	baris2
	call	ubahWaktu
	call	baris1
	mov	dptr,#empty
	call	tulisString
	call	baris2			;ke baris 2
	mov	dptr,#kalimat9		;tampilkan info
	call	tulisString
	jnb	AFlag,gakDiteken
	call	WRENB
	mov	A,alarm??+2		;ubah jam
	mov	B,#HR
	call	BYTEWRCLKREG
	mov	A,alarm??+1		;ubah menit
	mov	B,#MIN
	call	BYTEWRCLKREG
	mov	A,alarm??		;ubah detik
	mov	B,#SEC
	call	BYTEWRCLKREG
	call	WRDIS
	clr	AFlag
	sjmp	gakDiteken
clearFlag:
	clr	AFlag
	clr	AFlagLed
	clr	AFlagBuzz
gakDiteken:		;gak ditekan / '*' @1st
	jmp loop

;----------------------------------------
; Rutin LCD 2 x 16			|
;----------------------------------------
initLCD:	
	clr	RS
 	clr	RW
 	clr	EN
 	setb	EN
 	mov	DAT,#028h
 	clr	EN
 	call	lcdDelay_S
 	mov	A,#28h
	call	tulisInstr
 	mov	A,#0Ch
	call	tulisInstr
 	mov	A,#06h
 	call	tulisInstr
	call	clearLCD
	mov	A,#080H
	call	tulisInstr
 	ret

clearLCD:		
	clr	RS
	mov	A,#01h
 	call	tulisInstr
	ret

cursorBlink:
	mov	A,#0FH
	call	tulisInstr
	ret

cursorOff:
	mov	A,#0CH
	call	tulisInstr
	ret

tulisData:
	setb	RS
	clr	RW
	call	tulisNibble
	call	lcdDelay_L
	ret

tulisString:
	push	Acc
tulisString_:
	clr	A
	movc	A,@A+DPTR
	inc	DPTR
	cjne	A,#0,tulisString__
	sjmp	go_b2
tulisString__:
	call	tulisData	
	sjmp	tulisString_
go_b2:		
	pop	Acc
	ret

tulisInstr:		
	clr	RS
	clr	RW
	call	tulisNibble
	call	lcdDelay_S
	ret

tulisNibble:
	push	ACC           	;Save A for low nibble
	orl	DAT,#0F0h    	;Bits 4..7 <- 1
	orl	A,#0Fh        	;Don't affect bits 0-3
	anl	DAT,A        	;High nibble to display
	setb	EN 
	clr	EN 
	pop	ACC           	;Prepare to send
	swap	A             	;...second nibble
	orl	DAT,#0F0h    	; Bits 4...7 <- 1
	orl	A,#0Fh       	; Don't affect bits 0...3
	anl	DAT,A        	;Low nibble to display
	setb	EN 
	clr	EN
	ret

baris1:		
	mov	A,#80H
	call	tulisInstr
	ret
baris2:		
	mov	A,#0C0H
	call	tulisInstr
	ret


lcdDelay_S: 
	push	03h
	push	04h
	mov	R3,#1    			
here2:          
	mov	R4,#255  			
here:           
	djnz	R4,here
        djnz	R3,here2
	pop	04h
	pop	03h
        ret

lcdDelay_L:       
	push	03h
	push	04h
	mov	R3,#02    			
her2:          	
	mov	R4,#255  			
her:          	
	djnz	R4,her
        djnz	R3,her2
	pop	04h
	pop	03h
        ret


;----------------------------------------
; Rutin Scanning Keypad			|
;----------------------------------------
scanKeypad:
	mov	p2,#0ffh
cekB1:
	setb	b4
	clr	b1
cekB1K1:
	jb	k1,cekB1K2
	call	keyDelay
	call	keyDelay
	mov	A,#'1'
	jmp	ambilData
cekB1K2:
	jb	k2,cekB1K3
	call	keyDelay
	call	keyDelay
	mov	A,#'2'
	jmp	ambilData
cekB1K3:
	jb	k3,cekB2
	call	keyDelay
	call	keyDelay
	mov	A,#'3'
	jmp	ambilData
cekB2:
	setb	b1
	clr	b2
cekB2K1:
	jb	k1,cekB2K2
	call	keyDelay
	call	keyDelay
	mov	A,#'4'
	jmp	ambilData
cekB2K2:
	jb	k2,cekB2K3
	call	keyDelay
	call	keyDelay
	mov	A,#'5'
	jmp	ambilData
cekB2K3:
	jb	k3,cekB3
	call	keyDelay
	call	keyDelay
	mov	A,#'6'
	jmp	ambilData
cekB3:
	setb	b2
	clr	b3
cekB3K1:
	jb	k1,cekB3K2
	call	keyDelay
	call	keyDelay
	mov	A,#'7'
	jmp	ambilData
cekB3K2:
	jb	k2,cekB3K3
	call	keyDelay
	call	keyDelay
	mov	A,#'8'
	jmp	ambilData
cekB3K3:
	jb	k3,cekB4
	call	keyDelay
	call	keyDelay
	mov	A,#'9'
	jmp	ambilData
cekB4:
	setb	b3
	clr	b4
cekB4K1:
	jb	k1,cekB4K2
	call	keyDelay
	call	keyDelay
	mov	A,#'*'
	jmp	ambilData
cekB4K2:
	jb	k2,cekB4K3
	call	keyDelay
	call	keyDelay
	mov	A,#'0'
	jmp	ambilData
cekB4K3:
	jb	k3,scanKeypad_
	call	keyDelay
	call	keyDelay
	mov	A,#'#'
ambilData:
	ret
scanKeypad_:
	mov	A,#'x'
	sjmp	ambilData
	

keyDelay:
	push	03h
	push	04h
	mov	r3,#080h
keyDelay_:
	mov	r4,#0ffh
	djnz	r4,$
	djnz	r3,keyDelay_
	pop	04h
	pop	03h
	ret

;----------------------------------------
; Rutin tambahan			|
;----------------------------------------
delayLama:
	push	03h
	push	04h
	mov	r3,#255
delayLama_:
	mov	r4,#255
delayLama__:
	djnz	r4,delayLama__
	djnz	r3,delayLama_
	pop	04h
	pop	03h
	ret

delay_Xms:
	push	01
	mov	r1, A ;A x 1000 = X ms
	mov	tmod, #01 ;timer 0 - 16 bit
lagi: 
	mov	th0, #HIGH(-1000)
	MOV	tl0, #LOW(-1000)
	SETB	tr0
tunggu:
	JNB	TF0, tunggu
	clr	TF0
	clr	TR0
	djnz	r1,lagi
	pop	01
RET
		
kalimat1:		
	db ' Alarm Digital  ',0
kalimat2:		
	db ' by : gedex     ',0
kalimat3:
	db ' Set Alarm LED  ',0
kalimat4:
	db ' Set Alarm Buzz ',0
kalimat5:
	db '00:00:00        ',0
kalimat6:
	db 'Digit > 2 !!    ',0
kalimat7:
	db 'Digit > 5 !!    ',0	
kalimat8:
	db 'Digit > 3 !!    ',0
kalimat9:
	db '[4-6] utk info..',0
kalimat10:	
	db 'Led : xx:xx:xx  ',0
kalimat11:
	    ;01234567 		
	db 'Buzz : xx:xx:x  ',0
kalimat12:
	db 'Ubah Waktu      ',0
empty:
	db '                ',0
kalimat13:
	db 'Stopwatch:      ',0
end