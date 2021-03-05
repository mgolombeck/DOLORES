;
;***************************************************************************************
; DOLORES-AMP library - Double LORES Ampersand extension for the Apple //e
;
; written by Marc A. Golombeck - 2020/2021
;
; An 8-Bit-Shack production
;***************************************************************************************
;
;    DOLORES-AMP is free software: you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation, either version 3 of the License, or
;    (at your option) any later version.
;
;    DOLORES-AMP is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.
;
;    You should have received a copy of the GNU General Public License
;    along with DOLORES-AMP.  If not, see <https://www.gnu.org/licenses/>.
;
; Purpose: DOLORES-AMP is an extension containing functions that enable
; drawing on the Double LORES screen of an Apple //e enhanced or better.
; This library should be BRUNed first in order to install the Ampersand (&)
; parser in memory, then the single functions can be easily called from
; an AppleSoft-program.
;
; The library itself is located from $8000 upwards and resides also in two
; of the three DOS buffers. Be sure to set MAXFILES to 1 when using
; disk routines within your AppleSoft program. 
;
; Please note that DOLORES-AMP uses parts of the zero page variables
; but should cooperate peacefully with AppleSoft and DOS3.3
;
; More technical information can be found here:
; http://golombeck.eu/index.php?id=48&L=1
;
 				DSK 	dlcoreamp
 				MX 		%11
          		ORG 	$8000
*
KYBD      		EQU 	$C000     			; READ KEYBOARD
80SToff			EQU		$C000				; switch 80STORE off
80STon			EQU		$C001				; 80STORE on
WRITEMAIN		EQU		$C004				; write to MAIN memory
WRITEAUX		EQU		$C005				; write to AUX memory
READMAIN		EQU		$C002				; read MAIN memory
READAUX			EQU		$C003				; read AUX memory
ALTZPOFF		EQU		$C008				; select MAIN ZP
ALTZPON			EQU		$C009				; select AUX ZP
40COL			EQU		$C00C				; switch to 40 columns
80COL			EQU		$C00D				; switch to 80 columns
AN3on			EQU		$C05E				; switch AN3 on
AN3off			EQU		$C05F				; switch AN3 off
TEXTon			EQU		$C051				; switch back to TEXT
GRAFIK			EQU		$C050				; switch to graphics mode
FULLGRAF		EQU		$C052				; full screen graphic
MIXEDMODE		EQU		$C053				; mixed mode graphic/text
PAGE1			EQU		$C054				; page 1
PAGE2			EQU		$C055				; page 2
LORES			EQU		$C056				; switch LORES on
STROBE    		EQU 	$C010     			; CLEAR KEYBOARD
AUXMOVE			EQU		$C311				; move data to AUX mem
HOME      		EQU 	$FC58     			; CLEAR SCREEN
CLRSCR			EQU		$F832				; clear LORES screen
VERTBLANK		EQU		$C019				; vertical blanking -> available only IIe and above
BELL			EQU		$FBDD				; ring the bell
WAIT			EQU		$FCA8				; monitor ROM delay routine
SYNERR 			EQU   	$DEC9      			; SYNTAX ERROR
IQERR 			EQU  	$E199      			; ILLEGAL QUANTITY ERROR
PRSLOT			EQU		$FE95				; PR#-command
VTABZ			EQU		$FC24				; sets VTAB from ACCU-value
COUT			EQU		$FDED
TABV			EQU		$FB5B				; vertical tabulator
*
CHRGET			EQU		$00B1				; increase text pointer by 1
AMPERVEK		EQU		$03F5				; Ampersand vector adress
DATAEOL			EQU		$D995				; set text pointer to EOL or ":"
GETBYTE			EQU		$E6F8				; load byte from text pointer in X-reg
CHKCOM			EQU		$DEBE				; check if byte is a "," 
PTRGET			EQU		$DFE3				; get pointer to A-Soft variable
MOVFM			EQU		$EAF9 				; move value to FAC
CHKNUM			EQU		$DD6A				; check if numeric
VARPNT			EQU		$0083				; pointer to A-Soft variable
FBASE			EQU		$1000				; flood filler table base
TOPMARGIN		EQU		$0022				; Top margin of text window
*
GRTOKEN			EQU		$88
TEXTTOKEN		EQU		$89
PLOTTOKEN		EQU		$8D 
HLINTOKEN		EQU		$8E
VLINTOKEN		EQU		$8F
SCRNTOKEN		EQU		$D7
COLTOKEN		EQU		$A0
*
BASELINE		EQU		$06					; line base adress
*
* zero page vars
*
XKO				EQU		$E0
YKO				EQU		$E1
INDEX			EQU		$E2
COLOR			EQU		$E3
cByte			EQU		$E4
cOld			EQU		$E5
COUNT			EQU		$E6
XKO2			EQU		$E7				; for HLIN
YKO2			EQU		$E8				; for VLIN
SCRN			EQU		$E9				; SCRN-return value (color code)
XT				EQU		$EA
YT				EQU		$EB
XM				EQU		$EC				; circle midpoint
YM				EQU		$ED
XC				EQU		$EE				; current circle coordinates
YC				EQU		$EF
FPTR			EQU		$FE					; fill stack pointer on zero page
X1				EQU		$08
Y1				EQU		$09
Y2				EQU		$1F
FPTR2			EQU		$EA					; second pointer for floodfill
*
* 
;
;
;***************************************************************************************
; Init DLOres-lib
;***************************************************************************************
START			JSR		SETUP				; setup AUX mem
				LDA		#$4C
				STA		AMPERVEK
				LDA		#<AMPER
				STA		AMPERVEK+1
				LDA		#>AMPER
				STA		AMPERVEK+2
				RTS
;
;
;***************************************************************************************
; DOLORES lib jump table
;***************************************************************************************
JUMPTABLE
				JMP		INITDLO
				JMP		EXITDLO
				JMP		SETDRAW
				JMP		DUMPGRAF
				JMP		CLRTEXT
				JMP		SETDISP
				JMP		FILLSCREEN
				JMP		HLIN
				JMP		VLIN
				JMP		SCRNXY
				JMP		PLOTXY
				JMP		FASTLINE
				JMP		FASTCIRCLE
				JMP		FILLCIRCLE
				JMP		FILLRECT
				JMP		FLOODFILL
				JMP		TOGGLEMIXED
				JMP		DRAWRECT
				DS		30
;
;
;***************************************************************************************
; DoLOres vars
;***************************************************************************************
DUMMY			DS 		1
ASCR			DS 		1
NUMPIX			DS 		1				; number of pixels to draw
CURLINE			DS 		1				; current Y-line
DPAGE			DS 		1				; page to draw on
SPAGE			DS 		1				; page to display
XPOSL     		DS 		1
XPOSH     		DS 		1
YPOSN     		DS 		1
DELTAXL   		DS 		1
DELTAXH   		DS 		1
DELTAY    		DS 		2
COUNTH    		DS 		1
DIFF      		DS 		1
DIFFH     		DS 		1
DX				DS 		1
DY				DS 		1
FEHLER			DS 		1
RADIUS			DS 		1
FILL			DS 		1				; filled objects?
COLOR2			DS 		1				; border color in fill mode
CLIP			DS 		1
XSEED			DS 		1
YSEED			DS 		1
X1L				DS 		1				; local X1
X2L				DS 		1				; local X2
YLIM			DS 		1				; Y-limit for fillmode or screen filler
FSCREEN			DS 		1				; From-Screen
TSCREEN			DS 		1				; To-Screen
;
;
;***************************************************************************************
; Init & Exit DLOres
;***************************************************************************************
INITDLO			LDA 	STROBE   			; delete keystrobe
				JSR		$C300				; init registers for 80 columns
				LDA 	GRAFIK				; switch to graphics mode
				STA		80COL
				LDA		AN3on
				STA		FULLGRAF
          		STA		80SToff				; 80STORE off
          		LDA		PAGE1
				LDA		#$00				; clear both screens
				JSR		DL_Clear
				JSR		DL_ClearBot
				JSR		DL_Clear2
				JSR		DL_Clear2Bot
				LDA		#1
				STA		ASCR
				LDA		#47
				STA		YLIM   				; full 48 lines
				LDA		#$F0				; rewrite COUT adress to zero page
				STA		$36
				LDA		#$FD
				STA		$37
				JSR		$3EA				; reconnect DOS
				RTS
*
EXITDLO			LDA 	STROBE
          		STA		80SToff				; 80STORE off
          		STA		40COL				; switch to 40 columns
          		LDA		AN3off				; switch announciator 3 off
				LDA 	TEXTon      		; SWITCH TO TEXT -> end of program
          		LDA 	PAGE1
          		JSR		$F399				; TEXT
          		JSR  	HOME      			; CLEAR SCREEN
          		LDX		#0
          		JSR		PRSLOT
          		RTS
;
;
;***************************************************************************************
; Evaluate Ampersand-Command
;***************************************************************************************
AMPER      		STA		80SToff				; 80STORE off
				CMP		#GRTOKEN
				BNE		:next0000
				JMP		AMPGR
:next0000		CMP		#TEXTTOKEN
				BNE		:next000
				JMP		AMPTEXT
:next000		CMP		#PLOTTOKEN
				BNE		:next00
				JMP		AMPPLOT
:next00			CMP		#VLINTOKEN			; draw vertical line?
				BNE		:next0
				JMP		AMPVLIN
:next0			CMP		#SCRNTOKEN
				BNE		:next
				JMP		AMPSCRN
:next			CMP		#COLTOKEN
				BNE		:nexta
				JMP		AMPCOLOR
:nexta			CMP		#HLINTOKEN
				BNE		:nextb
				JMP		AMPHLIN					
:nextb			CMP		#$46				; Flood-FILL command &F
				BNE		:nextc
				JMP		AMPFILL
:nextc			CMP		#$53				; &S SHOW page 1/2
				BNE		:nextd
				JMP		AMPSPAGE
:nextd			CMP		#$44				; &D DRAW page 1/2
				BNE		:nexte
				JMP		AMPDPAGE
:nexte			CMP		#$4C				; &L LINE X1,Y1,X2,Y2,Color
				BNE		:nextf
				JMP		AMPLINE
:nextf			CMP		#$43				; &C CIRCLE XM,YM,RADIUS,COLOR
				BNE		:nextg
				JMP		AMPCIRCLE
:nextg			CMP		#$52				; &R RECTANGLE X1,Y1,X2,Y2,FILL,BORDER
				BNE		:nexth
				JMP		AMPRECT			
:nexth			CMP		#$48				; &H fill screen
				BNE		:nexti
				JMP		AMPFSCREEN
:nexti			CMP		#$4D				; &M toggle mixed mode
				BNE		:nextj
				JMP		AMPMIXED
:nextj			CMP		#$54				; &T toggle TEXT mode and delete
				BNE		:nextk
				JMP		AMPTSCREEN			
:nextk			CMP		#$47				; &G toggle GRAFIK and restore from AUX
				BNE		:nextl
				JMP		AMPGSCREEN
