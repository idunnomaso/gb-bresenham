INCLUDE "hardware.inc"

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

SECTION "STAT Interrupt", ROM0[$48]

	jp StatHandler

SECTION "Entry Point", ROM0[$100]

	di
	jp Startup

SECTION "Header - Part 1", ROM0[$104]

	NINTENDO_LOGO

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

	call InitApa

	ld a, STATF_LYC | STATF_MODE01
	ldh [rSTAT], a

	ld a, 96
	ldh [rLYC], a

	ld a, $1B
	ldh [rBGP], a
	ldh [rOBP0], a
	ldh [rOBP1], a

	ld a, IEF_STAT
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

StatHandler:
	push af
	ldh a, [rLCDC]
	xor a, LCDCF_BLK01
	ldh [rLCDC], a
	pop af
	reti