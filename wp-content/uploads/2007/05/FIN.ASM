;gedex02
;  kiri		  kanan	
; 7 6 5 4	3 2 1 0
;   + e -   - e +
; 0	1 1 0   0 0 0 0	60	bkan
; 0	1 1 0   1 1 0 0	6C	skan
; 0	0 0 0   0 1 1 0	06	bkir
; 0	0 1 1   0 1 1 0 36	skir
; 0	1 1 0   0 1 1 0	66  maju
; 0 0 1 1   1 1 0 0	3C  mundur		

enKir	bit		p2.5
negKir	bit		p2.4
posKir	bit		p2.6

enKan	bit		p2.2
posKan	bit		p2.1
negKan	bit		p2.3

pwmKa	EQU	30h
pwmKi	EQU	31h

;[4]	[3] [2] [1]		[0]
sKaLuar	 bit		p1.0
sKaDalam bit		p1.1
sTengah	 bit		p1.2
sKiDalam bit		p1.3
sKiLuar	 bit		p1.4

jalan	 bit		p2.7	;aktif low	 
led		 bit		p0.0	;aktif low
note	 bit		F0

org 0h
 		sjmp init
 
org	0bh
		Push PSW
		;Push Acc
		djnz r7,cek
		mov	 r7,#255
		clr enKan			;DutCyc Motor Kanan 0
		clr enKir			;DutCyc Motor Kiri	0
cek:	xch	a,r7
		cjne a,pwmKa,lanjut
		setb enKan			;DutCyc Motor Kanan 1
lanjut:	cjne a,pwmKi,lanjut2
		setb enKir			;DutCyc Motor Kiri	1
lanjut2:xch	a,r7
		;pop Acc
		pop	PSW		
		reti 
init:	
		mov	th0,#0cch
		mov	tmod,#02h	;timer0 mode 2
		clr	tr0			
		mov	ie,#82h		;interrupt timer0 
		mov	pwmKa,#0	
		mov	pwmKi,#0
		mov dptr,#pwm_
		clr note
mulai:
		setb jalan
		call delay2
		cpl led
		jb jalan, mulai
		
		setb led
		setb tr0		;timer0 on
				
		mov pwmKa,#0AFh	;maju dikit
 		mov pwmKi,#080h
 		mov p2, #66h		
		lcall delay2
		
		call MENUJU_GRB_C	;test menuju final
		clr led
		call scan
		call FASTSTOP
		sjmp init
		

;--------------------------------------------------------------------------
HKIRI1:
		mov	r3, #55
HKIRI1_WAIT:				
		call scan
		call delay1
		djnz r3, HKIRI1_WAIT
		clr led
HKIRI1_:
		call scan
		mov A, p1			;(4) (3) (2) (1) 0
		anl A,#1Eh
		cjne A,#1Eh,CekKi
		sjmp HKIRI1_OK
CekKi:	
		jb	sKiLuar, CekTeng
		sjmp HKIRI1_
CekTeng:
		mov A, p1
		anl A, #1Fh
		cjne A,#1Eh,Cek2Ki	;(4)  (3) (2) (1) 0
		sjmp HKIRI1_OK
Cek2Ki:
		cjne A, #1Ch,Cek1Ki;(4)  (3) (2)  1  0
		sjmp HKIRI1_OK
Cek1Ki:			
		cjne A, #18h,HKIRI1_;(4)  (3)  2   1  0	
HKIRI1_OK:
		mov pwmKi,#040h		;serkir
		mov pwmKa,#050h
		mov p2, #36h			
		call delay2
		call delay1
		call FASTSTOP
		
		;cek tengah			;(3)  (2)   (1)
		mov A, p1
		anl A, #1Eh
		jz _serkan_ 		;bukan haluan yg dimaksud					
		
		mov r3, #05			;haluan OK
HKIRI1_OK_:
		call scan
		call delay1
		djnz r3,HKIRI1_OK_		
ret

_serkan_:
		mov pwmKi,#050h		;serkan
		mov pwmKa,#040h
		mov p2, #6Ch
		call delay2
		call FASTSTOP
		sjmp HKIRI1_

;-----------------------------------------------------
HKIRI1_A:
		mov	r3, #03