:nextl			CMP		#$B7				; &SAVE move PAGE1 to AUX storage
				BNE		:nextm
				JMP		AMPMOVE		
:nextm
				JMP		SYNERR				; token not recognized

AMPMOVE			JSR		CHRGET				; plot command
				JSR		GETBYTE
				STX		FSCREEN				; save XKO
				JSR		CHKCOM				; check for ','
				JSR		GETBYTE
				STX		TSCREEN				; save YKO
				JSR		DUMPGRAF			; copy LORES pages
				JMP		EXIT	
				
AMPTSCREEN		LDA		#1					; dump PAGE1 to AUX-storage
				STA		FSCREEN
				LDA		#3
				STA		TSCREEN
				JSR		DUMPGRAF			
				JSR		CLRTEXT				; clear text page
				LDA		TEXTon				; toggle TEXT mode without erase
				JMP		EXIT					

AMPGSCREEN		LDA		GRAFIK				; toggle GRAFIK mode without erase
				LDA		#47
				STA		YLIM   				; full 48 lines
				LDA		FULLGRAF
				LDA		#3					; get PAGE1 from AUX-storage
				STA		FSCREEN
				LDA		#1
				STA		TSCREEN
				JSR		DUMPGRAF			
				JMP		EXIT					

AMPGR			JSR		INITDLO				; init DLOres
				JMP		EXIT
				
AMPTEXT			JSR		EXITDLO				; back to text mode
				JMP 	EXIT

AMPMIXED		
				JSR		TOGGLEMIXED
				JMP		EXIT				
				
AMPSPAGE		JSR		CHRGET				; set display page
				JSR		GETBYTE
				STX		SCRN				; save desired display SCRN number
				CPX		#3					; 1,2 allowed
				BCC		:nouid1
				JMP		IQERROR
:nouid1			JSR		SETDISP				; with VBLANK-sync
				JMP		EXIT				

AMPDPAGE		JSR		CHRGET				; set drawing page
				JSR		GETBYTE
				STX		SCRN				; save desired drawing SCRN number
				CPX		#4					; 1,2,3 allowed
				BCC		:nouid2
				JMP		IQERROR
:nouid2			JSR		SETDRAW				; with VBLANK-sync
				JMP		EXIT				

AMPPLOT			JSR		CHRGET				; plot command
				JSR		GETBYTE
				STX		XKO					; save XKO
				JSR		CHKCOM				; check for ','
				JSR		GETBYTE
				STX		YKO					; save YKO
				CMP		#$2C				; ','?
				BNE		:nocom1
				JSR		CHKCOM
				JSR		GETBYTE
				STX		COLOR				; save COLOR
				CPX		#16					; > 15?
				BCC		:nocom1
				JMP		IQERROR

:nocom1			LDA		XKO					; check X-range
				CMP		#80					; > 79?
				BCC		:next1
				JMP		IQERROR
:next1			LDA		YKO					; check Y-range
				CMP		#48					; > 47?
				BCC		:next2
				JMP		IQERROR
:next2			JSR		PLOTXY				; plot pixel
				JMP		EXIT
				
AMPVLIN			JSR		CHRGET				; VLIN command
				JSR		GETBYTE
				STX		YKO					; save YKO
				JSR		CHKCOM				
				JSR		GETBYTE
				STX		YKO2				; save YKO2
				JSR		CHKCOM				
				JSR		GETBYTE
				STX		XKO					; save XKO
				CMP		#$2C				; ','?
				BNE		:nocom2
				JSR		CHKCOM
				JSR		GETBYTE
				STX		COLOR				; save COLOR
				CPX		#16					; > 15?
				BCC		:nocom2
				JMP		IQERROR
				
:nocom2			LDA		XKO					; check X-range
				CMP		#80					; > 79?
				BCC		:nocom3		
				JMP 	IQERROR
:nocom3			LDA		YKO					; check Y-range
				CMP		#48					; > 47?
				BCC		:nocom4
				JMP		IQERROR
:nocom4			LDA		YKO2				; check Y-range
				CMP		#48					; > 47?
				BCC		:nocom5
				JMP		IQERROR
:nocom5				
				JSR		VLIN				; plot pixel
				JMP		EXIT

AMPSCRN			JSR		CHRGET				; SCRN command
				JSR		GETBYTE
				STX		XKO					; save XKO
				JSR		CHRGET				
				JSR		GETBYTE
				STX		YKO					; save YKO
				JSR		CHRGET
				JSR		PTRGET				; get pointer to A-Soft variable 
				JSR		MOVFM
				JSR		CHKNUM				; and store adress in to $83+$84
				JSR		CHRGET				; eat ")"

				LDA		XKO					; check X-range
				CMP		#80					; > 79?
				BCC		:nocom1
				JMP		IQERROR
:nocom1			LDA		YKO					; check Y-range
				CMP		#48					; > 47?
				BCC		:nocom2
				JMP		IQERROR
:nocom2
				JSR		SCRNXY

				LDY		#0					; output SCRN-value to A-Soft
				LDA		#0
				STA		(VARPNT),Y
				LDA		SCRN
				INY
				STA		(VARPNT),Y	

				JMP		EXIT

AMPCOLOR		JSR		CHRGET
				JSR		GETBYTE
				CPX		#16					; check if color is 0..15
				BCC		:nocom1
				JMP		IQERROR
:nocom1			STX		COLOR
				JMP		EXIT

AMPHLIN			JSR		CHRGET				; VLIN command
				JSR		GETBYTE
				STX		XKO					; save YKO
				JSR		CHKCOM				
				JSR		GETBYTE
				STX		XKO2				; save YKO2
				JSR		CHKCOM				
				JSR		GETBYTE
				STX		YKO					; save XKO
				CMP		#$2C				; ','?
				BNE		:nocom2
				JSR		CHKCOM
				JSR		GETBYTE
				STX		COLOR				; save COLOR
				CPX		#16					; > 15?
				BCC		:nocom2
				JMP		IQERROR
				
:nocom2			LDA		XKO					; check X-range
				CMP		#80					; > 79?
				BCC		:nocom3
				JMP		IQERROR
:nocom3			LDA		YKO					; check Y-range
				CMP		#48					; > 47?
				BCC		:nocom4		
				JMP		IQERROR
:nocom4			LDA		XKO2				; check Y-range
				CMP		#80					; > 47?
				BCC		:nocom5		
				JMP		IQERROR
:nocom5				
				JSR		HLIN				; plot pixel
				JMP		EXIT

AMPFILL			JSR		CHRGET				; FLOODFILL command
				JSR		GETBYTE
				STX		XSEED				; save X seed point
				JSR		CHKCOM				; check for ','
				JSR		GETBYTE
				STX		YSEED				; save Y seed point
				CMP		#$2C				; ','?
				BNE		:nocom1
				JSR		CHKCOM
				JSR		GETBYTE
				STX		COLOR				; save COLOR
				CPX		#16					; > 15?
				BCC		:nocom1
				JMP		IQERROR

:nocom1			LDA		XSEED				; check X-range
				CMP		#80					; > 79?
				BCC		:next1
				JMP		IQERROR
:next1			LDA		YSEED				; check Y-range
				CMP		#48					; > 47?
				BCC		:next2
				JMP		IQERROR
:next2			JSR		FLOODFILL			; fill range
				JMP		EXIT

AMPFSCREEN		JSR		FILLSCREEN			; fill screen with COLOR
				JMP		EXIT

AMPLINE			JSR		CHRGET				; VLIN command
				JSR		GETBYTE
				STX		XKO					; save XKO
				JSR		CHKCOM				
				JSR		GETBYTE
				STX		YKO					; save YKO
				JSR		CHKCOM				
				JSR		GETBYTE
				STX		XKO2				; save XKO2
				JSR		CHKCOM				
				JSR		GETBYTE
				STX		YKO2				; save YKO2
				CMP		#$2C				; ','?
				BNE		:nocom2
				JSR		CHKCOM
				JSR		GETBYTE
				STX		COLOR				; save COLOR & check range
				CPX		#16					; > 15?
				BCC		:nocom2
				JMP		IQERROR
				
:nocom2			LDA		XKO					; check X-range
				CMP		#80					; > 79?
				BCC		:nocom3		
				JMP 	IQERROR
:nocom3			LDA		YKO					; check Y-range
				CMP		#48					; > 47?
				BCC		:nocom4
				JMP		IQERROR
:nocom4			LDA		YKO2				; check Y-range
				CMP		#48					; > 47?
				BCC		:nocom5
				JMP		IQERROR
:nocom5			LDA		XKO2				; check X-range
				CMP		#80					; > 79?
				BCC		:nocom6
				JMP		IQERROR
:nocom6				
				LDA		XKO					; X1=X2?
				CMP		XKO2
				BNE		:nocom7
				LDA		YKO					; Y1=Y2?
				CMP		YKO2
				BNE		:nocom7
				JSR		PLOTXY				;-> yes, plot a single pixel
				JMP		EXIT
				
:nocom7			JSR		FASTLINE			; draw line
				JMP		EXIT

AMPCIRCLE		STZ		FILL				; FILL-mode?
				STZ		CLIP				; CLIP-mode?
				JSR		CHRGET				; VLIN command
				JSR		GETBYTE
				STX		XM					; save XKO
				JSR		CHKCOM				
				JSR		GETBYTE
				STX		YM					; save YKO
				JSR		CHKCOM				
				JSR		GETBYTE
				STX		RADIUS				; save XKO2
				CMP		#$2C				; ','?
				BNE		:nocom2				; check if FILL color is given
				JSR		CHKCOM
				JSR		GETBYTE
				STX		COLOR				; save COLOR & check range
				CPX		#16					; > 15?
				BCC		:nocom
				JMP		IQERROR
:nocom			INC		FILL				; FILL = 1
				
:nocom2			CMP		#$2C				; ','?
				BNE		:nocom2a			; check if extra border color is given
				JSR		CHKCOM
				JSR		GETBYTE
				STX		COLOR2				; save COLOR & check range
				CPX		#16					; > 15?
				BCC		:nocoma
				JMP		IQERROR
:nocoma			INC		FILL				; FILL = 2

:nocom2a		LDA		XM					; check X-range
				CMP		#80					; > 79?
				BCC		:nocom3		
				JMP 	IQERROR
:nocom3			LDA		YM					; check Y-range
				CMP		#48					; > 47?
				BCC		:nocom4
				JMP		IQERROR
:nocom4			LDA		RADIUS
				CMP		#80
				BCC		:nocom5
				JMP		IQERROR	

:nocom5			LDA		RADIUS				; R <= XM?
				CMP		XM
				BLT		:nocom5a
				BRA		:nocom6				; activate clipping
:nocom5a		CMP		YM					; R <= YM?
				BLT		:nocom5b
				BRA		:nocom6
:nocom5b		CLC
				ADC		XM
				CMP		#80					; R+XM <= 79?
				BLT		:nocom5c					
				BRA		:nocom6
