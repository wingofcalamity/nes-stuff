;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  PRG_COUNT = 2
  CHR_COUNT = 1
  JOY1 = $4016
  JOY2 = $4017
  PPUADDR = $2006
  PPUDATA = $2007

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  .db "NES", $1a             ; signature
  .db PRG_COUNT              ; prg in 16kb units
  .db CHR_COUNT              ; chr in 8kb units
  .db 1                      ; mirroring
  .dsb 9, $00                ; fill header
  .base (PRG_COUNT*$4000)    ; set for addressing

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

RESET:
  SEI
  CLD
  LDX #$40
  STX $4017
  LDX #$ff
  TXS
  INX
  STX $2000
  STX $2001
  STX $4010

vblank1:
  BIT $2002
  BPL vblank1

clearmem:
  LDA #$00
  STA $000,x
  STA $100,x
  STA $200,x
  STA $300,x
  STA $400,x
  STA $500,x
  STA $600,x
  STA $700,x
  INX
  BNE clearmem

vblank2:
  BIT $2002
  BPL vblank2

initPalette:
  LDA $2002
  LDA #$3F
  STA PPUADDR
  LDA #$00
  STA PPUADDR
  LDX #$00

loadBackgroundPalette:
  LDA backgroundPalette,x
  STA PPUDATA
  INX
  CPX #$10
  BNE loadBackgroundPalette

  LDX #$0                   ; reset X

loadSpritePalette:
  LDA spritePalette,x
  STA PPUDATA
  INX
  CPX #$10
  BNE loadSpritePalette

  LDA #10000000b
  STA $2000
  LDA #00010000b
  STA $2001

  LDX #$08
  LDA #$7B
  STA $00
  LDA #$73
  STA $01 
mainLoop:
  JMP mainLoop

NMI:
Latch:
  LDA #1
  STA JOY1
  LDA #0
  STA JOY1
  ;; skip buttons
  LDA JOY1 ; A
  LDA JOY1 ; B
  LDA JOY1 ; Start
  LDA JOY1 ; Select

ReadUp:
  LDA JOY1
  AND #1
  BEQ ReadDown
  LDX $00
  DEX
  STX $00
ReadDown:
  LDA JOY1
  AND #1
  BEQ ReadLeft
  LDX $00
  INX
  STX $00
ReadLeft:
  LDA JOY1
  AND #1
  BEQ ReadRight
  LDX $01
  DEX
  STX $01
ReadRight:
  LDA JOY1
  AND #1
  BEQ ReadDone
  LDX $01
  INX
  STX $01
ReadDone:
InitSprite:
  LDA #$00
  STA $2003
  LDA #$02
  STA $4014
DrawSprite:
  LDA $00 
  STA $0200
  LDA #$01
  STA $0201
  LDA #$00
  STA $0202
  LDA $01
  STA $0203
  RTI

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  .org $E000
backgroundPalette:
  .db $3F,$01,$05,$0B
  .db $3F,$01,$05,$0B
  .db $3F,$01,$05,$0B
  .db $3F,$01,$05,$0B
 
spritePalette:
  .db $3F,$27,$29,$2C
  .db $3F,$27,$29,$2C
  .db $3F,$27,$29,$2C
  .db $3F,$27,$29,$2C

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
interruptVectors:
  .org $FFFA
  .dw NMI                    ; NMI
  .dw RESET                  ; Reset
  .dw 0                      ; IRQ

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
incbin chr.bin