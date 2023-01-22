//Console Routines
console_init:
	php
	
	rep #$30
	stz console_cursor
	stz console_nmi_ready
	stz BG12NBA
	
	//Clean console_map buffer
	lda.w #$0000
	tax
-;	sta.l console_map,x
	inx
	inx
	cpx.w #console_map.size
	bmi -
	
	sep #$20
	lda.b #$8F
	sta.w INIDISP	//Force Blank
	stz BGMODE	//Mode 0, 8x8
	lda.b #$04
	sta.w BG1SC	//BG Base Word Addr = $1000
	
	uploadToCGRAM(font_pal, 0, font_pal.size)
	uploadToVRAM(font_chr, 0, font_chr.size)
	uploadToVRAM(console_map, $400, console_map.size)
	
	plp
	rtl

console_nmi:
	php
	sep #$20
	lda console_nmi_ready
	beq +
	uploadToVRAM(console_map, $400, console_map.size)
	consoleNMIBusy()
+;	plp
	rtl

console_print:
	//ram_args = address to print
	php
	
	rep #$30
	ldy.w #$0000
	ldx.w console_cursor
-;	lda [ram_args],y
	and.w #$00FF
	sta.l console_map,x
	inx
	inx
	iny
	cmp.w #$0000
	bne -
	dex
	dex
	stx console_cursor
	plp
	rtl

console_newline:
	php
	
	rep #$30
	lda console_cursor
	and.w #$FFC0
	clc
	adc.w #$0040
	sta console_cursor
	plp
	rtl

console_hexbyte:
	//A = byte (A = 8-bit)
	php

	rep #$10
	sep #$20
	pha
	ldx console_cursor
	
	lsr
	lsr
	lsr
	lsr
	cmp.b #$0A
	bcc +
	clc
	adc.b #$37
	bra ++
+;	ora.b #$30
+;	sta.l console_map,x
	inx
	inx
	
	pla
	and.b #$0F
	cmp.b #$0A
	bcc +
	clc
	adc.b #$37
	bra ++
+;	ora.b #$30
+;	sta.l console_map,x
	
	inx
	inx
	stx console_cursor
	
	plp
	rtl

console_nmibusy:
	php
	sep #$20
	stz console_nmi_ready
	plp
	rtl

console_nmiready:
	php
	sep #$20
	lda.b #$01
	sta console_nmi_ready
	plp
	rtl

console_wait:
	php
	rep #$20
-;	lda console_nmi_ready
	bne -
	plp
	rtl

insert font_chr,"../data/Font8_ASCII.chr"
insert font_pal,"../data/Font8.pal"
