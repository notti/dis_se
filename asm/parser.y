%{

package parser

import . "mp"

type constScanner interface {
    AddConst(id string, num int64)
    AddConstf(id string, num float64)
}

var mems map[string]int
var membase int
var mpFunction MPFunction
var mpFunctions map[string][]Argument

func ParserInit() {
    mems = make(map[string]int)
    mpFunctions = make(map[string][]Argument)
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

%}

%union{
    Num int64
    Fnum float64
    Id string
    Ival int
    Bval bool
    Var variable
}

%token <Num> LITERAL FIX REGISTER
%token <Fnum> FLOAT
%token <Id> IDENTIFIER

%token CONST DEFINE MEM REG LAST IMM UNSIGNED SIGNED RSHIFT LSHIFT

%token OP
%token OP1
%token OP2
%token OP3

%type <Num> integer florint
%type <Fnum> float florintF
%type <Ival> type fixed membase memrev signed
%type <Var> var rightvar eqn


%left '+'  '-' '|' '^'
%left '*'  '/'  '%' '&' RSHIFT LSHIFT

%start statements

%%

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
                if mpFunction.AddArgument(signed, $2, $4, membase, $5) == false {
                    Parserlex.Error("double argument " + $5)
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
            | DEFINE IDENTIFIER '('
                {
                    if _, ok := mpFunctions[$2]; ok {
                        Parserlex.Error("function named " + $2 + " already defined")
                        return 1
                    }
                    mpFunction = NewMPFunction()
                } arguments ')' '{' '\n' body '}'
            {
                stripped, err := mpFunction.Emit()
                if err != nil {
                    Parserlex.Error("function " + $2 + ": " + err.Error())
                    return 1
                }
                mpFunctions[$2] = stripped
            }
            ;

label       : IDENTIFIER ':'
            ;

asmarg      : IDENTIFIER
            | florint
            | REGISTER
            | IDENTIFIER '[' REGISTER ']'
            | LITERAL '[' REGISTER ']'
            | MEM LITERAL '[' REGISTER ']'
            ;

op          : OP
            ;

op1         : OP1 asmarg
            ;

op2         : OP2 asmarg ',' asmarg
            ;

op3         : OP3 asmarg ',' asmarg ',' asmarg
            ;

mparglist   : asmarg 
            | mparglist ',' asmarg
            ;

mpargs      :
            | mparglist
            ;

mp          : IDENTIFIER mpargs
            ;

asmstmnt    : op
            | op1
            | op2
            | op3
            | mp
            ;

asm         : label
            | label asmstmnt
            | asmstmnt
            ;

%%


