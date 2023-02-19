%define parse.error verbose
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
    void yyerror(const char *str)
    {
        fprintf(stderr,"error: %s\n",str);
    }
%}
%code requires {
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
                TYPE_FLOAT,
                LONG_DOUBLE

        };      
        enum types type;
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
}
%token <number> NUMBER
%token <number> CHARLIT
%token  INDSEL PLUSPLUS MINUSMINUS SHL SHR LTEQ GTEQ EQEQ NOTEQ LOGAND LOGOR,
        ELLIPSIS,
        TIMESEQ,
        DIVEQ,
        MODEQ,
        PLUSEQ,
        MINUSEQ,
        SHLEQ,
        SHREQ,
        ANDEQ,
        OREQ,
        XOREQ,
        AUTO,
        BREAK,
        CASE,
        CHAR,
        CONST,
        CONTINUE,
        DEFAULT,
        DO,
        DOUBLE,
        ELSE,
        ENUM,
        EXTERN,
        FLOAT,
        FOR,
        GOTO,
        IF,
        INLINE,
        INT,
        LONG,
        REGISTER,
        RESTRICT,
        RETURN,
        SHORT,
        SIGNED,
        SIZEOF,
        STATIC,
        STRUCT,
        SWITCH,
        TYPEDEF,
        UNION,
        UNSIGNED,
        VOID,
        VOLATILE,
        WHILE,
        _BOOL,
        _COMPLEX,
        _IMAGINARY,
        NAME
%token <string> IDENT 
%token <string> newString;
%left '+' '-' 
%left '*' '/'

%%
expr: _IMAGINARY {printf("IMAGINARY");}
    | NUMBER    {printf("NUMBER is %i",$1.value );}
    | newString {printf("STRING is : %s\n",$1);}
    ;


%%

main(){
       yyparse();



}