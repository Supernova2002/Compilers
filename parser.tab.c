/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison implementation for Yacc-like parsers in C

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

/* C LALR(1) parser skeleton written by Richard Stallman, by
   simplifying the original so-called "semantic" parser.  */

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

/* All symbols defined below should begin with yy or YY, to avoid
   infringing on user name space.  This should be done even for local
   variables, as they might otherwise be expanded by user macros.
   There are some unavoidable exceptions within include files to
   define necessary library symbols; they are noted "INFRINGES ON
   USER NAME SPACE" below.  */

/* Identify Bison output, and Bison version.  */
#define YYBISON 30802

/* Bison version string.  */
#define YYBISON_VERSION "3.8.2"

/* Skeleton name.  */
#define YYSKELETON_NAME "yacc.c"

/* Pure parsers.  */
#define YYPURE 0

/* Push parsers.  */
#define YYPUSH 0

/* Pull parsers.  */
#define YYPULL 1




/* First part of user prologue.  */
#line 3 "parser.y"

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
    
    

#line 115 "parser.tab.c"

# ifndef YY_CAST
#  ifdef __cplusplus
#   define YY_CAST(Type, Val) static_cast<Type> (Val)
#   define YY_REINTERPRET_CAST(Type, Val) reinterpret_cast<Type> (Val)
#  else
#   define YY_CAST(Type, Val) ((Type) (Val))
#   define YY_REINTERPRET_CAST(Type, Val) ((Type) (Val))
#  endif
# endif
# ifndef YY_NULLPTR
#  if defined __cplusplus
#   if 201103L <= __cplusplus
#    define YY_NULLPTR nullptr
#   else
#    define YY_NULLPTR 0
#   endif
#  else
#   define YY_NULLPTR ((void*)0)
#  endif
# endif

#include "parser.tab.h"
/* Symbol kind.  */
enum yysymbol_kind_t
{
  YYSYMBOL_YYEMPTY = -2,
  YYSYMBOL_YYEOF = 0,                      /* "end of file"  */
  YYSYMBOL_YYerror = 1,                    /* error  */
  YYSYMBOL_YYUNDEF = 2,                    /* "invalid token"  */
  YYSYMBOL_NUMBER = 3,                     /* NUMBER  */
  YYSYMBOL_CHARLIT = 4,                    /* CHARLIT  */
  YYSYMBOL_INDSEL = 5,                     /* INDSEL  */
  YYSYMBOL_PLUSPLUS = 6,                   /* PLUSPLUS  */
  YYSYMBOL_MINUSMINUS = 7,                 /* MINUSMINUS  */
  YYSYMBOL_SHL = 8,                        /* SHL  */
  YYSYMBOL_SHR = 9,                        /* SHR  */
  YYSYMBOL_LTEQ = 10,                      /* LTEQ  */
  YYSYMBOL_GTEQ = 11,                      /* GTEQ  */
  YYSYMBOL_EQEQ = 12,                      /* EQEQ  */
  YYSYMBOL_NOTEQ = 13,                     /* NOTEQ  */
  YYSYMBOL_LOGAND = 14,                    /* LOGAND  */
  YYSYMBOL_LOGOR = 15,                     /* LOGOR  */
  YYSYMBOL_ELLIPSIS = 16,                  /* ELLIPSIS  */
  YYSYMBOL_TIMESEQ = 17,                   /* TIMESEQ  */
  YYSYMBOL_DIVEQ = 18,                     /* DIVEQ  */
  YYSYMBOL_MODEQ = 19,                     /* MODEQ  */
  YYSYMBOL_PLUSEQ = 20,                    /* PLUSEQ  */
  YYSYMBOL_MINUSEQ = 21,                   /* MINUSEQ  */
  YYSYMBOL_SHLEQ = 22,                     /* SHLEQ  */
  YYSYMBOL_SHREQ = 23,                     /* SHREQ  */
  YYSYMBOL_ANDEQ = 24,                     /* ANDEQ  */
  YYSYMBOL_OREQ = 25,                      /* OREQ  */
  YYSYMBOL_XOREQ = 26,                     /* XOREQ  */
  YYSYMBOL_AUTO = 27,                      /* AUTO  */
  YYSYMBOL_BREAK = 28,                     /* BREAK  */
  YYSYMBOL_CASE = 29,                      /* CASE  */
  YYSYMBOL_CHAR = 30,                      /* CHAR  */
  YYSYMBOL_CONST = 31,                     /* CONST  */
  YYSYMBOL_CONTINUE = 32,                  /* CONTINUE  */
  YYSYMBOL_DEFAULT = 33,                   /* DEFAULT  */
  YYSYMBOL_DO = 34,                        /* DO  */
  YYSYMBOL_DOUBLE = 35,                    /* DOUBLE  */
  YYSYMBOL_ELSE = 36,                      /* ELSE  */
  YYSYMBOL_ENUM = 37,                      /* ENUM  */
  YYSYMBOL_EXTERN = 38,                    /* EXTERN  */
  YYSYMBOL_FLOAT = 39,                     /* FLOAT  */
  YYSYMBOL_FOR = 40,                       /* FOR  */
  YYSYMBOL_GOTO = 41,                      /* GOTO  */
  YYSYMBOL_IF = 42,                        /* IF  */
  YYSYMBOL_INLINE = 43,                    /* INLINE  */
  YYSYMBOL_INT = 44,                       /* INT  */
  YYSYMBOL_LONG = 45,                      /* LONG  */
  YYSYMBOL_REGISTER = 46,                  /* REGISTER  */
  YYSYMBOL_RESTRICT = 47,                  /* RESTRICT  */
  YYSYMBOL_RETURN = 48,                    /* RETURN  */
  YYSYMBOL_SHORT = 49,                     /* SHORT  */
  YYSYMBOL_SIGNED = 50,                    /* SIGNED  */
  YYSYMBOL_SIZEOF = 51,                    /* SIZEOF  */
  YYSYMBOL_STATIC = 52,                    /* STATIC  */
  YYSYMBOL_STRUCT = 53,                    /* STRUCT  */
  YYSYMBOL_SWITCH = 54,                    /* SWITCH  */
  YYSYMBOL_TYPEDEF = 55,                   /* TYPEDEF  */
  YYSYMBOL_UNION = 56,                     /* UNION  */
  YYSYMBOL_UNSIGNED = 57,                  /* UNSIGNED  */
  YYSYMBOL_VOID = 58,                      /* VOID  */
  YYSYMBOL_VOLATILE = 59,                  /* VOLATILE  */
  YYSYMBOL_WHILE = 60,                     /* WHILE  */
  YYSYMBOL__BOOL = 61,                     /* _BOOL  */
  YYSYMBOL__COMPLEX = 62,                  /* _COMPLEX  */
  YYSYMBOL__IMAGINARY = 63,                /* _IMAGINARY  */
  YYSYMBOL_NAME = 64,                      /* NAME  */
  YYSYMBOL_ENDFILE = 65,                   /* ENDFILE  */
  YYSYMBOL_IDENT = 66,                     /* IDENT  */
  YYSYMBOL_newString = 67,                 /* newString  */
  YYSYMBOL_68_ = 68,                       /* '+'  */
  YYSYMBOL_69_ = 69,                       /* '-'  */
  YYSYMBOL_70_ = 70,                       /* '*'  */
  YYSYMBOL_71_ = 71,                       /* '/'  */
  YYSYMBOL_72_ = 72,                       /* '%'  */
  YYSYMBOL_73_ = 73,                       /* ';'  */
  YYSYMBOL_74_ = 74,                       /* ','  */
  YYSYMBOL_75_ = 75,                       /* '('  */
  YYSYMBOL_76_ = 76,                       /* ')'  */
  YYSYMBOL_77_ = 77,                       /* '['  */
  YYSYMBOL_78_ = 78,                       /* ']'  */
  YYSYMBOL_79_ = 79,                       /* '.'  */
  YYSYMBOL_80_ = 80,                       /* '~'  */
  YYSYMBOL_81_ = 81,                       /* '!'  */
  YYSYMBOL_82_ = 82,                       /* '&'  */
  YYSYMBOL_83_ = 83,                       /* '<'  */
  YYSYMBOL_84_ = 84,                       /* '>'  */
  YYSYMBOL_85_ = 85,                       /* '^'  */
  YYSYMBOL_86_ = 86,                       /* '|'  */
  YYSYMBOL_87_ = 87,                       /* '?'  */
  YYSYMBOL_88_ = 88,                       /* ':'  */
  YYSYMBOL_89_ = 89,                       /* '='  */
  YYSYMBOL_YYACCEPT = 90,                  /* $accept  */
  YYSYMBOL_start = 91,                     /* start  */
  YYSYMBOL_statement = 92,                 /* statement  */
  YYSYMBOL_expr = 93,                      /* expr  */
  YYSYMBOL_primexp = 94,                   /* primexp  */
  YYSYMBOL_postexp = 95,                   /* postexp  */
  YYSYMBOL_argexplist = 96,                /* argexplist  */
  YYSYMBOL_castexp = 97,                   /* castexp  */
  YYSYMBOL_typename = 98,                  /* typename  */
  YYSYMBOL_unaryop = 99,                   /* unaryop  */
  YYSYMBOL_unexp = 100,                    /* unexp  */
  YYSYMBOL_multexp = 101,                  /* multexp  */
  YYSYMBOL_addexp = 102,                   /* addexp  */
  YYSYMBOL_shiftexp = 103,                 /* shiftexp  */
  YYSYMBOL_relexp = 104,                   /* relexp  */
  YYSYMBOL_eqexp = 105,                    /* eqexp  */
  YYSYMBOL_andexp = 106,                   /* andexp  */
  YYSYMBOL_exorexp = 107,                  /* exorexp  */
  YYSYMBOL_inorexp = 108,                  /* inorexp  */
  YYSYMBOL_logandexp = 109,                /* logandexp  */
  YYSYMBOL_logorexp = 110,                 /* logorexp  */
  YYSYMBOL_condexp = 111,                  /* condexp  */
  YYSYMBOL_assexp = 112,                   /* assexp  */
  YYSYMBOL_assop = 113                     /* assop  */
};
typedef enum yysymbol_kind_t yysymbol_kind_t;




#ifdef short
# undef short
#endif

/* On compilers that do not define __PTRDIFF_MAX__ etc., make sure
   <limits.h> and (if available) <stdint.h> are included
   so that the code can choose integer types of a good width.  */

#ifndef __PTRDIFF_MAX__
# include <limits.h> /* INFRINGES ON USER NAME SPACE */
# if defined __STDC_VERSION__ && 199901 <= __STDC_VERSION__
#  include <stdint.h> /* INFRINGES ON USER NAME SPACE */
#  define YY_STDINT_H
# endif
#endif

/* Narrow types that promote to a signed type and that can represent a
   signed or unsigned integer of at least N bits.  In tables they can
   save space and decrease cache pressure.  Promoting to a signed type
   helps avoid bugs in integer arithmetic.  */

#ifdef __INT_LEAST8_MAX__
typedef __INT_LEAST8_TYPE__ yytype_int8;
#elif defined YY_STDINT_H
typedef int_least8_t yytype_int8;
#else
typedef signed char yytype_int8;
#endif

#ifdef __INT_LEAST16_MAX__
typedef __INT_LEAST16_TYPE__ yytype_int16;
#elif defined YY_STDINT_H
typedef int_least16_t yytype_int16;
#else
typedef short yytype_int16;
#endif

/* Work around bug in HP-UX 11.23, which defines these macros
   incorrectly for preprocessor constants.  This workaround can likely
   be removed in 2023, as HPE has promised support for HP-UX 11.23
   (aka HP-UX 11i v2) only through the end of 2022; see Table 2 of
   <https://h20195.www2.hpe.com/V2/getpdf.aspx/4AA4-7673ENW.pdf>.  */
