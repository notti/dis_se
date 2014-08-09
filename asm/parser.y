%{

package parser

import "fmt"
import . "mp"

type constScanner interface {
    AddConst(id string, num int64)
    AddConstf(id string, num float64)
}

var mpFunction *MPFunction
var mpFunctions map[string]*MPFunction

%}

%union{
    Num int64
    Fnum float64
    Id string
    Type int
    Signed bool
    Fixed int
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
%type <Type> type
%type <Signed> signed
%type <Fixed> fixed


%left '+'  '-' '|' '^'
%left '*'  '/'  '%' '&' RSHIFT LSHIFT

%start statements

%%

statements  : /* empty */
            | statements statement
            ;

statement   : '\n'
            | const
            | define
            | asm
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

const       : CONST IDENTIFIER integer '\n'
            {
                {
                    lexer := Parserlex.(constScanner)
                    lexer.AddConst($2, $3)
                }
            }
            | CONST IDENTIFIER float '\n'
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
            | MEM
            {
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
                $$ = false
            }
            | UNSIGNED
            {
                $$ = false
            }
            | SIGNED
            {
                $$ = true
            }
            ;

fixed       : /* not fixed */
            {
                $$ = 0
            }
            | FIX
            {
                if $1 > 7 || $1 < 0 {
                    Parserlex.Error("fix must be 1-7")
                    return 1
                }
                fmt.Println($1)
                $$ = int($1)
            }
            ;

argument    : signed fixed type IDENTIFIER
            {
                if mpFunction.AddArgument($1, $2, $3, $4) == false {
                    Parserlex.Error("double argument " + $4)
                    return 1
                }
            }
            ;

arguments   : argument
            | arguments ',' argument
            ;

membase     : IDENTIFIER
            | MEM IDENTIFIER
            ;

memaddr     : IDENTIFIER
            | '^' IDENTIFIER
            ;

leftvar     : IDENTIFIER
            | membase '[' memaddr ']'
            ;

var         : IDENTIFIER
            {
                fmt.Println("id", $1)
            }
            | membase '[' IDENTIFIER ']'
            {
                fmt.Println("mem",$3)
            }
            ;


rightvar    : signed fixed var
            | LITERAL       // check for 0 1
            {
                fmt.Println("lit", $1)
            }
            ;

eqn         : rightvar
            | '(' eqn ')'
            | eqn '+' eqn
            {
                fmt.Println(" +")
            }
            | eqn '-' eqn
            {
                fmt.Println(" -")
            }
            | eqn '*' eqn
            {
                fmt.Println(" *")
            }
            | eqn RSHIFT eqn
            {
                fmt.Println(" >>")
            }
            ;

bodyline    : leftvar '=' eqn '\n'
            ;

body        : bodyline
            | body bodyline
            ;

define      : DEFINE IDENTIFIER MEM LITERAL '\n'
            {
                 fmt.Println("def", $2, $4)
            }
            | DEFINE IDENTIFIER '('
                {
                    if _, ok := mpFunctions[$2]; ok {
                        Parserlex.Error("function named " + $2 + " already defined")
                        return 1
                    }
                    mpFunction = NewMPFunction()
                } arguments ')' '{' '\n' body '}' '\n'
            {
                 fmt.Println("def fun", $2, mpFunction.Args)
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

asm         : label '\n'
            | label asmstmnt '\n'
            | asmstmnt '\n'
            ;

%%


