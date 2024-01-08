INCLUDE "hardware.inc"

MACRO get_delta
	ld a, \2
	sub a, \1
	ld \3, a

	ld a, 1
	ld [\4], a

	jr nc, .isPositive\@

	ld a, \3
	cpl
	inc a
	ld \3, a

	ld a, 255
	ld [\4], a

.isPositive\@
ENDM

MACRO draw_line
	srl \4

	ld a, \5
	sub a, \4
	ld \6, a

.loopPosition\@
	push de
	push hl

	call DrawPixel

	pop hl
	pop de

	bit 7, \6
	jr nz, .isNegative\@

	ld a, \6
	sub a, \4
	sub a, \4
	ld \6, a

	ld a, [\8]
	add a, \3
	ld \3, a

.isNegative\@
	ld a, \6
	add a, \5
	ld \6, a

	ld a, [\7]
	add a, \1
	ld \1, a

	cp a, \2
	jr nz, .loopPosition\@

	ret
ENDM

MACRO wait_stat
.waitStat\@
	ldh a, [rSTAT]
	and a, STATF_BUSY
	jr nz, .waitStat\@
ENDM

SECTION "APA Functions", ROM0

DrawLine::
	get_delta b, d, h, wXInc
	get_delta c, e, l, wYInc

	ld a, h
	cp a, l
	jr c, .dyLonger

	draw_line b, d, c, h, l, e, wXInc, wYInc

.dyLonger
	draw_line c, e, b, l, h, d, wYInc, wXInc

DrawPixel::
	ld d, 0
	ld e, c
	ld hl, YLut

	add hl, de
	add hl, de

	ld a, [hli]
	ld h, [hl]
	ld l, a

	ld a, b
	and a, 248
	ld e, a

	add hl, de
	add hl, de

	ld a, b
	and a, 7
	ld e, a
	ld d, HIGH(MaskLut)

	di
	wait_stat
	ld a, [de]
	or a, [hl]
	ld [hli], a
	ld [hl], a
	ei

	ret

InitApa::
	xor a, a
	ldh [rSCX], a
	ldh [rSCY], a

	ld bc, ApaTilemap
	ld e, 18
	ld hl, _SCRN0

.loopRows
	ld d, 20

.loopColumns
	di
	wait_stat
	ld a, [bc]
	ld [hli], a
	ei

	inc bc
	dec d
	jr nz, .loopColumns

	push bc
	ld bc, 12
	add hl, bc
	pop bc

	dec e
	jr nz, .loopRows

	ret

SECTION "APA Tilemap", ROMX

ApaTilemap:
	db $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1A, $1B, $1C, $1D, $1E, $1F
	db $20, $21, $22, $23, $24, $25, $26, $27, $28, $29, $2A, $2B, $2C, $2D, $2E, $2F
	db $30, $31, $32, $33, $34, $35, $36, $37, $38, $39, $3A, $3B, $3C, $3D, $3E, $3F
	db $40, $41, $42, $43, $44, $45, $46, $47, $48, $49, $4A, $4B, $4C, $4D, $4E, $4F
	db $50, $51, $52, $53, $54, $55, $56, $57, $58, $59, $5A, $5B, $5C, $5D, $5E, $5F
	db $60, $61, $62, $63, $64, $65, $66, $67, $68, $69, $6A, $6B, $6C, $6D, $6E, $6F
	db $70, $71, $72, $73, $74, $75, $76, $77, $78, $79, $7A, $7B, $7C, $7D, $7E, $7F
	db $80, $81, $82, $83, $84, $85, $86, $87, $88, $89, $8A, $8B, $8C, $8D, $8E, $8F
	db $90, $91, $92, $93, $94, $95, $96, $97, $98, $99, $9A, $9B, $9C, $9D, $9E, $9F
	db $A0, $A1, $A2, $A3, $A4, $A5, $A6, $A7, $A8, $A9, $AA, $AB, $AC, $AD, $AE, $AF
	db $B0, $B1, $B2, $B3, $B4, $B5, $B6, $B7, $B8, $B9, $BA, $BB, $BC, $BD, $BE, $BF
	db $C0, $C1, $C2, $C3, $C4, $C5, $C6, $C7, $C8, $C9, $CA, $CB, $CC, $CD, $CE, $CF
	db $D0, $D1, $D2, $D3, $D4, $D5, $D6, $D7, $D8, $D9, $DA, $DB, $DC, $DD, $DE, $DF
	db $E0, $E1, $E2, $E3, $E4, $E5, $E6, $E7, $E8, $E9, $EA, $EB, $EC, $ED, $EE, $EF
	db $F0, $F1, $F2, $F3, $F4, $F5, $F6, $F7, $F8, $F9, $FA, $FB, $FC, $FD, $FE, $FF
	db $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0D, $0E, $0F
	db $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1A, $1B, $1C, $1D, $1E, $1F
	db $20, $21, $22, $23, $24, $25, $26, $27, $28, $29, $2A, $2B, $2C, $2D, $2E, $2F
	db $30, $31, $32, $33, $34, $35, $36, $37, $38, $39, $3A, $3B, $3C, $3D, $3E, $3F
	db $40, $41, $42, $43, $44, $45, $46, $47, $48, $49, $4A, $4B, $4C, $4D, $4E, $4F
	db $50, $51, $52, $53, $54, $55, $56, $57, $58, $59, $5A, $5B, $5C, $5D, $5E, $5F
	db $60, $61, $62, $63, $64, $65, $66, $67, $68, $69, $6A, $6B, $6C, $6D, $6E, $6F
	db $70, $71, $72, $73, $74, $75, $76, $77

SECTION "Mask Lookup Table", ROMX, ALIGN[8]

MaskLut:
	db $80, $40, $20, $10, $08, $04, $02, $01

SECTION "Y Lookup Table", ROMX

YLut:
	dw $8100, $8102, $8104, $8106, $8108, $810A, $810C, $810E
	dw $8240, $8242, $8244, $8246, $8248, $824A, $824C, $824E
	dw $8380, $8382, $8384, $8386, $8388, $838A, $838C, $838E
	dw $84C0, $84C2, $84C4, $84C6, $84C8, $84CA, $84CC, $84CE
	dw $8600, $8602, $8604, $8606, $8608, $860A, $860C, $860E
	dw $8740, $8742, $8744, $8746, $8748, $874A, $874C, $874E
	dw $8880, $8882, $8884, $8886, $8888, $888A, $888C, $888E
	dw $89C0, $89C2, $89C4, $89C6, $89C8, $89CA, $89CC, $89CE
	dw $8B00, $8B02, $8B04, $8B06, $8B08, $8B0A, $8B0C, $8B0E
	dw $8C40, $8C42, $8C44, $8C46, $8C48, $8C4A, $8C4C, $8C4E
	dw $8D80, $8D82, $8D84, $8D86, $8D88, $8D8A, $8D8C, $8D8E
	dw $8EC0, $8EC2, $8EC4, $8EC6, $8EC8, $8ECA, $8ECC, $8ECE
	dw $9000, $9002, $9004, $9006, $9008, $900A, $900C, $900E
	dw $9140, $9142, $9144, $9146, $9148, $914A, $914C, $914E
	dw $9280, $9282, $9284, $9286, $9288, $928A, $928C, $928E
	dw $93C0, $93C2, $93C4, $93C6, $93C8, $93CA, $93CC, $93CE
	dw $9500, $9502, $9504, $9506, $9508, $950A, $950C, $950E
	dw $9640, $9642, $9644, $9646, $9648, $964A, $964C, $964E

SECTION "X and Y Increments", WRAM0

wXInc:
	db

wYInc:
	db