:nocom5c 		CLC
				LDA		RADIUS
				ADC		YM
				CMP		YLIM				; R+YM <= 39/47?
				BEQ		:nocom5d
				BLT		:nocom5d
				BRA		:nocom6		
:nocom5d		LDA		#$4C				; JMP -> no clip
				STA		HLINcheck			; self-modify
				STA		PLOTXYcheck	
				LDA		#<HLIN				; LO-Byte of HLIN-subroutine
				STA		HLINcheck+1
				LDA		#>HLIN				; HI-Byte of HLIN-subroutine
				STA		HLINcheck+2
				LDA		#<PLOTXY
				STA		PLOTXYcheck+1
				LDA		#>PLOTXY
				STA		PLOTXYcheck+2
				BRA		:nocom6a
							
:nocom6			LDA		#$A5				; LDA ZP -> activate clip
				STA		HLINcheck			; self-modify
				STA		PLOTXYcheck	
				LDA		#<XKO				; LO-Byte of HLIN-subroutine
				STA		HLINcheck+1
				STA		PLOTXYcheck+1
				LDA		#$EA				; NOP
				STA		HLINcheck+2
				STA		PLOTXYcheck+2
		
:nocom6a		LDA		FILL				; draw filled circle?
				BEQ		:circle
				JSR		FILLCIRCLE
				LDA		COLOR2				; set drawing color for outer border
				STA		COLOR
				DEC		FILL
				LDA		FILL
				BNE		:circle				; draw outer border in different color
				JMP		EXIT
:circle			JSR		FASTCIRCLE			; draw line
				JMP		EXIT

AMPRECT			STZ		FILL				; FILL-mode?
				JSR		CHRGET				; RECTANGLE command
				JSR		GETBYTE
				STX		XKO					; save XKO
				JSR		CHKCOM				
				JSR		GETBYTE
				STX		YKO					; save YKO
				STX		Y1
				JSR		CHKCOM				
				JSR		GETBYTE
				STX		XKO2				; save XKO2
				JSR		CHKCOM				
				JSR		GETBYTE
				STX		YKO2				; save YKO2
				STX		Y2

				CMP		#$2C				; ','?
				BNE		:nocom2				; check if FILL color is given
				JSR		CHKCOM
				JSR		GETBYTE
				STX		COLOR				; save COLOR & check range
				CPX		#16					; > 15?
				BCC		:nocom
				JMP		IQERROR
:nocom			INC		FILL				; FILL = 1
				
:nocom2			CMP		#$2C				; ','?
				BNE		:nocom2a			; check if extra border color is given
				JSR		CHKCOM
				JSR		GETBYTE
				STX		COLOR2				; save COLOR & check range
				CPX		#16					; > 15?
				BCC		:nocoma
				JMP		IQERROR
:nocoma			INC		FILL				; FILL = 2

:nocom2a		LDA		XKO					; check X-range
				CMP		#80					; > 79?
				BCC		:nocom3		
				JMP 	IQERROR
:nocom3			LDA		YKO					; check Y-range
				CMP		#48					; > 47?
				BCC		:nocom4
				JMP		IQERROR
:nocom4			LDA		XKO2
				CMP		#80
				BCC		:nocom5
				JMP		IQERROR	
:nocom5			LDA		YKO2					; check Y-range
				CMP		#48					; > 47?
				BCC		:nocom6
				JMP		IQERROR

:nocom6			LDA		XKO					; X1=X2?
				CMP		XKO2
				BNE		:nocom7
				LDA		YKO					; Y1=Y2?
				CMP		YKO2
				BNE		:nocom7
				JSR		PLOTXY				;-> yes, plot a single pixel
				JMP		EXIT
		
:nocom7			LDA		FILL				; draw filled circle?
				BEQ		:rect
				JSR		FILLRECT
				LDA		COLOR2				; set drawing color for outer border
				STA		COLOR
				DEC		FILL
				LDA		FILL
				BNE		:rect				; draw outer border in different color
				JMP		EXIT
:rect			JSR		DRAWRECT				
				JMP		EXIT
				
ERROR			JSR		BELL
EXIT			JMP		DATAEOL				; exit Ampersand-routine		
IQERROR			JMP		IQERR			


;
;
;***************************************************************************************
; Set drawing screen
;***************************************************************************************
DRAWRECT
          		STA		80SToff				; 80STORE off
				LDA		Y1
				STA		YKO
				LDA		Y2
				STA		YKO2
				JSR		HLIN				; draw first two lines of rect
				JSR		VLIN
				LDA		XKO					; exchange coordinates
				LDX		XKO2
				STA		XKO2
				STX		XKO
				JSR		VLIN
				LDA		Y2
				STA		YKO
				JSR		HLIN				; draw other two lines
				RTS
;
;
;***************************************************************************************
; Toggle mixed mode on/off
;***************************************************************************************
TOGGLEMIXED
				LDA		YLIM				; check if mixed mode is already active
				CMP		#47
				BEQ		:mixedon
:mixedoff		LDA		FULLGRAF
				LDA		#47
				STA		YLIM
				STZ		TOPMARGIN
				JMP		EXIT		

:mixedon		LDA		MIXEDMODE			; switch on mixed mode graphics
				LDA		#$A0				; AppleSoft Blank
				JSR		DL_ClearBot
				JSR		DL_Clear2Bot
				LDA		#39
				STA		YLIM				; reduces lines in Y-direction
				LDA		#$50				; sets text width in 80 column mode
				STA		$21
				LDA		#20					; set top margin
				STA		TOPMARGIN
				LDA		#20
				JSR		TABV				; set cursor to line 21 (vertical tabbing)
				RTS
;
;
;***************************************************************************************
; Set drawing screen
;***************************************************************************************
SETDRAW			LDA 	SCRN       			; select DRAW-SCREEN
          		CMP 	#$02				; If value = 2 then
          		BGE 	draw2      			; draw on SCREEN 2 or 3
draw1			LDA		#1
				STA		ASCR
				LDA 	#>YLOOKHI	      	; draw on SCREEN1, get YLOOKup-table base adress HI byte
          		BRA 	drawRTS

draw2     		CMP		#3
				BEQ		draw3				; draw on SCREEN3
				LDA		#2
				STA		ASCR
				LDA 	#>YLOOKHI2 			; draw on SCREEN2
          		BRA 	drawRTS

draw3     		LDA		#3
				STA		ASCR
				LDA 	#>YLOOKHI3 			; draw on SCREEN3
				
drawRTS
				STA		smyl1+2				; self-modify code
				STA		smyl2+2				; set HI-byte to drawing screen adress
				STA		smyl3+2
				STA		smyl4+2
				STA		smyl5+2
				STA		smyl6+2
				STA		smyl7+2
				STA		smyl8+2
				STA		smyl9+2				
				RTS
;
;
;***************************************************************************************
; Copy Screen from and to page 1,2,3
;***************************************************************************************

DUMPGRAF		
          		STA		80SToff				; 80STORE off
				LDA		FSCREEN				; get from screen
				CMP		TSCREEN				; TO = FROM?
				BNE		:dcont				; no -> continue
				RTS

:dcont			CMP		#1					; self-modification section
				BNE		:not1
				LDX		#$04				; FROM = 1
				STX		smf1+2
				STX		smf1a+2
				LDX		#$05
				STX		smf2+2
				STX		smf2a+2
				LDX		#$06
				STX		smf3+2
				STX		smf3a+2
				LDX		#$07
				STX		smf4+2
				STX		smf4a+2
				BRA		dumpcont
					
:not1			CMP		#2
				BNE		:not2
				LDX		#$08				; FROM = 2
				STX		smf1+2
				STX		smf1a+2
				LDX		#$09
				STX		smf2+2
				STX		smf2a+2
				LDX		#$0A
				STX		smf3+2
				STX		smf3a+2
				LDX		#$0B
				STX		smf4+2
				STX		smf4a+2
				BRA		dumpcont
					
:not2			CMP		#3
				BNE		:not3
				LDX		#$0C				; FROM = 3
				STX		smf1+2
				STX		smf1a+2
				LDX		#$0D
				STX		smf2+2
				STX		smf2a+2
				LDX		#$0E
				STX		smf3+2
				STX		smf3a+2
				LDX		#$0F
				STX		smf4+2
				STX		smf4a+2
				BRA		dumpcont
				
:not3			RTS							; error: FSCREEN out of range
				
dumpcont		
				LDA		TSCREEN				; get to screen
				CMP		#1
				BNE		:not1a
				LDX		#$04				; TO = 1
				STX		smt1+2
				STX		smt1a+2
				LDX		#$05
				STX		smt2+2
				STX		smt2a+2
				LDX		#$06
				STX		smt3+2
				STX		smt3a+2
				LDX		#$07
				STX		smt4+2
				STX		smt4a+2
				BRA		dumpcont2
					
:not1a			CMP		#2
				BNE		:not2a
				LDX		#$08				; FROM = 2
				STX		smt1+2
				STX		smt1a+2
				LDX		#$09
				STX		smt2+2
				STX		smt2a+2
				LDX		#$0A
				STX		smt3+2
				STX		smt3a+2
				LDX		#$0B
				STX		smt4+2
				STX		smt4a+2
				BRA		dumpcont2
					
:not2a			CMP		#3
				BNE		:not3a
				LDX		#$0C				; FROM = 3
				STX		smt1+2
				STX		smt1a+2
				LDX		#$0D
				STX		smt2+2
				STX		smt2a+2
				LDX		#$0E
				STX		smt3+2
				STX		smt3a+2
				LDX		#$0F
				STX		smt4+2
				STX		smt4a+2
				BRA		dumpcont2
				
:not3a			RTS							; error: FSCREEN out of range
				
dumpcont2		
				JSR		DUMPMOUSE
				STA		WRITEAUX			; $0400-$07FF -> $1000
				LDA		smf1+2				; copy sm values to AUX mem
				STA		smf1+2
				LDA		smt1+2				; copy sm values to AUX mem
				STA		smt1+2
				LDA		smf2+2				; copy sm values to AUX mem
				STA		smf2+2
				LDA		smt2+2				; copy sm values to AUX mem
				STA		smt2+2
				LDA		smf3+2				; copy sm values to AUX mem
				STA		smf3+2
				LDA		smt3+2				; copy sm values to AUX mem
				STA		smt3+2
				LDA		smf4+2				; copy sm values to AUX mem
				STA		smf4+2
				LDA		smt4+2				; copy sm values to AUX mem
				STA		smt4+2
				STA		READAUX				; copy AUX-memory screen area into AUX
				LDX 	#0					; loop over X-index
CPlp1			
smf1			LDA		$0400,X
smt1			STA		$1000,X
smf2			LDA		$0500,X
smt2			STA		$1100,X
smf3			LDA		$0600,X
smt3			STA		$1200,X
smf4			LDA		$0700,X
smt4			STA		$1300,X
				INX
				BNE		CPlp1
				STA		WRITEMAIN
				STA		READMAIN

											; copy MAIN-memory screen area into AUX
											; $0400-$07FF -> $1000
				LDX 	#0					; loop over X-index