#ifdef __hpux
# undef UINT_LEAST8_MAX
# undef UINT_LEAST16_MAX
# define UINT_LEAST8_MAX 255
# define UINT_LEAST16_MAX 65535
#endif

#if defined __UINT_LEAST8_MAX__ && __UINT_LEAST8_MAX__ <= __INT_MAX__
typedef __UINT_LEAST8_TYPE__ yytype_uint8;
#elif (!defined __UINT_LEAST8_MAX__ && defined YY_STDINT_H \
       && UINT_LEAST8_MAX <= INT_MAX)
typedef uint_least8_t yytype_uint8;
#elif !defined __UINT_LEAST8_MAX__ && UCHAR_MAX <= INT_MAX
typedef unsigned char yytype_uint8;
#else
typedef short yytype_uint8;
#endif

#if defined __UINT_LEAST16_MAX__ && __UINT_LEAST16_MAX__ <= __INT_MAX__
typedef __UINT_LEAST16_TYPE__ yytype_uint16;
#elif (!defined __UINT_LEAST16_MAX__ && defined YY_STDINT_H \
       && UINT_LEAST16_MAX <= INT_MAX)
typedef uint_least16_t yytype_uint16;
#elif !defined __UINT_LEAST16_MAX__ && USHRT_MAX <= INT_MAX
typedef unsigned short yytype_uint16;
#else
typedef int yytype_uint16;
#endif

#ifndef YYPTRDIFF_T
# if defined __PTRDIFF_TYPE__ && defined __PTRDIFF_MAX__
#  define YYPTRDIFF_T __PTRDIFF_TYPE__
#  define YYPTRDIFF_MAXIMUM __PTRDIFF_MAX__
# elif defined PTRDIFF_MAX
#  ifndef ptrdiff_t
#   include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  endif
#  define YYPTRDIFF_T ptrdiff_t
#  define YYPTRDIFF_MAXIMUM PTRDIFF_MAX
# else
#  define YYPTRDIFF_T long
#  define YYPTRDIFF_MAXIMUM LONG_MAX
# endif
#endif

#ifndef YYSIZE_T
# ifdef __SIZE_TYPE__
#  define YYSIZE_T __SIZE_TYPE__
# elif defined size_t
#  define YYSIZE_T size_t
# elif defined __STDC_VERSION__ && 199901 <= __STDC_VERSION__
#  include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  define YYSIZE_T size_t
# else
#  define YYSIZE_T unsigned
# endif
#endif

#define YYSIZE_MAXIMUM                                  \
  YY_CAST (YYPTRDIFF_T,                                 \
           (YYPTRDIFF_MAXIMUM < YY_CAST (YYSIZE_T, -1)  \
            ? YYPTRDIFF_MAXIMUM                         \
            : YY_CAST (YYSIZE_T, -1)))

#define YYSIZEOF(X) YY_CAST (YYPTRDIFF_T, sizeof (X))


/* Stored state numbers (used for stacks). */
typedef yytype_uint8 yy_state_t;

/* State numbers in computations.  */
typedef int yy_state_fast_t;

#ifndef YY_
# if defined YYENABLE_NLS && YYENABLE_NLS
#  if ENABLE_NLS
#   include <libintl.h> /* INFRINGES ON USER NAME SPACE */
#   define YY_(Msgid) dgettext ("bison-runtime", Msgid)
#  endif
# endif
# ifndef YY_
#  define YY_(Msgid) Msgid
# endif
#endif


#ifndef YY_ATTRIBUTE_PURE
# if defined __GNUC__ && 2 < __GNUC__ + (96 <= __GNUC_MINOR__)
#  define YY_ATTRIBUTE_PURE __attribute__ ((__pure__))
# else
#  define YY_ATTRIBUTE_PURE
# endif
#endif

#ifndef YY_ATTRIBUTE_UNUSED
# if defined __GNUC__ && 2 < __GNUC__ + (7 <= __GNUC_MINOR__)
#  define YY_ATTRIBUTE_UNUSED __attribute__ ((__unused__))
# else
#  define YY_ATTRIBUTE_UNUSED
# endif
#endif

/* Suppress unused-variable warnings by "using" E.  */
#if ! defined lint || defined __GNUC__
# define YY_USE(E) ((void) (E))
#else
# define YY_USE(E) /* empty */
#endif

/* Suppress an incorrect diagnostic about yylval being uninitialized.  */
#if defined __GNUC__ && ! defined __ICC && 406 <= __GNUC__ * 100 + __GNUC_MINOR__
# if __GNUC__ * 100 + __GNUC_MINOR__ < 407
#  define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN                           \
    _Pragma ("GCC diagnostic push")                                     \
    _Pragma ("GCC diagnostic ignored \"-Wuninitialized\"")
# else
#  define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN                           \
    _Pragma ("GCC diagnostic push")                                     \
    _Pragma ("GCC diagnostic ignored \"-Wuninitialized\"")              \
    _Pragma ("GCC diagnostic ignored \"-Wmaybe-uninitialized\"")
# endif
# define YY_IGNORE_MAYBE_UNINITIALIZED_END      \
    _Pragma ("GCC diagnostic pop")
#else
# define YY_INITIAL_VALUE(Value) Value
#endif
#ifndef YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
# define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
# define YY_IGNORE_MAYBE_UNINITIALIZED_END
#endif
#ifndef YY_INITIAL_VALUE
# define YY_INITIAL_VALUE(Value) /* Nothing. */
#endif

#if defined __cplusplus && defined __GNUC__ && ! defined __ICC && 6 <= __GNUC__
# define YY_IGNORE_USELESS_CAST_BEGIN                          \
    _Pragma ("GCC diagnostic push")                            \
    _Pragma ("GCC diagnostic ignored \"-Wuseless-cast\"")
# define YY_IGNORE_USELESS_CAST_END            \
    _Pragma ("GCC diagnostic pop")
#endif
#ifndef YY_IGNORE_USELESS_CAST_BEGIN
# define YY_IGNORE_USELESS_CAST_BEGIN
# define YY_IGNORE_USELESS_CAST_END
#endif


#define YY_ASSERT(E) ((void) (0 && (E)))

#if 1

/* The parser invokes alloca or malloc; define the necessary symbols.  */

# ifdef YYSTACK_USE_ALLOCA
#  if YYSTACK_USE_ALLOCA
#   ifdef __GNUC__
#    define YYSTACK_ALLOC __builtin_alloca
#   elif defined __BUILTIN_VA_ARG_INCR
#    include <alloca.h> /* INFRINGES ON USER NAME SPACE */
#   elif defined _AIX
#    define YYSTACK_ALLOC __alloca
#   elif defined _MSC_VER
#    include <malloc.h> /* INFRINGES ON USER NAME SPACE */
#    define alloca _alloca
#   else
#    define YYSTACK_ALLOC alloca
#    if ! defined _ALLOCA_H && ! defined EXIT_SUCCESS
#     include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
      /* Use EXIT_SUCCESS as a witness for stdlib.h.  */
#     ifndef EXIT_SUCCESS
#      define EXIT_SUCCESS 0
#     endif
#    endif
#   endif
#  endif
# endif

# ifdef YYSTACK_ALLOC
   /* Pacify GCC's 'empty if-body' warning.  */
#  define YYSTACK_FREE(Ptr) do { /* empty */; } while (0)
#  ifndef YYSTACK_ALLOC_MAXIMUM
    /* The OS might guarantee only one guard page at the bottom of the stack,
       and a page size can be as small as 4096 bytes.  So we cannot safely
       invoke alloca (N) if N exceeds 4096.  Use a slightly smaller number
       to allow for a few compiler-allocated temporary stack slots.  */
#   define YYSTACK_ALLOC_MAXIMUM 4032 /* reasonable circa 2006 */
#  endif
# else
#  define YYSTACK_ALLOC YYMALLOC
#  define YYSTACK_FREE YYFREE
#  ifndef YYSTACK_ALLOC_MAXIMUM
#   define YYSTACK_ALLOC_MAXIMUM YYSIZE_MAXIMUM
#  endif
#  if (defined __cplusplus && ! defined EXIT_SUCCESS \
       && ! ((defined YYMALLOC || defined malloc) \
             && (defined YYFREE || defined free)))
#   include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#   ifndef EXIT_SUCCESS
#    define EXIT_SUCCESS 0
#   endif
#  endif
#  ifndef YYMALLOC
#   define YYMALLOC malloc
#   if ! defined malloc && ! defined EXIT_SUCCESS
void *malloc (YYSIZE_T); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
#  ifndef YYFREE
#   define YYFREE free
#   if ! defined free && ! defined EXIT_SUCCESS
void free (void *); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
# endif
#endif /* 1 */

#if (! defined yyoverflow \
     && (! defined __cplusplus \
         || (defined YYSTYPE_IS_TRIVIAL && YYSTYPE_IS_TRIVIAL)))

/* A type that is properly aligned for any stack member.  */
union yyalloc
{
  yy_state_t yyss_alloc;
  YYSTYPE yyvs_alloc;
};

/* The size of the maximum gap between one aligned stack and the next.  */
# define YYSTACK_GAP_MAXIMUM (YYSIZEOF (union yyalloc) - 1)

/* The size of an array large to enough to hold all stacks, each with
   N elements.  */
# define YYSTACK_BYTES(N) \
     ((N) * (YYSIZEOF (yy_state_t) + YYSIZEOF (YYSTYPE)) \
      + YYSTACK_GAP_MAXIMUM)

# define YYCOPY_NEEDED 1

/* Relocate STACK from its old location to the new one.  The
   local variables YYSIZE and YYSTACKSIZE give the old and new number of
   elements in the stack, and YYPTR gives the new location of the
   stack.  Advance YYPTR to a properly aligned location for the next
   stack.  */
# define YYSTACK_RELOCATE(Stack_alloc, Stack)                           \
    do                                                                  \
      {                                                                 \
        YYPTRDIFF_T yynewbytes;                                         \
        YYCOPY (&yyptr->Stack_alloc, Stack, yysize);                    \
        Stack = &yyptr->Stack_alloc;                                    \
        yynewbytes = yystacksize * YYSIZEOF (*Stack) + YYSTACK_GAP_MAXIMUM; \
        yyptr += yynewbytes / YYSIZEOF (*yyptr);                        \
      }                                                                 \
    while (0)

#endif

#if defined YYCOPY_NEEDED && YYCOPY_NEEDED
/* Copy COUNT objects from SRC to DST.  The source and destination do
   not overlap.  */
# ifndef YYCOPY
#  if defined __GNUC__ && 1 < __GNUC__
#   define YYCOPY(Dst, Src, Count) \
      __builtin_memcpy (Dst, Src, YY_CAST (YYSIZE_T, (Count)) * sizeof (*(Src)))
#  else
#   define YYCOPY(Dst, Src, Count)              \
      do                                        \
        {                                       \
          YYPTRDIFF_T yyi;                      \
          for (yyi = 0; yyi < (Count); yyi++)   \
            (Dst)[yyi] = (Src)[yyi];            \
        }                                       \
      while (0)
#  endif
# endif
#endif /* !YYCOPY_NEEDED */

/* YYFINAL -- State number of the termination state.  */
#define YYFINAL  50
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   277

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  90
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  24
/* YYNRULES -- Number of rules.  */
#define YYNRULES  82
/* YYNSTATES -- Number of states.  */
#define YYNSTATES  129

/* YYMAXUTOK -- Last valid token kind.  */
#define YYMAXUTOK   322


/* YYTRANSLATE(TOKEN-NUM) -- Symbol number corresponding to TOKEN-NUM
   as returned by yylex, with out-of-bounds checking.  */
