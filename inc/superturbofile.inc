inline STF_Init() {
	jsl stf_init
}

inline STF_GetStatus() {
	jsl stf_get_status
}

inline STF_ReadArray(variable addr, variable saddr, variable size) {
	rep #$20
	lda.w #addr
	sta.w ram_args
	lda.w #(addr >> 8)
	sta.w ram_args+1

	lda.w #saddr
	sta.w ram_args+3
	lda.w #(saddr >> 8)
	sta.w ram_args+4

	lda.w #size
	sta.w ram_args+6

	jsl stf_read_array
}

inline STF_Done() {
	jsl stf_cmd_done
}