HKIRI1_WAIT_A:				
		call scan
		call delay1
		djnz r3, HKIRI1_WAIT_A
		clr led
HKIRI1A:
		call scan
		mov A, p1			;(4) (3) (2) (1) 0
		anl A,#1Eh
		cjne A,#1Eh,CekKiA
		sjmp HKIRI1_OKA
CekKiA:	
		jb	sKiLuar, CekTengA
		sjmp HKIRI1A
CekTengA:
		mov A, p1
		anl A, #1Fh
		cjne A,#1Eh,Cek2KiA	;(4)  (3) (2) (1) 0
		sjmp HKIRI1_OKA
Cek2KiA:
		cjne A, #1Ch,HKIRI1A;(4)  (3) (2)  1  0		
HKIRI1_OKA:
		mov pwmKi,#040h		;serkir
		mov pwmKa,#050h
		mov p2, #36h			
		call delay2
		call delay1
		
		;cek tengah			;(3)  (2)   (1)
		mov A, p1
		anl A, #1Eh
		jz _serkan2_ 		;bukan haluan yg dimaksud
		
		mov r3, #03
HKIRI1_OK_A:
		call scan
		call delay1
		djnz r3,HKIRI1_OK_A
		
HKIRI1A_FINISH_:
		call scan
		call delay1
		jb sKiLuar, _serkir_		
		sjmp HKIRI1A_FINISH_
HKIRI1A_FINISH:		
		ret					;exit
		
_serkir_:
		mov pwmKi,#030h		;serkir maju
		mov pwmKa,#0D0h
		mov p2, #66h			
		call delay2
		call delay1
		call FASTSTOP
		sjmp HKIRI1A_FINISH	
_serkan2_:
		mov pwmKi,#030h		;serkan
		mov pwmKa,#020h
		mov p2, #6Ch
		call delay2
		call FASTSTOP
		sjmp HKIRI1A

;-----------------------------------------------------
HKAN1:
		call scan
		mov A, p1
		anl A,#07		; 4  3  (2) (1) (0)
		cjne A,#07,CekKa
		sjmp HKAN1_OK
CekKa:
		jb sKaLuar, HKAN1_
		sjmp HKAN1
HKAN1_:
		mov A,p1
		anl A,#07
		cjne A,#07,HKAN1	
HKAN1_OK:
		mov pwmKi,#0D0h	;serkan
		mov pwmKa,#0C0h
		mov p2, #6Ch
		lcall delay2
		
		mov r3,#05
HKAN1_OK_:
		call scan
		call delay1
		djnz r3, HKAN1_OK_
		ret

;--------------------------------------------------------------------------------------
HKIRI2:
		mov	r3, #10
HKIRI2_WAIT:				
		call scan
		call delay1
		djnz r3, HKIRI2_WAIT

HKIRI2_:
		call scan
		mov A, p1			;(4) (3) (2) (1) 0
		anl A,#1Eh
		cjne A,#1Eh,CekKi2
		sjmp HKIRI2_OK
CekKi2:	
		jb	sKiLuar, CekTeng2
		sjmp HKIRI2_
CekTeng2:
		mov A, p1
		anl A, #1Fh
		cjne A,#1Eh,Cek2Ki2	;(4)  (3) (2) (1) 0
		sjmp HKIRI2_OK
Cek2Ki2:
		cjne A, #1Ch,HKIRI2_;(4)  (3) (2)  1  0		
HKIRI2_OK:
		mov pwmKi,#0C0h	;serkir
		mov pwmKa,#0D0h
		mov p2, #36h			
		lcall delay2
		
		mov r3, #20
HKIRI2_OK_:
		call scan
		call delay1
		djnz r3,HKIRI2_OK_		
ret



;--------------------------------------------------------------------------------------
MENUJU_SKL_C:
		;mov r4
		mov r3,#150
SKL_C_WAIT:
		call scan
		lcall delay1
		djnz r3,SKL_C_WAIT
		
SKL_C_CEK:				;cek p'an abiz saklar C
		call scan
		mov A,p1
		anl A, #1Fh		;(4) (3) (2) (1) (0) -> 2x
		cjne A,#1Fh,SKL_C_CEK