CPlp2			
smf1a			LDA		$0400,X
smt1a			STA		$0C00,X
smf2a			LDA		$0500,X
smt2a			STA		$0D00,X
smf3a			LDA		$0600,X
smt3a			STA		$0E00,X
smf4a			LDA		$0700,X
smt4a			STA		$0F00,X
				INX
				BNE		CPlp2
				JSR		GETMOUSE
				RTS

CLRTEXT			JSR		DUMPMOUSE			; clear 4 bottom text lines
				STA		READAUX				; copy AUX-memory screen area into AUX
				STA		WRITEAUX			; $0400-$07FF -> $1000
				LDA		#$A0
				LDX		#0					; clear text screen
:CPlp1a			STA		$0400,X
				STA		$0500,X
				STA		$0600,X
				STA		$0700,X
				INX
				BNE		:CPlp1a
				STA		WRITEMAIN
				STA		READMAIN
				LDX		#0					; clear text screen
:CPlp2a			STA		$0400,X
				STA		$0500,X
				STA		$0600,X
				STA		$0700,X
				INX
				BNE		:CPlp2a
				JSR		GETMOUSE
				RTS

DUMPMOUSE
				LDA		$0478				; dump current apple mouse vars before moving 
				STA		CODEEND				; screen pages brute force around
				LDA		$04F8
				STA		CODEEND+1
				LDA		$0578				 
				STA		CODEEND+2			
				LDA		$05F8
				STA		CODEEND+3
				LDA		$047C				 
				STA		CODEEND+4			
				LDA		$04FC
				STA		CODEEND+5
				LDA		$057C				 
				STA		CODEEND+6			
				LDA		$05FC
				STA		CODEEND+7
				LDA		$067C				 
				STA		CODEEND+8			
				LDA		$06FC
				STA		CODEEND+9
				LDA		$077C				 
				STA		CODEEND+10			
				LDA		$0678				 
				STA		CODEEND+11			
				LDA		$06F8
				STA		CODEEND+12
				LDA		$047E
				STA		CODEEND+13
				LDA		$04FE
				STA		CODEEND+14
				RTS
				
GETMOUSE
				LDA		CODEEND				; retrieve mouse vars
				STA		$0478				 
				LDA		CODEEND+1			
				STA		$04F8
				LDA		CODEEND+2
				STA		$0578				 
				LDA		CODEEND+3			
				STA		$05F8
				LDA		CODEEND+4
				STA		$047C				 
				LDA		CODEEND+5			
				STA		$04FC
				LDA		CODEEND+6
				STA		$057C				 
				LDA		CODEEND+7			
				STA		$05FC
				LDA		CODEEND+8
				STA		$067C				 
				LDA		CODEEND+9			
				STA		$06FC
				LDA		CODEEND+10
				STA		$077C				 
				LDA		CODEEND+11			
				STA		$0678
				LDA		CODEEND+12
				STA		$06F8				 
				LDA		CODEEND+13			
				STA		$47E
				LDA		CODEEND+14
				STA		$04FE				 
				RTS

;
;
;***************************************************************************************
; Retrieve Screen from aux mem
;***************************************************************************************

GETGRAF						
				;STA		READAUX				; copy AUX-memory screen area into AUX
				;STA		WRITEAUX			; $0400-$07FF -> $1000
				;LDX 	#0					; loop over X-index
:CPlp1			;LDA		$1000,X
				;STA		$0400,X
				;LDA		$1100,X
				;STA		$0500,X
				;LDA		$1200,X
				;STA		$0600,X
				;LDA		$1300,X
				;STA		$0700,X
				;INX
				;BNE		:CPlp1
				;STA		WRITEMAIN
				;STA		READMAIN

				;STA		READAUX				; copy MAIN-memory screen area into AUX
				;STA		WRITEAUX			; $0400-$07FF -> $1000
				;LDX 	#0					; loop over X-index
:CPlp2			;LDA		$0C00,X
				;STA		$0400,X
				;LDA		$0D00,X
				;STA		$0500,X
				;LDA		$0E00,X
				;STA		$0600,X
				;LDA		$0F00,X
				;STA		$0700,X
				;INX
				;BNE		:CPlp2
				;STA		WRITEMAIN
				;STA		READMAIN
				;RTS


;
;
;***************************************************************************************
; Set display screen
;***************************************************************************************
SETDISP
				CMP 	VERTBLANK      		; works with IIGS/IIE      
          		BPL 	SETDISP        		; wait until the end of the vertical blank
                                                
:nouid2    		CMP 	VERTBLANK  			; synchronizing counting algorithm      
         		BMI 	:nouid2        		; wait until the end of the complete display -> start of vertical blanking
*         	
dblBUF			STA		80SToff
				LDA 	SCRN       			; DISPLAY DRAW-SCREEN
          		CMP 	#$02				; If value = 2 then
          		BEQ 	DISP2      			; SHOW SCREEN 2
disp2     		LDA 	PAGE1      			; SCRN = 0/1 SWITCH TO SCREEN1
          		BRA 	dbRTS
DISP2     		LDA 	PAGE2      			; SWITCH TO SCREEN2
dbRTS			RTS
;
;
;***************************************************************************************
; Fill screen with set color
;***************************************************************************************
FILLSCREEN
          		STA		80SToff				; 80STORE off
				LDA		ASCR
				CMP		#3
				BNE		:nots3				; not SCREEN 3

				LDX		#0					; clear screen3
				LDA		#0
:cllp1			STA		$0C00,X
				STA		$0D00,X
				STA		$0E00,X
				STA		$0F00,X
				INX
				BNE		:cllp1
				
				STA		WRITEAUX			
:cllp2			STA		$0C00,X
				STA		$0D00,X
				STA		$0E00,X
				STA		$0F00,X
				INX
				BNE		:cllp2
				STA		WRITEMAIN
				
				RTS
				
:nots3			LDX		COLOR				; color needs to be set first 
				LDA		NIBDOUBLE,X			; double the nibble
				TAY
				LDA		ASCR
				CMP		#2
				BEQ		:fill2
				TYA
				JSR		DL_Clear			; fill screen 1
				LDA		YLIM
				CMP		#39					; check for fill bottom
				BEQ		:nof1				; nope all done
				TYA							; retrieve fill COLOR
				JSR		DL_ClearBota		; fill bottom			
:nof1			RTS		
:fill2			TYA
				JSR		DL_Clear2			; fill screen 2
				LDA		YLIM
				CMP		#39					; check for fill bottom
				BEQ		:nof2				; nope all done
				TYA							; retrieve fill COLOR
				JSR		DL_Clear2Bota		; fill bottom			
:nof2			RTS					

;
;
;***************************************************************************************
; Draw horizontal line
;***************************************************************************************
HLINcheck		LDA		XKO					; ZP
				NOP
				CMP		XKO2				; check if XKO < XKO2
				BCC		:hlinc1				; --> yes!
				BEQ		:checkRTS			; XKO = XKO2 -> do not plot anything here
				LDX		XKO2				; --> no --> exchange XKO and XKO2
				STA		X2L
				STX		X1L
:hlinc1			LDA		XKO
				BPL		:check1
				STZ		XKO					; if negative
				BRA		:check2
:check1			CMP		#80
				BLT		:check2
				LDA		#79
				STA		XKO

:check2			LDA		XKO2
				BPL		:check3
				STZ		XKO2				; if negative
				BRA		:check4
:check3			CMP		#80
				BLT		:check4
				LDA		#79
				STA		XKO2

:check4			LDA		YKO
				BPL		:check5
				RTS							; if negative
:check5			CMP		YLIM				; check against Y-limit
				BEQ		HLIN				; = 47?
				BLT		HLIN				; < 47?
:checkRTS		RTS							; if out of range
 
HLIN			
          		STA		80SToff				; 80STORE off
				LDA		XKO
				CMP		XKO2				; check if XKO < XKO2
				BCC		:hlincont			; --> yes!
				BEQ		:doplota			; XKO = XKO2 -> ust plot a single pixel
				LDX		XKO2				; --> no --> exchange XKO and XKO2
				STA		X2L
				STX		X1L
				BRA		:hlincont2

:doplota		JMP		PLOTXY				; plot a s ingle pixel
:hlincont		STA		X1L					; use local variables
				LDA		XKO2
				STA		X2L
:hlincont2		SEC
				SBC		X1L
				INC
				STA		NUMPIX				; store number of pixels to draw
				INC		X2L					; XKO2 +=1 -> increment by one for drawing loop control
				LDA		YKO					; load line number
				LSR							; div 2
				TAX							; generate correct line number
				LDA		YLOOKLO,X			; get base adress
				STA		BASELINE
smyl1			LDA		YLOOKHI,X
				STA		BASELINE+1
				LDA		YKO					; check if we are on an even or uneven row
				BIT		#%00000001
				BEQ		:evenrow			; plot in an even row 0, 2, 4,...
				JMP		:unevenrow			; we plot in an uneven row 1, 3, 5,...
:evenrow		LDA		COLOR				; get color
				STA		cByte				; save COLOR
				TAX
				LDA		MainAuxMap,X		; get AUX COLOR
				STA		cOld				; save AUX COLOR
				LDA		#%11110000			; self-modify AND-Mask
				STA		:sm1+1				; for even row pixels
				STA		:sm2+1
				BRA		:evenlp

:unevenrow		LDX		COLOR				; get color and prepare color bytes for uneven rows
				LDA		NIBFLIP,X			; flip nibbles so color is in upper nibble
				STA		cByte				; save COLOR
				TAX
				LDA		MainAuxMap,X		; get AUX COLOR
				STA		cOld				; save AUX COLOR
				LDA		#%00001111			; self-modify AND-Mask
				STA		:sm1+1				; for even row pixels
				STA		:sm2+1
		
:evenlp			LDA		X1L					; get current x-pos
				BIT		#%00000001			; determine if we plot in an even or odd column
				BNE		:evenmain			; we plot an even column -> MAIN MEM
:evenAUX			
				LSR
				TAY							; set Y-reg with pixel index
				STA		READAUX
				LDA		(BASELINE),Y		; get old Colors
				STA		READMAIN
:sm1			AND		#%11110000			; save lower pixel
				ORA		cOld				; combine pixels
				STA		WRITEAUX
				STA		(BASELINE),Y		; set byte
				STA		WRITEMAIN
				INC		X1L
				LDA		X1L
				CMP		X2L
				BCC		:evenlp				; not done
				RTS							; all done!

:evenmain				
				LSR
				TAY							; set Y-reg with pixel index
				LDA		(BASELINE),Y		; get old Colors
:sm2			AND		#%11110000			; save lower pixel
				ORA		cByte				; combine pixels
				STA		(BASELINE),Y		; set byte
				INC		X1L
				LDA		X1L
				CMP		X2L
				BCC		:evenlp				; not done
				RTS							; all done!
	