#define YYTRANSLATE(YYX)                                \
  (0 <= (YYX) && (YYX) <= YYMAXUTOK                     \
   ? YY_CAST (yysymbol_kind_t, yytranslate[YYX])        \
   : YYSYMBOL_YYUNDEF)

/* YYTRANSLATE[TOKEN-NUM] -- Symbol number corresponding to TOKEN-NUM
   as returned by yylex.  */
static const yytype_int8 yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,    81,     2,     2,     2,    72,    82,     2,
      75,    76,    70,    68,    74,    69,    79,    71,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,    88,    73,
      83,    89,    84,    87,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,    77,     2,    78,    85,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,    86,     2,    80,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     1,     2,     3,     4,
       5,     6,     7,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    38,    39,    40,    41,    42,    43,    44,
      45,    46,    47,    48,    49,    50,    51,    52,    53,    54,
      55,    56,    57,    58,    59,    60,    61,    62,    63,    64,
      65,    66,    67
};

#if YYDEBUG
/* YYRLINE[YYN] -- Source line where rule number YYN was defined.  */
static const yytype_int16 yyrline[] =
{
       0,    77,    77,    78,    80,    84,    85,    96,   101,   105,
     109,   113,   116,   117,   126,   132,   136,   141,   145,   153,
     158,   168,   169,   174,   175,   176,   177,   178,   182,   183,
     184,   185,   187,   188,   197,   206,   210,   214,   218,   222,
     229,   230,   237,   244,   252,   253,   260,   268,   269,   276,
     284,   285,   290,   295,   300,   306,   307,   312,   318,   319,
     327,   328,   336,   337,   345,   346,   354,   355,   363,   364,
     372,   373,   382,   383,   384,   385,   386,   387,   388,   389,
     390,   391,   392
};
#endif

/** Accessing symbol of state STATE.  */
#define YY_ACCESSING_SYMBOL(State) YY_CAST (yysymbol_kind_t, yystos[State])

#if 1
/* The user-facing name of the symbol whose (internal) number is
   YYSYMBOL.  No bounds checking.  */
static const char *yysymbol_name (yysymbol_kind_t yysymbol) YY_ATTRIBUTE_UNUSED;

/* YYTNAME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
   First, the terminals, then, starting at YYNTOKENS, nonterminals.  */
static const char *const yytname[] =
{
  "\"end of file\"", "error", "\"invalid token\"", "NUMBER", "CHARLIT",
  "INDSEL", "PLUSPLUS", "MINUSMINUS", "SHL", "SHR", "LTEQ", "GTEQ", "EQEQ",
  "NOTEQ", "LOGAND", "LOGOR", "ELLIPSIS", "TIMESEQ", "DIVEQ", "MODEQ",
  "PLUSEQ", "MINUSEQ", "SHLEQ", "SHREQ", "ANDEQ", "OREQ", "XOREQ", "AUTO",
  "BREAK", "CASE", "CHAR", "CONST", "CONTINUE", "DEFAULT", "DO", "DOUBLE",
  "ELSE", "ENUM", "EXTERN", "FLOAT", "FOR", "GOTO", "IF", "INLINE", "INT",
  "LONG", "REGISTER", "RESTRICT", "RETURN", "SHORT", "SIGNED", "SIZEOF",
  "STATIC", "STRUCT", "SWITCH", "TYPEDEF", "UNION", "UNSIGNED", "VOID",
  "VOLATILE", "WHILE", "_BOOL", "_COMPLEX", "_IMAGINARY", "NAME",
  "ENDFILE", "IDENT", "newString", "'+'", "'-'", "'*'", "'/'", "'%'",
  "';'", "','", "'('", "')'", "'['", "']'", "'.'", "'~'", "'!'", "'&'",
  "'<'", "'>'", "'^'", "'|'", "'?'", "':'", "'='", "$accept", "start",
  "statement", "expr", "primexp", "postexp", "argexplist", "castexp",
  "typename", "unaryop", "unexp", "multexp", "addexp", "shiftexp",
  "relexp", "eqexp", "andexp", "exorexp", "inorexp", "logandexp",
  "logorexp", "condexp", "assexp", "assop", YY_NULLPTR
};

static const char *
yysymbol_name (yysymbol_kind_t yysymbol)
{
  return yytname[yysymbol];
}
#endif

#define YYPACT_NINF (-76)

#define yypact_value_is_default(Yyn) \
  ((Yyn) == YYPACT_NINF)

#define YYTABLE_NINF (-1)

#define yytable_value_is_error(Yyn) \
  0

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
static const yytype_int16 yypact[] =
{
      97,   -76,   -76,   122,   122,   177,   -76,   -76,   -76,   -76,
      97,    76,   -76,   -76,    97,    27,   -76,   -50,   -76,    35,
     -76,    97,   188,   -52,   -40,    43,    15,    42,   -75,   -73,
     -54,    23,    -6,   -76,   -76,    97,   -76,   -76,    76,   -76,
     -76,   -76,   -76,   -76,   -76,   -76,   -76,   -27,   -20,   -76,
     -76,   -76,   -76,    97,    -4,   -76,   -76,    97,    97,     2,
     -76,   -76,   -76,   -76,   -76,   -76,   -76,   -76,   -76,   -76,
     -76,   -76,    97,    97,    97,    97,    97,    97,    97,    97,
      97,    97,    97,    97,    97,    97,    97,    97,    97,    97,
      97,    97,    -7,   -76,    97,   -76,   -76,   -26,   -76,   -64,
     -76,   -76,   -76,   -76,   -76,   -52,   -52,   -40,   -40,    43,
      43,    43,    43,    15,    15,    42,   -75,   -73,   -54,    23,
     -66,   -76,   -76,    97,   -76,   -76,    97,   -76,   -76
};

/* YYDEFACT[STATE-NUM] -- Default reduction number in state STATE-NUM.
   Performed when YYTABLE does not specify something else to do.  Zero
   means the default is an error.  */
static const yytype_int8 yydefact[] =
{
       0,     8,     9,     0,     0,     0,     7,    10,    28,    29,
       0,     0,    30,    31,     0,     0,     2,     0,    12,    32,
      40,     0,    21,    44,    47,    50,    55,    58,    60,    62,
      64,    66,    68,    70,     5,     0,    33,    34,     0,    38,
      37,    21,    23,    26,    27,    24,    25,     0,     0,    36,
       1,     3,     4,     0,     0,    17,    18,     0,     0,     0,
      35,    73,    74,    75,    76,    77,    78,    79,    80,    82,
      81,    72,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    11,     0,     6,    16,     0,    19,     0,
      15,    71,    41,    42,    43,    45,    46,    48,    49,    53,
      54,    51,    52,    56,    57,    59,    61,    63,    65,    67,
       0,    39,    22,     0,    14,    13,     0,    20,    69
};

/* YYPGOTO[NTERM-NUM].  */
static const yytype_int8 yypgoto[] =
{
     -76,   -76,    24,     1,   -76,   -76,   -76,    -8,    36,   -76,
       0,   -16,   -15,   -37,   -14,   -13,   -12,   -11,    -5,    -2,
     -76,   -41,   -36,   -76
};

/* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int8 yydefgoto[] =
{
       0,    15,    16,    47,    18,    19,    97,    20,    48,    21,
      41,    23,    24,    25,    26,    27,    28,    29,    30,    31,
      32,    33,    34,    72
};

/* YYTABLE[YYPACT[STATE-NUM]] -- What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule whose
   number is the opposite.  If YYTABLE_NINF, syntax error.  */
static const yytype_uint8 yytable[] =
{
      22,    17,    40,    36,    37,    39,    49,    86,    53,    90,
      53,    22,    87,    60,   125,    22,    17,    95,    73,    74,
      75,    98,   126,    52,    53,    80,    81,    50,    76,    77,
       1,     2,    88,     3,     4,    22,   101,    89,    22,    51,
      54,    55,    56,   109,   110,   111,   112,    53,   123,    93,
     124,    78,    79,    22,    84,    85,    94,    22,    22,    99,
     105,   106,    96,   107,   108,   102,   103,   104,   100,   121,
     113,   114,    22,   115,    92,   116,     0,   117,     5,     1,
       2,    91,     3,     4,   118,   128,   122,   127,   119,     0,
       0,    22,   120,     6,     7,     8,     9,    10,    82,    83,
       1,     2,    11,     3,     4,     0,    42,    12,    13,    14,
      57,    43,    58,     0,    59,    44,     0,     0,     0,     0,
      45,    46,     0,    22,     0,     1,     2,     5,     3,     4,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     6,     7,     8,     9,    10,     0,     5,     0,
       0,    11,     0,     0,     0,     0,    12,    13,    14,     0,
       0,     0,     0,     6,     7,     8,     9,    10,     0,     0,
       0,     0,    11,     5,     0,     0,     0,    12,    13,    14,
       1,     2,     0,     3,     4,     0,     0,     0,     6,     7,
       8,     9,    10,     0,     0,     0,     0,    35,     0,     0,
       0,     0,    12,    13,    14,    61,    62,    63,    64,    65,
      66,    67,    68,    69,    70,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     5,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     6,     7,     8,     9,    10,     0,     0,
       0,     0,    38,     0,     0,     0,     0,    12,    13,    14,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    71
};

static const yytype_int8 yycheck[] =
{
       0,     0,    10,     3,     4,     5,    14,    82,    74,    15,
      74,    11,    85,    21,    78,    15,    15,    53,    70,    71,
      72,    57,    88,    73,    74,    10,    11,     0,    68,    69,
       3,     4,    86,     6,     7,    35,    72,    14,    38,    15,
       5,     6,     7,    80,    81,    82,    83,    74,    74,    76,
      76,     8,     9,    53,    12,    13,    76,    57,    58,    58,
      76,    77,    66,    78,    79,    73,    74,    75,    66,    76,
      84,    85,    72,    86,    38,    87,    -1,    88,    51,     3,
       4,    87,     6,     7,    89,   126,    94,   123,    90,    -1,
      -1,    91,    91,    66,    67,    68,    69,    70,    83,    84,
       3,     4,    75,     6,     7,    -1,    30,    80,    81,    82,
      75,    35,    77,    -1,    79,    39,    -1,    -1,    -1,    -1,
      44,    45,    -1,   123,    -1,     3,     4,    51,     6,     7,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    66,    67,    68,    69,    70,    -1,    51,    -1,
      -1,    75,    -1,    -1,    -1,    -1,    80,    81,    82,    -1,
      -1,    -1,    -1,    66,    67,    68,    69,    70,    -1,    -1,
      -1,    -1,    75,    51,    -1,    -1,    -1,    80,    81,    82,
       3,     4,    -1,     6,     7,    -1,    -1,    -1,    66,    67,
      68,    69,    70,    -1,    -1,    -1,    -1,    75,    -1,    -1,
      -1,    -1,    80,    81,    82,    17,    18,    19,    20,    21,
      22,    23,    24,    25,    26,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    51,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    66,    67,    68,    69,    70,    -1,    -1,
      -1,    -1,    75,    -1,    -1,    -1,    -1,    80,    81,    82,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    89
};

/* YYSTOS[STATE-NUM] -- The symbol kind of the accessing symbol of
   state STATE-NUM.  */
