%{

package parser

import . "mp"
import "strings"
import "math"
import "fmt"

type constScanner interface {
    AddConst(id string, num int64)
    AddConstf(id string, num float64)
}

var mems map[string]int
var membase int
var mpFunction MPFunction
var mpFunctions map[string][]Argument
var mpFunctionIds [8]string
var code []interface{}
var labels map[string]int

func ParserInit() {
    mems = make(map[string]int)
    mpFunctions = make(map[string][]Argument)
    code = make([]interface{}, 0, 4096)
    labels = make(map[string]int)
    labels["SERIAL"] = 0xFFFF
}

type variable struct {
    id int
    signed bool
    fix int
    typed bool
}

func mpMerge(a, b variable) (bool, int, bool, bool) {
    if a.typed && b.typed {
        if a.signed != b.signed || a.fix != b.fix {
            return false, 0, false, false
        }
        return a.signed, a.fix, true, true
    }
    if a.typed {
        return a.signed, a.fix, true, true
    }
    if b.typed {
        return b.signed, b.fix, true, true
    }
    return false, 0, false, true
}

type argtype int

const (
        ARG_REGISTER argtype = iota
        ARG_LABEL
        ARG_IMMEDIATE
)

type asmarg struct {
    reg int64
    id string
    num int64
    t argtype
}

%}

%union{
    Num int64
    Fnum float64
    Id string
    Ival int
    Bval bool
    Var variable
    Arg asmarg
    Args []asmarg
}

%token <Num> LITERAL FIX REGISTER REGISTERLH
%token <Fnum> FLOAT
%token <Id> IDENTIFIER

%token CONST DEFINE MEM REG LAST IMM UNSIGNED SIGNED RSHIFT LSHIFT DB DW INT

%token <Num> OP MOV OP1 OP2 OP3

%type <Num> integer florint register registerlh
%type <Fnum> float florintF
%type <Ival> type fixed membase memrev signed
%type <Var> var rightvar eqn
%type <Arg> asmarg mparg
%type <Args> mparglist mpargs


%left '+'  '-' '|' '^'
%left '*'  '/'  '%' '&' RSHIFT LSHIFT

%start program

%%

program     : statements
            {
                for i, cp := range code {
                    if label, ok := cp.(string); ok {
                        if c, ok := labels[label]; ok {
                            code[i] = uint16(c)
                        } else {
                            Parserlex.Error("label " + label + " not found")
                            return 1
                        }
                    }
                }
                fmt.Print("@0000")
                for _, cp := range code {
                    c := cp.(uint16)
                    fmt.Printf(" %04X", c)
                }
                fmt.Println()
            }
            ;

statements  : /* empty */
            | statements statement
            ;

statement   : '\n'
            | const '\n'
            | define '\n'
            | asm '\n'
            ;

florint     : float
            {
                $$ = int64($1)
            }
            | integer
            ;

florintF    : float
            | integer
            {
                $$ = float64($1)
            }
            ;

float       : FLOAT 
            | '-' float %prec '*' 
            {
                $$ = -$2
            }
            | float '+' float
            {
                $$ = $1 + $3
            }
            | float '+' integer 
            {
                $$ = $1 + float64($3)
            }
            | integer '+' float
            {
                $$ = float64($1) + $3
            }
            | float '-' float
            {
                $$ = $1 - $3
            }
            | float '-' integer 
            {
                $$ = $1 - float64($3)
            }
            | integer '-' float
            {
                $$ = float64($1) - $3
            }
            | float '*' float
            {
                $$ = $1 * $3
            }
            | float '*' integer 
            {
                $$ = $1 * float64($3)
            }
            | integer '*' float
            {
                $$ = float64($1) * $3
            }
            | float '/' float
            {
                $$ = $1 / $3
            }
            | float '/' integer 
            {
                $$ = $1 / float64($3)
            }
            | integer '/' float
            {
                $$ = float64($1) / $3
            }
            | IDENTIFIER '(' florintF ')'
            {
                switch(strings.ToLower($1)) {
                    case "sin": $$ = math.Sin($3)
                    case "cos": $$ = math.Cos($3)
                    case "tan": $$ = math.Tan($3)
                    case "sinh": $$ = math.Sinh($3)
                    case "cosh": $$ = math.Cosh($3)
                    case "tanh": $$ = math.Tanh($3)
                    case "asin": $$ = math.Asin($3)
                    case "acos": $$ = math.Acos($3)
                    case "atan": $$ = math.Atan($3)
                    case "asinh": $$ = math.Asinh($3)
                    case "acosh": $$ = math.Acosh($3)
                    case "atanh": $$ = math.Atanh($3)
                    case "log": $$ = math.Log($3)
                    case "log10": $$ = math.Log10($3)
                    case "log2": $$ = math.Log2($3)
                    case "sqrt": $$ = math.Sqrt($3)
                    case "floor": $$ = math.Floor($3)
                    case "ceil": $$ = math.Ceil($3)
                    case "abs": $$ = math.Abs($3)
                    case "exp": $$ = math.Abs($3)
                    default:
                        Parserlex.Error("function " + $1 + " not defined or wrong argument count")
                        return 1
                }
            }
            | IDENTIFIER '(' florintF ',' florintF ')'
            {
                switch(strings.ToLower($1)) {
                    case "pow": $$ = math.Pow($3, $5)
                    case "atan2": $$ = math.Atan2($3, $5)
                    default:
                        Parserlex.Error("function " + $1 + " not defined or wrong argument count")
                        return 1
                }
            }
            ;

