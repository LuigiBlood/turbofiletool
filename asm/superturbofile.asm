//Super Turbo File

allocateWRAM(stf_last_cmd, 1)
allocateWRAM(stf_scratch, 1)
allocateWRAM(stf_last_stat, 3)

db "SUPER TURBO FILE YAKU00"

stf_init:
	php
	rep #$30
	stz.w stf_last_cmd
	stz.w stf_last_stat+0
	stz.w stf_last_stat+1
	plp
	rtl

stf_get_status:
	php
	rep #$30
	stz.w stf_last_stat+0
	stz.w stf_last_stat+1
	sep #$30

	//Reset
	lda.b #$01
	sta.w JOYWR
	stz.w JOYWR

	//Skip 12 bits
	ldx.b #12
-;	lda.w JOYB
	dex
	bne -

	//Get 4 bits
	ldx.b #4
-;	lda.w JOYB
	lsr
	rol.w stf_last_stat+0
	dex
	bne -

	//Check if it's 0x0E
	lda.w stf_last_stat+0
	cmp.b #$0E
	beq +
	//Error
	plp
	sec
	rtl

+;	//Get 8 bits
	lda.b #$01
	sta.w stf_last_stat+1
-;	lda.w JOYB
	lsr
	rol.w stf_last_stat+1
	bcc -

	//Check if it's 0xFE
	lda.w stf_last_stat+1
	cmp.b #$FE
	beq +
	//Error
	plp
	sec
	rtl

+;	//Get 8 bits
	lda.b #$01
	sta.w stf_last_stat+2
-;	lda.w JOYB
	lsr
	rol.w stf_last_stat+2
	bcc -

	plp
	clc
	rtl

stf_cmd_done:
	php
	sep #$30
	lda.b #$01
	sta.w JOYWR
	lda.w stf_last_cmd
	bne +
	//Read Command only
	lda.w JOYB

+;	stz.w JOYWR
	//Check Status
	jsl stf_get_status
	lda.w stf_last_cmd
	bne +
	//Read Check
	bit.w stf_last_stat+2
	bvc ++
	plp
	brl stf_cmd_done

+;	//Write Check
	bit.w stf_last_stat+2
	bpl +
	plp
	brl stf_cmd_done

+;	plp
	rtl

//ram_args = Address (3 bytes)
stf_cmd_read:
	php
	sep #$30
	ldx.b #$00
	lda.b #$24
	jsl _stf_cmd_proc
	bcc +
	brl _stf_error
+;	//Check General Error bit
	lda.w stf_last_stat+2
	and.b #$20
	beq +
	brl _stf_error
+;	//Check if Read mode is set
	bit.w stf_last_stat+2
	bvs +
	//Retry if not set
	plp
	brl stf_cmd_read

+;	plp
	clc
	rtl

stf_cmd_write:
	php
	sep #$30
	ldx.b #$01
	lda.b #$75
	jsl _stf_cmd_proc
	bcc +
	brl _stf_error
+;	//Check General Error bit & Write Protect bit
	lda.w stf_last_stat+2
	and.b #$30
	beq +
	brl _stf_error
+;	//Check if Write mode is set
	bit.w stf_last_stat+2
	bmi +
	//Retry if not set
	plp
	brl stf_cmd_write

+;	plp
	clc
	rtl

_stf_cmd_proc:
	stx.w stf_last_cmd
	sta.w stf_scratch
	lda.b #$01
	sta.w JOYWR
	clc

	//Send CMD
	ldy.b #$00
	ldx.b #$08
-;	lsr.w stf_scratch
	tya
	ror
	sta.w WRIO
	lda.w JOYB
	dex
	bne -

	//Send ADDR
	ldx.b #$08
-;	lsr.w ram_args+0
	tya
	ror
	sta.w WRIO
	lda.w JOYB
	dex
	bne -

	ldx.b #$08
-;	lsr.w ram_args+1
	tya
	ror
	sta.w WRIO
	lda.w JOYB
	dex
	bne -

	ldx.b #$04
-;	lsr.w ram_args+2
	tya
	ror
	sta.w WRIO
	lda.w JOYB
	dex
	bne -

	stz.w JOYWR

	jsl stf_get_status
	rtl

_stf_error:
	plp
	sec
	rtl

stf_read8:
	php
	sep #$20
	lda.b #$80
	sta.w stf_scratch
	lda.b #$01
	sta.w JOYWR
	stz.w JOYWR
	//Recv byte
-;	lda.w JOYB
	eor.b #$02
	lsr; lsr
	ror.w stf_scratch
	bcc -
	//Return byte
	lda.w stf_scratch

	plp
	rtl

stf_write8:
	//A = write byte
	php
	sep #$30
	sta.w stf_scratch
	ldy.b #$00
	ldx.b #$01
	stx.w JOYWR
	//Send byte
	ldx.b #$08
-;	lsr.w stf_scratch
	tya
	ror
	sta.w WRIO
	lda.w JOYB
	dex
	bne -

	stz.w JOYWR

	plp
	rtl

stf_read_array:
	//ram_args+0 = STF Address
	//ram_args+3 = SNES Long Address to read to
	//ram_args+6 = Byte amount
	php
	rep #$20

	jsl stf_cmd_read

	rep #$10
	sep #$20
	ldx.w ram_args+6
	ldy.w #$0000

-;	phy
	jsl stf_read8
	ply
	sta [ram_args+3],y
	iny
	dex
	bne -

	jsl stf_cmd_done

	plp
	rtl