static const yytype_int8 yystos[] =
{
       0,     3,     4,     6,     7,    51,    66,    67,    68,    69,
      70,    75,    80,    81,    82,    91,    92,    93,    94,    95,
      97,    99,   100,   101,   102,   103,   104,   105,   106,   107,
     108,   109,   110,   111,   112,    75,   100,   100,    75,   100,
      97,   100,    30,    35,    39,    44,    45,    93,    98,    97,
       0,    92,    73,    74,     5,     6,     7,    75,    77,    79,
      97,    17,    18,    19,    20,    21,    22,    23,    24,    25,
      26,    89,   113,    70,    71,    72,    68,    69,     8,     9,
      10,    11,    83,    84,    12,    13,    82,    85,    86,    14,
      15,    87,    98,    76,    76,   112,    66,    96,   112,    93,
      66,   112,    97,    97,    97,   101,   101,   102,   102,   103,
     103,   103,   103,   104,   104,   105,   106,   107,   108,   109,
      93,    76,    97,    74,    76,    78,    88,   112,   111
};

/* YYR1[RULE-NUM] -- Symbol kind of the left-hand side of rule RULE-NUM.  */
static const yytype_int8 yyr1[] =
{
       0,    90,    91,    91,    92,    93,    93,    94,    94,    94,
      94,    94,    95,    95,    95,    95,    95,    95,    95,    96,
      96,    97,    97,    98,    98,    98,    98,    98,    99,    99,
      99,    99,   100,   100,   100,   100,   100,   100,   100,   100,
     101,   101,   101,   101,   102,   102,   102,   103,   103,   103,
     104,   104,   104,   104,   104,   105,   105,   105,   106,   106,
     107,   107,   108,   108,   109,   109,   110,   110,   111,   111,
     112,   112,   113,   113,   113,   113,   113,   113,   113,   113,
     113,   113,   113
};

/* YYR2[RULE-NUM] -- Number of symbols on the right-hand side of rule RULE-NUM.  */
static const yytype_int8 yyr2[] =
{
       0,     2,     1,     2,     2,     1,     3,     1,     1,     1,
       1,     3,     1,     4,     4,     3,     3,     2,     2,     1,
       3,     1,     4,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     2,     2,     2,     2,     2,     2,     4,
       1,     3,     3,     3,     1,     3,     3,     1,     3,     3,
       1,     3,     3,     3,     3,     1,     3,     3,     1,     3,
       1,     3,     1,     3,     1,     3,     1,     3,     1,     5,
       1,     3,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1
};


enum { YYENOMEM = -2 };

#define yyerrok         (yyerrstatus = 0)
#define yyclearin       (yychar = YYEMPTY)

#define YYACCEPT        goto yyacceptlab
#define YYABORT         goto yyabortlab
#define YYERROR         goto yyerrorlab
#define YYNOMEM         goto yyexhaustedlab


#define YYRECOVERING()  (!!yyerrstatus)

#define YYBACKUP(Token, Value)                                    \
  do                                                              \
    if (yychar == YYEMPTY)                                        \
      {                                                           \
        yychar = (Token);                                         \
        yylval = (Value);                                         \
        YYPOPSTACK (yylen);                                       \
        yystate = *yyssp;                                         \
        goto yybackup;                                            \
      }                                                           \
    else                                                          \
      {                                                           \
        yyerror (YY_("syntax error: cannot back up")); \
        YYERROR;                                                  \
      }                                                           \
  while (0)

/* Backward compatibility with an undocumented macro.
   Use YYerror or YYUNDEF. */
#define YYERRCODE YYUNDEF


/* Enable debugging if requested.  */
#if YYDEBUG

# ifndef YYFPRINTF
#  include <stdio.h> /* INFRINGES ON USER NAME SPACE */
#  define YYFPRINTF fprintf
# endif

# define YYDPRINTF(Args)                        \
do {                                            \
  if (yydebug)                                  \
    YYFPRINTF Args;                             \
} while (0)




# define YY_SYMBOL_PRINT(Title, Kind, Value, Location)                    \
do {                                                                      \
  if (yydebug)                                                            \
    {                                                                     \
      YYFPRINTF (stderr, "%s ", Title);                                   \
      yy_symbol_print (stderr,                                            \
                  Kind, Value); \
      YYFPRINTF (stderr, "\n");                                           \
    }                                                                     \
} while (0)


/*-----------------------------------.
| Print this symbol's value on YYO.  |
`-----------------------------------*/

static void
yy_symbol_value_print (FILE *yyo,
                       yysymbol_kind_t yykind, YYSTYPE const * const yyvaluep)
{
  FILE *yyoutput = yyo;
  YY_USE (yyoutput);
  if (!yyvaluep)
    return;
  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  YY_USE (yykind);
  YY_IGNORE_MAYBE_UNINITIALIZED_END
}


/*---------------------------.
| Print this symbol on YYO.  |
`---------------------------*/

static void
yy_symbol_print (FILE *yyo,
                 yysymbol_kind_t yykind, YYSTYPE const * const yyvaluep)
{
  YYFPRINTF (yyo, "%s %s (",
             yykind < YYNTOKENS ? "token" : "nterm", yysymbol_name (yykind));

  yy_symbol_value_print (yyo, yykind, yyvaluep);
  YYFPRINTF (yyo, ")");
}

/*------------------------------------------------------------------.
| yy_stack_print -- Print the state stack from its BOTTOM up to its |
| TOP (included).                                                   |
`------------------------------------------------------------------*/

static void
yy_stack_print (yy_state_t *yybottom, yy_state_t *yytop)
{
  YYFPRINTF (stderr, "Stack now");
  for (; yybottom <= yytop; yybottom++)
    {
      int yybot = *yybottom;
      YYFPRINTF (stderr, " %d", yybot);
    }
  YYFPRINTF (stderr, "\n");
}

# define YY_STACK_PRINT(Bottom, Top)                            \
do {                                                            \
  if (yydebug)                                                  \
    yy_stack_print ((Bottom), (Top));                           \
} while (0)


/*------------------------------------------------.
| Report that the YYRULE is going to be reduced.  |
`------------------------------------------------*/

static void
yy_reduce_print (yy_state_t *yyssp, YYSTYPE *yyvsp,
                 int yyrule)
{
  int yylno = yyrline[yyrule];
  int yynrhs = yyr2[yyrule];
  int yyi;
  YYFPRINTF (stderr, "Reducing stack by rule %d (line %d):\n",
             yyrule - 1, yylno);
  /* The symbols being reduced.  */
  for (yyi = 0; yyi < yynrhs; yyi++)
    {
      YYFPRINTF (stderr, "   $%d = ", yyi + 1);
      yy_symbol_print (stderr,
                       YY_ACCESSING_SYMBOL (+yyssp[yyi + 1 - yynrhs]),
                       &yyvsp[(yyi + 1) - (yynrhs)]);
      YYFPRINTF (stderr, "\n");
    }
}

# define YY_REDUCE_PRINT(Rule)          \
do {                                    \
  if (yydebug)                          \
    yy_reduce_print (yyssp, yyvsp, Rule); \
} while (0)

/* Nonzero means print parse trace.  It is left uninitialized so that
   multiple parsers can coexist.  */
int yydebug;
#else /* !YYDEBUG */
# define YYDPRINTF(Args) ((void) 0)
# define YY_SYMBOL_PRINT(Title, Kind, Value, Location)
# define YY_STACK_PRINT(Bottom, Top)
# define YY_REDUCE_PRINT(Rule)
#endif /* !YYDEBUG */


/* YYINITDEPTH -- initial size of the parser's stacks.  */
#ifndef YYINITDEPTH
# define YYINITDEPTH 200
#endif

/* YYMAXDEPTH -- maximum size the stacks can grow to (effective only
   if the built-in stack extension method is used).

   Do not make this value too large; the results are undefined if
   YYSTACK_ALLOC_MAXIMUM < YYSTACK_BYTES (YYMAXDEPTH)
   evaluated with infinite-precision integer arithmetic.  */

#ifndef YYMAXDEPTH
# define YYMAXDEPTH 10000
#endif


/* Context of a parse error.  */
typedef struct
{
  yy_state_t *yyssp;
  yysymbol_kind_t yytoken;
} yypcontext_t;

/* Put in YYARG at most YYARGN of the expected tokens given the
   current YYCTX, and return the number of tokens stored in YYARG.  If
   YYARG is null, return the number of expected tokens (guaranteed to
   be less than YYNTOKENS).  Return YYENOMEM on memory exhaustion.
   Return 0 if there are more than YYARGN expected tokens, yet fill
   YYARG up to YYARGN. */
static int
yypcontext_expected_tokens (const yypcontext_t *yyctx,
                            yysymbol_kind_t yyarg[], int yyargn)
{
  /* Actual size of YYARG. */
  int yycount = 0;
  int yyn = yypact[+*yyctx->yyssp];
  if (!yypact_value_is_default (yyn))
    {
      /* Start YYX at -YYN if negative to avoid negative indexes in
         YYCHECK.  In other words, skip the first -YYN actions for
         this state because they are default actions.  */
      int yyxbegin = yyn < 0 ? -yyn : 0;
      /* Stay within bounds of both yycheck and yytname.  */
      int yychecklim = YYLAST - yyn + 1;
      int yyxend = yychecklim < YYNTOKENS ? yychecklim : YYNTOKENS;
      int yyx;
      for (yyx = yyxbegin; yyx < yyxend; ++yyx)
        if (yycheck[yyx + yyn] == yyx && yyx != YYSYMBOL_YYerror
            && !yytable_value_is_error (yytable[yyx + yyn]))
          {
            if (!yyarg)
              ++yycount;
            else if (yycount == yyargn)
              return 0;
            else
              yyarg[yycount++] = YY_CAST (yysymbol_kind_t, yyx);
          }
    }
  if (yyarg && yycount == 0 && 0 < yyargn)
    yyarg[0] = YYSYMBOL_YYEMPTY;
  return yycount;
}




#ifndef yystrlen
# if defined __GLIBC__ && defined _STRING_H
#  define yystrlen(S) (YY_CAST (YYPTRDIFF_T, strlen (S)))
# else
/* Return the length of YYSTR.  */
static YYPTRDIFF_T
yystrlen (const char *yystr)
{
  YYPTRDIFF_T yylen;
  for (yylen = 0; yystr[yylen]; yylen++)
    continue;
  return yylen;
}
# endif
#endif

#ifndef yystpcpy
# if defined __GLIBC__ && defined _STRING_H && defined _GNU_SOURCE
#  define yystpcpy stpcpy
# else
/* Copy YYSRC to YYDEST, returning the address of the terminating '\0' in
   YYDEST.  */
static char *
yystpcpy (char *yydest, const char *yysrc)
{
  char *yyd = yydest;
  const char *yys = yysrc;

  while ((*yyd++ = *yys++) != '\0')
    continue;

  return yyd - 1;
}
# endif
#endif

#ifndef yytnamerr
/* Copy to YYRES the contents of YYSTR after stripping away unnecessary
   quotes and backslashes, so that it's suitable for yyerror.  The
   heuristic is that double-quoting is unnecessary unless the string
   contains an apostrophe, a comma, or backslash (other than
   backslash-backslash).  YYSTR is taken from yytname.  If YYRES is
   null, do not copy; instead, return the length of what the result
   would have been.  */
static YYPTRDIFF_T
yytnamerr (char *yyres, const char *yystr)
{
  if (*yystr == '"')
    {
      YYPTRDIFF_T yyn = 0;
      char const *yyp = yystr;
      for (;;)
        switch (*++yyp)
          {
          case '\'':
          case ',':
            goto do_not_strip_quotes;

          case '\\':
            if (*++yyp != '\\')
              goto do_not_strip_quotes;
            else
              goto append;

          append:
          default:
            if (yyres)
              yyres[yyn] = *yyp;
            yyn++;
            break;

          case '"':
            if (yyres)
              yyres[yyn] = '\0';
            return yyn;
          }
    do_not_strip_quotes: ;
    }

  if (yyres)
    return yystpcpy (yyres, yystr) - yyres;
  else
    return yystrlen (yystr);
}
#endif


