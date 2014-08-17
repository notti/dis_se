package scanner

import (
    "fmt"
    "strconv"
    "math"
    "os"
    . "parser"
)

%%{
    machine asm;
    write data;
}%%

type forState struct {
    name string
    max int64
    p int
}

type ScannerState struct {
    cs, p, pe, ts, te, act, eof, line int
    data []byte
    consts map[string]int64
    fconsts map[string]float64
    forloops []forState
    forvars map[string]int64
}

func NewScanner(data []byte) *ScannerState {
    state := ScannerState{0, 0, len(data), 0, 0, 0, 0, 1, data, make(map[string]int64), make(map[string]float64), make([]forState, 0, 3), make(map[string]int64)}
    state.fconsts["M_PI"] = math.Pi
    %% write init;
    return &state
}

func (state *ScannerState) Lex(lval *ParserSymType) int {
    token := 0
    sa := 0
    var ok bool
    %%{
        variable cs state.cs;
        variable p state.p;
        variable pe state.pe;
        variable ts state.ts;
        variable te state.te;
        variable act state.act;
        variable eof state.eof;
        variable data state.data;
        
        action singleToken {
            token = int(state.data[state.p])
            fbreak;
        }
        action pos {
            sa = state.p
        }
        action storeString {
            lval.Id = string(state.data[sa:state.p])
        }
        action parseBin {
            lval.Num, _ = strconv.ParseInt(string(state.data[sa:state.p]), 2, 0)
        }
        action parseOct {
            lval.Num, _ = strconv.ParseInt(string(state.data[sa:state.p]), 8, 0)
        }
        action parseDec {
            lval.Num, _ = strconv.ParseInt(string(state.data[sa:state.p]), 10, 0)
        }
        action parseHex {
            lval.Num, _ = strconv.ParseInt(string(state.data[sa:state.p]), 16, 0)
        }
        action parseAscii {
            lval.Num = int64(state.data[state.p - 1])
        }
        action parseFloat {
            lval.Fnum, _ = strconv.ParseFloat(string(state.data[sa:state.p]), 64)
        }

        identifier = [a-zA-Z_] >pos [a-zA-Z0-9_]* %storeString;
        literal =  '0b'i %pos [01]+ %parseBin |
                   '0x'i %pos xdigit+ %parseHex |
                   '0' %pos digit+ %parseOct |
                         digit+ >pos %parseDec | 
                        "'" extend %parseAscii "'" ;
        float = ( digit+ '.' digit* |
                digit* '.' digit+ ) >pos %parseFloat;
        fix = 'fix'i [1-7] %{ lval.Num = int64(state.data[state.p-1] - '0') };
        comment := any* '\n' @{ fhold; fnext main; };
        registerLH = '$' %pos digit+  %parseDec ('L'i | 'H'i %{ lval.Num |= 0x10 } );
        register = '$' %pos digit+  %parseDec;
        literalorconst = literal | identifier %{ lval.Num, ok = state.consts[lval.Id]; if ok == false { state.p = sa; fnext *asm_error; } };
        for := space* identifier %{ state.forloops = append(state.forloops, forState{lval.Id, 0, 0}) } space* 'in'i space* literalorconst %{ state.forvars[state.forloops[len(state.forloops)-1].name] = lval.Num } space* 'to'i space* literalorconst %{ state.forloops[len(state.forloops)-1].max = lval.Num } space* '{' @{ state.forloops[len(state.forloops)-1].p = state.p; fnext main; };

        main := |*
                 '\n' => {
                     state.line++
                     token = int(state.data[state.p])
                     fbreak;
                 };
                 ';' => { fnext comment; };
                 space;
                 'for'i => { fnext for; };
                 'const'i => {
                     token = CONST
                     fbreak;
                 };
                 float => {
                     token = FLOAT;
                     fbreak;
                 };
                 'define'i => {
                     token = DEFINE
                     fbreak;
                 };
                 'mem'i => {
                     token = MEM
                     fbreak;
                 };
                 'reg'i => {
                     token = REG
                     fbreak;
                 };
                 'last'i => {
                     token = LAST
                     fbreak;
                 };
                 'imm'i => {
                     token = IMM
                     fbreak;
                 };
                 'unsigned'i => {
                     token = UNSIGNED
                     fbreak;
                 };
                 'signed'i => {
                     token = SIGNED
                     fbreak;
                 };
                 'int'i => {
                     token = INT
                     fbreak;
                 };
                 fix => {
                     token = FIX
                     fbreak;
                 };
                 literal => {
                     token = LITERAL
                     fbreak;
                 };
                 '(' => singleToken;
                 ')' => singleToken;
                 '{' => singleToken;
                 '}' => {
                     if len(state.forloops) > 0 {
                         name := state.forloops[len(state.forloops)-1].name
                         state.forvars[name]++
                         if state.forvars[name] == state.forloops[len(state.forloops)-1].max {
                             state.forloops = state.forloops[:len(state.forloops)-1]
                             delete(state.forvars, name)
                         } else {
                             state.p = state.forloops[len(state.forloops)-1].p
                         }
                     } else {
                         token = int(state.data[state.p])
                         fbreak;
                     }
                 };
                 '=' => singleToken;
                 '+' => singleToken;
                 '-' => singleToken;
                 '*' => singleToken;
                 '/' => singleToken;
                 '%' => singleToken;
                 '&' => singleToken;
                 '|' => singleToken;
                 '>>' => {
                     token = RSHIFT
                     fbreak;
                 };
                 '<<' => {
                     token = LSHIFT
                     fbreak;
                 };
                 '[' => singleToken;
                 ']' => singleToken;
                 '^' => singleToken;
                 ',' => singleToken;
                 ':' => singleToken;
                 register => {
                     token = REGISTER
                     fbreak;
                 };
                 registerLH => {
                     token = REGISTERLH
                     fbreak;
                 };
                 'DW'i => {
                     token = DW
                     fbreak;
                 };
                 'NOP'i => {
                     token = OP
                     lval.Num = 0x0000
                     fbreak;
                 };
                 'JMP'i => {
                     token = OP1
                     lval.Num = 0x0010
                     fbreak;
                 };
                 'JZ'i => {
                     token = OP1
                     lval.Num = 0x0020
                     fbreak;
                 };
                 'JNE'i => {
                     token = OP1
                     lval.Num = 0x0030
                     fbreak;
                 };
                 'JNZ'i => {
                     token = OP1
                     lval.Num = 0x0030
                     fbreak;
                 };
                 'JLE'i => {
                     token = OP1
                     lval.Num = 0x0040
                     fbreak;
                 };
                 'JLT'i => {
                     token = OP1
                     lval.Num = 0x0050
                     fbreak;
                 };
                 'JGE'i => {
                     token = OP1
                     lval.Num = 0x0060
                     fbreak;
                 };
                 'JGT'i => {
                     token = OP1
                     lval.Num = 0x0070
                     fbreak;
                 };
                 'JULE'i => {
                     token = OP1
                     lval.Num = 0x0080
                     fbreak;
                 };
                 'JULT'i => {
                     token = OP1
                     lval.Num = 0x0090
                     fbreak;
                 };
                 'JUGE'i => {
                     token = OP1
                     lval.Num = 0x00A0
                     fbreak;
                 };
                 'JUGT'i => {
                     token = OP1
                     lval.Num = 0x00B0
                     fbreak;
                 };
                 'CMP'i => {
                     token = OP2
                     lval.Num = 0x0100
                     fbreak;
                 };
                 'MOV'i => {
                     token = MOV
                     lval.Num = 0xC300
                     fbreak;
                 };
                 'MOVH'i => {
                     token = MOV
                     lval.Num = 0xC200
                     fbreak;
                 };
                 'MOVL'i => {
                     token = MOV
                     lval.Num = 0xC100
                     fbreak;
                 };
                 'ADD'i => {
                     token = OP3
                     lval.Num = 0x1000
                     fbreak;
                 };
                 'ADDC'i => {
                     token = OP3
                     lval.Num = 0x2000
                     fbreak;
                 };
                 'SUB'i => {
                     token = OP3
                     lval.Num = 0x3000
                     fbreak;
                 };
                 'SUBB'i => {
                     token = OP3
                     lval.Num = 0x4000
                     fbreak;
                 };
                 'AND'i => {
                     token = OP3
                     lval.Num = 0x5000
                     fbreak;
                 };
                 'OR'i => {
                     token = OP3
                     lval.Num = 0x6000
                     fbreak;
                 };
                 'XOR'i => {
                     token = OP3
                     lval.Num = 0x7000
                     fbreak;
                 };
                 'SHL'i => {
                     token = OP3
                     lval.Num = 0x8000
                     fbreak;
                 };
                 'SHR'i => {
                     token = OP3
                     lval.Num = 0x9000
                     fbreak;
                 };
                 'SAR'i => {
                     token = OP3
                     lval.Num = 0xA000
                     fbreak;
                 };
                 identifier => {
                     token = IDENTIFIER
                     lval.Num, ok = state.forvars[lval.Id]
                     if ok == true {
                         token = LITERAL
                     } else {
                         lval.Num, ok = state.consts[lval.Id]
                         if ok == true {
                             token = LITERAL
                         } else {
                            lval.Fnum, ok = state.fconsts[lval.Id]
                            if ok == true {
                                token = FLOAT
                            }
                         }
                     }
                     fbreak;
                 };
                 *|;

        write exec;
    }%%
    return token
}

func (state *ScannerState) ScanOk() {
    if state.p != state.pe {
        last := state.p
        for ; last<=state.pe; last++ {
            if state.data[last] == '\n' {
                break
            }
        }
        fmt.Fprintln(os.Stderr, "Scan error at line", state.line, "near", string(state.data[state.p:last]))
    } 
}

func (state *ScannerState) Error(s string) {
    fmt.Fprintf(os.Stderr, "syntax error: %s in line %d\n", s, state.line)
}

func (state *ScannerState) AddConst(id string, num int64) {
    state.consts[id] = num
}

func (state *ScannerState) AddConstf(id string, num float64) {
    state.fconsts[id] = num
}