;
;
;***************************************************************************************
; Draw vertical line
;***************************************************************************************
VLIN			
          		STA		80SToff				; 80STORE off
				LDA		YKO
				CMP		YKO2				; check if YKO < YKO2
				BCC		:vlincont			; --> yes!
				BEQ		:doplot				; YKO = YKO2 -> ust plot a single pixel
				LDX		YKO2				; --> no --> exchange YKO and YKO2
				STA		YKO2
				STX		YKO
				BRA		:vlincont

:doplot			JMP		PLOTXY
:vlincont		LDA		YKO2				; determine how many pixels to draw
				SEC
				SBC		YKO
				INC
				STA		NUMPIX				; store number of pixels to draw
				LDA		XKO
				BIT		#%00000001			; check if even/uneven
				BEQ		vlinAUX				; check if even column -> AUX MEM
				JMP		vlinMAIN
				

vlinAUX
				LSR
				TAY							; scale XKO
				LDA		YKO
				LSR
				STA		CURLINE				; determine current line number
				LDA		YKO
				BIT		#%00000001			; check if even/uneven
				BEQ		:evenrowa			; we start on an even row
		
				LDX		CURLINE				; we need to set the uneven row pixel first
				LDA		YLOOKLO,X			; get base adress
				STA		BASELINE
smyl2			LDA		YLOOKHI,X
				STA		BASELINE+1
				STA		READAUX
				LDA		(BASELINE),Y		; get old Colors
				STA		READMAIN
				TAX
				LDA		AuxMainMap,X
				AND		#%00001111			; save upper pixel
				STA		cOld
				LDX		COLOR				; load new color
				LDA		NIBFLIP,X			; swap nibbles
				ORA		cOld				; combine pixels
				TAX
				LDA		MainAuxMap,X		; convert color codes
				STA		WRITEAUX
				STA		(BASELINE),Y		; set byte
				STA		WRITEMAIN
					
				INC		CURLINE				; skip to next Y-row
				DEC		NUMPIX				; decrement pixel counter

:evenrowa		LDA		NUMPIX				; check if we have at least two pixels to draw
				CMP		#2		
				BCC		:lastpixela			; less than 2 pixels to draw
:vlinlp1a		LDX		CURLINE				; we need to set the uneven row pixel first
				LDA		YLOOKLO,X			; get base adress
				STA		BASELINE
smyl3			LDA		YLOOKHI,X
				STA		BASELINE+1
				LDX		COLOR
				LDA		NIBDOUBLE,X			; get the same value for both nibbles
				TAX
				LDA		MainAuxMap,X		; convert color codes
				STA		WRITEAUX
				STA		(BASELINE),Y		; set byte
				STA		WRITEMAIN
				DEC		NUMPIX
				DEC		NUMPIX
				INC		CURLINE
				BRA		:evenrowa			; check if we need to set more pixel

:lastpixela		LDA		NUMPIX				; draw lastpixel
				BNE		:drwlpixa			; check if we still need to draw a single pixel
				RTS
:drwlpixa		LDX		CURLINE				; we need to set the uneven row pixel first
				LDA		YLOOKLO,X			; get base adress
				STA		BASELINE
smyl4			LDA		YLOOKHI,X
				STA		BASELINE+1
				STA		READAUX
				LDA		(BASELINE),Y		; get old Colors
				STA		READMAIN
				TAX
				LDA		AuxMainMap,X
				AND		#%11110000			; save lower pixel
				ORA		COLOR				; add new color
				TAX
				LDA		MainAuxMap,X		; convert color codes
				STA		WRITEAUX
				STA		(BASELINE),Y		; set byte
				STA		WRITEMAIN
				RTS

vlinMAIN				
				LSR
				TAY							; scale XKO
				LDA		YKO
				LSR
				STA		CURLINE				; determine current line number
				LDA		YKO
				BIT		#%00000001			; check if even/uneven
				BEQ		evenrow			; we start on an even row
		
				LDX		CURLINE				; we need to set the uneven row pixel first
				LDA		YLOOKLO,X			; get base adress
				STA		BASELINE
smyl5			LDA		YLOOKHI,X
				STA		BASELINE+1
				LDA		(BASELINE),Y		; get old Colors
				AND		#%00001111			; save upper pixel
				STA		cOld
				LDX		COLOR				; load new color
				LDA		NIBFLIP,X			; swap nibbles
				ORA		cOld				; combine pixels
				STA		(BASELINE),Y		; put new pixel
					
				INC		CURLINE				; skip to next Y-row
				DEC		NUMPIX				; decrement pixel counter

evenrow			LDA		NUMPIX				; check if we have at least two pixels to draw
				CMP		#2		
				BCC		:lastpixel			; less than 2 pixels to draw
:vlinlp1		LDX		CURLINE				; we need to set the uneven row pixel first
				LDA		YLOOKLO,X			; get base adress
				STA		BASELINE
smyl6			LDA		YLOOKHI,X
				STA		BASELINE+1
				LDX		COLOR
				LDA		NIBDOUBLE,X			; get the same value for both nibbles
				STA		(BASELINE),Y		; draw two pixels
				DEC		NUMPIX
				DEC		NUMPIX
				INC		CURLINE
				BRA		evenrow			; check if we need to set more pixel

:lastpixel		LDA		NUMPIX				; draw lastpixel
				BNE		:drwlpix			; check if we still need to draw a single pixel
				RTS
:drwlpix		LDX		CURLINE				; we need to set the uneven row pixel first
				LDA		YLOOKLO,X			; get base adress
				STA		BASELINE
smyl7			LDA		YLOOKHI,X
				STA		BASELINE+1
				LDA		(BASELINE),Y		; get old Colors
				AND		#%11110000			; save lower pixel
				ORA		COLOR				; add new color
				STA		(BASELINE),Y		; put new pixel
				RTS
;
;
;***************************************************************************************
; Dolores SCRN-function
;***************************************************************************************
SCRNXY			
          		STA		80SToff				; 80STORE off
				LDA		YKO		
				LSR							; divide by 2 to get row index
				TAX
				LDA		YLOOKLO,X
				STA		BASELINE
smyl8			LDA		YLOOKHI,X
				STA		BASELINE+1

				LDA		XKO
				BIT		#%00000001			; check if even/uneven
				BNE		scrnMAIN			; check if uneven column -> main MEM
scrnAUX			LSR							; divide XKO by 2 -> create index
				TAY							; push x-index in Y-reg
				STA		READAUX
				LDA		(BASELINE),Y		; get old Colors
				STA		READMAIN
				TAX
             	LDA   	AuxMainMap,x		; convert AUX colors to "real" color 
				STA		SCRN

				LDA		YKO
				AND		#%00000001			; check if uneven row
				BEQ		:lowernib			; yes -> uneven row, read lower nibble
				LDA		SCRN				; read color in upper nibble
				AND		#%11110000
				LSR							; move nibble
				LSR
				LSR
				LSR
				STA		SCRN
				RTS
				
:lowernib		LDA		SCRN				; read color in lower nibble
				AND		#%00001111
				STA		SCRN
				RTS
	
scrnMAIN		LSR							; divide by 2 -> create index
				TAY							; push x-index in Y-reg
				LDA		(BASELINE),Y		; get old Colors
				STA		SCRN
				
				LDA		YKO
				AND		#%00000001			; check if uneven row
				BEQ		:lowernib2			; yes -> uneven row, set lower nibble
				LDA		SCRN				; read color in upper nibble
				AND		#%11110000
				LSR
				LSR
				LSR
				LSR
				STA		SCRN
				RTS
								
:lowernib2		LDA		SCRN				; read color in lower nibble
				AND		#%00001111
				STA		SCRN
				RTS				
;
;
;***************************************************************************************
; Plot pixel
;***************************************************************************************
PLOTXYcheck
          		STA		80SToff				; 80STORE off
				LDA		XKO
				NOP
				CMP		#80
				BLT		:check2
				RTS
:check2			LDA		YKO
				CMP		YLIM				; check against Y-limit
				BEQ		PLOTXY				; = 39/47?
				BLT		PLOTXY				; < 39/47?
				RTS				
				
PLOTXY			LDA		COLOR				
				STA		cByte				; set color byte
				LDA		YKO		
				LSR							; divide by 2 to get row index
				TAX
				LDA		YLOOKLO,X
				STA		BASELINE
smyl9			LDA		YLOOKHI,X
				STA		BASELINE+1

				LDX		COLOR
				LDA		XKO
				BIT		#%00000001			; check if even/uneven
				BNE		plotMAIN			; check if uneven column -> main MEM
plotAUX			LSR							; divide XKO by 2 -> create index
				TAY							; push x-index in Y-reg
				STA		READAUX
				LDA		(BASELINE),Y		; get old Colors
				STA		READMAIN
				STA		cOld
             	LDA   	MainAuxMap,x
				STA		cByte				; color now in upper nibble
				LDA		YKO
				AND		#%00000001			; check if uneven row
				BEQ		lowernib			; yes -> uneven row, set lower nibble
				LDA		cOld				; save old color in lower nibble
				AND		#%00001111
				STA		cOld
				LDA		NIBFLIP,X			; swap nibbles
             	TAX                  		; get aux color value
             	LDA   	MainAuxMap,x
				STA		cByte				; color now in upper nibble
				BRA		setPIX
				
lowernib		LDA		cOld				; save old color in upper nibble
				AND		#%11110000
				STA		cOld
				
setPIX			LDA		cByte				; get new color
				ORA		cOld				; restore other nibble
				STA		WRITEAUX
bl1				STA		(BASELINE),Y		; set byte
				STA		WRITEMAIN
				RTS
	
plotMAIN
				LSR							; divide by 2 -> create index
				TAY							; push x-index in Y-reg
				LDA		(BASELINE),Y		; get old Colors
				STA		cOld
				LDA		YKO
				AND		#%00000001			; check if uneven row
				BEQ		lowernib2			; yes -> uneven row, set lower nibble
				LDA		cOld				; save old color in lower nibble
				AND		#%00001111
				STA		cOld
				LDA		NIBFLIP,X			; swap nibbles
				STA		cByte				; color now in upper nibble
				BRA		setPIX2
				
lowernib2		LDA		cOld				; save old color in upper nibble
				AND		#%11110000
				STA		cOld
				
setPIX2			LDA		cByte				; get new color
				ORA		cOld				; restore other nibble
				STA		(BASELINE),Y		; set byte

				RTS				
;
;
;***************************************************************************************
; Init & Exit DLOres
;***************************************************************************************
SETUP			
				LDA		#$00
				STA		SPAGE				; show page
				STA		DPAGE				; draw page
				STA		$3C					; copy lib to AUX mem
				LDA		#$80
				STA		$3D
				LDA		#$FF
				STA		$3E
				LDA		#$9F
				STA		$3F
				LDA		#$00
				STA		$42
				LDA		#$80
				STA		$43
				SEC							; MAIN to AUX
				JMP		AUXMOVE
				RTS