SKL_C_CEK_:				;cek maju sedikit, 0 smua gak
		lcall MAJU
		lcall delay1
		lcall FASTSTOP
		mov A,p1
		anl A, #0Fh
		jz	SKL_C_CEK_OK
		sjmp SKL_C_CEK	
SKL_C_CEK_OK:
		lcall MUNDUR
		lcall delay1		 
		mov pwmKi,#0D0h	;serkan
		mov pwmKa,#0C0h
		mov p2, #6Ch
		lcall delay2
		
		mov r3,#80
SKL_C_CEK_OK_:
		call scan
		call delay1
		djnz r3, SKL_C_CEK_OK_
		ret				 


;--------------------------------------------------------------------------------------
MENUJU_GRB_C:
		mov r4, #16
GRB_C_WAIT_:		
		mov r3, #10
GRB_C_WAIT:
		call scan		
		call delay1
		jb sKiLuar,_serKiAwal 
		jb sKaLuar,_serKaAwal
GRB_C_DEC:		
		djnz r3,GRB_C_WAIT
		djnz r4,GRB_C_WAIT_
		sjmp _WAIT_ABIZ
		
_serKiAwal:
		mov pwmKi,#020h			;serkir
		mov pwmKa,#0B0h
		mov p2, #66h			
		call delay2
		sjmp GRB_C_DEC

_serKaAwal:		
		mov pwmKi,#0C0h			;serkan
		mov pwmKa,#020h
		mov p2, #66h
		call delay2
		sjmp GRB_C_DEC

_WAIT_ABIZ:		
		;d'truth
		clr led
WAIT_ABIZ:
		clr A
		call scan
		jb sKaLuar, _serkan3_
		mov A,P1		
		anl A,#1Eh
		cjne A,#1Eh,cekKiri!!	;(4)  (3) (2) (1) 0 
		sjmp HKIRI1_OKA!!
cekKiri!!:		
		jb sKiLuar,CekTengA_
		sjmp WAIT_ABIZ
CekTengA_:
		clr A
		mov A, p1
		anl A, #1Fh
		cjne A,#1Eh,Cek2KiA_	;(4)  (3) (2) (1)  0
		sjmp HKIRI1_OKA!!
Cek2KiA_:
		cjne A, #1Ch,Cek1KiA_	;(4)  (3) (2)  1   0	
		sjmp HKIRI1_OKA!!
Cek1KiA_:		
		cjne A, #18h,WAIT_ABIZ	;(4)  (3)  2   1   0
HKIRI1_OKA!!:
		jb sKaLuar, WAIT_ABIZ
		
		;cek tengah				;(3)  (2)   (1)
		mov A, p1
		anl A, #1Eh
		jz _serkir3_ 			;bukan haluan yg dimaksud

		;OK , haluan..
		setb led
	
		mov pwmKi,#040h			;serkir
		mov pwmKa,#050h
		mov p2, #36h			
		call delay2
		call delay1
		call FASTSTOP
				
		mov r3,#10				
BELOK_FINISH:
		call scan
		call delay1
		djnz r3, BELOK_FINISH 
		RET

_serkir3_:
		mov pwmKi,#040h			;serkir
		mov pwmKa,#050h
		mov p2, #36h			
		call delay2
		call delay1
		call FASTSTOP
		mov r3,#05
_serkir3__:		
		call scan 
		call delay1
		djnz r3,_serkir3__
		jmp WAIT_ABIZ			;
		
_serkan3_:
		mov pwmKi,#080h			;serkan
		mov pwmKa,#020h
		mov p2, #66h
		call delay1
		jmp WAIT_ABIZ



;--------------------------------------------------------------------------------------
KIRI_AWAL:				;(4) (3) (2) (1) 0
		call scan
		mov A, p1
		anl A, #1Eh
		cjne A,#1Eh,KIRI_AWAL_
		sjmp _KIR_A
		
KIRI_AWAL_:			;cek (4)
		jnb	ACC.4, KIRI_AWAL
_KIR_A:
		mov pwmKi,#20h
		mov pwmKa,#70h
		mov p2, #36h
		
		lcall delay2
		
_KIR_A_:
		mov A,P1
		anl A,#0eh
	 	jz _KIR_A
		sjmp KIRI_AWAL
		
		mov r3, #50
_KIR_OK:
		call scan
		lcall delay1
		djnz r3, _KIR_OK 		
		

						
