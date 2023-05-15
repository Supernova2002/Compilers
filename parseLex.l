%option noyywrap
%{



#include "parser.tab.h"
#include <stdio.h>
#include <math.h>
#include <ctype.h>
#include <string.h>
#define INTLONG 500
#define LLU 501
#define newline 600
#define PUNCTUATION 601

char* placeholder;
char name[1024] = "stdin";
int isFloat=0;
int line = 1;
%}
%x STRING 
%x CHARCASE
%x FILEINFO
DEC [1-9][0-9]*
E [\e][\+-]?{DEC}+
P [\p][\+-]?{DEC}+
FLOAT [0-9]+\.[0-9]*
FLOAT2 \.[0-9]+
DIGIT [0-9]+
HEXDIGIT   [0-9a-fA-F]
OCTALDIGIT      [0-7]

HEX     0[xX]{HEXDIGIT}+
OCTAL   0{OCTALDIGIT}*
%%
#               {BEGIN(FILEINFO);}
        /*<FILEINFO>[0-9]+    { line = (int) strtol (yytext,NULL, 10); }*/
    
<FILEINFO>\"(\\.|[^\\\"])*\"  {      
                strncpy(name, yytext+1, strlen(yytext)-2); //copy into filename
                name[strlen(yytext)-2] = '\0'; //ignore ""
                }

<FILEINFO>.         { ;}  
<FILEINFO>\n        {BEGIN(INITIAL);}
        /*[a-z|A-Z]+\.c   {yylval.string = strdup(yytext);name = yylval.string; return NAME;*/
<INITIAL>\L?\" {BEGIN(STRING);placeholder= malloc(1024);sprintf(placeholder,"");}
<INITIAL>\L?\' {BEGIN(CHARCASE);placeholder= malloc(1024);sprintf(placeholder,"");}

