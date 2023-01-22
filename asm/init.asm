
initsnes:
        pha
        php             // save all registers and status flag

        sep   #$20      // A = 8-bit mode
        lda.b #$8F      // screen off, full brightness (while initializing)
        sta   $2100     // store to screen register
        stz   $2101     // sprite register (size + address in VRAM)
        stz   $2102     // sprite registers (address of sprite memory [OAM])
        stz   $2103     // "
        stz   $2105     // set graphics Mode 0
        stz   $2106     // no planes, no mosiac
        stz   $2107     // plane 0 map VRAM location ($0000 vram)
        stz   $2108     // plane 1 map VRAM location
        stz   $2109     // plane 2 "
        stz   $210A     // plane 3 "
        stz   $210B     // plane 0+1 tile data location
        stz   $210C     // plane 0+2 "
        stz   $210D     // plane 0 scroll x (first 8 bits)
        stz   $210D     // plane 0 scroll x (last 3 bits) write to reg twice
        stz   $210E     // plane 0 scroll y "
        stz   $210E     // plane 0 scroll y "
        stz   $210F     // plane 1 scroll x (first 8 bits)
        stz   $210F     // plane 1 scroll x (last 3 bits) write to reg twice
        stz   $2110     // plane 1 scroll y "
        stz   $2110     // plane 1 scroll y "
        stz   $2111     // plane 2 scroll x (first 8 bits)
        stz   $2111     // plane 2 scroll x (last 3 bits) write to reg twice
        stz   $2112     // plane 2 scroll y "
        stz   $2112     // plane 2 scroll y "
        stz   $2113     // plane 3 scroll x (first 8 bits)
        stz   $2113     // plane 3 scroll x (last 3 bits) write to reg twice
        stz   $2114     // plane 3 scroll y "
        stz   $2114     // plane 3 scroll y "
        lda.b #$80      // increase VRAM after writes to $2118.19
        sta   $2115     // store to VRAM increment register
        stz   $2116     // VRAM address low
        stz   $2117     // VRAM address hi
        stz   $211A     // init mode 7 setting reg
        stz   $211B     // mode 7 matrix parameter A register (low)
        stz   $211B	// Mode 7 matrix parameter A register (low)
        lda.b #$01
        sta   $211B	// Mode 7 matrix parameter A register (high)
        stz   $211C	// Mode 7 matrix parameter B register (low)
        stz   $211C	// Mode 7 matrix parameter B register (high)
        stz   $211D	// Mode 7 matrix parameter C register (low)
        stz   $211D	// Mode 7 matrix parameter C register (high)
        stz   $211E	// Mode 7 matrix parameter D register (low)
        lda.b #$01
        sta   $211E	// Mode 7 matrix parameter D register (high)
        stz   $211F	// Mode 7 center position X register (low)
        stz   $211F	// Mode 7 center position X register (high)
        stz   $2120	// Mode 7 center position Y register (low)
        stz   $2120	// Mode 7 center position Y register (high)
        stz   $2121	// Color number register ($0-ff)
        stz   $2123	// BG1 & BG2 Window mask setting register
        stz   $2124	// BG3 & BG4 Window mask setting register
        stz   $2125	// OBJ & Color Window mask setting register
        stz   $2126	// Window 1 left position register
        stz   $2127	// Window 2 left position register
        stz   $2128	// Window 3 left position register
        stz   $2129	// Window 4 left position register
        stz   $212A	// BG1, BG2, BG3, BG4 Window Logic register
        stz   $212B     // OBJ, Color Window Logic Register (or,and,xor,xnor)
        lda.b #$01
        sta   $212C	// Main Screen designation (planes, sprites enable)
        stz   $212D	// Sub Screen designation
        stz   $212E	// Window mask for Main Screen
        stz   $212F	// Window mask for Sub Screen
        lda.b #$30
        sta   $2130	// Color addition & screen addition init setting
        stz   $2131	// Add/Sub sub designation for screen, sprite, color
        lda.b #$E0
        sta   $2132	// color data for addition/subtraction
        stz   $2133	// Screen setting (interlace x,y/enable SFX�data)
        stz   $4200	// Enable V-blank, interrupt, Joypad register
        lda.b #$FF
        sta   $4201	// Programmable I/O port
        stz   $4202	// Multiplicand A
        stz   $4203	// Multiplier B
        stz   $4204	// Multiplier C
        stz   $4205	// Multiplicand C
        stz   $4206	// Divisor B
        stz   $4207	// Horizontal Count Timer
        stz   $4208	// Horizontal Count Timer MSB (most significant bit)
        stz   $4209	// Vertical Count Timer
        stz   $420A	// Vertical Count Timer MSB
        stz   $420B	// General DMA enable (bits 0-7)
        stz   $420C	// Horizontal DMA (HDMA) enable (bits 0-7)
        lda.b #$01
        sta   $420D	// Access cycle designation (slow/fast rom)

        plp             // restore processor status (8 or 16 bit mode)
        pla             // restore all registers
        rts
		