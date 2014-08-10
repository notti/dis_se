const N 256

define R mem 0b10
define I mem 0b11

define load(reg r1, reg i1, reg addr1, reg r2, reg i2) {
    addr2 = addr1 + 1
    R[^8 addr1] = r1
    I[^8 addr1] = i1
    R[^8 addr2] = r2
    I[^8 addr2] = i2
}

define bfr(unsigned reg i, unsigned reg j, signed fix7 reg wr, signed fix7 reg wi) {
    tr = wr * R[j] - wi * I[j]
    qr = signed fix7 R[i] >> 1
    R[j] = qr - tr
    R[i] = qr + tr
}

define bfi(unsigned last i, unsigned last j, signed fix7 last wr, signed fix7 last wi) {
    ti = wr * I[j] + wi * R[j]
    qi = signed fix7 I[i] >> 1
    I[j] = qi - ti
    I[i] = qi + ti
}
 
; sync

BEGIN_SYNC:
    CMPL $SERIAL, 0x55
    JNE BEGIN_SYNC
    CMPL $SERIAL, 0xAA
    JNE BEGIN_SYNC

    MOVL $SERIAL, '1'

LOAD:
    MOV $2, 0
READ:
    MOVL $0, $SERIAL
    MOVH $0, $SERIAL     ; $0 = IR
    MOVL $1, $SERIAL
    MOVH $1, $SERIAL     ; $1 = IR
    load $0L, $0H, $2, $1L, $1H
    ADD $2, $2, 2
    CMP $2, N
    JULT READ

    MOV $0, 1           ; l
    MOV $1, 7           ; k
FFT_STEP:
    SHL $2, $0, 1       ; step
    MOV $3, 0           ; m

OUTER:
    SHL $4, $3, $1      ; j
    ADD $5, $4, N/4
    MOVL $8, SINE[$4]        ; wi
    MOVL $7, SINE[$5]        ; wr
    SUB $8, 0, $8
    MOV $5, $3          ; i

INNER:
    ADD $4, $5, $0
    bfr $5, $4, $7, $8
    bfi
    ADD $5, $5, $2
    CMP $5, N
    JULT INNER

    ADD $3, $3, 1
    CMP $3, $0
    JULT OUTER

    SUB $1, $1, 1
    MOV $0, $2
    CMP $0, N
    JULT FFT_STEP

UNLOAD:
    MOV $0, 0
    MOV $SERIAL, R[$0]
    MOV $SERIAL, I[$0]
    ADD $0, $0, 1
    CMP $0, N
    JULT UNLOAD
    JMP LOAD

SINE:
for i in 0 to N {
    DB sin(2 * M_PI * i / 256) * 128
}
