%define parse.error verbose
%define parse.trace
%{
    int yylex();
    //#include "tokens-manual.h"
    #include <stdio.h>
    #include <math.h>
    #include <ctype.h>
    #include <string.h>
    #define INTLONG 500
    #define LLU 501
    #define newline 600
    #define PUNCTUATION 601
    
    const char *stringFromType(int type ){
        static const char *strings[] = { "integer",  "long", "longlong","double","float","charliteral" };
        if(type <2){
            return strings[0];
        }
        else if (type<4){
            return strings[1];
        }
        else if (type < 6){
            return strings[2];
        }
        else if (type <8){
            return strings[3];
        }
        else if (type <9){
            return strings[4];
        }
        else{
            return strings[5];
        }

        
    }
    void yyerror(const char *str)
    {
        fprintf(stderr,"error: %s\n",str);
    }
    
    
%}
//0 is binop, 1 is num, 2 is ident, 3 is string, 4 is ternary, 5 is logop
%code requires {
    struct astnode_ternop{
        struct astnode *opIf;
        struct astnode *opThen;
        struct astnode *opElse;
    };
    struct astnode_binop{
        int nodetype;
        int operator;
        struct astnode *left;
        struct astnode *right;
    };
    struct astnode_logop{
        int operator;
        struct astnode *left;
        struct astnode *right;
    };
    struct astnode_num{
        int numtype;
        long long int number;
    };
    struct astnode_ident{
        int nodetype;
        char* ident;
    };
    struct astnode_string{
        char* string;
    };
    
    struct astnode{
        int nodetype;
        union {
            struct astnode_binop binop;
            struct astnode_num num;
            struct astnode_ident ident;
            struct astnode_string string;
            struct astnode_ternop ternop;
            struct astnode_logop logop;
        };

    };
    struct number{
        unsigned long long integer;
        enum types {
                SIGNED_INT,
                UNSIGNED_INT,
                SIGNED_LONG,
                UNSIGNED_LONG,
                UNSIGNED_LONGLONG,
                SIGNED_LONGLONG,
                TYPE_DOUBLE,
                LONG_DOUBLE,
                TYPE_FLOAT,
                TYPE_CHAR
                

        }type;    
        
        union {
                int charVal;
                long int intVal;
                long double realVal;
        }value;




    };
}
%union{
    struct number number;
    char *string;
    struct astnode *astnode_p;
}
%token <number> NUMBER
%token <number> CHARLIT
%token  INDSEL PLUSPLUS MINUSMINUS SHL SHR LTEQ GTEQ EQEQ NOTEQ LOGAND LOGOR ELLIPSIS TIMESEQ DIVEQ MODEQ PLUSEQ MINUSEQ SHLEQ SHREQ
%token  ANDEQ OREQ XOREQ AUTO BREAK CASE CHAR CONST CONTINUE DEFAULT DO DOUBLE ELSE ENUM EXTERN FLOAT FOR GOTO IF INLINE INT LONG REGISTER
%token  RESTRICT RETURN SHORT SIGNED SIZEOF STATIC STRUCT SWITCH TYPEDEF UNION UNSIGNED VOID VOLATILE WHILE _BOOL _COMPLEX _IMAGINARY NAME
%token <string> IDENT 
%token <string> newString;
%left '+' '-' 
%left '*' '/' '%'
%type <astnode_p> expr primexp postexp castexp unexp multexp addexp shiftexp relexp eqexp andexp exorexp inorexp logandexp logorexp condexp assexp constexp 
%%
expr: assexp 
    | expr ',' assexp {  struct astnode *n = malloc(1024);
                                
                        setupBinop(n,',',$1,$3);
                                
                        $$= n;

                    }
    | expr ';'  {printAST($1,0);}
;


primexp: IDENT { struct astnode *n = malloc(1024);
                 setupIdent(n,$1);
                 $$ = n;

                }    
    | NUMBER   {struct astnode *n = malloc(1024);
                         setupNumber(n,$1);
                $$ = n;
                }
    | CHARLIT   {struct astnode *n = malloc(1024);
                         setupNumber(n,$1);
                $$ = n;
                }
    | newString { struct astnode *n = malloc(1024);
                 setupString(n,$1);
                 $$ = n;
                 }  
    | '(' expr ')' {$$ = $2;}
                 
;
postexp:  primexp
    | postexp '[' expr ']' {  struct astnode *n = malloc(1024);
                                //Need to add in a dereference AST node above the binop.
                                setupBinop(n,'+',$1,$3);
                                //printAST(n,0);
                                $$= n;

                            }
    | postexp '.' IDENT 
    | postexp INDSEL IDENT
    | postexp MINUSMINUS



;
castexp: unexp  
    | '('typename')' castexp
;
typename: CHAR
    | INT
    | LONG
    | DOUBLE
    | FLOAT


;
unaryop: '&'
    | '*'
    | '+'
    | '-'
    | '~'
    | '!'

;
unexp: postexp
    | PLUSPLUS unexp
    | MINUSMINUS unexp
    | unaryop castexp
    | SIZEOF unexp
    | SIZEOF '('typename')'
;
multexp:castexp
    | multexp '*' castexp   {  struct astnode *n = malloc(1024);
                                
                                setupBinop(n,'*',$1,$3);
                                
                                $$= n;

                            }
    | multexp '/' castexp   {  struct astnode *n = malloc(1024);
                                
                                setupBinop(n,'/',$1,$3);
                                
                                $$= n;

                            }
    | multexp '%' castexp   {  struct astnode *n = malloc(1024);
                                
                                setupBinop(n,'%',$1,$3);
                                
                                $$= n;

                            }
