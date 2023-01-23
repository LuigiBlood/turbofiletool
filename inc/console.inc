allocateWRAM(console_cursor, 2)
allocateWRAM(console_nmi_ready, 2)
allocate(console_map, $7E2000, 0x800)

//Use this to init console
macro consoleInit() {
	jsl console_init
}

//Use this once every frame
macro consoleNMI() {
	jsl console_nmi
}

//Use this to print a string
macro consolePrint(variable addr) {
	rep #$20
	lda.w #addr
	sta.b ram_args
	lda.w #(addr >> 8)
	sta.b ram_args+1
	jsl console_print
}

//Use this to use a new line
macro consoleNewLine() {
	jsl console_newline
}

//Don't use this
macro consoleNMIBusy() {
	jsl console_nmibusy
}

//Use this to tell Console NMI the screen is ready to be uploaded
macro consoleNMIReady() {
	jsl console_nmiready
}

//Use this to wait for screen update
macro consoleWait() {
	jsl console_wait
}

//Use this to change cursor position
inline consolePosition(variable x, variable y) {
	rep #$20
	lda.w #((x*2)+(y*32))
	sta console_cursor
}
