  include "ggsound.inc"
song_index_4eew20song = 0 
  .inesprg 1   ; 1x 16KB PRG code
  .ineschr 1   ; 1x  8KB CHR data
  .inesmap 0   ; mapper 0 = NROM, no bank swapping
  .inesmir 1   ; background mirroring
  

;;;;;;;;;;;;;;;

  .rsset $0000       ; put pointers in zero page
  include "audio/ggsound_zp.inc"
pointerLo  .rs 1   ; pointer variables are declared in RAM
pointerHi  .rs 1   ; low byte first, high byte immediately after
gamepad1   .rs 1   ; player 1 gamepad gamepad, 1 bit/button
gamepad2   .rs 1   ; player 2 gamepad gamepad, 1 bit/button
gamestate  .rs 1   ; current gamestate
backgroundon .rs 1 ; shows background
ballx         .rs 1  ; ball horizontal position
bally         .rs 1  ; ball vertical position
ballup        .rs 1  ; 1 = ball moving up
balldown      .rs 1  ; 1 = ball moving down
ballleft      .rs 1  ; 1 = ball moving left
ballright     .rs 1  ; 1 = ball moving right
ballspeedx    .rs 1  ; ball horizontal speed per frame
ballspeedy    .rs 1  ; ball vertical speed per frame
ballrightcheck .rs 1
paddle1ytop   .rs 1  ; player 1 paddle top vertical position
paddle1ybot   .rs 1
paddle1ybotcheck .rs 1
paddle1ytopcheck .rs 1
paddle2ytop   .rs 1
paddle2ybot   .rs 1
paddle2ybotcheck .rs 1  ; player 2 paddle bottom vertical position
paddle2ytopcheck .rs 1
comppadup     .rs 1
comppaddown   .rs 1
comppadspeed  .rs 1
scoreOnes     .rs 1  ; byte for each digit in the decimal score
scoreTens     .rs 1
scoreHundreds .rs 1

;; CONSTANT DECLARATIONS
STATETITLE    = $00 ; displaying title screen
STATEPLAYING  = $01 ; main game state, player controls sprites
STATEGAMEOVER = $02 ; displaying gameover screen

RIGHTWALL      = $F4  ; when ball reaches one of these, do something
TOPWALL        = $20
BOTTOMWALL     = $E0
LEFTWALL       = $04
  
PADDLE1X       = $08  ; horizontal position for paddles, doesnt move
PADDLE2X       = $F0
PADDLE1COLLISION = $0E

;;;;;;;;;;;;;;;
  .rsset $0400
  include "audio/ggsound_ram.inc"
  
  .bank 0
  .org $8000 
  include "audio/ggsound.asm"
  include "audio/sounds.asm"
RESET:
  SEI          ; disable IRQs
  CLD          ; disable decimal mode
  LDX #$40
  STX $4017    ; disable APU frame IRQ
  LDX #$FF
  TXS          ; Set up stack
  INX          ; now X = 0
  STX $2000    ; disable NMI
  STX $2001    ; disable rendering
  STX $4010    ; disable DMC IRQs

vblankwait1:       ; First wait for vblank to make sure PPU is ready
  BIT $2002
  BPL vblankwait1

clrmem:
  LDA #$00
  STA $0000, x
  STA $0100, x
  STA $0300, x
  STA $0400, x
  STA $0500, x
  STA $0600, x
  STA $0700, x
  LDA #$FE
  STA $0200, x
  INX
  BNE clrmem
   
vblankwait2:      ; Second wait for vblank, PPU is ready after this
  BIT $2002
  BPL vblankwait2

LoadPalettes:
  LDA $2002             ; read PPU status to reset the high/low latch
  LDA #$3F
  STA $2006             ; write the high byte of $3F00 address
  LDA #$00
  STA $2006             ; write the low byte of $3F00 address
  LDX #$00              ; start out at 0
