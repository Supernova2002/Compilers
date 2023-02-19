#ifndef LEXER_H
#define LEXER_H


struct number{
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
struct number number;

typedef union{
        char *string;
        struct number number; 
        
} YYSTYPE;
extern YYSTYPE yylval;
#endif