static int
yy_syntax_error_arguments (const yypcontext_t *yyctx,
                           yysymbol_kind_t yyarg[], int yyargn)
{
  /* Actual size of YYARG. */
  int yycount = 0;
  /* There are many possibilities here to consider:
     - If this state is a consistent state with a default action, then
       the only way this function was invoked is if the default action
       is an error action.  In that case, don't check for expected
       tokens because there are none.
     - The only way there can be no lookahead present (in yychar) is if
       this state is a consistent state with a default action.  Thus,
       detecting the absence of a lookahead is sufficient to determine
       that there is no unexpected or expected token to report.  In that
       case, just report a simple "syntax error".
     - Don't assume there isn't a lookahead just because this state is a
       consistent state with a default action.  There might have been a
       previous inconsistent state, consistent state with a non-default
       action, or user semantic action that manipulated yychar.
     - Of course, the expected token list depends on states to have
       correct lookahead information, and it depends on the parser not
       to perform extra reductions after fetching a lookahead from the
       scanner and before detecting a syntax error.  Thus, state merging
       (from LALR or IELR) and default reductions corrupt the expected
       token list.  However, the list is correct for canonical LR with
       one exception: it will still contain any token that will not be
       accepted due to an error action in a later state.
  */
  if (yyctx->yytoken != YYSYMBOL_YYEMPTY)
    {
      int yyn;
      if (yyarg)
        yyarg[yycount] = yyctx->yytoken;
      ++yycount;
      yyn = yypcontext_expected_tokens (yyctx,
                                        yyarg ? yyarg + 1 : yyarg, yyargn - 1);
      if (yyn == YYENOMEM)
        return YYENOMEM;
      else
        yycount += yyn;
    }
  return yycount;
}

/* Copy into *YYMSG, which is of size *YYMSG_ALLOC, an error message
   about the unexpected token YYTOKEN for the state stack whose top is
   YYSSP.

   Return 0 if *YYMSG was successfully written.  Return -1 if *YYMSG is
   not large enough to hold the message.  In that case, also set
   *YYMSG_ALLOC to the required number of bytes.  Return YYENOMEM if the
   required number of bytes is too large to store.  */
static int
yysyntax_error (YYPTRDIFF_T *yymsg_alloc, char **yymsg,
                const yypcontext_t *yyctx)
{
  enum { YYARGS_MAX = 5 };
  /* Internationalized format string. */
  const char *yyformat = YY_NULLPTR;
  /* Arguments of yyformat: reported tokens (one for the "unexpected",
     one per "expected"). */
  yysymbol_kind_t yyarg[YYARGS_MAX];
  /* Cumulated lengths of YYARG.  */
  YYPTRDIFF_T yysize = 0;

  /* Actual size of YYARG. */
  int yycount = yy_syntax_error_arguments (yyctx, yyarg, YYARGS_MAX);
  if (yycount == YYENOMEM)
    return YYENOMEM;

  switch (yycount)
    {
#define YYCASE_(N, S)                       \
      case N:                               \
        yyformat = S;                       \
        break
    default: /* Avoid compiler warnings. */
      YYCASE_(0, YY_("syntax error"));
      YYCASE_(1, YY_("syntax error, unexpected %s"));
      YYCASE_(2, YY_("syntax error, unexpected %s, expecting %s"));
      YYCASE_(3, YY_("syntax error, unexpected %s, expecting %s or %s"));
      YYCASE_(4, YY_("syntax error, unexpected %s, expecting %s or %s or %s"));
      YYCASE_(5, YY_("syntax error, unexpected %s, expecting %s or %s or %s or %s"));
#undef YYCASE_
    }

  /* Compute error message size.  Don't count the "%s"s, but reserve
     room for the terminator.  */
  yysize = yystrlen (yyformat) - 2 * yycount + 1;
  {
    int yyi;
    for (yyi = 0; yyi < yycount; ++yyi)
      {
        YYPTRDIFF_T yysize1
          = yysize + yytnamerr (YY_NULLPTR, yytname[yyarg[yyi]]);
        if (yysize <= yysize1 && yysize1 <= YYSTACK_ALLOC_MAXIMUM)
          yysize = yysize1;
        else
          return YYENOMEM;
      }
  }

  if (*yymsg_alloc < yysize)
    {
      *yymsg_alloc = 2 * yysize;
      if (! (yysize <= *yymsg_alloc
             && *yymsg_alloc <= YYSTACK_ALLOC_MAXIMUM))
        *yymsg_alloc = YYSTACK_ALLOC_MAXIMUM;
      return -1;
    }

  /* Avoid sprintf, as that infringes on the user's name space.
     Don't have undefined behavior even if the translation
     produced a string with the wrong number of "%s"s.  */
  {
    char *yyp = *yymsg;
    int yyi = 0;
    while ((*yyp = *yyformat) != '\0')
      if (*yyp == '%' && yyformat[1] == 's' && yyi < yycount)
        {
          yyp += yytnamerr (yyp, yytname[yyarg[yyi++]]);
          yyformat += 2;
        }
      else
        {
          ++yyp;
          ++yyformat;
        }
  }
  return 0;
}


/*-----------------------------------------------.
| Release the memory associated to this symbol.  |
`-----------------------------------------------*/

static void
yydestruct (const char *yymsg,
            yysymbol_kind_t yykind, YYSTYPE *yyvaluep)
{
  YY_USE (yyvaluep);
  if (!yymsg)
    yymsg = "Deleting";
  YY_SYMBOL_PRINT (yymsg, yykind, yyvaluep, yylocationp);

  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  YY_USE (yykind);
  YY_IGNORE_MAYBE_UNINITIALIZED_END
}


/* Lookahead token kind.  */
int yychar;

/* The semantic value of the lookahead symbol.  */
YYSTYPE yylval;
/* Number of syntax errors so far.  */
int yynerrs;




/*----------.
| yyparse.  |
`----------*/