LoadPalettesLoop:
  LDA palette, x        ; load data from address (palette + the value in x)
                          ; 1st time through loop it will load palette+0
                          ; 2nd time through loop it will load palette+1
                          ; 3rd time through loop it will load palette+2
                          ; etc
  STA $2007             ; write to PPU
  INX                   ; X = X + 1
  CPX #$04              ; Compare X to hex $10, decimal 16 - copying 16 bytes = 4 sprites
  BNE LoadPalettesLoop  ; Branch to LoadPalettesLoop if compare was Not Equal to zero
                        ; if compare was equal to 32, keep going down

  ;;;Set some initial ball stats
  LDA #$01
  STA balldown
  STA ballright
  STA comppadup
  LDA #$00
  STA ballup
  STA ballleft
  STA comppaddown
  
  LDA #$50
  STA bally
  
  LDA #$80
  STA ballx
  
  LDA #$86
  STA ballrightcheck
  
  LDA #$02
  STA comppadspeed
  
  LDA #$02
  STA ballspeedy
  STA ballspeedx
  
  LDA #PADDLE1X
  STA $0207
  LDA #$80
  STA paddle1ytop
  
  LDA paddle1ytop
  SEC
  SBC #$10
  STA paddle1ytopcheck    
  
  LDA #PADDLE1X
  STA $020B
  LDA #$78
  STA paddle1ybot
  
  LDA paddle1ybot
  CLC
  ADC #$10
  STA paddle1ybotcheck  

  LDA #PADDLE2X
  STA $020F
  LDA #$80
  STA paddle2ytop
  
  LDA paddle2ytop
  SEC
  SBC #$10
  STA paddle2ytopcheck    

  LDA #PADDLE2X
  STA $0213
  LDA #$78
  STA paddle2ybot
  
  LDA paddle2ybot
  CLC
  ADC #$10
  STA paddle2ybotcheck  


;;;Set initial score value
  LDA #$00
  STA scoreOnes
  STA scoreTens
  STA scoreHundreds
						
						
  LDA #STATETITLE
  STA gamestate						


LoadSprites:
  LDX #$00              ; start at 0
LoadSpritesLoop:
  LDA sprites, x        ; load data from address (sprites +  x)
  STA $0200, x          ; store into RAM address ($0200 + x)
  INX                   ; X = X + 1
  CPX #$10              ; Compare X to hex $10, decimal 16
  BNE LoadSpritesLoop   ; Branch to LoadSpritesLoop if compare was Not Equal to zero
                        ; if compare was equal to 16, keep going down
              
			  

  LoadBackground:
  LDA $2002             ; read PPU status to reset the high/low latch
  LDA #$20
  STA $2006             ; write the high byte of $2000 address
  LDA #$00
  STA $2006             ; write the low byte of $2000 address
  LDA #$00
  STA pointerLo       ; put the low byte of the address of background into pointer
  LDA #HIGH(background)
  STA pointerHi       ; put the high byte of the address into pointer
  
  LDX #$00            ; start at pointer + 0
  LDY #$00
OutsideLoop:
  
InsideLoop:
  LDA [pointerLo], y  ; copy one background byte from address in pointer plus Y
  STA $2007           ; this runs 256 * 4 times
  
  INY                 ; inside loop counter
  CPY #$00
  BNE InsideLoop      ; run the inside loop 256 times before continuing down
  
  INC pointerHi       ; low byte went 0 to 256, so high byte needs to be changed now
  
  INX
  CPX #$04
  BNE OutsideLoop     ; run the outside loop 256 times before continuing down
			  
  LDA #%10000000   ; enable NMI, sprites and background from Pattern Table 0
  STA $2000

  LDA #%00011110   ; enable sprites, enable background, no clipping on left side
  STA $2001
  
  LDA #SOUND_REGION_NTSC
  STA sound_param_byte_0
  LDA #low(song_list)
  STA sound_param_word_0
  LDA #high(song_list)
  STA sound_param_word_0+1
  LDA #low(instrument_list)
  STA sound_param_word_2
  LDA #high(instrument_list)
  STA sound_param_word_2+1
  JSR sound_initialize
	
  LDA #song_index_4eew20song
  STA sound_param_byte_0
  JSR play_song

Forever:
  JMP Forever     ;jump back to Forever, infinite loop
  
 