;
;
; fast linedraw &LINE X1,Y1,X2,Y2,COLOR
;
FASTLINE  									; check numbers and rearrange if necessary
          		STA		80SToff				; 80STORE off
				LDA		XKO
				CMP		XKO2				; check if XKO < XKO2
				BCC		:FLcont				; --> yes!
				LDX		XKO2				; --> no --> exchange XKO and XKO2
				STA		XKO2
				STX		XKO
				LDA		YKO
				LDX		YKO2				; --> no --> exchange YKO and YKO2
				STA		YKO2
				STX		YKO
				BRA		:FLcont2
:FLcont			LDA		YKO
				CMP		YKO2				; check if XKO < XKO2
				BCC		:FLcont2			; --> yes!
				LDX		YKO2				; --> no --> exchange YKO and YKO2
				STA		YKO2
				STX		YKO
				LDX		XKO2				; --> no --> exchange XKO and XKO2
				LDA		XKO
				STA		XKO2
				STX		XKO
		
:FLcont2	LDA 	XKO        		; WHICH X-VALUE IS ON THE LEFT? @XTO,YTO
          	SEC
          	SBC 	XKO2
          	BEQ 	fCHKVERT    	; LOW BYTE EVEN CHECK VERTICAL
          	BCS 	fLX0LEFT
*
fLX0RIGHT 	EOR 	#$FF       		; INVERT LO-BYTE
			INC
          	STA 	DELTAXL
*          	
fNOINCHI  	LDA 	XKO        		; START WITH XTO
          	STA 	XPOSL
          	LDA 	YKO
          	STA 	YPOSN
          	SEC
          	SBC 	YKO2      		; DELTA-Y?
          	JMP 	fLNCOMMON
*
fCHKVERT 	JSR		VLIN			; pure vertical line
			RTS
*
fphorizontal						; pure horizontal line
			JSR   	HLIN
			RTS
*
fLX0LEFT  	STA 	DELTAXL    		; XDRAW IS LEFT
          	LDA 	XKO2      		; START WITH XDRAW
          	STA 	XPOSL
          	LDA 	YKO2
          	STA 	YPOSN      		; GET DELTA-Y
          	SEC
          	SBC 	YKO
*
fLNCOMMON 	BCS 	fLPOSY
          	EOR 	#$FF       		; INVERT IF NEGATIVE
          	ADC 	#$01
          	STA 	DELTAY
          	LDA 	#$EE       		; INC adr
          	BNE 	fGOTDY
fLPOSY    	BEQ 	fphorizontal	; pure horizontal line HLIN
			STA 	DELTAY
          	LDA 	#$CE       		; DEC adr
fGOTDY    	STA 	fLHMODY     	; SELF-MODIFYING CODE
          	STA 	fLVMODY			; depending on the slope of the line
*
* CHECK DOMINANCE
*
          	LDA 	DELTAXL
          	CMP 	DELTAY
          	BGE 	fHORIDOM    	; horizontal is dominating
          	JMP 	fVERTDOM		; vertical is dominating
*
fHORIDOM  	
			INC
          	STA 	COUNT      		; COUNT = DELTAX + 1
			DEC	
          	LSR            			; DIFF = DELTAX / 2
          	STA 	DIFF
*
*          	
fNOTWIDE  	JMP 	fHORZLOOP
*
fHRTS     	RTS
*
fHNOROLL  	STA 	DIFF       		; LOOP BOTTOM
fHDECC    	DEC 	COUNT
          	BEQ 	fHRTS
*
fHORZLOOP  	
*
          	LDA		XPOSL
          	STA		XKO
          	LDA		YPOSN
          	STA		YKO
          	JSR 	PLOTXY
          	INC		XPOSL
			LDA 	DIFF       		; UPDATE ERROR DIFFERENCE
          	SEC
          	SBC 	DELTAY
          	BCS 	fHNOROLL
          	ADC 	DELTAXL
          	STA 	DIFF
fLHMODY   	INC		YPOSN			; next line
			BRA 	fHDECC
*
fVERTDOM  	LDX 	YKO
          	CPX 	YPOSN
          	BNE 	fENDY0
          	LDX 	YKO2
fENDY0    	STX 	fLVCHK+1			; self-modifying loop end index
          	LDA 	DELTAY
          	LSR
          	STA 	DIFF
*
          	LDX 	YPOSN
          	JMP 	fVERTLOOP
*
fVNOROLL  	STA 	DIFF
fVERTLOOP 	LDA		XPOSL
          	STA		XKO
          	LDA		YPOSN
          	STA		YKO
          	JSR 	PLOTXY
			
			LDA		YPOSN
fLVCHK    	CMP 	#$00
          	BEQ 	fVRTS
fLVMODY   	INC		YPOSN			; move down/up
			LDA 	DIFF
          	SEC
          	SBC 	DELTAXL
          	BCS 	fVNOROLL
          	ADC 	DELTAY
          	STA 	DIFF
          	INC		XPOSL			; move right
          	BNE 	fVERTLOOP
*
fVRTS     	RTS
*
;
;***************************************************************************************
; fast Bresenham circle algorithm
;***************************************************************************************
FASTCIRCLE
          		STA		80SToff				; 80STORE off
				LDA		RADIUS
				STA		FEHLER
				STA		XC
				STZ		YC
				JSR		SETPIX1			; set first pixels
								
LOOP			LDA		YC	
				CMP		XC
				BCC		LOOPGO
				RTS						; exit -> circle done!
				
LOOPGO			LDA		YC
				ASL
				ADC		#1
				STA		DY
				INC		YC
				LDA		DY
				EOR		#$FF
				CLC
				ADC		#1
				ADC		FEHLER
				STA		FEHLER
				BPL		DOPLOTS
STEPX			LDA		XC
				ASL
				EOR		#$FF
				CLC
				ADC		#2
				STA		DX
				DEC		XC
				LDA		DX
				EOR		#$FF
				CLC
				ADC		#1
				ADC		FEHLER
				STA		FEHLER
				
DOPLOTS			LDA		XC				; Calc XT and YT
				EOR		#$FF
				CLC
				ADC		#$01
				STA		XT
				LDA		YC
				EOR		#$FF
				CLC						
				ADC		#$01
				STA		YT
				CLC						; 1st octant
				LDA		XM				; X midpoint
				ADC		XC				; add-on
				STA		XKO				; X plot coordinate
				CLC
				LDA		YM
				ADC		YC
				STA		YKO
				JSR		PLOTXYcheck
:plot2			CLC						; 2nd octant
				LDA		XM
				ADC		XT
				STA		XKO
				JSR		PLOTXYcheck
:plot3			CLC						; 3rd octant
				LDA		YM
				ADC		YT
				STA		YKO
				JSR 	PLOTXYcheck
:plot4			CLC						; 4th octant
				LDA		XM
				ADC		XC
				STA		XKO
				JSR		PLOTXYcheck
:plot5			CLC						; 5th octant
				LDA		XM
				ADC		YC
				STA		XKO
				CLC	
				LDA		YM
				ADC		XC
				STA		YKO
				JSR		PLOTXYcheck
:plot6			CLC						; 6th octant
				LDA		XM
				ADC		YT
				STA		XKO
				JSR		PLOTXYcheck
:plot7			CLC						; 7th octant
				LDA		YM
				ADC		XT
				STA		YKO
				JSR		PLOTXYcheck
:plot8			CLC						; 8th octant
				LDA		XM
				ADC		YC
				STA		XKO
				JSR		PLOTXYcheck
:plot9			JMP		LOOP						
				
SETPIX1			LDA		XC
				EOR		#$FF
				CLC
				ADC		#$01
				STA		XT
				LDA		YC
				EOR		#$FF
				CLC
				ADC		#$01
				STA		YT

				CLC
				LDA		XM
				ADC		XC
				STA		XKO
				LDA		YM
				STA		YKO
				JSR		PLOTXYcheck
:plota			CLC
				LDA		XM
				ADC		XT
				STA		XKO
				JSR		PLOTXYcheck
:plotb			LDA		XM
				STA		XKO
				CLC
				LDA		YM
				ADC		XC
				STA		YKO
				JSR		PLOTXYcheck
:plotc			CLC
				LDA		YM
				ADC		XT
				STA		YKO
				JSR		PLOTXYcheck
:plotd			RTS			
;
;***************************************************************************************
; fast Bresenham circle algorithm with fillmode
;***************************************************************************************
FILLCIRCLE
          		STA		80SToff				; 80STORE off
				LDA		RADIUS
				STA		FEHLER
				STA		XC
				STZ		YC
				JSR		:SETPIX1		; set first pixels
								
:LOOP			LDA		YC	
				CMP		XC
				BCC		:LOOPGO
				RTS						; exit -> circle done!
				
:LOOPGO			LDA		YC
				ASL
				ADC		#1
				STA		DY
				INC		YC
				LDA		DY
				EOR		#$FF
				CLC
				ADC		#1
				ADC		FEHLER
				STA		FEHLER
				BPL		:DOPLOTS
:STEPX			LDA		XC
				ASL
				EOR		#$FF
				CLC
				ADC		#2
				STA		DX
				DEC		XC
				LDA		DX
				EOR		#$FF
				CLC
				ADC		#1
				ADC		FEHLER
				STA		FEHLER
				
:DOPLOTS		LDA		XC				; Calc XT and YT
				EOR		#$FF
				CLC
				ADC		#$01
				STA		XT
				LDA		YC
				EOR		#$FF
				CLC						
				ADC		#$01
				STA		YT
				CLC						; 1st octant
				LDA		XM
				ADC		XC
				STA		XKO
				STA		XKO2
				CLC
				LDA		YM
				ADC		YC
				STA		YKO
				JSR		PLOTXYcheck
				CLC						; 2nd octant
				LDA		XM
				ADC		XT
				STA		XKO
				JSR		PLOTXYcheck
				JSR		HLINcheck		 ; fill line
				LDA		XKO
				STA		XKO2
				CLC						; 3rd octant
				LDA		YM
				ADC		YT
				STA		YKO
				JSR 	PLOTXYcheck
				CLC						; 4th octant
				LDA		XM
				ADC		XC
				STA		XKO
				JSR		PLOTXYcheck
				JSR		HLINcheck
				CLC						; 5th octant
				LDA		XM
				ADC		YC
				STA		XKO
				STA		XKO2
				CLC	
				LDA		YM
				ADC		XC
				STA		YKO
				JSR		PLOTXYcheck
				CLC						; 6th octant
				LDA		XM
				ADC		YT
				STA		XKO
				JSR		PLOTXYcheck
				JSR 	HLINcheck
				LDA		XKO
				STA		XKO2
				CLC						; 7th octant
				LDA		YM
				ADC		XT
				STA		YKO
				JSR		PLOTXYcheck
				CLC						; 8th octant
				LDA		XM
				ADC		YC
				STA		XKO
				JSR		PLOTXYcheck
				JSR		HLINcheck
				JMP		:LOOP						
				
