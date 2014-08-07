define R mem 0b10
define I mem 0b11

define load(reg r1, reg i1, reg addr1, reg r2, reg i2) {
    addr2 = addr1 + 1
    R[^addr1] = r1
    I[^addr1] = i1
    R[^addr2] = r2
    I[^addr2] = i2
}

define bfr(unsigned reg i, unsigned reg j, signed fix7 reg wr, signed fix7 reg wi) {
    tr = wr * R[j] - wi * I[j]
    qr = (signed) R[i] >> 1
    R[j] = qr - tr
    R[i] = qr + tr
}

define bfi(unsigned last i, unsigned last j, signed fix7 last wr, signed fix7 last wi) {
    ti = wr * I[j] + wi * R[j]
    qi = (signed) I[i] >> 1
    I[j] = qi - ti
    I[i] = qi + ti
}
 

; sync

BEGIN_SYNC:
    CMPL SERIAL, 0x55
    JNE BEGIN_SYNC
    CMPL SERIAL, 0xAA
    JNE BEGIN_SYNC

    MOVL SERIAL, '1'

LOAD:
    MOV $2, 0
READ:
    MOVL $0, SERIAL
    MOVR $0, SERIAL     ; $0 = IR
    MOVL $1, SERIAL
    MOVR $1, SERIAL     ; $1 = IR
    load $0L, $0H, $2, $1L, $1H
    ADD $2, $2, 2
    CMP $2, 256
    JB READ

    MOV $0, 1           ; l
    MOV $1, 7           ; k
FFT_STEP:
    SHL $2, $0, 1       ; step
    MOV $3, 0           ; m

OUTER:
    SHL $4, $3, $1      ; j
    ADD $5, $4, 64
    MOVL $8, SINE[$4]        ; wi
    MOVL $7, SINE[$5]        ; wr
    SUB $8, 0, $8
    MOV $5, $3          ; i

INNER:
    ADD $4, $5, $0
    bfr $5, $4, $7 $8
    bfi
    ADD $5, $5, $2
    CMP $5, 256
    JB INNER

    ADD $3, $3, 1
    CMP $3, $0
    JB OUTER

    SUB $1, $1, 1
    MOV $0, $2
    CMP $0, 256
    JB FFT_STEP

UNLOAD:
    MOV $0, 0
    MOV SERIAL, R[$0]
    MOV SERIAL, I[$0]
    ADD $0, $0, 1
    CMP $0, 256
    JB UNLOAD
    JMP LOAD

SINE:
for i in 0 to 255 {
    DB sin(2 * M_PI * i / 256) * 128
}
