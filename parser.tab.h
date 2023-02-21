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

#line 119 "parser.tab.h"

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
    TIMESEQ = 272,                 /* TIMESEQ  */
    DIVEQ = 273,                   /* DIVEQ  */
    MODEQ = 274,                   /* MODEQ  */
    PLUSEQ = 275,                  /* PLUSEQ  */
    MINUSEQ = 276,                 /* MINUSEQ  */
    SHLEQ = 277,                   /* SHLEQ  */
    SHREQ = 278,                   /* SHREQ  */
    ANDEQ = 279,                   /* ANDEQ  */
    OREQ = 280,                    /* OREQ  */
    XOREQ = 281,                   /* XOREQ  */
    AUTO = 282,                    /* AUTO  */
    BREAK = 283,                   /* BREAK  */
    CASE = 284,                    /* CASE  */
    CHAR = 285,                    /* CHAR  */
    CONST = 286,                   /* CONST  */
    CONTINUE = 287,                /* CONTINUE  */
    DEFAULT = 288,                 /* DEFAULT  */
    DO = 289,                      /* DO  */
    DOUBLE = 290,                  /* DOUBLE  */
    ELSE = 291,                    /* ELSE  */
    ENUM = 292,                    /* ENUM  */
    EXTERN = 293,                  /* EXTERN  */
    FLOAT = 294,                   /* FLOAT  */
    FOR = 295,                     /* FOR  */
    GOTO = 296,                    /* GOTO  */
    IF = 297,                      /* IF  */
    INLINE = 298,                  /* INLINE  */
    INT = 299,                     /* INT  */
    LONG = 300,                    /* LONG  */
    REGISTER = 301,                /* REGISTER  */
    RESTRICT = 302,                /* RESTRICT  */
    RETURN = 303,                  /* RETURN  */
    SHORT = 304,                   /* SHORT  */
    SIGNED = 305,                  /* SIGNED  */
    SIZEOF = 306,                  /* SIZEOF  */
    STATIC = 307,                  /* STATIC  */
    STRUCT = 308,                  /* STRUCT  */
    SWITCH = 309,                  /* SWITCH  */
    TYPEDEF = 310,                 /* TYPEDEF  */
    UNION = 311,                   /* UNION  */
    UNSIGNED = 312,                /* UNSIGNED  */
    VOID = 313,                    /* VOID  */
    VOLATILE = 314,                /* VOLATILE  */
    WHILE = 315,                   /* WHILE  */
    _BOOL = 316,                   /* _BOOL  */
    _COMPLEX = 317,                /* _COMPLEX  */
    _IMAGINARY = 318,              /* _IMAGINARY  */
    NAME = 319,                    /* NAME  */
    IDENT = 320,                   /* IDENT  */
    newString = 321                /* newString  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 115 "parser.y"

    struct number number;
    char *string;
    struct astnode *astnode_p;

#line 208 "parser.tab.h"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;


int yyparse (void);


#endif /* !YY_YY_PARSER_TAB_H_INCLUDED  */