NMI:

  PHA
  TXA
  PHA
  TYA
  PHA
  PHP
  
  LDA #$00
  STA $2003       ; set the low byte (00) of the RAM address
  LDA #$02
  STA $4014       ; set the high byte (02) of the RAM address, start the transfer





  ;;This is the PPU clean up section, so rendering the next frame starts properly.
  LDA #%10000000   ; enable NMI, sprites and background from Pattern Table 0
  STA $2000
  LDA #%00011110   ; enable sprites, enable background, no clipping on left side
  STA $2001
  LDA #$00        ;;tell the ppu there is no background scrolling
  STA $2005
  STA $2005

  JSR ReadController1
  JSR ReadController2
  
GameEngine:
  LDA gamestate
  CMP #STATETITLE
  BEQ EngineTitle  ; display title screen
  
GameEngineDone:

  JSR UpdateSprites
  
  soundengine_update
  PLP
  PLA
  TAY
  PLA
  TAX
  PLA

  RTI             ; return from interrupt

  RTI             ; return from interrupt
 
;;;;;;;;;;;;;;;;;;  
  
EngineTitle:

EnginePlaying:

MoveBallRight:
  LDA ballright
  BEQ MoveBallRightDone   ;;if ballright=0, skip this section

  LDA ballx
  CLC
  ADC ballspeedx        ;;ballx position = ballx + ballspeedx
  STA ballx
  
  LDA ballrightcheck
  CLC
  ADC ballspeedx        ;;ballx position = ballx + ballspeedx
  STA ballrightcheck

  LDA ballx
  CMP #RIGHTWALL
  BCC MoveBallRightDone      ;;if ball x < right wall, still on screen, skip next section
  JSR ResetPos
  ;;in real game, give point to player 1, reset ball
  jsr IncrementScore
MoveBallRightDone:


MoveBallLeft:
  LDA ballleft
  BEQ MoveBallLeftDone   ;;if ballleft=0, skip this section

  LDA ballx
  SEC
  SBC ballspeedx        ;;ballx position = ballx - ballspeedx
  STA ballx
  
  LDA ballrightcheck
  SEC
  SBC ballspeedx        ;;ballx position = ballx - ballspeedx
  STA ballrightcheck

  LDA ballx
  CMP #LEFTWALL
  BCS MoveBallLeftDone      ;;if ball x > left wall, still on screen, skip next section
  LDA #$01
  STA ballright
  JSR ResetPos
  ;;in real game, give point to player 2, reset ball
  jsr IncrementScore
MoveBallLeftDone:


MoveBallUp:
  LDA ballup
  BEQ MoveBallUpDone   ;;if ballup=0, skip this section

  LDA bally
  SEC
  SBC ballspeedy        ;;bally position = bally - ballspeedy
  STA bally

  LDA bally
  CMP #TOPWALL
  BCS MoveBallUpDone      ;;if ball y > top wall, still on screen, skip next section
  LDA #$01
  STA balldown
  LDA #$00
  STA ballup         ;;bounce, ball now moving down
MoveBallUpDone:


MoveBallDown:
  LDA balldown
  BEQ MoveBallDownDone   ;;if ballup=0, skip this section

  LDA bally
  CLC
  ADC ballspeedy        ;;bally position = bally + ballspeedy
  STA bally

  LDA bally
  CMP #BOTTOMWALL
  BCC MoveBallDownDone      ;;if ball y < bottom wall, still on screen, skip next section
  LDA #$00
  STA balldown
  LDA #$01
  STA ballup         ;;bounce, ball now moving down
MoveBallDownDone: 

MovePaddle1Up:
  JSR ReadController1
  LDA gamepad1
  AND #%00000100
  BEQ MovePaddle1UpDone
  
  LDA paddle1ytop
  CLC
  ADC #$02
  STA paddle1ytop
  LDA paddle1ybot
  CLC
  ADC #$02
  STA paddle1ybot 

  LDA paddle1ybotcheck  
  CLC
  ADC #$02
  STA paddle1ybotcheck
  LDA paddle1ytopcheck  
  CLC
  ADC #$02
  STA paddle1ytopcheck  
  ;;if up button pressed
  ;;  if paddle top > top wall
  ;;    move paddle top and bottom up