integer     : '(' integer ')'
            {
                $$ = $2
            }
            | integer '+' integer
            {
                $$ = $1 + $3
            }
            | integer '-' integer
            {
                $$ = $1 - $3
            }
            | integer '*' integer
            {
                $$ = $1 * $3
            }
            | integer '/' integer
            {
                $$ = $1 / $3
            }
            | integer '%' integer
            {
                $$ = $1 % $3
            }
            | integer '&' integer
            {
                $$ = $1 & $3
            }
            | integer '|' integer
            {
                $$ = $1 | $3
            }
            | integer '^' integer
            {
                $$ = $1 ^ $3
            }
            | integer LSHIFT integer
            {
                $$ = $1 << uint64($3)
            }
            | integer RSHIFT integer
            {
                $$ = $1 >> uint64($3)
            }
            | '-' integer %prec '*'
            {
                $$ = -$2
            }
            | LITERAL
            | INT '(' florint ')'
            {
                $$ = $3
            }
            ;

const       : CONST IDENTIFIER integer
            {
                {
                    lexer := Parserlex.(constScanner)
                    lexer.AddConst($2, $3)
                }
            }
            | CONST IDENTIFIER float
            {
                {
                    lexer := Parserlex.(constScanner)
                    lexer.AddConstf($2, $3)
                }
            }
            ;

type        : REG
            {
                $$ = ARG_REG
            }
            | IDENTIFIER
            {
                v, ok := mems[$1]
                if !ok {
                    Parserlex.Error("mem " + $1 + " not defined")
                    return 1
                }
                membase = v
                $$ = ARG_MEM
            }
            | MEM LITERAL
            {
                if $2 < 0 || $2 > 3 {
                    Parserlex.Error("mem must be in range 0-3")
                    return 1
                }
                membase = int($2)
                $$ = ARG_MEM
            }
            | IMM
            {
                $$ = ARG_IMM
            }
            | LAST
            {
                $$ = ARG_NONE
            }
            ;

signed      : /* no modifier */
            {
                $$ = -1
            }
            | UNSIGNED
            {
                $$ = 0
            }
            | SIGNED
            {
                $$ = 1
            }
            ;

fixed       : /* not fixed */
            {
                $$ = -1
            }
            | FIX
            {
                if $1 > 7 || $1 < 0 {
                    Parserlex.Error("fix must be 1-7")
                    return 1
                }
                $$ = int($1)
            }
            ;

argument    : signed fixed { membase = 0 } type IDENTIFIER
            {
                signed := false
                if $1 == 1 {
                    signed = true
                }
                if $2 == -1 {
                    $2 = 0
                }
                if err := mpFunction.AddArgument(signed, $2, $4, membase, $5); err != nil {
                    Parserlex.Error(err.Error())
                    return 1
                }
            }
            ;

arguments   : argument
            | arguments ',' argument
            ;

membase     : IDENTIFIER
            {
                v, ok := mems[$1]
                if !ok {
                    Parserlex.Error("mem " + $1 + " not defined")
                    return 1
                }
                $$ = v
            }
            | MEM LITERAL
            {
                if $2 < 0 || $2 > 3 {
                    Parserlex.Error("mem must be in range 0-3")
                    return 1
                }
                $$ = int($2)
            }
            ;