<STRING,CHARCASE>\\['|"|\\|?] {strcat(placeholder,&yytext[1]);}
<STRING,CHARCASE>\\[0|a|b|f|n|r|t|v] {strcat(placeholder, yytext);}
<STRING,CHARCASE>\\{OCTALDIGIT}{1,3} {long temp = strtol(yytext+1,NULL,8);char* storage=malloc(1024);
        if(temp > 255){
                
                fprintf(stderr,"%s:%d:Hex escape sequence %s out of range",name,line); 
                temp = 255;
        }
        int intTemp = temp;
        if(isprint(temp)==0){
                sprintf(storage,"\\%03o",intTemp);
        }
        else{
                sprintf(storage,"%c",intTemp);
        }
        strcat(placeholder,storage);free(storage);}

<STRING,CHARCASE>\\x{HEXDIGIT}+ {long temp = strtol(yytext+2,NULL,16);char* storage=malloc(1024);
        if(temp > 255){
                fprintf(stderr,"%s:%d:Hex escape sequence %s out of range",name,line); 
                temp = 255;
        }
        int intTemp = temp;
        if(isprint(temp)==0){
                sprintf(storage,"\\%03o",intTemp);
        }
        else{
                sprintf(storage,"%c",intTemp);
        }
        strcat(placeholder,storage);free(storage);}
<STRING>[^\"\\\n\0\a\b\f\n\r\t\v]+ {strcat(placeholder, yytext);}
<CHARCASE>[^|\'|\"|\\|\n|\0|\a|\b|\f|\n|\r|\t|\v]+ {strcat(placeholder, yytext);}
<CHARCASE>\' {BEGIN(INITIAL);
        if(strlen(placeholder) >1){
                fprintf(stderr,"%s:%d:WARNING:Unsupported multibyte character literal truncated to first byte \n",name,line); 
                placeholder[1] = '\0';
        }
        yylval.number.type = 9;
        yylval.number.value.charVal= placeholder[0]; 
        free(placeholder);
        return CHARLIT;}
<STRING>\" {BEGIN(INITIAL);yylval.string = strdup(placeholder); free(placeholder);return newString;}

-\> {return INDSEL;}
\<\< {return SHL;}
\>\> {return SHR;}
<INITIAL>{HEX}{P}?[lL]? {
        char * end;
        long temp = strtol(yytext+2,&end,16);
        char* storage= malloc(1024);
        sprintf(storage,"%ld",temp);
        strcat(storage,end);yylval.string =strdup(storage);
        free(storage);
        isFloat = numberProcessing(0);
        
        
        

        return NUMBER;}
<INITIAL>{HEX}{P}?[u|U]?[l|L]{0,2} {
        char * end;
        long temp = strtol(yytext+2,&end,16);
        char* storage= malloc(1024);
        sprintf(storage,"%ld",temp);
        strcat(storage,end);yylval.string =strdup(storage);
        free(storage);
        isFloat = numberProcessing(0);
        
        
        

        return NUMBER;}
<INITIAL>{HEX}{P}?[l|L]{0,2}[u|U]? {
        char * end;
        long temp = strtol(yytext+2,&end,16);
        char* storage= malloc(1024);
        sprintf(storage,"%ld",temp);
        strcat(storage,end);yylval.string =strdup(storage);
        free(storage);
        isFloat = numberProcessing(0);
        
        
        

        return NUMBER;}
<INITIAL>{DEC}({E}|{P})?[lL]? {
        yylval.string = strdup(yytext);
        isFloat  = numberProcessing(0);
        return NUMBER;
}
<INITIAL>{DEC}[u|U]?[l|L]{0,2} {        
        yylval.string = strdup(yytext);
        isFloat  = numberProcessing(0);
        return NUMBER;
}
<INITIAL>{DEC}[l|L]{0,2}[u|U]? {
        yylval.string = strdup(yytext);
        isFloat  = numberProcessing(0);
        return NUMBER;
}
<INITIAL>{OCTAL}[lLfF]? {
        char * end;
        long temp = strtol(yytext,&end,8);
        char* storage= malloc(1024);
        sprintf(storage,"%ld",temp);
        strcat(storage,end);
        yylval.string =strdup(storage);

        free(storage);
        isFloat = numberProcessing(isFloat);
        return NUMBER;}
<INITIAL>{OCTAL}([u|U]?[l|L]{0,2}) {
        char * end;
        long temp = strtol(yytext,&end,8);
        char* storage= malloc(1024);
        sprintf(storage,"%ld",temp);
        strcat(storage,end);
        yylval.string =strdup(storage);

        free(storage);
        isFloat = numberProcessing(isFloat);
        return NUMBER;}
<INITIAL>{OCTAL}([l|L]{0,2}[u|U]?) {
        char * end;
        long temp = strtol(yytext,&end,8);
        char* storage= malloc(1024);
        sprintf(storage,"%ld",temp);
        strcat(storage,end);
        yylval.string =strdup(storage);

        free(storage);
        isFloat = numberProcessing(isFloat);
        return NUMBER;}
({FLOAT}|{FLOAT2})({E}|{P})?[l|L|f|F]?      {
        
        yylval.string = strdup(yytext);
        isFloat = 1; 
        isFloat = numberProcessing(isFloat);
        return NUMBER; }  
{DIGIT}({E}|{P})[lLfF]? {
        yylval.string = strdup(yytext);
        isFloat  = numberProcessing(0);
        return NUMBER;
}
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
<<EOF>> {yyterminate();printf("test"); }

\n      {line = line + 1;}
<INITIAL>[\.\+\-\;\!\?\:\,\@\#\$\%\*\&\(\)\[\]\{\}\^\~\|\<\>\`\\\/\=] {
        
        yylval.string = strdup(yytext);
       // printf("String is %s\n", yylval.string);
        int returnVal = yylval.string[0];
       // printf("Punctuation is %i\n", returnVal);
        return returnVal;
        }
<INITIAL>[a-zA-Z_][a-zA-Z0-9_]* {yylval.string = strdup(yytext); return IDENT;}
[ ]+ 
.       {fprintf(stderr, "Error: Unknown token %s\n", yytext);}

%%



int numberProcessing(int realCheck){
        int isFloat = realCheck;
        double floatVal;
        char* copyVal;
        
        int charCount =0;
        long eSign = 0;
        long eVal = 0;
        int pSign =0;
        int pVal =0;
        char* type = malloc(1024);
        sprintf(type,"");
        char* end;
        char* eCheck = NULL;
        char* pCheck = NULL;
        char* fCheck = NULL;
        char* temp = strdup(yylval.string);
        if(strchr(yylval.string,'f') != NULL){
                fCheck = strchr(yylval.string,'f');
                
        }
        else if (strchr(yylval.string,'F') != NULL){
                fCheck = strchr(yylval.string,'F');
                
        }
        if(strchr(yylval.string,'e') != NULL){
                eCheck = strchr(yylval.string,'e');
        }
        else if (strchr(yylval.string,'E') != NULL){
                eCheck = strchr(yylval.string,'E');
        }
        
        if(strchr(yylval.string,'p') != NULL){
                pCheck = strchr(yylval.string,'p');
        }
        else if(strchr(yylval.string,'P') != NULL){
                pCheck = strchr(yylval.string,'P');
        }
        
        
        if ( eCheck!= NULL){
                isFloat = 1;
                charCount+=1;
                
                if(isdigit(eCheck[1])){
                        eSign = 1;
                        eVal = strtol(yylval.string+(int)(eCheck-yylval.string)+1,NULL,10);
                }
                else if (eCheck[1] == '-'){
                        charCount+=1;
                        eSign = -1;
                        eVal = strtol(yylval.string+(int)(eCheck-yylval.string)+2,NULL,10);
                }
                else{
                        charCount+=1;
                        eSign = 1;
                        eVal = strtol(yylval.string+(int)(eCheck-yylval.string)+2,NULL,10);
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
                        pVal = strtol(temp+(int)(pCheck-temp)+1,NULL,10);
                }
                else if (pCheck[1] == '-'){
                        charCount+=1;
                        pSign = -1;
                        pVal = strtol(yylval.string+(int)(pCheck-yylval.string)+2,NULL,10);
                }
                else{
                        charCount+=1;
                        pSign = 1;
                        pVal = strtol(yylval.string+(int)(pCheck-yylval.string)+2,NULL,10);
                }
                
                
                
        }

        test = pVal;
        while (test>0){
                test = test/10;
                charCount++;
        }
        if(!isFloat){
                
                if((strchr(temp,'U') != NULL) || (strchr(temp,'u') != NULL))
                {
                        yylval.number.type = 1;
                        
                        charCount++;
                }
                if(strstr(temp,"LL") != NULL)
                {       if(yylval.number.type == 1){
                                yylval.number.type = 4;
                        }
                        else{
                                yylval.number.type = 5;
                        }
                        
                        charCount+=2;

                }
                else if(strstr(temp,"L") != NULL || strstr(temp,"l") != NULL)
                {       if(yylval.number.type == 1){
                                yylval.number.type = 3;
                        }
                        else{
                                yylval.number.type = 2;
                        }

                        
                        charCount++;

                }
                else {
                        yylval.number.type = 0;
                        
                }

                
                
        }
        
        
        if(isFloat){
                
                if( (strchr(temp,'L') != NULL) || (strchr(temp,'l') != NULL))
                {
                        yylval.number.type = 8;
                        
                        charCount++;

                }
                else if(strchr(temp,'f')!= NULL || strchr(temp,'F')!= NULL  ){
                        yylval.number.type = 7;
                        
                        charCount++;
                }
                else{
                        yylval.number.type = 6;
                        
                }
                
                
                
        }
        if(charCount!=0){
                temp[strlen(temp)-charCount] = '\0';
        }
        floatVal = atof(temp);
        long double numTemp = floatVal * pow(10,eSign*eVal) * pow(2,pSign*pVal);
        if(isFloat){
                yylval.number.value.realVal = numTemp;
        }
        else{
                yylval.number.value.intVal= numTemp;
        }
        
        //sprintf(yylval.string,"%Lg\t%s",temp,type);
        free(type);
        return isFloat;

        
}

