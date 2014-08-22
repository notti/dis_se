const N 256

define R mem 0b10
define I mem 0b11

define load 0(reg r1, reg i1, reg addr1, reg r2, reg i2) {
    addr2 = addr1 + 1
    R[^8 addr1] = r1
    I[^8 addr1] = i1
    R[^8 addr2] = r2
    I[^8 addr2] = i2
}

define bfr 1(unsigned reg i, unsigned reg j, signed fix7 reg wr, signed fix7 reg wi) {
    tr = wr * R[j] - wi * I[j]
    qr = signed fix7 R[i] >> 1
    R[j] = qr - tr
    R[i] = qr + tr
}

define bfi 2(unsigned last i, unsigned last j, signed fix7 last wr, signed fix7 last wi) {
    ti = wr * I[j] + wi * R[j]
    qi = signed fix7 I[i] >> 1
    I[j] = qi - ti
    I[i] = qi + ti
}
 
; sync

    MOV $0, 0
    MOV $9, N
    MOV $10, N/4
    MOV $11, 7
    MOV $12, 2
BEGIN_SYNC:
    MOVL $0, SERIAL[0]
    CMP $0, 0x55
    JNE BEGIN_SYNC
    MOVL $0, SERIAL[0]
    CMP $0, 0xAA
    JNE BEGIN_SYNC

    MOV $0, '1'
    MOVL SERIAL[0], $0

LOAD:
    MOV $2, 0
    MOV $0, 0
    MOV $1, 0
READ:
    MOVL $0, SERIAL[0]
    MOVH $0, SERIAL[0]     ; $0 = IR
    MOVL $1, SERIAL[0]
    MOVH $1, SERIAL[0]     ; $1 = IR
    load $0L, $0H, $2L, $1L, $1H
    ADD $2, $2, $12
    CMP $2, $9
    JULT READ

    MOV $0, 1           ; l
    MOV $1, $11           ; k
FFT_STEP:
    SHL $2, $0, 1       ; step
    MOV $3, 0           ; m

OUTER:
    SHL $4, $3, $1      ; j
    ADD $5, $4, $10
    MOV $8, SINE[$4]        ; wi
    MOV $7, SINE[$5]        ; wr
    SUB $8, 0, $8
    MOV $5, $3          ; i

    ADD $4, $5, $0
    NOP
INNER:
    bfr $5L, $4L, $7L, $8L
    ADD $5, $5, $2
    ADD $4, $5, $0
    CMP $5, $9
    bfi
    JULT INNER

    ADD $3, $3, 1
    CMP $3, $0
    JULT OUTER

    SUB $1, $1, 1
    MOV $0, $2
    CMP $0, $9
    JULT FFT_STEP

    MOV $0, 0
UNLOAD:
    MOV $1, R[$0]
    MOV $2, I[$0]
    MOVL SERIAL[0], $1
    MOVL SERIAL[0], $2
    MOVH SERIAL[0], $1
    MOVH SERIAL[0], $2
    ADD $0, $0, 2
    CMP $0, $9
    JULT UNLOAD
    JMP LOAD

SINE:
for i in 0 to N {
    DW int(sin(2 * M_PI * i / 256) * 128) >> 1
}