memrev      :
            {
                $$ = 0
            }
            | '^' LITERAL
            {
                if $2 < 2 || $2 > 8 {
                    Parserlex.Error("reverse addressing must be in range 2-8")
                    return 1
                }
                $$ = int($2) - 1
            }
            ;

var         : IDENTIFIER
            {
                id, signed, fix, ok := mpFunction.GetNamedRegister($1)
                if ok == false {
                    Parserlex.Error("variable " + $1 + " unknown")
                    return 1
                }
                $$.id = id
                $$.signed = signed
                $$.fix = fix
                $$.typed = true

            }
            | membase '[' IDENTIFIER ']'
            {
                id, ok := mpFunction.AddRMemory($1, $3)
                if ok == false {
                    Parserlex.Error("variable " + $3 + " unknown")
                    return 1
                }
                $$.id = id
                $$.signed = false
                $$.fix = 0
                $$.typed = false
            }
            ;


rightvar    : signed fixed var
            {
                $$ = $3
                switch $1 {
                case 0:
                    $$.signed = false
                    $$.typed = true
                case 1:
                    $$.signed = true
                    $$.typed = true
                }
                if $2 != -1 {
                    $$.fix = $2
                    $$.typed = true
                }
            }
            | LITERAL
            {
                switch $1 {
                case 0:
                    $$.id = ALUIN_0
                case 1:
                    $$.id = ALUIN_1
                default:
                    Parserlex.Error("only 0 or 1 allowed as literal")
                    return 1
                }
                $$.signed = false
                $$.fix = 0
                $$.typed = false
            }
            ;

eqn         : rightvar
            | '(' eqn ')'
            {
                $$ = $2
            }
            | eqn '+' eqn
            {
                signed, fix, typed, ok := mpMerge($1, $3)
                if ok == false {
                    Parserlex.Error("variable types don't match!")
                    return 1
                }
                $$.signed = signed
                $$.fix = fix
                $$.typed = typed
                $$.id = mpFunction.AddRegister(signed, fix)
                mpFunction.AddTerm($1.id, $3.id, ALU_ADD, signed, fix, $$.id)
            }
            | eqn '-' eqn
            {
                signed, fix, typed, ok := mpMerge($1, $3)
                if ok == false {
                    Parserlex.Error("variable types don't match!")
                    return 1
                }
                $$.signed = signed
                $$.fix = fix
                $$.typed = typed
                $$.id = mpFunction.AddRegister(signed, fix)
                mpFunction.AddTerm($1.id, $3.id, ALU_SUB, signed, fix, $$.id)
            }
            | eqn '*' eqn
            {
                signed, fix, typed, ok := mpMerge($1, $3)
                if ok == false {
                    Parserlex.Error("variable types don't match!")
                    return 1
                }
                $$.signed = signed
                $$.fix = fix
                $$.typed = typed
                $$.id = mpFunction.AddRegister(signed, fix)
                mpFunction.AddTerm($1.id, $3.id, ALU_MUL, signed, fix, $$.id)
            }
            | eqn RSHIFT eqn
            {
                signed, fix, typed, ok := mpMerge($1, $3)
                if ok == false {
                    Parserlex.Error("variable types don't match!")
                    return 1
                }
                $$.signed = signed
                $$.fix = fix
                $$.typed = typed
                $$.id = mpFunction.AddRegister(signed, fix)
                mpFunction.AddTerm($1.id, $3.id, ALU_RSHIFT, signed, fix, $$.id)
            }
            | eqn '|' eqn
            {
                signed, fix, typed, ok := mpMerge($1, $3)
                if ok == false {
                    Parserlex.Error("variable types don't match!")
                    return 1
                }
                $$.signed = signed
                $$.fix = fix
                $$.typed = typed
                $$.id = mpFunction.AddRegister(signed, fix)
                mpFunction.AddTerm($1.id, $3.id, ALU_OR, signed, fix, $$.id)
            }
            | eqn '^' eqn
            {
                signed, fix, typed, ok := mpMerge($1, $3)
                if ok == false {
                    Parserlex.Error("variable types don't match!")
                    return 1
                }
                $$.signed = signed
                $$.fix = fix
                $$.typed = typed
                $$.id = mpFunction.AddRegister(signed, fix)
                mpFunction.AddTerm($1.id, $3.id, ALU_XOR, signed, fix, $$.id)
            }
            | eqn '&' eqn
            {
                signed, fix, typed, ok := mpMerge($1, $3)
                if ok == false {
                    Parserlex.Error("variable types don't match!")
                    return 1
                }
                $$.signed = signed
                $$.fix = fix
                $$.typed = typed
                $$.id = mpFunction.AddRegister(signed, fix)
                mpFunction.AddTerm($1.id, $3.id, ALU_AND, signed, fix, $$.id)
            }
            ;

