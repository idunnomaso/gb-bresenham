; main.asm

INCLUDE "hardware.inc"

MACRO set_palette
	ld a, \1CPSF_AUTOINC
	ldh [r\1CPS], a

	ld b, 0
	ld d, 64
	ld hl, r\1CPD

.loopCpd\@
	ld [hl], b
	dec d
	jr nz, .loopCpd\@
ENDM

SECTION "RST Vector 0", ROM0[$0]

CopyMemory::
	ld a, [bc]
	ld [hli], a
	inc bc
	dec de
	ld a, d
	or a, e
	jr nz, CopyMemory
	ret

SECTION "RST Vector 10", ROM0[$10]

SetMemory::
	ld a, b
	ld [hli], a
	dec de
	ld a, d
	or a, e
	jr nz, SetMemory
	ret

SECTION "VBlank Interrupt", ROM0[$40]

	jp VblankHandler

SECTION "Entry Point", ROM0[$100]

	di
	jp Startup

SECTION "Header - Part 1", ROM0[$104]

	NINTENDO_LOGO

SECTION "Header - Part 2", ROM0[$143]

	db CART_COMPATIBLE_GBC

SECTION "Startup Routine", ROM0[$150]

Startup:
	ldh a, [rLY]
	cp a, 144
	jr nz, Startup

	xor a, a
	ldh [rLCDC], a

	ld b, 0
	ld de, _SRAM - _VRAM
	ld hl, _VRAM
	rst 16

	ld a, 1
	ldh [rVBK], a

	ld b, 8
	ld de, _SCRN1 - _SCRN0
	ld hl, _SCRN0
	rst 16

	xor a, a
	ldh [rVBK], a

	call InitLineDrawing

	ld de, wShadowOam.end - wShadowOam
	ld hl, wShadowOam
	rst 16

	set_palette B
	set_palette O

	ld a, BCPSF_AUTOINC + 6
	ldh [rBCPS], a

	ld bc, $FF7F
	ld hl, rBCPD

	ld [hl], b
	ld [hl], c

	ld bc, OamDmaSource
	ld de, OamDmaSource.end - OamDmaSource
	ld hl, hOamDmaDest
	rst 0

	ld a, IEF_VBLANK
	ldh [rIE], a
	xor a, a
	ldh [rIF], a
	ei

	ld a, LCDCF_ON | LCDCF_BLK01 | LCDCF_BGON
	ldh [rLCDC], a

	ld b, 0
	ld c, 24
	ld d, 159
	ld e, 119
	call DrawLine

	ld b, 98
	ld c, 54
	ld d, 44
	ld e, 73
	call DrawLine

MainLoop::
	halt
	jr MainLoop

OamDmaSource:
	ldh [rDMA], a
	ld a, 53
.wait636
	dec a
	jr nz, .wait636
	ret
.end

VblankHandler:
	push af
	ld a, HIGH(wShadowOam)
	call hOamDmaDest
	pop af
	reti

SECTION "Shadow OAM", WRAM0, ALIGN[8]

wShadowOam::
	ds 4 * OAM_COUNT
.end

SECTION "OAM DMA Destination", HRAM

hOamDmaDest:
	ds OamDmaSource.end - OamDmaSource