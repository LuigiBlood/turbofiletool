architecture snes.cpu

//Macros
include "../inc/snes.inc"
include "../inc/snes_alloc.inc"
include "../inc/macros.inc"

//Libraries
include "../inc/console.inc"
include "../inc/superturbofile.inc"

allocate(sram, $F00000, $20000)

seek($FFC0)
db "TURBOFILE TEST       "
db $30
db $02	//ROM+RAM+Battery
db $08
db $07	//128KB RAM
db $00
db $00
db $00
dw $FFFF, $0000

dw $2011, $2011, _cop_r, _brk_r, _lock, _nmi_r, _lock, _irq_r
dw $2011, $2011, _lock, _lock, _lock, _lock, _start, _lock

seek($808000)

_cop_r:
	jml _cop

_brk_r:
	jml _brk

_nmi_r:
	jml _nmi

_irq_r:
	jml _irq

_cop:
_brk:
_irq:
_lock:
	bra _lock

_nmi:
	php
	rep #$30
	pha
	phx
	phy
	phb
	phd
	
	phk
	plb
	
	sep #$20
	lda.w RDNMI	//Acknowledge NMI
	lda.b #$8F
	sta.w INIDISP
	
	//Do VBlank specific stuff
	consoleNMI()
	
	sep #$20
	lda.b #$0F
	sta.w INIDISP

	//Stuff you can do outside of VBlank (safe)
	jsl joypad_controller_update

	rep #$30	
	pld
	plb
	ply
	plx
	pla
	
	plp
	rti

_start:
	clc
	xce
	jsr initsnes
	jml start

include "init.asm"

allocateWRAM(ram_counter, 1)

start:
	consoleInit()
	jsl joypad_init
	STF_Init()
	sep #$20
	lda.b #$80
	sta.w NMITIMEN	//Enable NMI

	stz ram_counter
	
	consoleNewLine()
	consoleNewLine()
	consolePrint(string_title)
	consoleNewLine()
	consolePrint(string_port1)

	lda joypad1_id
	jsl console_hexbyte
	lda joypad1_id+1
	jsl console_hexbyte

	consoleNewLine()
	consolePrint(string_port2)

	lda joypad2_id
	jsl console_hexbyte
	lda joypad2_id+1
	jsl console_hexbyte
	consoleNMIReady()
	consoleWait()

	rep #$20
	lda.w joypad2_id
	cmp.w #$FE0E
	beq +
	consoleNewLine()
	consolePrint(string_notfound)

	consoleNMIReady()
	consoleWait()
	brl ++

+;	consoleNewLine()
	consolePrint(string_stfdump)

	consoleNMIReady()
	consoleWait()

	sep #$20
	stz.w NMITIMEN //Disable NMI

	//Test read
	STF_GetStatus()
	STF_ReadArray(0x00000, $F00000, 0x8000)
	STF_ReadArray(0x08000, $F10000, 0x8000)
	STF_ReadArray(0x10000, $F20000, 0x8000)
	STF_ReadArray(0x18000, $F30000, 0x8000)

	sep #$20
	lda.b #$80
	sta.w NMITIMEN	//Enable NMI

	consoleNewLine()
	consolePrint(string_stfcheck)

	consoleNMIReady()
	consoleWait()
+;
start_loop:
	rep #$20
	lda.w #$0180
	sta console_cursor
	
	lda ram_counter
	jsl console_hexbyte

	consoleNMIReady()
	consoleWait()
	inc ram_counter
	bvc start_loop
	
	jml _lock

string_title:
	db "  -- Turbo File Test --",0
string_port1:
	db "  Controller Port 1: ",0
string_port2:
	db "  Controller Port 2: ",0

string_notfound:
	db "  Turbo File not found.",0

string_stfdump:
	db "  Dumping Super Turbo File...",0

string_stfcheck:
	db "  Successfully dumped",0

include "console.asm"
include "joypad.asm"
include "superturbofile.asm"