bodyline    :
            | IDENTIFIER '=' eqn
            {
                mpFunction.AddNamedRegister($1, $3.id)
            }
            | membase '[' memrev IDENTIFIER ']' '=' eqn
            {
                ok1, ok2 := mpFunction.AddWMemory($1, $3, $4, $7.id)
                if ok1 == false {
                    Parserlex.Error("variable " + $4 + " unknown")
                    return 1
                }
                if ok2 == false {
                    Parserlex.Error("can't assign memory location twize")
                    return 1
                }
            }
            ;

body        : bodyline '\n'
            | body bodyline '\n'
            ;

define      : DEFINE IDENTIFIER MEM LITERAL
            {
                if $4 < 0 || $4 > 3 {
                    Parserlex.Error("mem must be in range 0-3")
                    return 1
                }
                if _, ok := mems[$2]; ok {
                    Parserlex.Error("mem " + $2 + " already defined")
                    return 1
                }
                mems[$2] = int($4)
            }
            | DEFINE IDENTIFIER LITERAL '('
                {
                    if _, ok := mpFunctions[$2]; ok {
                        Parserlex.Error("function named " + $2 + " already defined")
                        return 1
                    }
                    if $3 > 7 || $3 < 0 {
                        Parserlex.Error("function slot needs to be in range from 0-7")
                        return 1
                    }
                    mpFunction = NewMPFunction()
                } arguments ')' '{' '\n' body '}'
            {
                fdef, stripped, err := mpFunction.Emit($2)
                if err != nil {
                    Parserlex.Error("function " + $2 + ": " + err.Error())
                    return 1
                }
                mpFunctions[$2] = stripped
                if mpFunctionIds[$3] != "" {
                    delete(mpFunctions, mpFunctionIds[$3])
                }
                mpFunctionIds[$3] = $2
                code = append(code, uint16(0x00C8 | uint16($3)))
                for _, f := range fdef {
                    code = append(code, f)
                }
            }
            ;

label       : IDENTIFIER ':'
            {
                if _, ok := labels[$1]; ok {
                    Parserlex.Error("label named " + $1 + " already defined")
                    return 1
                }
                labels[$1] = len(code)
            }
            ;

registerlh  : REGISTERLH
            {
                if ($1 & 0xF) > 13 || ($1 & 0xF) < 0 || ($1 >> 5) != 0 {
                    Parserlex.Error("register must be $0 - $13")
                    return 1
                }
                $$ = $1
            }

register    : REGISTER
            {
                if $1 > 13 || $1 < 0 {
                    Parserlex.Error("register must be $0 - $13")
                    return 1
                }
                $$ = $1
            }

asmarg      : register
            {
                $$.t = ARG_REGISTER
                $$.reg = $1
            }
            | IDENTIFIER
            {
                $$.t = ARG_LABEL
                $$.id = $1
            }
            | florint
            {
                $$.t = ARG_IMMEDIATE
                $$.num = $1
            }
            ;

op          : OP
            {
                code = append(code, uint16($1))
            }
            ;

op1         : OP1 asmarg 
            {
                switch $2.t {
                    case ARG_REGISTER:
                        code = append(code, uint16($1 | $2.reg))
                    case ARG_IMMEDIATE:
                        if $2.num == 0 {
                            code = append(code, uint16($1 | 0xE))
                        } else {
                            code = append(code, uint16($1 | 0xF))
                            code = append(code, uint16($2.num))
                        }
                    case ARG_LABEL:
                        code = append(code, uint16($1 | 0xF))
                        code = append(code, $2.id)
                }
            }
            ;