int
yyparse (void)
{
    yy_state_fast_t yystate = 0;
    /* Number of tokens to shift before error messages enabled.  */
    int yyerrstatus = 0;

    /* Refer to the stacks through separate pointers, to allow yyoverflow
       to reallocate them elsewhere.  */

    /* Their size.  */
    YYPTRDIFF_T yystacksize = YYINITDEPTH;

    /* The state stack: array, bottom, top.  */
    yy_state_t yyssa[YYINITDEPTH];
    yy_state_t *yyss = yyssa;
    yy_state_t *yyssp = yyss;

    /* The semantic value stack: array, bottom, top.  */
    YYSTYPE yyvsa[YYINITDEPTH];
    YYSTYPE *yyvs = yyvsa;
    YYSTYPE *yyvsp = yyvs;

  int yyn;
  /* The return value of yyparse.  */
  int yyresult;
  /* Lookahead symbol kind.  */
  yysymbol_kind_t yytoken = YYSYMBOL_YYEMPTY;
  /* The variables used to return semantic value and location from the
     action routines.  */
  YYSTYPE yyval;

  /* Buffer for error messages, and its allocated size.  */
  char yymsgbuf[128];
  char *yymsg = yymsgbuf;
  YYPTRDIFF_T yymsg_alloc = sizeof yymsgbuf;

#define YYPOPSTACK(N)   (yyvsp -= (N), yyssp -= (N))

  /* The number of symbols on the RHS of the reduced rule.
     Keep to zero when no symbol should be popped.  */
  int yylen = 0;

  YYDPRINTF ((stderr, "Starting parse\n"));

  yychar = YYEMPTY; /* Cause a token to be read.  */

  goto yysetstate;


/*------------------------------------------------------------.
| yynewstate -- push a new state, which is found in yystate.  |
`------------------------------------------------------------*/
yynewstate:
  /* In all cases, when you get here, the value and location stacks
     have just been pushed.  So pushing a state here evens the stacks.  */
  yyssp++;


/*--------------------------------------------------------------------.
| yysetstate -- set current state (the top of the stack) to yystate.  |
`--------------------------------------------------------------------*/
yysetstate:
  YYDPRINTF ((stderr, "Entering state %d\n", yystate));
  YY_ASSERT (0 <= yystate && yystate < YYNSTATES);
  YY_IGNORE_USELESS_CAST_BEGIN
  *yyssp = YY_CAST (yy_state_t, yystate);
  YY_IGNORE_USELESS_CAST_END
  YY_STACK_PRINT (yyss, yyssp);

  if (yyss + yystacksize - 1 <= yyssp)
#if !defined yyoverflow && !defined YYSTACK_RELOCATE
    YYNOMEM;
#else
    {
      /* Get the current used size of the three stacks, in elements.  */
      YYPTRDIFF_T yysize = yyssp - yyss + 1;

# if defined yyoverflow
      {
        /* Give user a chance to reallocate the stack.  Use copies of
           these so that the &'s don't force the real ones into
           memory.  */
        yy_state_t *yyss1 = yyss;
        YYSTYPE *yyvs1 = yyvs;

        /* Each stack pointer address is followed by the size of the
           data in use in that stack, in bytes.  This used to be a
           conditional around just the two extra args, but that might
           be undefined if yyoverflow is a macro.  */
        yyoverflow (YY_("memory exhausted"),
                    &yyss1, yysize * YYSIZEOF (*yyssp),
                    &yyvs1, yysize * YYSIZEOF (*yyvsp),
                    &yystacksize);
        yyss = yyss1;
        yyvs = yyvs1;
      }
# else /* defined YYSTACK_RELOCATE */
      /* Extend the stack our own way.  */
      if (YYMAXDEPTH <= yystacksize)
        YYNOMEM;
      yystacksize *= 2;
      if (YYMAXDEPTH < yystacksize)
        yystacksize = YYMAXDEPTH;

      {
        yy_state_t *yyss1 = yyss;
        union yyalloc *yyptr =
          YY_CAST (union yyalloc *,
                   YYSTACK_ALLOC (YY_CAST (YYSIZE_T, YYSTACK_BYTES (yystacksize))));
        if (! yyptr)
          YYNOMEM;
        YYSTACK_RELOCATE (yyss_alloc, yyss);
        YYSTACK_RELOCATE (yyvs_alloc, yyvs);
#  undef YYSTACK_RELOCATE
        if (yyss1 != yyssa)
          YYSTACK_FREE (yyss1);
      }
# endif

      yyssp = yyss + yysize - 1;
      yyvsp = yyvs + yysize - 1;

      YY_IGNORE_USELESS_CAST_BEGIN
      YYDPRINTF ((stderr, "Stack size increased to %ld\n",
                  YY_CAST (long, yystacksize)));
      YY_IGNORE_USELESS_CAST_END

      if (yyss + yystacksize - 1 <= yyssp)
        YYABORT;
    }
#endif /* !defined yyoverflow && !defined YYSTACK_RELOCATE */


  if (yystate == YYFINAL)
    YYACCEPT;

  goto yybackup;


/*-----------.
| yybackup.  |
`-----------*/
yybackup:
  /* Do appropriate processing given the current state.  Read a
     lookahead token if we need one and don't already have one.  */

  /* First try to decide what to do without reference to lookahead token.  */
  yyn = yypact[yystate];
  if (yypact_value_is_default (yyn))
    goto yydefault;

  /* Not known => get a lookahead token if don't already have one.  */

  /* YYCHAR is either empty, or end-of-input, or a valid lookahead.  */
  if (yychar == YYEMPTY)
    {
      YYDPRINTF ((stderr, "Reading a token\n"));
      yychar = yylex ();
    }

  if (yychar <= YYEOF)
    {
      yychar = YYEOF;
      yytoken = YYSYMBOL_YYEOF;
      YYDPRINTF ((stderr, "Now at end of input.\n"));
    }
  else if (yychar == YYerror)
    {
      /* The scanner already issued an error message, process directly
         to error recovery.  But do not keep the error token as
         lookahead, it is too special and may lead us to an endless
         loop in error recovery. */
      yychar = YYUNDEF;
      yytoken = YYSYMBOL_YYerror;
      goto yyerrlab1;
    }
  else
    {
      yytoken = YYTRANSLATE (yychar);
      YY_SYMBOL_PRINT ("Next token is", yytoken, &yylval, &yylloc);
    }

  /* If the proper action on seeing token YYTOKEN is to reduce or to
     detect an error, take that action.  */
  yyn += yytoken;
  if (yyn < 0 || YYLAST < yyn || yycheck[yyn] != yytoken)
    goto yydefault;
  yyn = yytable[yyn];
  if (yyn <= 0)
    {
      if (yytable_value_is_error (yyn))
        goto yyerrlab;
      yyn = -yyn;
      goto yyreduce;
    }

  /* Count tokens shifted since error; after three, turn off error
     status.  */
  if (yyerrstatus)
    yyerrstatus--;

  /* Shift the lookahead token.  */
  YY_SYMBOL_PRINT ("Shifting", yytoken, &yylval, &yylloc);
  yystate = yyn;
  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  *++yyvsp = yylval;
  YY_IGNORE_MAYBE_UNINITIALIZED_END

  /* Discard the shifted token.  */
  yychar = YYEMPTY;
  goto yynewstate;


/*-----------------------------------------------------------.
| yydefault -- do the default action for the current state.  |
`-----------------------------------------------------------*/
yydefault:
  yyn = yydefact[yystate];
  if (yyn == 0)
    goto yyerrlab;
  goto yyreduce;


/*-----------------------------.
| yyreduce -- do a reduction.  |
`-----------------------------*/
yyreduce:
  /* yyn is the number of a rule to reduce with.  */
  yylen = yyr2[yyn];

  /* If YYLEN is nonzero, implement the default value of the action:
     '$$ = $1'.

     Otherwise, the following line sets YYVAL to garbage.
     This behavior is undocumented and Bison
     users should not rely upon it.  Assigning to YYVAL
     unconditionally makes the parser a bit smaller, and it avoids a
     GCC warning that YYVAL may be used uninitialized.  */
  yyval = yyvsp[1-yylen];


  YY_REDUCE_PRINT (yyn);
  switch (yyn)
    {
  case 4: /* statement: expr ';'  */
#line 80 "parser.y"
                   {
                    printAST((yyvsp[-1].astnode_p),0);}
#line 1611 "parser.tab.c"
    break;

  case 6: /* expr: expr ',' assexp  */
#line 85 "parser.y"
                      {  struct astnode *n = malloc(1024);
                                
                        setupBinop(n,',',(yyvsp[-2].astnode_p),(yyvsp[0].astnode_p));
                                
                        (yyval.astnode_p)= n;

                    }
#line 1623 "parser.tab.c"
    break;

  case 7: /* primexp: IDENT  */
#line 96 "parser.y"
               { struct astnode *n = malloc(1024);
                 setupIdent(n,(yyvsp[0].string));
                 (yyval.astnode_p) = n;

                }
#line 1633 "parser.tab.c"
    break;

  case 8: /* primexp: NUMBER  */
#line 101 "parser.y"
               {struct astnode *n = malloc(1024);
                         setupNumber(n,(yyvsp[0].number));
                (yyval.astnode_p) = n;
                }
#line 1642 "parser.tab.c"
    break;

  case 9: /* primexp: CHARLIT  */
#line 105 "parser.y"
                {struct astnode *n = malloc(1024);
                         setupNumber(n,(yyvsp[0].number));
                (yyval.astnode_p) = n;
                }
#line 1651 "parser.tab.c"
    break;

  case 10: /* primexp: newString  */
#line 109 "parser.y"
                { struct astnode *n = malloc(1024);
                 setupString(n,(yyvsp[0].string));
                 (yyval.astnode_p) = n;
                 }
#line 1660 "parser.tab.c"
    break;

  case 11: /* primexp: '(' expr ')'  */
#line 113 "parser.y"
                   {(yyval.astnode_p) = (yyvsp[-1].astnode_p);}
#line 1666 "parser.tab.c"
    break;

  case 13: /* postexp: postexp '[' expr ']'  */
#line 117 "parser.y"
                           {  struct astnode *sub = malloc(1024);
                                //Need to add in a dereference AST node above the binop.
                                setupBinop(sub,'+',(yyvsp[-3].astnode_p),(yyvsp[-1].astnode_p));
                                struct astnode *n = malloc(1024);
                                setupGeneral(n, 0, sub);
                                
                                (yyval.astnode_p)= n;

                            }
#line 1680 "parser.tab.c"
    break;

  case 14: /* postexp: postexp '(' argexplist ')'  */
#line 126 "parser.y"
                                    {   struct astnode *n = malloc(1024);
                                        setupFunc(n,(yyvsp[-3].astnode_p),(yyvsp[-1].astnode_p));
                                        (yyval.astnode_p) = n;
                                        }
#line 1689 "parser.tab.c"
    break;

  case 15: /* postexp: postexp '.' IDENT  */
#line 132 "parser.y"
                            {struct astnode *n = malloc(1024);
                                setupSelect(n,0,(yyvsp[-2].astnode_p),(yyvsp[0].string));
                                (yyval.astnode_p)= n;
                                }
#line 1698 "parser.tab.c"
    break;

  case 16: /* postexp: postexp INDSEL IDENT  */
#line 136 "parser.y"
                            {struct astnode *n = malloc(1024);
                            //FIX THIS WITH THE EQUIVALENCY
                                setupSelect(n,1,(yyvsp[-2].astnode_p),(yyvsp[0].string));
                                (yyval.astnode_p)= n;
                                }
#line 1708 "parser.tab.c"
    break;

  case 17: /* postexp: postexp PLUSPLUS  */
#line 141 "parser.y"
                            {struct astnode *n = malloc(1024);
                            setupUnop(n,PLUSPLUS,(yyvsp[-1].astnode_p));
                            (yyval.astnode_p) = n;
                        }
#line 1717 "parser.tab.c"
    break;

  case 18: /* postexp: postexp MINUSMINUS  */
#line 145 "parser.y"
                            {struct astnode *n = malloc(1024);
                            setupUnop(n,MINUSMINUS,(yyvsp[-1].astnode_p));
                            (yyval.astnode_p) = n;
                        }
#line 1726 "parser.tab.c"
    break;

  case 19: /* argexplist: assexp  */
#line 153 "parser.y"
                        { struct astnode *n = malloc(1024);
                            setupFuncarg(n,(yyvsp[0].astnode_p),n);
                            n->funcarg.head = n;
                            (yyval.astnode_p) = n;
                            }
#line 1736 "parser.tab.c"
    break;

  case 20: /* argexplist: argexplist ',' assexp  */
#line 158 "parser.y"
                            {  struct astnode *n = malloc(1024);
                                
                                setupFuncarg(n,(yyvsp[0].astnode_p),(yyvsp[-2].astnode_p));
                                n->funcarg.argCount = (yyvsp[-2].astnode_p)->funcarg.argCount + 1;
                                n->funcarg.head = (yyvsp[-2].astnode_p)->funcarg.head;
                                (yyvsp[-2].astnode_p)->funcarg.next = n;
                                
                            (yyval.astnode_p)= n;

                    }
#line 1751 "parser.tab.c"
    break;

  case 22: /* castexp: '(' typename ')' castexp  */
#line 169 "parser.y"
                                {   struct astnode *n = malloc(1024);
                                    setupType(n,(yyvsp[-2].operator),(yyvsp[0].astnode_p));
                                    (yyval.astnode_p) = n;
                                }
#line 1760 "parser.tab.c"
    break;

  case 23: /* typename: CHAR  */
#line 174 "parser.y"
                {(yyval.operator) = CHAR;}
#line 1766 "parser.tab.c"
    break;

  case 24: /* typename: INT  */
#line 175 "parser.y"
            {(yyval.operator) = INT;}
#line 1772 "parser.tab.c"
    break;

  case 25: /* typename: LONG  */
#line 176 "parser.y"
            { (yyval.operator) = LONG;}
#line 1778 "parser.tab.c"
    break;

  case 26: /* typename: DOUBLE  */
#line 177 "parser.y"
                { (yyval.operator) = DOUBLE;}
#line 1784 "parser.tab.c"
    break;

  case 27: /* typename: FLOAT  */
#line 178 "parser.y"
            { (yyval.operator) = FLOAT;}
#line 1790 "parser.tab.c"
    break;

  case 28: /* unaryop: '+'  */
#line 182 "parser.y"
               {(yyval.operator) = '+';}
#line 1796 "parser.tab.c"
    break;

  case 29: /* unaryop: '-'  */
#line 183 "parser.y"
            {(yyval.operator) = '-';}
#line 1802 "parser.tab.c"
    break;

  case 30: /* unaryop: '~'  */
#line 184 "parser.y"
            {(yyval.operator) = '~';}
#line 1808 "parser.tab.c"
    break;

  case 31: /* unaryop: '!'  */
#line 185 "parser.y"
            {(yyval.operator) = '!';}
#line 1814 "parser.tab.c"
    break;

  case 33: /* unexp: PLUSPLUS unexp  */
#line 188 "parser.y"
                        {struct astnode *n = malloc(1024);
                            struct astnode *sub = malloc(1024);
                            struct number tempNum;
                            tempNum.value.intVal = 1;
                            tempNum.type = 0;
                            setupNumber(sub,tempNum);
                            setupAssignment(n,PLUSEQ, (yyvsp[0].astnode_p),sub );
                            (yyval.astnode_p) = n;
                        }
#line 1828 "parser.tab.c"
    break;

  case 34: /* unexp: MINUSMINUS unexp  */
#line 197 "parser.y"
                        {struct astnode *n = malloc(1024);
                        struct astnode *sub = malloc(1024);
                        struct number tempNum;
                        tempNum.value.intVal = 1;
                        tempNum.type = 0;
                        setupNumber(sub,tempNum);
                        setupAssignment(n,MINUSEQ, (yyvsp[0].astnode_p),sub );
                        (yyval.astnode_p) = n;
                        }
#line 1842 "parser.tab.c"
    break;

  case 35: /* unexp: unaryop castexp  */
#line 206 "parser.y"
                        {struct astnode *n = malloc(1024);
                        setupUnop(n,(yyvsp[-1].operator),(yyvsp[0].astnode_p));
                        (yyval.astnode_p) = n;
                        }
#line 1851 "parser.tab.c"
    break;

  case 36: /* unexp: '&' castexp  */
#line 210 "parser.y"
                        { struct astnode *n = malloc(1024);
                            setupGeneral(n,1,(yyvsp[0].astnode_p));
                            (yyval.astnode_p) = n;
                            }
#line 1860 "parser.tab.c"
    break;

  case 37: /* unexp: '*' castexp  */
#line 214 "parser.y"
                        { struct astnode *n = malloc(1024);
                            setupGeneral(n,0,(yyvsp[0].astnode_p));
                            (yyval.astnode_p)= n;
                            }
#line 1869 "parser.tab.c"
    break;

  case 38: /* unexp: SIZEOF unexp  */
#line 218 "parser.y"
                    {struct astnode *n = malloc(1024);
                        setupGeneral(n,2,(yyvsp[0].astnode_p));
                        (yyval.astnode_p) = n;
                        }
#line 1878 "parser.tab.c"
    break;

  case 39: /* unexp: SIZEOF '(' typename ')'  */
#line 222 "parser.y"
                            {struct astnode *n = malloc(1024);
                                struct astnode *type = malloc(1024);
                                setupType(type,(yyvsp[-1].operator),NULL);
                            setupGeneral(n,2,type);
                            (yyval.astnode_p) = n;
                            }
#line 1889 "parser.tab.c"
    break;

  case 41: /* multexp: multexp '*' castexp  */
#line 230 "parser.y"
                            {  struct astnode *n = malloc(1024);
                                
                                setupBinop(n,'*',(yyvsp[-2].astnode_p),(yyvsp[0].astnode_p));
                                
                                (yyval.astnode_p)= n;

                            }
#line 1901 "parser.tab.c"
    break;

  case 42: /* multexp: multexp '/' castexp  */
#line 237 "parser.y"
                            {  struct astnode *n = malloc(1024);
                                
                                setupBinop(n,'/',(yyvsp[-2].astnode_p),(yyvsp[0].astnode_p));
                                
                                (yyval.astnode_p)= n;

                            }
#line 1913 "parser.tab.c"
    break;

  case 43: /* multexp: multexp '%' castexp  */
#line 244 "parser.y"
                            {  struct astnode *n = malloc(1024);
                                
                                setupBinop(n,'%',(yyvsp[-2].astnode_p),(yyvsp[0].astnode_p));
                                
                                (yyval.astnode_p)= n;

                            }
#line 1925 "parser.tab.c"
    break;

  case 45: /* addexp: addexp '+' multexp  */
#line 253 "parser.y"
                            {  struct astnode *n = malloc(1024);
                                
                                setupBinop(n,'+',(yyvsp[-2].astnode_p),(yyvsp[0].astnode_p));
                                
                                (yyval.astnode_p)= n;

                            }
#line 1937 "parser.tab.c"
    break;

  case 46: /* addexp: addexp '-' multexp  */
#line 260 "parser.y"
                            {  struct astnode *n = malloc(1024);
                                
                                setupBinop(n,'-',(yyvsp[-2].astnode_p),(yyvsp[0].astnode_p));
                                
                                (yyval.astnode_p)= n;

                            }
#line 1949 "parser.tab.c"
    break;

  case 48: /* shiftexp: shiftexp SHL addexp  */
#line 269 "parser.y"
                           {  struct astnode *n = malloc(1024);
                                
                                setupBinop(n,SHL,(yyvsp[-2].astnode_p),(yyvsp[0].astnode_p));
                                
                                (yyval.astnode_p)= n;

                            }
#line 1961 "parser.tab.c"
    break;

  case 49: /* shiftexp: shiftexp SHR addexp  */
#line 276 "parser.y"
                            {  struct astnode *n = malloc(1024);
                                
                                setupBinop(n,SHR,(yyvsp[-2].astnode_p),(yyvsp[0].astnode_p));
                                
                                (yyval.astnode_p)= n;

                            }
#line 1973 "parser.tab.c"
    break;

  case 51: /* relexp: relexp '<' shiftexp  */
#line 285 "parser.y"
                          { struct astnode *n = malloc(1024);
                            setupCompop(n,'<', (yyvsp[-2].astnode_p),(yyvsp[0].astnode_p));
                            (yyval.astnode_p) = n;

                            }
#line 1983 "parser.tab.c"
    break;

  case 52: /* relexp: relexp '>' shiftexp  */
#line 290 "parser.y"
                            { struct astnode *n = malloc(1024);
                            setupCompop(n,'>', (yyvsp[-2].astnode_p),(yyvsp[0].astnode_p));
                            (yyval.astnode_p) = n;

                            }
#line 1993 "parser.tab.c"
    break;

  case 53: /* relexp: relexp LTEQ shiftexp  */
#line 295 "parser.y"
                            { struct astnode *n = malloc(1024);
                            setupCompop(n,LTEQ, (yyvsp[-2].astnode_p),(yyvsp[0].astnode_p));
                            (yyval.astnode_p) = n;

                            }
#line 2003 "parser.tab.c"
    break;

  case 54: /* relexp: relexp GTEQ shiftexp  */
#line 300 "parser.y"
                            { struct astnode *n = malloc(1024);
                            setupCompop(n,GTEQ, (yyvsp[-2].astnode_p),(yyvsp[0].astnode_p));
                            (yyval.astnode_p) = n;

                            }
#line 2013 "parser.tab.c"
    break;

  case 56: /* eqexp: eqexp EQEQ relexp  */
#line 307 "parser.y"
                        { struct astnode *n = malloc(1024);
                            setupCompop(n,EQEQ, (yyvsp[-2].astnode_p),(yyvsp[0].astnode_p));
                            (yyval.astnode_p) = n;

                            }
#line 2023 "parser.tab.c"
    break;

  case 57: /* eqexp: eqexp NOTEQ relexp  */
#line 312 "parser.y"
                            { struct astnode *n = malloc(1024);
                            setupCompop(n,NOTEQ, (yyvsp[-2].astnode_p),(yyvsp[0].astnode_p));
                            (yyval.astnode_p) = n;

                            }
#line 2033 "parser.tab.c"
    break;

  case 59: /* andexp: andexp '&' eqexp  */
#line 319 "parser.y"
                        {  struct astnode *n = malloc(1024);
                                
                                setupBinop(n,'&',(yyvsp[-2].astnode_p),(yyvsp[0].astnode_p));
                                
                                (yyval.astnode_p)= n;

                            }
#line 2045 "parser.tab.c"
    break;

  case 61: /* exorexp: exorexp '^' andexp  */
#line 328 "parser.y"
                            {  struct astnode *n = malloc(1024);
                                
                                setupBinop(n,'^',(yyvsp[-2].astnode_p),(yyvsp[0].astnode_p));
                                
                                (yyval.astnode_p)= n;

                            }
#line 2057 "parser.tab.c"
    break;

  case 63: /* inorexp: inorexp '|' exorexp  */
#line 337 "parser.y"
                            {  struct astnode *n = malloc(1024);
                                
                                setupBinop(n,'|',(yyvsp[-2].astnode_p),(yyvsp[0].astnode_p));
                                
                                (yyval.astnode_p)= n;

                            }
#line 2069 "parser.tab.c"
    break;

  case 65: /* logandexp: logandexp LOGAND inorexp  */
#line 346 "parser.y"
                                {  struct astnode *n = malloc(1024);
                                
                                setupLogop(n,LOGAND,(yyvsp[-2].astnode_p),(yyvsp[0].astnode_p));
                                
                                (yyval.astnode_p)= n;

                            }
#line 2081 "parser.tab.c"
    break;

  case 67: /* logorexp: logorexp LOGOR logandexp  */
#line 355 "parser.y"
                                {  struct astnode *n = malloc(1024);
                                
                                setupLogop(n,LOGOR,(yyvsp[-2].astnode_p),(yyvsp[0].astnode_p));
                                
                                (yyval.astnode_p)= n;

                            }
#line 2093 "parser.tab.c"
    break;

  case 69: /* condexp: logorexp '?' expr ':' condexp  */
#line 364 "parser.y"
                                    {  struct astnode *n = malloc(1024);
                                        
                                        setupTernary(n,(yyvsp[-4].astnode_p),(yyvsp[-2].astnode_p),(yyvsp[0].astnode_p));
                                        
                                        (yyval.astnode_p)= n;

                                    }
#line 2105 "parser.tab.c"
    break;

  case 71: /* assexp: unexp assop assexp  */
#line 373 "parser.y"
                            {  struct astnode *n = malloc(1024);
                                        
                                setupAssignment(n,(yyvsp[-1].operator),(yyvsp[-2].astnode_p),(yyvsp[0].astnode_p));
                                        
                                (yyval.astnode_p)= n;

                            }
#line 2117 "parser.tab.c"
    break;

  case 72: /* assop: '='  */
#line 382 "parser.y"
           {(yyval.operator) = '=';}
#line 2123 "parser.tab.c"
    break;

  case 73: /* assop: TIMESEQ  */
#line 383 "parser.y"
              {(yyval.operator) = TIMESEQ;}
#line 2129 "parser.tab.c"
    break;

  case 74: /* assop: DIVEQ  */
#line 384 "parser.y"
            {(yyval.operator) = DIVEQ;}
#line 2135 "parser.tab.c"
    break;

  case 75: /* assop: MODEQ  */
#line 385 "parser.y"
            {(yyval.operator) = MODEQ;}
#line 2141 "parser.tab.c"
    break;

  case 76: /* assop: PLUSEQ  */
#line 386 "parser.y"
             {(yyval.operator) = PLUSEQ;}
#line 2147 "parser.tab.c"
    break;

  case 77: /* assop: MINUSEQ  */
#line 387 "parser.y"
                {(yyval.operator) = MINUSEQ;}
#line 2153 "parser.tab.c"
    break;

  case 78: /* assop: SHLEQ  */
#line 388 "parser.y"
            { (yyval.operator) = SHLEQ;}
#line 2159 "parser.tab.c"
    break;

  case 79: /* assop: SHREQ  */
#line 389 "parser.y"
            { (yyval.operator) = SHREQ;}
#line 2165 "parser.tab.c"
    break;

  case 80: /* assop: ANDEQ  */
#line 390 "parser.y"
            {(yyval.operator) = ANDEQ;}
#line 2171 "parser.tab.c"
    break;

  case 81: /* assop: XOREQ  */
#line 391 "parser.y"
            {(yyval.operator) = XOREQ;}
#line 2177 "parser.tab.c"
    break;

  case 82: /* assop: OREQ  */
#line 392 "parser.y"
            {(yyval.operator) = OREQ;}
#line 2183 "parser.tab.c"
    break;


#line 2187 "parser.tab.c"

      default: break;
    }
  /* User semantic actions sometimes alter yychar, and that requires
     that yytoken be updated with the new translation.  We take the
     approach of translating immediately before every use of yytoken.
     One alternative is translating here after every semantic action,
     but that translation would be missed if the semantic action invokes
     YYABORT, YYACCEPT, or YYERROR immediately after altering yychar or
     if it invokes YYBACKUP.  In the case of YYABORT or YYACCEPT, an
     incorrect destructor might then be invoked immediately.  In the
     case of YYERROR or YYBACKUP, subsequent parser actions might lead
     to an incorrect destructor call or verbose syntax error message
     before the lookahead is translated.  */
  YY_SYMBOL_PRINT ("-> $$ =", YY_CAST (yysymbol_kind_t, yyr1[yyn]), &yyval, &yyloc);

  YYPOPSTACK (yylen);
  yylen = 0;

  *++yyvsp = yyval;

  /* Now 'shift' the result of the reduction.  Determine what state
     that goes to, based on the state we popped back to and the rule
     number reduced by.  */
  {
    const int yylhs = yyr1[yyn] - YYNTOKENS;
    const int yyi = yypgoto[yylhs] + *yyssp;
    yystate = (0 <= yyi && yyi <= YYLAST && yycheck[yyi] == *yyssp
               ? yytable[yyi]
               : yydefgoto[yylhs]);
  }

  goto yynewstate;


/*--------------------------------------.
| yyerrlab -- here on detecting error.  |
`--------------------------------------*/
yyerrlab:
  /* Make sure we have latest lookahead translation.  See comments at
     user semantic actions for why this is necessary.  */
  yytoken = yychar == YYEMPTY ? YYSYMBOL_YYEMPTY : YYTRANSLATE (yychar);
  /* If not already recovering from an error, report this error.  */
  if (!yyerrstatus)
    {
      ++yynerrs;
      {
        yypcontext_t yyctx
          = {yyssp, yytoken};
        char const *yymsgp = YY_("syntax error");
        int yysyntax_error_status;
        yysyntax_error_status = yysyntax_error (&yymsg_alloc, &yymsg, &yyctx);
        if (yysyntax_error_status == 0)
          yymsgp = yymsg;
        else if (yysyntax_error_status == -1)
          {
            if (yymsg != yymsgbuf)
              YYSTACK_FREE (yymsg);
            yymsg = YY_CAST (char *,
                             YYSTACK_ALLOC (YY_CAST (YYSIZE_T, yymsg_alloc)));
            if (yymsg)
              {
                yysyntax_error_status
                  = yysyntax_error (&yymsg_alloc, &yymsg, &yyctx);
                yymsgp = yymsg;
              }
            else
              {
                yymsg = yymsgbuf;
                yymsg_alloc = sizeof yymsgbuf;
                yysyntax_error_status = YYENOMEM;
              }
          }
        yyerror (yymsgp);
        if (yysyntax_error_status == YYENOMEM)
          YYNOMEM;
      }
    }

  if (yyerrstatus == 3)
    {
      /* If just tried and failed to reuse lookahead token after an
         error, discard it.  */

      if (yychar <= YYEOF)
        {
          /* Return failure if at end of input.  */
          if (yychar == YYEOF)
            YYABORT;
        }
      else
        {
          yydestruct ("Error: discarding",
                      yytoken, &yylval);
          yychar = YYEMPTY;
        }
    }

  /* Else will try to reuse lookahead token after shifting the error
     token.  */
  goto yyerrlab1;


/*---------------------------------------------------.
| yyerrorlab -- error raised explicitly by YYERROR.  |
`---------------------------------------------------*/
yyerrorlab:
  /* Pacify compilers when the user code never invokes YYERROR and the
     label yyerrorlab therefore never appears in user code.  */
  if (0)
    YYERROR;
  ++yynerrs;

  /* Do not reclaim the symbols of the rule whose action triggered
     this YYERROR.  */
  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);
  yystate = *yyssp;
  goto yyerrlab1;