MovePaddle1UpDone:

MovePaddle1Down:
  JSR ReadController1
  LDA gamepad1
  AND #%00001000
  BEQ MovePaddle1DownDone
  
  LDA paddle1ytop   ; load sprite X position
  SEC             ; make sure carry flag is set
  SBC #$02        ; A = A - 1
  STA paddle1ytop  
  LDA paddle1ybot   ; load sprite X position
  SEC             ; make sure carry flag is set
  SBC #$02        ; A = A - 1
  STA paddle1ybot
  
  LDA paddle1ybotcheck  
  SEC
  SBC #$02
  STA paddle1ybotcheck
  LDA paddle1ytopcheck  
  SEC
  SBC #$02
  STA paddle1ytopcheck  
  ;;if down button pressed
  ;;  if paddle bottom < bottom wall
  ;;    move paddle top and bottom down
MovePaddle1DownDone:

MoveComputerPaddleUp:
  JSR ReadController2
  LDA gamepad2
  AND #%00000100
  BEQ MoveComputerPaddleUpDone
  
  LDA paddle2ytop
  CLC
  ADC #$02
  STA paddle2ytop
  LDA paddle2ybot
  CLC
  ADC #$02
  STA paddle2ybot 

  LDA paddle2ybotcheck  
  CLC
  ADC #$02
  STA paddle2ybotcheck
  LDA paddle2ytopcheck  
  CLC
  ADC #$02
  STA paddle2ytopcheck  
  ;;if up button pressed
  ;;  if paddle top > top wall
  ;;    move paddle top and bottom up
MoveComputerPaddleUpDone:  
  
MoveComputerPaddleDown: 
  JSR ReadController2
  LDA gamepad2
  AND #%00001000
  BEQ MoveComputerPaddleDownDone
  
  LDA paddle2ytop   ; load sprite X position
  SEC             ; make sure carry flag is set
  SBC #$02        ; A = A - 1
  STA paddle2ytop  
  LDA paddle2ybot   ; load sprite X position
  SEC             ; make sure carry flag is set
  SBC #$02        ; A = A - 1
  STA paddle2ybot
  
  LDA paddle2ybotcheck  
  SEC
  SBC #$02
  STA paddle2ybotcheck
  LDA paddle2ytopcheck  
  SEC
  SBC #$02
  STA paddle2ytopcheck  
  ;;if down button pressed
  ;;  if paddle bottom < bottom wall
  ;;    move paddle top and bottom down
MoveComputerPaddleDownDone: 

CheckPaddle1Collision:
  CLC
  LDA ballx
  CMP #PADDLE1COLLISION
  BCS CheckPaddle1CollisionDone
  CLC
  LDA bally
  CMP paddle1ybotcheck
  BCS CheckPaddle1CollisionDone
  CLC
  
  LDA bally
  CMP paddle1ytopcheck
  BCC CheckPaddle1CollisionDone
  
  LDA #$00
  STA ballleft
  LDA #$01
  STA ballright
  
CheckPaddle1CollisionDone:
  
CheckPaddle2Collision:
  CLC
  LDA ballrightcheck
  CMP #PADDLE2X
  BCC CheckPaddle2CollisionDone
  CLC
  LDA bally
  CMP paddle2ybotcheck
  BCS CheckPaddle2CollisionDone
  CLC

  LDA bally
  CMP paddle2ytopcheck
  BCC CheckPaddle2CollisionDone
  
  
  LDA #$00
  STA ballright
  LDA #$01
  STA ballleft
  
CheckPaddle2CollisionDone:

  JMP GameEngineDone
 
 
 
 