:SETPIX1		LDA		XC
				EOR		#$FF
				CLC
				ADC		#$01
				STA		XT
				LDA		YC
				EOR		#$FF
				CLC
				ADC		#$01
				STA		YT

				CLC
				LDA		XM
				ADC		XC
				STA		XKO
				STA		XKO2
				LDA		YM
				STA		YKO
				JSR		PLOTXYcheck
				CLC
				LDA		XM
				ADC		XT
				STA		XKO
				JSR		PLOTXYcheck
				JSR		HLINcheck
				LDA		XM
				STA		XKO
				CLC
				LDA		YM
				ADC		XC
				STA		YKO
				JSR		PLOTXYcheck
				CLC
				LDA		YM
				ADC		XT
				STA		YKO
				JSR		PLOTXYcheck
				RTS			
;
;***************************************************************************************
; fast filled rectangle algorithm
;***************************************************************************************
FILLRECT
          		STA		80SToff				; 80STORE off
				LDA		YKO
				LDX		YKO2
				CMP		YKO2			; check if XKO < XKO2
				BCC		:frcont			; --> yes!
				STA		YKO2
				STX		YKO
				BRA		:frcont

:frcont			INC		YKO2
				LDA		YKO
:frloop			STA		YKO
				JSR		HLIN
				INC 	YKO
				LDA		YKO
				CMP		YKO2
				BLT		:frloop
				RTS
;
;***************************************************************************************
; fast flood-fill
;***************************************************************************************
FLOODFILL

; XSEED/YSEED must be inside the polygon
; FPTR on zero page
; COLOR2 is the current COLOR to be replaced
; COLOR is the color to set the pixel to

; Check SEED-point if valid and not already in COLOR

          		STA		80SToff				; 80STORE off
				
				STA		WRITEAUX
				LDX		#0				; erase memory area for fill check
er_lp			TXA
				STZ		FPTR
				CLC
				ADC		#>FBASE
				STA		FPTR+1
				LDA		#0
				LDY		#0
er_lp2			STA		(FPTR),Y		; erase row
				INY
				CPY		#80
				BLT		er_lp2
				INX						; next row
				CPX		#48
				BLT		er_lp
				STA		WRITEMAIN

				STZ		FPTR
				LDA		#$40
				STA		FPTR+1

				LDA		XSEED			; read COLOR2 from SEED-point als replacement color 
				STA		XKO
				LDA		YSEED
				STA		YKO
				JSR		SCRNXY
				LDA		SCRN
				STA		COLOR2

				LDY		#0				; PUSH SEED-point to stack (XSEED/YSEED), increase FPTR
				LDA		XSEED
				STA		WRITEAUX
				STA		(FPTR),Y
				INY
				LDA		YSEED
				STA		(FPTR),Y
				STA		WRITEMAIN
				CLC
				LDA		FPTR
				ADC		#2
				STA		FPTR
				LDA		FPTR+1
				ADC		#0				; add carry bit if necessary
				STA		FPTR+1
			
; timing measurements:
;
; Version with AUX-check
; 1st screen: 2246796620-2253765161=6968541
; 2nd screen: 2253765161-2258915949=5150788	
; 3rd screen: 2265410752-2258915949=6494803			
;
; Version without AUX-check
; 1st screen: 16421101-26188091=9766990
; 2nd screen: 33905210-26188091=7717119
; 3rd screen: 42515566-33905210=8610356
;
; Ratios:
; 1st screen: 71,3%
; 2nd screen: 66,7%
; 3rd screen: 75,4%	
;
; check all pixels against COLOR2 and set them to COLOR via PLOTXY
; Loop over stack queue until FPTR = init values ($2000)
FILLLOOP		LDA		FPTR			; check if queue pointer has reached its init value
				BNE		FILLcont
				LDA		FPTR+1
				CMP		#$40
				BNE		FILLcont
				RTS						; all done		

FILLcont								; POP last queue value into (X1/Y1) and set to COLOR via PLOTXY(XKO,YKO,COLOR)
				SEC						; get queue adress of last value
				LDA		FPTR
				SBC		#2
				STA		FPTR
				LDA		FPTR+1
				SBC		#0
				STA		FPTR+1
				LDY		#0
				STA		READAUX
				LDA		(FPTR),Y		; retrieve last X/Y-coordinates from queue
				STA		READMAIN
				STA		X1
				STA		XKO
				STA		FPTR2
				INY
				STA		READAUX
				LDA		(FPTR),Y
				STA		READMAIN
				STA		Y1
				STA		YKO
				CLC							; check if point was already plotted
				ADC		#>FBASE
				STA		FPTR2+1
				STA		READAUX
				LDA		(FPTR2)
				STA		READMAIN
				BNE		FILLLOOP			; if value > 0 pixel was already set
				JSR		PLOTXY			; plot pixel in COLOR	
				LDA		#2				; write flag into aux
				STA		WRITEAUX		; write back value to AUX mem
				STA		(FPTR2)
				STA		WRITEMAIN

; check 4-neighbourhood if COLOR2 needs to be replaced
; check if Y1+1 < 48, check if SCRNXY(X1,Y1+1) = COLOR2 -> yes? -> PUSH (X1,Y1+1) to queue
:noplot
				LDA		Y1				; Y1 < 47?
				CMP		YLIM
				BGE		:nb4			; no
				INC						; get color (X1,Y1+1)
				STA		YKO
				LDA		X1
				STA		XKO
				JSR		SCRNXY			; get color of pixel to test
				LDA		SCRN
				CMP		COLOR2			; = COLOR2
				BNE		:nb4			; no -> do not save in queue
				CMP		COLOR			; = COLOR2
				BEQ		:nb4			; no -> do not save in queue
				LDY		#0				; PUSH new point to stack (X1/Y1), increase FPTR
				LDA		X1
				STA		WRITEAUX
				STA		(FPTR),Y
				INY
				LDA		YKO
				STA		(FPTR),Y
				STA		WRITEMAIN
				CLC
				LDA		FPTR
				ADC		#2
				STA		FPTR
				LDA		FPTR+1
				ADC		#0				; add carry bit if necessary
				STA		FPTR+1

; check if Y1-1 >= 0, check if SCRNXY(X1,Y1-1) = COLOR2 -> yes? -> PUSH (X1,Y1-1) to queue
:nb4
				LDA		Y1				; Y1 > 0?
				BEQ		:nb3			; no
				DEC						; get color (X1,Y1-1)
				STA		YKO
				LDA		X1
				STA		XKO
				JSR		SCRNXY			; get color of pixel to test
				LDA		SCRN
				CMP		COLOR2			; = COLOR2
				BNE		:nb3			; no -> do not save in queue
				CMP		COLOR			; = COLOR2
				BEQ		:nb3			; no -> do not save in queue
				LDY		#0				; PUSH new point to stack (X1/Y1), increase FPTR
				LDA		X1
				STA		WRITEAUX
				STA		(FPTR),Y
				INY
				LDA		YKO
				STA		(FPTR),Y
				STA		WRITEMAIN
				CLC
				LDA		FPTR
				ADC		#2
				STA		FPTR
				LDA		FPTR+1
				ADC		#0				; add carry bit if necessary
				STA		FPTR+1

; check if X1+1 < 80, check if SCRNXY(X1+1,Y1) = COLOR2 -> yes? -> PUSH (X1+1,Y1) to queue
:nb3			LDA		X1				; X1 < 79?
				CMP		#79
				BGE		:nb2			; no
				INC						; get color (X1+1,Y1)
				STA		XKO
				LDA		Y1
				STA		YKO
				JSR		SCRNXY			; get color of pixel to test
				LDA		SCRN
				CMP		COLOR2			; = COLOR2
				BNE		:nb2			; no -> do not save in queue
				CMP		COLOR
				BEQ		:nb2
				LDY		#0				; PUSH new point to stack (X1/Y1), increase FPTR
				LDA		XKO
				STA		WRITEAUX
				STA		(FPTR),Y
				INY
				LDA		Y1
				STA		(FPTR),Y
				STA		WRITEMAIN
				CLC
				LDA		FPTR
				ADC		#2
				STA		FPTR
				LDA		FPTR+1
				ADC		#0				; add carry bit if necessary
				STA		FPTR+1
				
; check if X1-1 >= 0, check if SCRNXY(X1-1,Y1) = COLOR2 -> yes? -> PUSH (X1-1,Y1) to queue
:nb2
				LDA		X1				; X1 > 0?
				BEQ		FILLbody		; no
				DEC						; get color (X111,Y1)
				STA		XKO
				LDA		Y1
				STA		YKO
				JSR		SCRNXY			; get color of pixel to test
				LDA		SCRN
				CMP		COLOR2			; = COLOR2
				BNE		FILLbody		; no -> do not save in queue
				CMP		COLOR			; = COLOR2
				BEQ		FILLbody		; no -> do not save in queue
				LDY		#0				; PUSH new point to stack (X1/Y1), increase FPTR
				LDA		XKO
				STA		WRITEAUX
				STA		(FPTR),Y
				INY
				LDA		Y1
				STA		(FPTR),Y
				STA		WRITEMAIN
				CLC
				LDA		FPTR
				ADC		#2
				STA		FPTR
				LDA		FPTR+1
				ADC		#0				; add carry bit if necessary
				STA		FPTR+1
;
; loop body
FILLbody		JMP		FILLLOOP
;
;***************************************************************************************
; Clear Double LORES Screen 
;***************************************************************************************
* A = lo-res color byte
DL_Clear     	ldx   #40
:loop        	dex								; clear MAIN mem page
				sta   Lo01,x
             	sta   Lo02,x
             	sta   Lo03,x
             	sta   Lo04,x
             	sta   Lo05,x
             	sta   Lo06,x
             	sta   Lo07,x
             	sta   Lo08,x
             	sta   Lo09,x
             	sta   Lo10,x
             	sta   Lo11,x
             	sta   Lo12,x
             	sta   Lo13,x
             	sta   Lo14,x
             	sta   Lo15,x
             	sta   Lo16,x
             	sta   Lo17,x
             	sta   Lo18,x
             	sta   Lo19,x
             	sta   Lo20,x
             	bne   :loop
             	tax                  			; get aux color value
             	lda   MainAuxMap,x
             	ldx   #40
:loop2       	dex								; clear AUX mem page 
				STA		WRITEAUX
             	sta   Lo01,x
             	sta   Lo02,x
             	sta   Lo03,x
             	sta   Lo04,x
             	sta   Lo05,x
             	sta   Lo06,x
             	sta   Lo07,x
             	sta   Lo08,x
             	sta   Lo09,x
             	sta   Lo10,x
             	sta   Lo11,x
             	sta   Lo12,x
             	sta   Lo13,x
             	sta   Lo14,x
             	sta   Lo15,x
             	sta   Lo16,x
             	sta   Lo17,x
             	sta   Lo18,x
             	sta   Lo19,x
             	sta   Lo20,x
				STA		WRITEMAIN
             	bne   :loop2
             	rts

