%option noyywrap
%{
#include "tokens-manual.h"
#include <math.h>
#include <ctype.h>
#include <string.h>
#define INTLONG 500
#define LLU 501
#define newline 600
#define PUNCTUATION 601
char* yylval;
char* placeholder;
char* name = "stdin";
int isFloat=0;
int line = 1;
%}
%x STRING CHAR

DEC [1-9][0-9]*
E [\e][\+-]?{DEC}+
P [\p][\+-]?{DEC}+
FLOAT [0-9]+\.[0-9]*
HEXDIGIT   [0-9a-fA-F]
OCTALDIGIT      [0-7]

HEX     0[xX]{HEXDIGIT}+
OCTAL   0{OCTALDIGIT}*
%%

[a-z|A-Z]+\.c   {yylval = strdup(yytext); return NAME;}
<INITIAL>\L?\" {BEGIN(STRING);placeholder= malloc(sizeof(char));sprintf(placeholder,"");}
<INITIAL>\L?\' {BEGIN(CHAR);placeholder= malloc(sizeof(char));sprintf(placeholder,"");}

<STRING,CHAR>\\['|"|\\|?] {strcat(placeholder,&yytext[1]);}
<STRING,CHAR>\\[0|a|b|f|n|r|t|v] {strcat(placeholder, yytext);}
<STRING,CHAR>\\{OCTALDIGIT}{1,3} {long temp = strtol(yytext+1,NULL,8);char* storage=malloc(sizeof(char));
        if(temp > 255){
                fprintf("%s:%d:Hex escape sequence %s out of range",name,line); 
                temp = 255;
        }
        if(isprint(temp)==0){
                sprintf(storage,"\\%03o",temp);
        }
        else{
                sprintf(storage,"%c",temp);
        }
        strcat(placeholder,storage);free(storage);}

<STRING,CHAR>\\x{HEXDIGIT}+ {long temp = strtol(yytext+2,NULL,16);char* storage=malloc(sizeof(char));
        if(temp > 255){
                fprintf("%s:%d:Hex escape sequence %s out of range",name,line); 
                temp = 255;
        }
        if(isprint(temp)==0){
                sprintf(storage,"\\%03o",temp);
        }
        else{
                sprintf(storage,"%c",temp);
        }
        strcat(placeholder,storage);free(storage);}
<STRING>[^\"\\\n\0\a\b\f\n\r\t\v]+ {strcat(placeholder, yytext);}
<CHAR>[^\'\"\\\n\0\a\b\f\n\r\t\v]+ {strcat(placeholder, yytext);}
<CHAR>\' {BEGIN(INITIAL);
        if(strlen(placeholder) >1){
                fprintf("%s:%d:WARNING:Unsupported multibyte character literal truncated to first byte \n",name,line); 
                placeholder[1] = '\0';
        }
        yylval = strdup(placeholder); free(placeholder);return CHAR;}
<STRING>\" {BEGIN(INITIAL);yylval = strdup(placeholder); free(placeholder);return STRING;}

-\> {return INDSEL;}
\<\< {return SHL;}
\>\> {return SHR;}
<INITIAL>{HEX}[u|U]?[l|L]{0,2}{P}?[fF]? {
        char * end;
        long temp = strtol(yytext+2,&end,16);
        char* storage= malloc(sizeof(char));
        sprintf(storage,"%ld",temp);
        strcat(storage,end);yylval =strdup(storage);
        free(storage);
        return NUMBER;}
<INITIAL>{DEC}[u|U]?[l|L]{0,2}({E}|{P})?[fF]? {yylval = strdup(yytext);return NUMBER;}
<INITIAL>{OCTAL}[u|U]?[l|L]{0,2}({E}|{P})?[fF]?        {
        char * end;
        long temp = strtol(yytext,&end,8);
        char* storage= malloc(1024);
        sprintf(storage,"%ld",temp);
        strcat(storage,end);
        yylval =strdup(storage);
        free(storage);return NUMBER;}
{FLOAT}[l|L]?{E}?      {yylval = strdup(yytext);isFloat = 1; return NUMBER; }   
<INITIAL>\+\+ {return PLUSPLUS;}
<INITIAL>-- {return MINUSMINUS;}
<INITIAL>\<= {return LTEQ;}
<INITIAL>\>= {return GTEQ;}
<INITIAL>== {return EQEQ;}
<INITIAL>\!= {return NOTEQ;}
<INITIAL>&& {return LOGAND;}
<INITIAL>\|\| {return LOGOR;}
<INITIAL>\.\.\. {return ELLIPSIS;}
\*= {return TIMESEQ;}
\/= {return DIVEQ;}
%= {return MODEQ;}
\+= {return PLUSEQ;}
-= {return MINUSEQ;}
\<\<= {return SHLEQ;}
\>\>= {return SHREQ;}
\|= {return OREQ;}
&= {return ANDEQ;}
\^= {return XOREQ;}
auto   {return AUTO;}
break  {return BREAK;}
case  {return CASE;}
char {return CHAR;}
const {return CONST;}
continue {return CONTINUE;}
default {return DEFAULT;}
do {return DO;}
double {return DOUBLE;}
else {return ELSE;}
enum {return ENUM;}
extern {return EXTERN;}
float {return FLOAT;}
for {return FOR;}
goto {return GOTO;}
if {return IF;}
inline {return INLINE;}
int {return INT;}
long {return LONG;}
register {return REGISTER;}
restrict {return RESTRICT;}
return {return RETURN;}
short {return SHORT;}
signed {return SIGNED;}
sizeof {return SIZEOF;}
static {return STATIC;}
struct {return STRUCT;}
switch {return SWITCH;}
typedef {return TYPEDEF;}
union {return UNION;}
unsigned {return UNSIGNED;}
void    {return VOID;}
volatile {return VOLATILE;}
while {return WHILE;}
_Bool {return _BOOL;}
_Complex {return _COMPLEX;}
_Imaginary {return _IMAGINARY;}
\n      {line = line + 1;}
<INITIAL>[\.\+\-\;\!\?\:\,\@\#\$\%\*\&\(\)\[\]\{\}\^\~\|\<\>\`\\\/] {yylval = strdup(yytext);return PUNCTUATION;}
<INITIAL>[a-z|A-Z|_][a-z|A-Z|0-9|_]* {yylval = strdup(yytext); return IDENT;}
.       {fprintf(stderr, "Error: Unknown token %s\n", yytext);}

%%
main(){
        int t;
        yylval = malloc(sizeof(float));
        
        char* name = "stdin";
        printf("File name is %s\n", __FILE__);
        while (t = yylex())
        {
                switch(t)
                        {
                                case NAME: printf("Name is %s\n", yylval); name = yylval; break;
                                
                                case INDSEL: printf("%s\t\%d\tINDSEL\n",name,line); break;
                                case IDENT:printf("%s\t%d\tIDENT\t%s\n",name,line,yylval); break;
                                case CHAR:  printf("%s\t%d\tCHARLITERAL\t%s\n",name,line,yylval); break;
                                case STRING: printf("%s\t%d\tSTRING\t%s\n",name,line,yylval); break;
                                case PUNCTUATION: printf("%s\t%d\t%s\n",name,line,yylval); break;
                                case SHL:printf("%s\t%d\tSHL\n", name, line); break;
                                case SHR: printf("%s\t%d\tSHR\n", name, line); break;
                                
                                case PLUSPLUS: printf("%s\t%d\tPLUSPLUS\n", name, line); break;
                                case MINUSMINUS:printf("%s\t%d\tMINUSMINUS\n", name, line); break;
                                case LTEQ: printf("%s\t%d\tLTEQ\n", name, line); break;
                                case GTEQ: printf("%s\t%d\tGTEQ\n", name, line); break;
                                case EQEQ: printf("%s\t%d\tEQEQ\n", name, line); break;
                                case NOTEQ: printf("%s\t%d\tNOTEQ\n", name, line); break;
                                case LOGAND: printf("%s\t%d\tLOGAND\n", name, line); break;
                                case LOGOR: printf("%s\t%d\tLOGOR\n", name, line); break;
                                case ELLIPSIS: printf("%s\t%d\tELLIPSIS\n", name, line); break;
                                case TIMESEQ: printf("%s\t%d\tTIMESEQ\n", name, line); break;
                                case DIVEQ: printf("%s\t%d\tDIVEQ\n", name, line); break;
                                case MODEQ:printf("%s\t%d\tMODEQ\n", name, line); break;
                                case PLUSEQ: printf("%s\t%d\tPLUSEQ\n", name, line); break;
                                case MINUSEQ: printf("%s\t%d\tMINUSEQ\n", name, line); break;
                                case SHLEQ: printf("%s\t%d\tSHLEQ\n", name, line); break;
                                case SHREQ: printf("%s\t%d\tSHREQ\n", name, line); break;
                                case ANDEQ: printf("%s\t%d\tANDEQ\n", name, line); break;
                                case OREQ: printf("%s\t%d\tOREQ\n", name, line); break;
                                case XOREQ: printf("%s\t%d\tXOREQ\n", name, line); break;
                                case NUMBER:;
                                        double floatVal;
                                        char* copyVal;
                                        
                                        int charCount =0;
                                        long eSign = 0;
                                        long eVal = 0;
                                        int pSign =0;
                                        int pVal =0;
                                        char* type = malloc(1024);
                                        char* end;
                                        char* eCheck = strchr(yylval,'e');
                                        char* pCheck = strchr(yylval,'p');
                                        if ( eCheck!= NULL){
                                                isFloat = 1;
                                                charCount+=1;
                                                
                                                if(isdigit(eCheck[1])){
                                                        eSign = 1;
                                                        eVal = strtol(yylval+(int)(eCheck-yylval)+1,NULL,10);
                                                }
                                                else if (yylval[strlen(yylval)-2] == '-'){
                                                        charCount+=1;
                                                        eSign = -1;
                                                        eVal = strtol(yylval+(int)(eCheck-yylval)+2,NULL,10);
                                                }
                                                else{
                                                        charCount+=1;
                                                        eSign = 1;
                                                        eVal = strtol(yylval+(int)(eCheck-yylval)+2,NULL,10);
                                                }
                                                
                                                
                                                
                                        }
                                        
                                        long test = eVal;
                                        while (test>0){
                                                test = test/10;
                                                charCount++;
                                        }
                                        if ( pCheck!= NULL){
                                                isFloat = 1;
                                                charCount+=1;
                                                
                                                if(isdigit(pCheck[1])){
                                                        pSign = 1;
                                                        pVal = strtol(yylval+(int)(pCheck-yylval)+1,NULL,10);
                                                }
                                                else if (yylval[strlen(yylval)-2] == '-'){
                                                        charCount+=1;
                                                        pSign = -1;
                                                        pVal = strtol(yylval+(int)(pCheck-yylval)+2,NULL,10);
                                                }
                                                else{
                                                        charCount+=1;
                                                        pSign = 1;
                                                        pVal = strtol(yylval+(int)(pCheck-yylval)+2,NULL,10);
                                                }
                                                
                                                
                                                
                                        }
                                        
                                        test = pVal;
                                        while (test>0){
                                                test = test/10;
                                                charCount++;
                                        }
                                        if(!isFloat){
                                                
                                                if((strchr(yylval,'U') != NULL) || (strchr(yylval,'u') != NULL))
                                                {
                                                        strcat(type,"UNSIGNED,");
                                                        charCount++;
                                                }
                                                if(strstr(yylval,"LL") != NULL)
                                                {
                                                        strcat(type,"LONGLONG");
                                                        charCount+=2;

                                                }
                                                else if( (strchr(yylval,'L') != NULL) || (strchr(yylval,'l') != NULL))
                                                {
                                                        strcat(type,"LONG");
                                                        charCount++;

                                                }
                                                else {

                                                        strcat(type,"INT");
                                                }

                                                
                                                
                                        }
                                        
                                        
                                        if(isFloat){
                                                
                                                if( (strchr(yylval,'L') != NULL) || (strchr(yylval,'l') != NULL))
                                                {
                                                        strcat(type,"LONGDOUBLE");
                                                        charCount++;

                                                }
                                                else if(strchr(yylval,'f')!= NULL || strchr(yylval,'F')!= NULL  ){
                                                        strcat(type,"Float");
                                                        charCount++;
                                                }
                                                else{
                                                        strcat(type,"DOUBLE");
                                                }
                                                
                                                //memcpy(copyVal,yylval,strlen(yylval)-charCount);
                                               // floatVal = atof(copyVal);
                                                
                                        }
                                        
                                        
                                        if(charCount!=0){yylval[strlen(yylval)-charCount] = '\0';}
                                        floatVal = atof(yylval);
                                        
                                        if(isFloat){
                                                long double temp = floatVal * pow(10,eSign*eVal) * pow(2,pSign*pVal);
                                                sprintf(yylval,"%Lg",temp);
                                                printf("%s\t%d\tNUMBER\tREAL\t%s\t%s\n",name,line, yylval,type);  
                                        }
                                        else{
                                                long int temp = atoi(yylval) * pow(10,eSign*eVal) * pow(2,pSign*pVal);
                                                sprintf(yylval,"%lld",temp);
                                                printf("%s\t%d\tNUMBER\tINTEGER\t%s\t%s\n",name,line, yylval,type);
                                        }
                                        
                                        break;
                                
                                case AUTO: printf("%s\t%d\tAUTO\n", name, line); break;
                                case BREAK: printf("%s\t%d\tBREAK\n", name,line); break;
                                case CASE: printf("%s\t%d\tCASE\n", name, line); break;
                                case CONST: printf("%s\t%d\tCONST\n", name, line); break;
                                case CONTINUE: printf("%s\t%d\tCONTINUE\n", name, line); break;
                                case DEFAULT: printf("%s\t%d\tDEFAULT\n",name, line); break;
                                case DO: printf("%s\t%d\tDO\n", name, line); break;
                                case DOUBLE: printf("%s\t%d\tDOUBLE\n", name, line); break;
                                case ELSE: printf("%s\t%d\tELSE\n",name, line); break;
                                case ENUM: printf("%s\t%d\tENUM\n", name, line); break;
                                case EXTERN: printf("%s\t%d\tEXTERN\n", name, line); break;
                                case FLOAT: printf("%s\t%d\tFLOAT\n", name, line); break;
                                case FOR: printf("%s\t%d\tFOR\n", name, line); break;
                                case GOTO: printf("%s\t%d\tGOTO\n", name, line); break;
                                case IF: printf("%s\t%d\tIF\n", name, line); break;
                                case INLINE: printf("%s\t%d\tINLINE\n", name, line); break;
                                case INT: printf("%s\t%d\tINT\n", name, line); break;
                                case LONG: printf("%s\t%d\tLONG\n", name, line); break;
                                case REGISTER: printf("%s\t%d\tREGISTER\n", name, line); break;
                                case RESTRICT: printf("%s\t%d\tRESTRICT\n", name, line); break;
                                case RETURN: printf("%s\t%d\tRETURN\n", name, line); break;
                                case SHORT: printf("%s\t%d\tSHORT\n", name, line); break;
                                case SIGNED: printf("%s\t%d\tSIGNED\n", name, line); break;
                                case SIZEOF: printf("%s\t%d\tSIZEOF\n", name, line); break;
                                case STATIC: printf("%s\t%d\tSTATIC\n", name, line); break;
                                case STRUCT: printf("%s\t%d\tSTRUCT\n", name, line); break;
                                case SWITCH: printf("%s\t%d\tSWITCH\n", name, line); break;
                                case TYPEDEF: printf("%s\t%d\tTYPEDEF\n", name, line); break;
                                case UNION: printf("%s\t%d\tUNION\n", name, line); break;
                                case UNSIGNED: printf("%s\t%d\tUNSIGNED\n",name,line); break;
                                case VOID: printf("%s\t%d\tUNION\n", name, line); break;
                                case VOLATILE: printf("%s\t%d\tVolatile\n", name, line); break;
                                case WHILE: printf("%s\t%d\tWHILE\n", name, line);break;
                                case _BOOL: printf("%s\t%d\t_BOOL\n", name, line); break;
                                case _COMPLEX: printf("%s\t%d\t_COMPLEX\n", name, line); break;
                                case _IMAGINARY: printf("%s\t%d\t_IMAGINARY\n",name,line); break;
                        }

        }
        free(yylval);



}