op2         : OP2 asmarg ',' asmarg
            {
                app := make([]interface{}, 0, 2) 
                switch $2.t {
                    case ARG_REGISTER:
                        $1 |= $2.reg << 4
                    case ARG_IMMEDIATE:
                        if $2.num == 0 {
                            $1 |= 0xE << 4
                        } else {
                            $1 |= 0xF << 4
                            app = append(app, uint16($2.num))
                        }
                    case ARG_LABEL:
                        $1 |= 0xF << 4
                        app = append(app, $2.id)
                }
                switch $4.t {
                    case ARG_REGISTER:
                        $1 |= $4.reg
                    case ARG_IMMEDIATE:
                        if $4.num == 0 {
                            $1 |= 0xE
                        } else {
                            $1 |= 0xF
                            app = append(app, uint16($4.num))
                        }
                    case ARG_LABEL:
                        $1 |= 0xF
                        app = append(app, $4.id)
                }
                code = append(code, uint16($1))
                code = append(code, app...)
            }
            ;

mov         : MOV register ',' asmarg
            {
                app := make([]interface{}, 0, 2) 
                $1 |= $2 << 4
                switch $4.t {
                    case ARG_REGISTER:
                        $1 |= $4.reg
                    case ARG_IMMEDIATE:
                        if $4.num == 0 {
                            $1 |= 0xE
                        } else {
                            $1 |= 0xF
                            app = append(app, uint16($4.num))
                        }
                    case ARG_LABEL:
                        $1 |= 0xF
                        app = append(app, $4.id)
                }
                code = append(code, uint16($1))
                code = append(code, app...)
            }
            | MOV IDENTIFIER '[' asmarg ']' ',' register
            {
                $1 |= $7 | 0x0400
                switch $4.t {
                    case ARG_REGISTER:
                        code = append(code, uint16($1 | ($4.reg << 4)))
                    case ARG_IMMEDIATE:
                        if $4.num == 0 {
                            code = append(code, uint16($1 | (0xE << 4)))
                        } else {
                            code = append(code, uint16($1 | (0xF << 4)))
                            code = append(code, uint16($4.num))
                        }
                    case ARG_LABEL:
                        code = append(code, uint16($1 | (0xF << 4)))
                        code = append(code, $4.id)
                }
                code = append(code, $2)
            }
            | MOV LITERAL '[' asmarg ']' ',' register
            {
                $1 |= $7 | 0x0400
                switch $4.t {
                    case ARG_REGISTER:
                        code = append(code, uint16($1 | ($4.reg << 4)))
                    case ARG_IMMEDIATE:
                        if $4.num == 0 {
                            code = append(code, uint16($1 | (0xE << 4)))
                        } else {
                            code = append(code, uint16($1 | (0xF << 4)))
                            code = append(code, uint16($4.num))
                        }
                    case ARG_LABEL:
                        code = append(code, uint16($1 | (0xF << 4)))
                        code = append(code, $4.id)
                }
                code = append(code, uint16($2))
            }
            | MOV register ',' IDENTIFIER '[' asmarg ']' 
            {
                $1 |= ($2 << 4)
                mem, ok := mems[$4]
                if ok {
                    $1 |= 0x0C00
                } else {
                    $1 |= 0x0800
                }
                switch $6.t {
                    case ARG_REGISTER:
                        code = append(code, uint16($1 | $6.reg))
                    case ARG_IMMEDIATE:
                        if $6.num == 0 {
                            code = append(code, uint16($1 | 0xE))
                        } else {
                            code = append(code, uint16($1 | 0xF))
                            code = append(code, uint16($6.num))
                        }
                    case ARG_LABEL:
                        code = append(code, uint16($1 | 0xF))
                        code = append(code, $6.id)
                }
                if ok {
                    code = append(code, uint16(mem))
                } else {
                    code = append(code, $4)
                }
            }
            | MOV register ',' LITERAL '[' asmarg ']' 
            {
                $1 |= ($2 << 4) | 0x0800
                switch $6.t {
                    case ARG_REGISTER:
                        code = append(code, uint16($1 | $6.reg))
                    case ARG_IMMEDIATE:
                        if $6.num == 0 {
                            code = append(code, uint16($1 | 0xE))
                        } else {
                            code = append(code, uint16($1 | 0xF))
                            code = append(code, uint16($6.num))
                        }
                    case ARG_LABEL:
                        code = append(code, uint16($1 | 0xF))
                        code = append(code, $6.id)
                }
                code = append(code, $4)
            }
            | MOV register ',' MEM LITERAL '[' asmarg ']' 
            {
                if $5 < 0 || $5 > 0 {
                    Parserlex.Error("mem must be in range 0-3")
                    return 1
                }
                $1 |= ($2 << 4) | 0x0C00
                switch $7.t {
                    case ARG_REGISTER:
                        code = append(code, uint16($1 | $7.reg))
                    case ARG_IMMEDIATE:
                        if $7.num == 0 {
                            code = append(code, uint16($1 | 0xE))
                        } else {
                            code = append(code, uint16($1 | 0xF))
                            code = append(code, uint16($7.num))
                        }
                    case ARG_LABEL:
                        code = append(code, uint16($1 | 0xF))
                        code = append(code, $7.id)
                }
                code = append(code, uint16($5))
            }
            ;