* A = lo-res color byte
DL_Clear2     	ldx   #40						; clear page 2
:loopa        	dex								; clear MAIN mem page
             	sta   Lo01a,x
             	sta   Lo02a,x
             	sta   Lo03a,x
             	sta   Lo04a,x
             	sta   Lo05a,x
             	sta   Lo06a,x
             	sta   Lo07a,x
             	sta   Lo08a,x
             	sta   Lo09a,x
             	sta   Lo10a,x
             	sta   Lo11a,x
             	sta   Lo12a,x
             	sta   Lo13a,x
             	sta   Lo14a,x
             	sta   Lo15a,x
             	sta   Lo16a,x
             	sta   Lo17a,x
             	sta   Lo18a,x
             	sta   Lo19a,x
             	sta   Lo20a,x
             	bne   :loopa
             	tax                  			; get aux color value
             	lda   MainAuxMap,x
             	ldx   #40
:loop2a      	dex								; clear AUX mem page 
				STA		WRITEAUX
             	sta   Lo01a,x
             	sta   Lo02a,x
             	sta   Lo03a,x
             	sta   Lo04a,x
             	sta   Lo05a,x
             	sta   Lo06a,x
             	sta   Lo07a,x
             	sta   Lo08a,x
             	sta   Lo09a,x
             	sta   Lo10a,x
             	sta   Lo11a,x
             	sta   Lo12a,x
             	sta   Lo13a,x
             	sta   Lo14a,x
             	sta   Lo15a,x
             	sta   Lo16a,x
             	sta   Lo17a,x
             	sta   Lo18a,x
             	sta   Lo19a,x
             	sta   Lo20a,x
             	STA		WRITEMAIN
             	bne   :loop2a
             	rts

				DS \
MainAuxMap
             	hex   	00,08,01,09,02,0A,03,0B,04,0C,05,0D,06,0E,07,0F
             	hex   	80,88,81,89,82,8A,83,8B,84,8C,85,8D,86,8E,87,8F
             	hex   	10,18,11,19,12,1A,13,1B,14,1C,15,1D,16,1E,17,1F
             	hex   	90,98,91,99,92,9A,93,9B,94,9C,95,9D,96,9E,97,9F
             	hex   	20,28,21,29,22,2A,23,2B,24,2C,25,2D,26,2E,27,2F
             	hex   	A0,A8,A1,A9,A2,AA,A3,AB,A4,AC,A5,AD,A6,AE,A7,AF
             	hex   	30,38,31,39,32,3A,33,3B,34,3C,35,3D,36,3E,37,3F
             	hex   	B0,B8,B1,B9,B2,BA,B3,BB,B4,BC,B5,BD,B6,BE,B7,BF
             	hex   	40,48,41,49,42,4A,43,4B,44,4C,45,4D,46,4E,47,4F
             	hex   	C0,C8,C1,C9,C2,CA,C3,CB,C4,CC,C5,CD,C6,CE,C7,CF
             	hex   	50,58,51,59,52,5A,53,5B,54,5C,55,5D,56,5E,57,5F
             	hex   	D0,D8,D1,D9,D2,DA,D3,DB,D4,DC,D5,DD,D6,DE,D7,DF
             	hex   	60,68,61,69,62,6A,63,6B,64,6C,65,6D,66,6E,67,6F
             	hex   	E0,E8,E1,E9,E2,EA,E3,EB,E4,EC,E5,ED,E6,EE,E7,EF
             	hex   	70,78,71,79,72,7A,73,7B,74,7C,75,7D,76,7E,77,7F
             	hex   	F0,F8,F1,F9,F2,FA,F3,FB,F4,FC,F5,FD,F6,FE,F7,FF

AuxMainMap		HEX		00,02,04,06,08,0A,0C,0E,01,03,05,07,09,0B,0D,0F             	
				HEX		20,22,24,26,28,2A,2C,2E,21,23,25,27,29,2B,2D,2F
				HEX		40,42,44,46,48,4A,4C,4E,41,43,45,47,49,4B,4D,4F
				HEX		60,62,64,66,68,6A,6C,6E,61,63,65,67,69,6B,6D,6F
				HEX		80,82,84,86,88,8A,8C,8E,81,83,85,87,89,8B,8D,8F
				HEX		A0,A2,A4,A6,A8,AA,AC,AE,A1,A3,A5,A7,A9,AB,AD,AF
				HEX		C0,C2,C4,C6,C8,CA,CC,CE,C1,C3,C5,C7,C9,CB,CD,CF
				HEX		E0,E2,E4,E6,E8,EA,EC,EE,E1,E3,E5,E7,E9,EB,ED,EF
				HEX		10,12,14,16,18,1A,1C,1E,11,13,15,17,19,1B,1D,1F
				HEX		30,32,34,36,38,3A,3C,3E,31,33,35,37,39,3B,3D,3F
				HEX		50,52,54,56,58,5A,5C,5E,51,53,55,57,59,5B,5D,5F
				HEX		70,72,74,76,78,7A,7C,7E,71,73,75,77,79,7B,7D,7F
				HEX		90,92,94,96,98,9A,9C,9E,91,93,95,97,99,9B,9D,9F
				HEX		B0,B2,B4,B6,B8,BA,BC,BE,B1,B3,B5,B7,B9,BB,BD,BF
				HEX		D0,D2,D4,D6,D8,DA,DC,DE,D1,D3,D5,D7,D9,DB,DD,DF
				HEX		F0,F2,F4,F6,F8,FA,FC,FE,F1,F3,F5,F7,F9,FB,FD,FF

         		;DS 	\						; alignment needed here for self-modification!
*                  
YLOOKHI   		HEX 	0404050506060707
          		HEX 	0404050506060707
          		HEX 	0404050506060707
          		HEX 	0404050506060707
          		
* A = lo-res color byte
DL_ClearBot    	ldx   #40						; clear bottom 4 lines
:loop        	dex								; clear MAIN mem page
             	sta   Lo21,x
             	sta   Lo22,x
             	sta   Lo23,x
             	sta   Lo24,x
             	bne   :loop
             	ldx   #40
:loop2       	dex								; clear AUX mem page 
				STA		WRITEAUX
             	sta   Lo21,x
             	sta   Lo22,x
             	sta   Lo23,x
             	sta   Lo24,x
				STA		WRITEMAIN
             	bne   :loop2
             	rts

* A = lo-res color byte
DL_Clear2Bot   	ldx   #40						; clear page 2
:loopa2        	dex								; clear MAIN mem page
             	sta   Lo21a,x
             	sta   Lo22a,x
             	sta   Lo23a,x
             	sta   Lo24a,x
             	bne   :loopa2
             	ldx   #40
:loop2a2      	dex								; clear AUX mem page 
				STA		WRITEAUX
				sta   Lo21a,x
             	sta   Lo22a,x
             	sta   Lo23a,x
             	sta   Lo24a,x
             	STA		WRITEMAIN
             	bne   :loop2a2
             	rts

* A = lo-res color byte
DL_ClearBota   	ldx   #40						; clear bottom 4 lines
:loop21       	dex								; clear MAIN mem page
             	sta   Lo21,x
             	sta   Lo22,x
             	sta   Lo23,x
             	sta   Lo24,x
             	bne   :loop21
             	tax                  			; get aux color value
             	lda   MainAuxMap,x
             	ldx   #40
:loop22       	dex								; clear AUX mem page 
				STA		WRITEAUX
             	sta   Lo21,x
             	sta   Lo22,x
             	sta   Lo23,x
             	sta   Lo24,x
				STA		WRITEMAIN
             	bne   :loop22
             	rts

* A = lo-res color byte
DL_Clear2Bota  	ldx   #40						; clear page 2
:loopa        	dex								; clear MAIN mem page
             	sta   Lo21a,x
             	sta   Lo22a,x
             	sta   Lo23a,x
             	sta   Lo24a,x
             	bne   :loopa
             	tax                  			; get aux color value
             	lda   MainAuxMap,x
             	ldx   #40
:loop2a      	dex								; clear AUX mem page 
				STA		WRITEAUX
				sta   Lo21a,x
             	sta   Lo22a,x
             	sta   Lo23a,x
             	sta   Lo24a,x
             	STA		WRITEMAIN
             	bne   :loop2a
             	rts


          		DS 	\						; alignment needed here for self-modification!
*                  
YLOOKHI2  		HEX 	080809090A0A0B0B
          		HEX 	080809090A0A0B0B
          		HEX 	080809090A0A0B0B
          		HEX 	080809090A0A0B0B
         		;DS 	\
*
NIBFLIP			HEX		0010203040506070				; LUT for NIBBLE-flipping color values
				HEX		8090A0B0C0D0E0F0
*
NIBDOUBLE		HEX		0011223344556677
				HEX		8899AABBCCDDEEFF
*
YLOOKLO   		HEX 	0080008000800080
				HEX		28A828A828A828A8
				HEX		50D050D050D050D0
				HEX		78F878F878F878F8
 				DS  \             
*                  
YLOOKHI3  		HEX 	0C0C0D0D0E0E0F0F
          		HEX 	0C0C0D0D0E0E0F0F
          		HEX 	0C0C0D0D0E0E0F0F
          		HEX 	0C0C0D0D0E0E0F0F
*
CODEEND										; dump storage for local variables          		
               
* Lores/Text lines page 1
Lo01          	equ   $400
Lo02            equ   $480
Lo03            equ   $500
Lo04            equ   $580
Lo05            equ   $600
Lo06            equ   $680
Lo07            equ   $700
Lo08            equ   $780
Lo09            equ   $428
Lo10            equ   $4a8
Lo11            equ   $528
Lo12            equ   $5a8
Lo13            equ   $628
Lo14            equ   $6a8
Lo15            equ   $728
Lo16            equ   $7a8
Lo17            equ   $450
Lo18            equ   $4d0
Lo19            equ   $550
Lo20            equ   $5d0
* the "plus four" lines
Lo21            equ   $650
Lo22            equ   $6d0
Lo23            equ   $750
Lo24            equ   $7d0

* Lores/Text lines page2
Lo01a            equ   $800
Lo02a            equ   $880
Lo03a            equ   $900
Lo04a            equ   $980
Lo05a            equ   $A00
Lo06a            equ   $A80
Lo07a            equ   $B00
Lo08a            equ   $B80
Lo09a            equ   $828
Lo10a            equ   $8a8
Lo11a            equ   $928
Lo12a            equ   $9a8
Lo13a            equ   $A28
Lo14a            equ   $Aa8
Lo15a            equ   $B28
Lo16a            equ   $Ba8
Lo17a            equ   $850
Lo18a            equ   $8d0
Lo19a            equ   $950
Lo20a            equ   $9d0
* the "plus four" lines
Lo21a            equ   $A50
Lo22a            equ   $Ad0
Lo23a            equ   $B50
Lo24a            equ   $Bd0

				
				

          		
          		