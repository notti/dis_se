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

%token CONST DEFINE MEM REG LAST UNSIGNED SIGNED RSHIFT LSHIFT

%token ADD
%token ADDC
%token SUB
%token SUBB
%token AND
%token OR
%token XOR
%token NOT
%token NEG
%token CMP
%token SHL
%token SHR
%token SAR
%token ROLC
%token RORC
%token JMP
%token JZ
%token JNZ
%token JLE
%token JLT
%token JGE
%token JGT
%token JULE
%token JULT
%token JUGE
%token JUGT
%token NOP
%token MOV
%token MOVH
%token MOVL

%type <Num> integer
%type <Fnum> float


%left '+'  '-' '|' '^'
%left '*'  '/'  '%' '&' RSHIFT LSHIFT
%right UMINUS

%start statements

%%

statements : /* empty */
           | statements statement
           ;

statement  : '\n'
           | const
           | define
           ;

float      : FLOAT 
           | '-' float %prec UMINUS
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
           | '-' integer %prec UMINUS
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

define     : DEFINE IDENTIFIER MEM LITERAL '\n'
           {
                fmt.Println($2, $4)
           }

%%