SCAN_KANAN:
		call scan
		mov r3, #20
SCAN_KANAN_:		
		mov A, P1		;4 (3) (2) (1) (0)
		anl A,#0Fh
		cjne  A,#0Fh,SCAN_KANAN
		call _delay_
		djnz r3,SCAN_KANAN_
SCAN_KANAN__:		;
		call scan
		mov r3, #50
SCAN_KANAN___:
		jb sKaLuar,SCAN_KANAN__
		call _delay_
		djnz r3, SCAN_KANAN___				
		ret

SCAN_KANAN2:		;+ T
		call scan
		mov r3, #20
SCAN_KANAN2_:		
		mov A, P1		;(4) (3) (2) (1) (0)
		anl A,#1Fh
		cjne  A,#1Fh,SCAN_KANAN2
		call _delay_
		djnz r3,SCAN_KANAN2_
SCAN_KANAN2__:
		call scan
		mov r3, #50
SCAN_KANAN2___:
		jb sKaLuar,SCAN_KANAN2__
		call _delay_
		djnz r3, SCAN_KANAN2___				
		ret


;e maju, c serkir, 6 serkan
scan:
		mov	a,p1		
		anl	a,#0eh	
		jz	cekKiKa	
			
		mov p2, #66h	
mundur:	;serkan / serkir / maju, 0,6,c,e
		mov B, A
		movc A,@A+dptr
		mov pwmKi, A
		mov A, B
		inc A
		movc A,@A+dptr
		mov pwmKa, A
		ret

mundur_:mov p2, #3Ch
		sjmp mundur
		
		
cekKiKa:jnb	sKiLuar,_kanan
_kiri:	mov pwmKi,#40h
		mov pwmKa,#50h
		mov p2, #36h
		ret
		
_kanan:	jnb	sKaLuar,mundur_
		mov pwmKi,#50h
		mov pwmKa,#40h
		mov p2, #6Ch
		ret

		

		
MUNDUR: ;lcall FASTSTOP
		mov pwmKa,#04Fh
 		mov pwmKi,#040h
 		mov p2, #3Ch		
		ret

MAJU:   mov pwmKa,#09Fh
 		mov pwmKi,#08Ch
 		mov p2, #66h		
		ret

SERKAN: mov pwmKi,#0CFh
		mov pwmKa,#0A0h
		mov p2, #6Ch
		ret
		
SERKIR: mov pwmKi,#0A0h
		mov pwmKa,#0CFh
		mov p2, #36h
		ret

FASTSTOP:
		mov p2, #0
		mov pwmKi,#0
		mov pwmKa,#0
		ret
BKAN:
		lcall FASTSTOP
		mov pwmKi,#0CFh
		mov pwmKa,#50h
		mov p2, #60h
		ret
		
BKIR:	lcall FASTSTOP
		mov pwmKi,#50h
		mov pwmKa,#0CFh
		mov p2, #06h
		ret							


delay2: push 2
        mov R2, #3
_delay2:call delay1
        djnz R2,_delay2
        pop 2
        ret        

delay1:	push 1
		mov	R1,#0
_delay1:call _delay_
		djnz R1,_delay1
		pop	1
		ret	

_delay_:push 0
		mov	R0,#0
   		djnz R0,$
   		pop 0   	
   		ret

			;ki	 ka	
;pwm2_:	DB	020h,030h	;mundur	pelan	0
;		DB	0BFh,020h	;serKan++		2
;		DB	070h,090h	;maju pelan		4
;		DB	0BFh,05Ch	;serkan			6
;		DB	20h, 0Bfh	;serkir++		8
;		DB	80h, 0BFh	;				10  a  
;		DB	5Ch, 0BFh	;serkir			12	c
;		DB	90h, 0BFh	;maju			14  e
		
			;ki	 ka	
pwm_:	DB	01Bh,030h	;mundur	pelan	0
		DB	08Fh,03Ah	;serKan++		2
		DB	070h,090h	;maju pelan		4
		DB	080h,04Fh	;serkan			6
		DB	03Ah,080h	;serkir++		8
		DB	070h,09Fh	;				10  a  
		DB	050h,080h	;serkir			12	c
		DB	0D0h,085h	;maju			14  e


abiz_:		
		end
	