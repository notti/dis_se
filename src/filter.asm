define B mem 0b00
define X mem 0b01
define Y mem 0b10
define DUMMY mem 0b11

define loadb 0(imm b0, imm b1, imm b2, imm b3, imm addr0, imm addr2) {
    addr1 = addr0 + 1
    addr3 = addr2 + 1
    B[addr0] = b0
    B[addr1] = b1
    B[addr2] = b2
    B[addr3] = b3
}

define loadx 1(imm b0, imm b1, imm b2, imm b3, imm addr0, imm addr2) {
    addr1 = addr0 + 1
    addr3 = addr2 + 1
    X[addr0] = b0
    X[addr1] = b1
    X[addr2] = b2
    X[addr3] = b3
}

;0
;3
;0
;33
;0
;93
;0
;127
;0
;93
;0
;33
;0
;3
;0

loadb 0, 3, 0, 33, 0, 2
loadx 0, 0, 0, 0, 0, 2
loadb 0, 93, 0, 127, 4, 6
loadx 0, 0, 0, 0, 4, 6
loadb 0, 93, 0, 33, 8, 10
loadx 0, 0, 0, 0, 8, 10
loadb 0, 3, 0, 0, 12, 14
loadx 0, 0, 0, 0, 12, 14

;loadb 13, 12, 6, -1, 0, 2
;loadx 0, 0, 0, 0, 0, 2
;loadb -28, 32, 9, 89, 4, 6
;loadx 0, 0, 0, 0, 4, 6
;loadb 9, 32, -28, -1, 8, 10
;loadx 0, 0, 0, 0, 8, 10
;loadb 6, 12, 13, 0, 12, 14
;loadx 0, 0, 0, 0, 12, 14

; Y[0] = x * B[0] + X[0] * B[1]
; X[0] = x
; X[1] = X[0]
define first 0(imm a0, imm a1, signed fix7 reg x) {
    Y[a0] = x * B[a0] + signed fix7 X[a0] * B[a1]
    X[a0] = x
    X[a1] = X[a0]
}

; Y[1] = X[1] * B[2] + X[2] * B[3]
; X[2] = X[1]
; X[3] = X[2]
define middle 1(imm a1, imm a2, imm a3) {
    Y[a1] = signed fix7 X[a1] * B[a2] + signed fix7 X[a2] * B[a3]
    X[a2] = X[a1]
    X[a3] = X[a2]
}

define merge 2(imm a1, imm a2, imm a3, imm a4, imm a5) {
    sum1 = Y[a1] + Y[a2]
    sum2 = Y[a3] + Y[a4]
    Y[a5] = sum1 + sum2
}

LOOP:
MOVL $0, SERIAL[0]
first 0, 1, $0L

; 1 2 3
; 3 4 5
; 5 6 7
; 7 8 9
; 9 10 11
; 11 12 13
; 13 14 15
for i in 0 to 7 {
    middle i*2+1, i*2+2, i*2+3
}

; 0 + 1 + 3 + 5 + 7 + 9 + 11 + 13
merge 0, 1, 3, 5, 0
merge 7, 9, 11, 13, 1
NOP
NOP
NOP
NOP
NOP
MOVL $0, Y[0]
MOVL $1, Y[1]
ADD $0, $0, $1
MOVL SERIAL[0], $1
JMP LOOP