/*-------------------------------------------------------------.
| yyerrlab1 -- common code for both syntax error and YYERROR.  |
`-------------------------------------------------------------*/
yyerrlab1:
  yyerrstatus = 3;      /* Each real token shifted decrements this.  */

  /* Pop stack until we find a state that shifts the error token.  */
  for (;;)
    {
      yyn = yypact[yystate];
      if (!yypact_value_is_default (yyn))
        {
          yyn += YYSYMBOL_YYerror;
          if (0 <= yyn && yyn <= YYLAST && yycheck[yyn] == YYSYMBOL_YYerror)
            {
              yyn = yytable[yyn];
              if (0 < yyn)
                break;
            }
        }

      /* Pop the current state because it cannot handle the error token.  */
      if (yyssp == yyss)
        YYABORT;


      yydestruct ("Error: popping",
                  YY_ACCESSING_SYMBOL (yystate), yyvsp);
      YYPOPSTACK (1);
      yystate = *yyssp;
      YY_STACK_PRINT (yyss, yyssp);
    }

  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  *++yyvsp = yylval;
  YY_IGNORE_MAYBE_UNINITIALIZED_END


  /* Shift the error token.  */
  YY_SYMBOL_PRINT ("Shifting", YY_ACCESSING_SYMBOL (yyn), yyvsp, yylsp);

  yystate = yyn;
  goto yynewstate;