op3         : OP3 register ',' asmarg ',' asmarg
            {
                app := make([]interface{}, 0, 2) 
                $1 |= $2 << 8
                switch $4.t {
                    case ARG_REGISTER:
                        $1 |= $4.reg << 4
                    case ARG_IMMEDIATE:
                        if (($1 & 0x8000) == 0x8000 && $4.num == 1) || (($1 & 0x8000) == 0x0000 && $4.num == 0) {
                            $1 |= 0xE << 4
                        } else {
                            $1 |= 0xF << 4
                            app = append(app, uint16($4.num))
                        }
                    case ARG_LABEL:
                        $1 |= 0xF << 4
                        app = append(app, $4.id)
                }
                switch $6.t {
                    case ARG_REGISTER:
                        $1 |= $6.reg
                    case ARG_IMMEDIATE:
                        if (($1 & 0x8000) == 0x8000 && $6.num == 1) || (($1 & 0x8000) == 0x0000 && $6.num == 0) {
                            $1 |= 0xE
                        } else {
                            $1 |= 0xF
                            app = append(app, uint16($6.num))
                        }
                    case ARG_LABEL:
                        $1 |= 0xF
                        app = append(app, $6.id)
                }
                code = append(code, uint16($1))
                code = append(code, app...)
            }
            ;

mparg       : registerlh
            {
                $$.t = ARG_REGISTER
                $$.reg = $1
            }
            | florint
            {
                $$.t = ARG_IMMEDIATE
                $$.num = $1
            }
            ;

mparglist   : mparg
            {
                $$ = make([]asmarg, 0, 6)
                $$ = append($$, $1)
            }
            | mparglist ',' mparg
            {
                $$ = append($1, $3)
            }
            ;

mpargs      :
            {
                $$ = nil
            }
            | mparglist
            ;

mp          : IDENTIFIER mpargs
            {
                args, ok := mpFunctions[$1]
                if ok == false {
                    Parserlex.Error("function named " + $1 + " does not exist!")
                    return 1
                }
                for id, val := range mpFunctionIds {
                    if val == $1 {
                        code = append(code, uint16(0x00C0 | id))
                        break
                    }
                }
                var tmp uint16 = 0;
                low := true
                none := false
                argloop: for i, arg := range args {
                    switch arg.Type {
                    case ARG_NONE:
                        if len($2) == i {
                            none = true
                            break argloop
                        } else {
                            Parserlex.Error("wrong argument count")
                            return 1
                        }
                    case ARG_REG:
                        if len($2) > i {
                            if $2[i].t == ARG_REGISTER {
                                if low {
                                    tmp = uint16($2[i].reg)
                                    low = false
                                } else {
                                    code = append(code, tmp | (uint16($2[i].reg) << 8))
                                    low = true
                                }
                            } else {
                                Parserlex.Error("wrong argument type")
                                return 1
                            }
                        } else {
                            Parserlex.Error("wrong argument count")
                            return 1
                        }
                    case ARG_MEM, ARG_IMM:
                        if len($2) > i {
                            if $2[i].t == ARG_IMMEDIATE {
                                if low {
                                    tmp = uint16($2[i].num) & 0x00FF
                                    low = false
                                } else {
                                    code = append(code, tmp | ((uint16($2[i].num) & 0x00FF) << 8))
                                    low = true
                                }
                            } else {
                                Parserlex.Error("wrong argument type")
                                return 1
                            }
                        } else {
                            Parserlex.Error("wrong argument count")
                            return 1
                        }
                    }
                }
                if none == false && len($2) != len(args) {
                    Parserlex.Error("wrong argument count")
                    return 1
                }
                if low == false {
                    code = append(code, tmp)
                }
            }
            ;

data        : DW integer
            {
                code = append(code, uint16($2))
            }
            ;

asmstmnt    : op
            | op1
            | op2
            | mov
            | op3
            | mp
            | data
            ;

asm         : label
            | label asmstmnt
            | asmstmnt
            ;

%%