;
addexp: multexp
    | addexp '+' multexp    {  struct astnode *n = malloc(1024);
                                
                                setupBinop(n,'+',$1,$3);
                                //printAST(n,0);
                                $$= n;

                            }
    | addexp '-' multexp    {  struct astnode *n = malloc(1024);
                                
                                setupBinop(n,'-',$1,$3);
                                //printAST(n,0);
                                $$= n;

                            }
;
shiftexp: addexp
    | shiftexp  SHL addexp {  struct astnode *n = malloc(1024);
                                
                                setupBinop(n,SHL,$1,$3);
                                
                                $$= n;

                            }
    | shiftexp SHR addexp   {  struct astnode *n = malloc(1024);
                                
                                setupBinop(n,SHR,$1,$3);
                                
                                $$= n;

                            }
;
relexp: shiftexp
    | relexp '<' shiftexp 
    | relexp '>' shiftexp
    | relexp LTEQ shiftexp
    | relexp GTEQ shiftexp
;
eqexp: relexp 
    | eqexp EQEQ relexp
    | eqexp NOTEQ relexp
;
andexp:eqexp
    | andexp '&' eqexp  {  struct astnode *n = malloc(1024);
                                
                                setupBinop(n,'&',$1,$3);
                                
                                $$= n;

                            }
;
exorexp: andexp
    | exorexp '^' andexp    {  struct astnode *n = malloc(1024);
                                
                                setupBinop(n,'^',$1,$3);
                                
                                $$= n;

                            }
;
inorexp:exorexp
    | inorexp '|' exorexp   {  struct astnode *n = malloc(1024);
                                
                                setupBinop(n,'|',$1,$3);
                                
                                $$= n;

                            }
;
logandexp: inorexp
    | logandexp LOGAND inorexp  {  struct astnode *n = malloc(1024);
                                
                                setupLogop(n,LOGAND,$1,$3);
                                
                                $$= n;

                            }
;
logorexp: logandexp
    | logorexp LOGOR logandexp
;
condexp: logorexp
    | logorexp '?' expr ':' condexp {  struct astnode *n = malloc(1024);
                                        
                                        setupTernary(n,$1,$3,$5);
                                        
                                        $$= n;

                                    }
;
assexp: condexp 
    | unexp assop assexp
;
assop: '='
    | TIMESEQ
    | DIVEQ
    | MODEQ
    | MINUSEQ
    | SHLEQ
    | SHREQ
    | ANDEQ
    | XOREQ
    | OREQ

;
constexp: condexp
;
%%
void printAST(struct astnode* n, int indent){
        for (int i = 0; i<indent; i++){
            printf("\t");
        }
        switch(n->nodetype){
            case 0:  
                if(n->binop.operator > 255){
                    char temp[3];
                    switch(n->binop.operator){
                        case SHL : strcpy(temp, "<<");break;
                        case SHR: strcpy(temp, ">>");break;
                    }
                    printf("BINARY OP %s\n", temp);
                }
                else{
                    printf("BINARY OP %c\n", n->binop.operator);
                }
                
                printAST(n->binop.left, indent+1);
                printAST(n->binop.right, indent+1);
                break;
            case 1:
                printf("CONSTANT: (type = %s)%lld\n",stringFromType(n->num.numtype),n->num.number); break;
            case 2:
                printf("IDENT %s\n", n->ident.ident);
            case 3: 
                printf("STRING %s\n", n->string.string);
            case 4:
                printf("TERNARY OP, IF\n");
                printAST(n->ternop.opIf,indent+1);
                printf("THEN\n");
                printAST(n->ternop.opThen,indent+1);
                printf("ELSE\n");
                printAST(n->ternop.opElse,indent+1);
            case 5:
                char temp[3];
                switch(n->logop.operator){
                    case LOGAND: strcpy(temp, "&&"); break;
                    case LOGOR: strcpy(temp, "||"); break;
                }
                printf("LOGICAL OP %s\n", temp);
                printAST(n->logop.left, indent+1);
                printAST(n->logop.right, indent+1);
        }
}

void setupBinop(struct astnode *n, int operator,struct astnode* left, struct astnode* right){
        
        n->nodetype = 0;
        n->binop.operator = operator;
        n->binop.left = left;
        n->binop.right = right;
        
}
void setupLogop(struct astnode *n, int operator,struct astnode* left, struct astnode* right){
        
        n->nodetype = 5;
        n->binop.operator = operator;
        n->binop.left = left;
        n->binop.right = right;
        
}
void setupNumber(struct astnode *n,struct number number){
        
        n->nodetype = 1;
        n->num.numtype = number.type;
        if(number.type<6){
            n->num.number = number.value.intVal;
        }
        else if (number.type<9 ){
            n->num.number = number.value.realVal;
        }
        else{
            n->num.number = number.value.charVal;
        }
        
       
}
void setupIdent(struct astnode *n, char *string){
    n->nodetype = 2;
    n->ident.ident = strdup(string);
}
void setupString(struct astnode *n, char *string){
    n->nodetype = 3;
    n->string.string = strdup(string);
}
void setupTernary(struct astnode *n, struct astnode *opIf,struct astnode *opThen, struct astnode *opElse ){
    n->nodetype = 4;
    n->ternop.opIf  = opIf;
    n->ternop.opThen = opThen;
    n->ternop.opElse  = opElse;

}

int main(){
    int t;
       while(!(t = yyparse())){

       };



}