/*-------------------------------------.
| yyacceptlab -- YYACCEPT comes here.  |
`-------------------------------------*/
yyacceptlab:
  yyresult = 0;
  goto yyreturnlab;


/*-----------------------------------.
| yyabortlab -- YYABORT comes here.  |
`-----------------------------------*/
yyabortlab:
  yyresult = 1;
  goto yyreturnlab;


/*-----------------------------------------------------------.
| yyexhaustedlab -- YYNOMEM (memory exhaustion) comes here.  |
`-----------------------------------------------------------*/
yyexhaustedlab:
  yyerror (YY_("memory exhausted"));
  yyresult = 2;
  goto yyreturnlab;


/*----------------------------------------------------------.
| yyreturnlab -- parsing is finished, clean up and return.  |
`----------------------------------------------------------*/
yyreturnlab:
  if (yychar != YYEMPTY)
    {
      /* Make sure we have latest lookahead translation.  See comments at
         user semantic actions for why this is necessary.  */
      yytoken = YYTRANSLATE (yychar);
      yydestruct ("Cleanup: discarding lookahead",
                  yytoken, &yylval);
    }
  /* Do not reclaim the symbols of the rule whose action triggered
     this YYABORT or YYACCEPT.  */
  YYPOPSTACK (yylen);
  YY_STACK_PRINT (yyss, yyssp);
  while (yyssp != yyss)
    {
      yydestruct ("Cleanup: popping",
                  YY_ACCESSING_SYMBOL (+*yyssp), yyvsp);
      YYPOPSTACK (1);
    }
#ifndef yyoverflow
  if (yyss != yyssa)
    YYSTACK_FREE (yyss);
#endif
  if (yymsg != yymsgbuf)
    YYSTACK_FREE (yymsg);
  return yyresult;
}

#line 397 "parser.y"

void printAST(struct astnode* n, int indent){
        char temp[1000];
        strcpy(temp, "");
        for (int i = 0; i<indent; i++){
            printf("\t");
        }
        switch(n->nodetype){
            case 0:  
                if(n->binop.operator > 255){
                    
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
                if(n->num.numtype <6){
                    printf("CONSTANT: (type = %s)%lld\n",stringFromType(n->num.numtype),n->num.number); break;
                }
                else if (n->num.numtype<9){
                    printf("CONSTANT: (type = %s)%Lg\n",stringFromType(n->num.numtype),n->num.realNum); break;
                }
                else if (n->num.numtype == 9){
                    printf("CONSTANT: (type = %s)%c\n",stringFromType(n->num.numtype),n->num.number); break;
                }
                break;
            case 2:
                printf("IDENT %s\n", n->ident.ident); break;
            case 3: 
                printf("STRING %s\n", n->string.string); break;
            case 4:
                printf("TERNARY OP, IF\n");
                printAST(n->ternop.opIf,indent+1);
                printf("THEN\n");
                printAST(n->ternop.opThen,indent+1);
                printf("ELSE\n");
                printAST(n->ternop.opElse,indent+1);
                break;
            case 5:
                
                switch(n->logop.operator){
                    case LOGAND: strcpy(temp, "&&"); break;
                    case LOGOR: strcpy(temp, "||"); break;
                }
                printf("LOGICAL OP %s\n", temp);
                printAST(n->logop.left, indent+1);
                printAST(n->logop.right, indent+1);
                break;
            case 6:
                
                if(n->assop.assType == '=')
                {
                    printf("ASSIGNMENT\n");
                    
                }
                else{
                    switch(n->assop.assType){
                        case TIMESEQ: strcpy(temp,"*"); break;
                        case DIVEQ: strcpy(temp,"/"); break;
                        case MODEQ: strcpy(temp,"%"); break;
                        case PLUSEQ : strcpy(temp,"+"); break;
                        case MINUSEQ : strcpy(temp,"-"); break;
                        case SHLEQ: strcpy(temp,"<<"); break;
                        case SHREQ: strcpy(temp,">>"); break;
                        case ANDEQ: strcpy(temp,"&"); break;
                        case XOREQ: strcpy(temp,"^"); break;
                        case OREQ: strcpy(temp,"|"); break;
                    }
                    printf("ASSIGNMENT COMPOUND (%s)\n", temp);
                }
                printAST(n->assop.left, indent+1);
                printAST(n->assop.right, indent+1);
                break;
            case 7:
                if(n->unop.operator <= 255){
                    printf("UNARY OP %c\n",n->unop.operator);
                }
                else{
                   switch(n->unop.operator){
                    case PLUSPLUS: strcpy(temp, "POSTINC"); break;
                    case MINUSMINUS: strcpy(temp, "POSTDEC"); break;
                   } 
                   printf("UNARY OP %s\n", temp);
                }
                

                printAST(n->unop.operand,indent+1);
                break;
            case 8: 
                if(n->compop.operator<=255){
                    printf("COMPARISON OP %c\n",n->compop.operator);
                }
                else{
                    switch(n->compop.operator){
                        case LTEQ: strcpy(temp,"<="); break;
                        case GTEQ: strcpy(temp,">="); break;
                        case EQEQ: strcpy(temp,"=="); break;
                        case NOTEQ: strcpy(temp,"!="); break;
                    }
                    printf("COMPARISON OP %s\n",temp);
                }
                printAST(n->compop.left, indent+1);
                printAST(n->compop.right,indent+1);

                break;
            case 9: 
                switch(n->general.genType){
                    case 0: printf("DEREF\n"); break;
                    case 1: printf("ADDRESSOF\n"); break;
                    case 2: printf("SIZEOF\n"); break;
                }
                printAST(n->general.next, indent + 1);
                break;
            case 10:
                switch(n->select.indirectFlag){
                    case 0: printf("SELECT, MEMBER %s\n", n->select.member); break;
                    case 1: printf("INDIRECT SELECT, MEMBER %s\n", n->select.member); break;
                }
                printAST(n->select.parent,indent+1);
                break;
            case 11: 
                switch(n->type.type){
                    case CHAR: strcpy(temp, "char"); break;
                    case INT: strcpy(temp, "int"); break;
                    case LONG: strcpy(temp, "long"); break;
                    case DOUBLE: strcpy(temp, "double"); break;
                    case FLOAT: strcpy(temp, "float"); break;
                }
                printf("TYPE %s\n", temp);
                
                if(n->type.next != NULL){
                    
                    printAST(n->type.next, indent + 1);
                }
                break;
            case 13:    
                printf("FUNCTION CALL,%i arguments\n",n->func.args->funcarg.argCount);
                printAST(n->func.name, indent + 1);
                int i;
                i = 1;
                struct astnode *copy = n->func.args->funcarg.head;
                while (copy!= NULL){
                    printf("arg #%i=\n",i);
                    printAST(copy->funcarg.current,indent+1);
                    copy = copy->funcarg.next;
                    i++;
                }
                break;




                break;
            
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
        n->logop.operator = operator;
        n->logop.left = left;
        n->logop.right = right;
        
}
void setupNumber(struct astnode *n,struct number number){
        
        n->nodetype = 1;
        n->num.numtype = number.type;
        if(number.type<6){
            n->num.number = number.value.intVal;
        }
        else if (number.type<9 ){
            n->num.realNum = number.value.realVal;
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
void setupAssignment(struct astnode *n, int operator,struct astnode* left, struct astnode* right){
        
        n->nodetype = 6;
        n->assop.assType = operator;
        n->assop.left = left;
        n->assop.right = right;
        
}
void setupUnop(struct astnode *n, int operator,struct astnode* operand){
        
        n->nodetype = 7;
        n->unop.operator = operator;
        n->unop.operand = operand;
       
        
}
void setupCompop(struct astnode *n, int operator,struct astnode* left, struct astnode* right){
        
        n->nodetype = 8;
        n->compop.operator = operator;
        n->compop.left = left;
        n->compop.right = right;
        
}
void setupGeneral(struct astnode *n, int type, struct astnode *sub){
    n->nodetype = 9;
    n->general.genType = type;
    n->general.next = sub;
}
void setupSelect(struct astnode *n, int flag, struct astnode *parent, char* member){
    n->nodetype = 10;
    n->select.indirectFlag = flag;
    n->select.parent = parent;
    n->select.member = strdup(member);
}
void setupType(struct astnode *n, int type, struct astnode *next){
    n->nodetype = 11;
    n->type.type = type;
    n->type.next = next;
}
void setupFuncarg(struct astnode *n, struct astnode *current, struct astnode* head){
    n->nodetype = 12;
    n->funcarg.current = current;
    n->funcarg.next = NULL;
    //n->funcarg.head = head->funcarg.head;
    n->funcarg.argCount = 1;
}
void setupFunc(struct astnode *n, struct astnode *name, struct astnode *args){
    n->nodetype = 13;
    n->func.name = name;
    n->func.args = args;
}
int main(){
    int t;
       yyparse();



}
