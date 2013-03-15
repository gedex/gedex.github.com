$MOD51

DSEG
	out7seg	equ	p1

	puluhan	bit p3.0	;aktif low, org-ijo,tuk mulai
	satuan  bit p3.1	;biru-kuning, tuk reset ke '60'	
	sw	bit p3.2


CSEG
	org 0h
	sjmp init__

	org 03h


	reti
init__:
	mov	IE,#81h		;int 0
	setb	IT0		;edge trigerred

init_:				;exec by reset mikon & sw
	clr	F0			;F0 -> indikator sudah '00'
	mov	A,#84h		;6
	mov	B,#0C0h		;0
init:
	setb	satuan		;off 7 seg
	setb	puluhan		;satuan -> common 7's utk angka satuan, puluhan -> common 7's utk angka puluhan 	
	mov	dptr,#data7seg 	;ambil alamat data 7seg di label #data7seg
	clr	p3.4		;sumber low utk switching
	jnb	F0,loop		;sempet '00' ?
wait00: 			;iya
	sjmp	loop 	
	clr	satuan		;ON 7's
	clr	puluhan
	mov	out7seg,#0C0h	;tampil '00' truz
	setb	satuan
	jb	satuan, wait00	;di rst gak?
	sjmp	init_		;iya	

;awal nyala '60'
loop:				
 ;jnb puluhan, startCount ;puluhan / switch 'set' == 0 ??
	setb	satuan	;gak	 
	clr	puluhan
	mov	out7seg,A
	acall	delay_1ms
	setb	puluhan		
	clr	satuan
	mov	out7seg,B
	acall	delay_1ms
	setb	puluhan 
	setb	satuan
;sjmp loop
 

;switch set ditekan
;mulai menghitung mundur
startCount:
	mov	r1,#100
sub0: 
	mov	r2,#5
sub0_:
	jnb	satuan,init_	;reset dipencet?
	setb	satuan		
	clr	puluhan
	mov	out7seg,#84h	;6
	acall	delay_1ms
	setb	puluhan		
	clr	satuan
	mov	out7seg,#0C0h	;0
	acall	delay_1ms
	setb	satuan
	djnz	r2,sub0_
	djnz	r1,sub0 
decPuluhan:  
	mov	A,#04		;index pointer '5'
	movc	A,@A+dptr
	cjne	A,#0ffh,ambil_	;dah '0'?
	mov	A,#0C0h		;'0'
	mov	B,A
	setb	F0		;hrs d rst ke '60'
	ajmp	init			
ambil_: 		;blum '0'
	cpl	A
	mov	B, A		;B utk puluhan
	inc	dptr
	push	dph
	push	dpl
	mov	dptr,#data7seg 	;index ke-'0'
decSatuan:			
	clr	A 
	movc	A,@A+dptr
	inc	dptr
	cjne	A,#0ffh,ambil	;blum abis?
	sjmp	exit		;dah abis = '0'
ambil:				;decrement satuan
	cpl	A		;A utk satuan
	mov	r1,#100
sub: 
	mov	r2,#5
sub_: 				;tampilkan ganti-gantian setiap 1 ms
	jnb	satuan,reset_  	;reset dipencet?
	setb	satuan		
	clr	puluhan
	mov	out7seg, B
	acall	delay_1ms			 
	setb	puluhan		
	clr	satuan
	mov	out7seg, A
	acall	delay_1ms
	setb	satuan
	djnz	r2,sub_
	djnz	r1,sub
	sjmp	decSatuan
reset_:
	ajmp	init_
exit:
	pop	dpl
	pop	dph
	ajmp	decPuluhan	;decrement puluhan
delay_1ms:	
	push	07h
	push	06h
	mov	r6,#02
subz: 
	mov	r7, #220
	djnz	r7, $
	djnz	r6,subz
	pop	06h
	pop	07h
ret 

data7seg: 
  db  5Fh,7Fh,0Eh,7Bh,5Bh,4Dh,5Eh,76h,0Ch,3Fh,0FFh
      ;9   8   7   6   5   4   3   2   1   0
end