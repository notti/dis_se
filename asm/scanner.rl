package scanner

import (
    "fmt"
    "strconv"
    "math"
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
            lval.Num = int64(state.data[sa])
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
        fix = 'fix'i [1-7] %{ lval.Num = int64(state.data[sa] - '0') };
        comment := any* '\n' @{ fhold; fnext main; };
        register = '$' ( digit+ >pos %parseDec | 'SERIAL'i %{ lval.Num = -1 } );
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
                 'unsigned'i => {
                     token = UNSIGNED
                     fbreak;
                 };
                 'signed'i => {
                     token = SIGNED
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
                 'ADD'i => {
                     token = ADD
                     fbreak;
                 };
                 'ADDC'i => {
                     token = ADDC
                     fbreak;
                 };
                 'SUB'i => {
                     token = SUB
                     fbreak;
                 };
                 'SUBB'i => {
                     token = SUBB
                     fbreak;
                 };
                 'AND'i => {
                     token = AND
                     fbreak;
                 };
                 'OR'i => {
                     token = OR
                     fbreak;
                 };
                 'XOR'i => {
                     token = XOR
                     fbreak;
                 };
                 'NOT'i => {
                     token = NOT
                     fbreak;
                 };
                 'NEG'i => {
                     token = NEG
                     fbreak;
                 };
                 'CMP'i => {
                     token = CMP
                     fbreak;
                 };
                 'SHL'i => {
                     token = SHL
                     fbreak;
                 };
                 'SHR'i => {
                     token = SHR
                     fbreak;
                 };
                 'SAR'i => {
                     token = SAR
                     fbreak;
                 };
                 'ROLC'i => {
                     token = ROLC
                     fbreak;
                 };
                 'RORC'i => {
                     token = RORC
                     fbreak;
                 };
                 'JMP'i => {
                     token = JMP
                     fbreak;
                 };
                 'JZ'i => {
                     token = JZ
                     fbreak;
                 };
                 'JNZ'i => {
                     token = JNZ
                     fbreak;
                 };
                 'JLE'i => {
                     token = JLE
                     fbreak;
                 };
                 'JLT'i => {
                     token = JLT
                     fbreak;
                 };
                 'JGE'i => {
                     token = JGE
                     fbreak;
                 };
                 'JGT'i => {
                     token = JGT
                     fbreak;
                 };
                 'JULE'i => {
                     token = JULE
                     fbreak;
                 };
                 'JULT'i => {
                     token = JULT
                     fbreak;
                 };
                 'JUGE'i => {
                     token = JUGE
                     fbreak;
                 };
                 'JUGT'i => {
                     token = JUGT
                     fbreak;
                 };
                 'NOP'i => {
                     token = NOP
                     fbreak;
                 };
                 'MOV'i => {
                     token = MOV
                     fbreak;
                 };
                 'MOVH'i => {
                     token = MOVH
                     fbreak;
                 };
                 'MOVL'i => {
                     token = MOVL
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
        fmt.Println("Scan error at line", state.line, "near", string(state.data[state.p:last]))
    } 
}

func (state *ScannerState) Error(s string) {
    fmt.Printf("syntax error: %s\n", s)
}

func (state *ScannerState) AddConst(id string, num int64) {
    fmt.Println("const:", id, num)
    state.consts[id] = num
}

func (state *ScannerState) AddConstf(id string, num float64) {
    fmt.Println("fconst:", id, num)
    state.fconsts[id] = num
}
