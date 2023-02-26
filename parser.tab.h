/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2021 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

#ifndef YY_YY_PARSER_TAB_H_INCLUDED
# define YY_YY_PARSER_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 1
#endif
#if YYDEBUG
extern int yydebug;
#endif
/* "%code requires" blocks.  */
#line 46 "parser.y"

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
    struct astnode_assop{
        int assType;
        struct astnode *left;
        struct astnode *right;
    };
    struct astnode_unop{
        int operator;
        struct astnode *operand;
       
    };
    struct astnode_compop{
        int operator;
        struct astnode *left;
        struct astnode *right;
    };
    struct astnode_general{
        int genType;
        struct astnode *next;
        // 0 is DEREF, 1 is ADDRESSOF
    };
    struct astnode_select{
        int indirectFlag;
        //0 if direct, 1 if indirect
        char* member;
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
            struct astnode_assop assop;
            struct astnode_unop unop;
            struct astnode_compop compop;
            struct astnode_general general;
            struct astnode_select select;
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

#line 148 "parser.tab.h"

/* Token kinds.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    YYEMPTY = -2,
    YYEOF = 0,                     /* "end of file"  */
    YYerror = 256,                 /* error  */
    YYUNDEF = 257,                 /* "invalid token"  */
    NUMBER = 258,                  /* NUMBER  */
    CHARLIT = 259,                 /* CHARLIT  */
    INDSEL = 260,                  /* INDSEL  */
    PLUSPLUS = 261,                /* PLUSPLUS  */
    MINUSMINUS = 262,              /* MINUSMINUS  */
    SHL = 263,                     /* SHL  */
    SHR = 264,                     /* SHR  */
    LTEQ = 265,                    /* LTEQ  */
    GTEQ = 266,                    /* GTEQ  */
    EQEQ = 267,                    /* EQEQ  */
    NOTEQ = 268,                   /* NOTEQ  */
    LOGAND = 269,                  /* LOGAND  */
    LOGOR = 270,                   /* LOGOR  */
    ELLIPSIS = 271,                /* ELLIPSIS  */
    DIVEQ = 272,                   /* DIVEQ  */
    MODEQ = 273,                   /* MODEQ  */
    PLUSEQ = 274,                  /* PLUSEQ  */
    MINUSEQ = 275,                 /* MINUSEQ  */
    SHLEQ = 276,                   /* SHLEQ  */
    SHREQ = 277,                   /* SHREQ  */
    ANDEQ = 278,                   /* ANDEQ  */
    OREQ = 279,                    /* OREQ  */
    XOREQ = 280,                   /* XOREQ  */
    AUTO = 281,                    /* AUTO  */
    BREAK = 282,                   /* BREAK  */
    CASE = 283,                    /* CASE  */
    CHAR = 284,                    /* CHAR  */
    CONST = 285,                   /* CONST  */
    CONTINUE = 286,                /* CONTINUE  */
    DEFAULT = 287,                 /* DEFAULT  */
    DO = 288,                      /* DO  */
    DOUBLE = 289,                  /* DOUBLE  */
    ELSE = 290,                    /* ELSE  */
    ENUM = 291,                    /* ENUM  */
    EXTERN = 292,                  /* EXTERN  */
    FLOAT = 293,                   /* FLOAT  */
    FOR = 294,                     /* FOR  */
    GOTO = 295,                    /* GOTO  */
    IF = 296,                      /* IF  */
    INLINE = 297,                  /* INLINE  */
    INT = 298,                     /* INT  */
    LONG = 299,                    /* LONG  */
    REGISTER = 300,                /* REGISTER  */
    RESTRICT = 301,                /* RESTRICT  */
    RETURN = 302,                  /* RETURN  */
    SHORT = 303,                   /* SHORT  */
    SIGNED = 304,                  /* SIGNED  */
    SIZEOF = 305,                  /* SIZEOF  */
    STATIC = 306,                  /* STATIC  */
    STRUCT = 307,                  /* STRUCT  */
    SWITCH = 308,                  /* SWITCH  */
    TYPEDEF = 309,                 /* TYPEDEF  */
    UNION = 310,                   /* UNION  */
    UNSIGNED = 311,                /* UNSIGNED  */
    VOID = 312,                    /* VOID  */
    VOLATILE = 313,                /* VOLATILE  */
    WHILE = 314,                   /* WHILE  */
    _BOOL = 315,                   /* _BOOL  */
    _COMPLEX = 316,                /* _COMPLEX  */
    _IMAGINARY = 317,              /* _IMAGINARY  */
    NAME = 318,                    /* NAME  */
    TIMESEQ = 319,                 /* TIMESEQ  */
    IDENT = 320,                   /* IDENT  */
    newString = 321                /* newString  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 144 "parser.y"

    struct number number;
    char *string;
    struct astnode *astnode_p;
    int operator;

#line 238 "parser.tab.h"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;


int yyparse (void);


#endif /* !YY_YY_PARSER_TAB_H_INCLUDED  */