UpdateSprites:
  LDA bally  ;;update all ball sprite info
  STA $0200
  
  LDA #$C7
  STA $0201
  
  LDA #$00
  STA $0202
  
  LDA ballx
  STA $0203
  
  LDA #PADDLE1X  ;;update all ball sprite info
  STA $0207
  
  LDA #$C7
  STA $0205
  
  LDA #$00
  STA $0206
  
  LDA paddle1ytop
  STA $0204
  
  
  LDA #PADDLE1X  ;;update all ball sprite info
  STA $020B
  
  LDA #$C7
  STA $0209
  
  LDA #$00
  STA $020A
  
  LDA paddle1ybot
  STA $0208
  
  LDA #PADDLE2X  ;;update all ball sprite info
  STA $020F
  
  LDA #$C7
  STA $020D
  
  LDA #$00
  STA $020E
  
  LDA paddle2ytop
  STA $020C
  
  LDA #PADDLE2X  ;;update all ball sprite info
  STA $0213
  
  LDA #$C7
  STA $0211
  
  LDA #$00
  STA $0212
  
  LDA paddle2ybot
  STA $0210
  
  ;;update paddle sprites
  RTS
  
ResetPos:
  LDA #$50
  STA bally
  LDA #$80
  STA ballx
  LDA #$01
  STA ballright
  LDA #$01
  STA ballright
  LDA #$00
  STA ballleft
  LDA #$86
  STA ballrightcheck
  RTS 
 
 
DrawScore:
  LDA $2002
  LDA #$20
  STA $2006
  LDA #$20
  STA $2006          ; start drawing the score at PPU $2020
  
  LDA scoreHundreds  ; get first digit
;  CLC
;  ADC #$30           ; add ascii offset  (this is UNUSED because the tiles for digits start at 0)
  STA $2007          ; draw to background
  LDA scoreTens      ; next digit
;  CLC
;  ADC #$30           ; add ascii offset
  STA $2007
  LDA scoreOnes      ; last digit
;  CLC
;  ADC #$30           ; add ascii offset
  STA $2007
  RTS
 
 
IncrementScore:
IncOnes:
  LDA scoreOnes      ; load the lowest digit of the number
  CLC 
  ADC #$01           ; add one
  STA scoreOnes
  CMP #$0A           ; check if it overflowed, now equals 10
  BNE IncDone        ; if there was no overflow, all done
IncTens:
  LDA #$00
  STA scoreOnes      ; wrap digit to 0
  LDA scoreTens      ; load the next digit
  CLC 
  ADC #$01           ; add one, the carry from previous digit
  STA scoreTens
  CMP #$0A           ; check if it overflowed, now equals 10
  BNE IncDone        ; if there was no overflow, all done
IncHundreds:
  LDA #$00
  STA scoreTens      ; wrap digit to 0
  LDA scoreHundreds  ; load the next digit
  CLC 
  ADC #$01           ; add one, the carry from previous digit
  STA scoreHundreds
IncDone:

  RTS

ReadController1:
  LDA #$01
  STA $4016
  LDA #$00
  STA $4016
  LDX #$08
ReadController1Loop:
  LDA $4016
  LSR A
  ROL gamepad1
  DEX
  BNE ReadController1Loop
  RTS
  
ReadController2:
  LDA #$01
  STA $4016
  LDA #$00
  STA $4016
  LDX #$08
ReadController2Loop:
  LDA $4017
  LSR A            ; bit0 -> Carry
  ROL gamepad2     ; bit0 <- Carry
  DEX
  BNE ReadController2Loop
  RTS
  
;;;;;;;;;;;;;;;;;;
  
  .bank 1
  .org $E000    ;;align the background data so the lower address is $00
background:
  .incbin "graphics/bg.map"


palette:
  .db $02,$19,$02,$02
  .db $02,$19,$02,$02

sprites:
     ;vert tile attr horiz
  .db $80, $C7, $00, $80   ;sprite 0
  .db $80, $C7, $00, $88   ;sprite 1
  .db $88, $C7, $00, $80   ;sprite 2
  .db $88, $C7, $00, $88   ;sprite 3



  .org $FFFA     ;first of the three vectors starts here
  .dw NMI        ;when an NMI happens (once per frame if enabled) the 
                   ;processor will jump to the label NMI:
  .dw RESET      ;when the processor first turns on or is reset, it will jump
                   ;to the label RESET:
  .dw 0          ;external interrupt IRQ is not used in this tutorial
  
  
;;;;;;;;;;;;;;  
  
  
  .bank 2
  .org $0000
  .incbin "graphics/ASCII Char Set.chr"   ;includes ASCII character set graphics