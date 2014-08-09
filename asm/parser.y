%{

package parser

import "fmt"

type constScanner interface {
    AddConst(id string, num int64)
    AddConstf(id string, num float64)
}

%}

%union{
    Num int64
    Fnum float64
    Id string
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


%left '+'  '-' '|' '^'
%left '*'  '/'  '%' '&' RSHIFT LSHIFT

%start statements

%%

statements : /* empty */
           | statements statement
           ;

statement  : '\n'
           | const
           | define
           | asm
           ;

florint    : float
           {
                $$ = int64($1)
           }
           | integer
           ;

florintF   : float
           | integer
           {
                $$ = float64($1)
           }
           ;

float      : FLOAT 
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

integer    : '(' integer ')'
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

const      : CONST IDENTIFIER integer '\n'
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

type       : REG
           | MEM
           | IMM
           | LAST
           ;

signed     : /* no modifier */
           | UNSIGNED
           | SIGNED
           ;

fixed      : /* not fixed */
           | FIX
           ;

argument   : signed fixed type IDENTIFIER
           ;

arguments  : argument
           | arguments ',' argument
           ;

membase    : IDENTIFIER
           | MEM IDENTIFIER
           ;

memaddr    : IDENTIFIER
           | '^' IDENTIFIER
           ;

leftvar    : IDENTIFIER
           | membase '[' memaddr ']'
           ;

var        : IDENTIFIER
           | membase '[' IDENTIFIER ']'
           ;


rightvar   : signed fixed var
           | LITERAL       // check for 0 1
           ;

eqn        : rightvar
           | '(' eqn ')'
           | eqn '+' eqn
           | eqn '-' eqn
           | eqn '*' eqn
           | eqn RSHIFT eqn
           ;

bodyline   : leftvar '=' eqn '\n'
           ;

body       : bodyline
           | body bodyline
           ;

define     : DEFINE IDENTIFIER MEM LITERAL '\n'
           {
                fmt.Println("def", $2, $4)
           }
           | DEFINE IDENTIFIER '(' arguments ')' '{' '\n' body '}' '\n'
           {
                fmt.Println("def fun", $2)
           }
           ;

label      : IDENTIFIER ':'
           ;

asmarg     : IDENTIFIER
           | florint
           | REGISTER
           | IDENTIFIER '[' REGISTER ']'
           | LITERAL '[' REGISTER ']'
           | MEM LITERAL '[' REGISTER ']'
           ;

op         : OP
           ;

op1        : OP1 asmarg
           ;

op2        : OP2 asmarg ',' asmarg
           ;

op3        : OP3 asmarg ',' asmarg ',' asmarg
           ;

mparglist  : asmarg 
           | mparglist ',' asmarg
           ;

mpargs     :
           | mparglist
           ;

mp         : IDENTIFIER mpargs
           ;

asmstmnt   : op
           | op1
           | op2
           | op3
           | mp
           ;

asm        : label '\n'
           | label asmstmnt '\n'
           | asmstmnt '\n'
           ;

%%


