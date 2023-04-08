%define parse.error verbose
%define parse.trace
%{
    int yylex();
    
    #include <stdio.h>
    #include <math.h>
    #include <ctype.h>
    #include <string.h>
    #include <stdlib.h>
    #include "parser.h"
    #define INTLONG 500
    #define LLU 501
    #define newline 600
    #define PUNCTUATION 601 
    

    struct symbolNode *base;
    struct symbolNode *last;
    struct symbolNode *funcHead;
    struct symbolNode *scopeList[1024];
    struct symbolNode *lastSymbol[1024];
    struct symbolNode *scopeList[1024];
    int lastType;
    int scopeNum;
    int scopeNum;
    int nameSpaceNum;
    int structOrFunc; //0 if struct, 1 if funct, -1 if neither
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
    const char *stringFromDecType(int type){
        switch(type){
            case 0: return "void";
            case 1: return "char";
            case 2: return "short";
            case 3: return "int";
            case 4: return "long";
            case 5: return "float";
            case 6: return "double";
            case 7: return "signed";
            case 8: return "unsigned";
            case 9: return "_bool";
            case 10: return "_complex";
            case 11: return "const";
            case 12: return "restrict";
            case 13: return "volatile";
        }


    }
    struct symbolNode *generateSymbol(int decLine, int localScopeStart, int scope,int identType, char* type, char* name,char* fileName,int astType, struct astnode *member, struct symbolNode *head, int subFlag, int nameSpace, int storageClass){
        struct symbolNode *s = malloc(sizeof(struct symbolNode));
        s->declaredLine = decLine;
        s->scopeStart = localScopeStart;
        s->scope = scope;
        s->identType = identType;
        s->type = type;
        
        s->identName = name;
        s->fileName = fileName;
        s->astType = astType;
        s->member  = member;
        if(head == NULL){
            s->head = s;
        }
        else{
            s->head = head;
        }
       // s->structCompleteFlag = 0;
        s->subHead = NULL;
        s->nameSpace = nameSpace;
        s->structCompleteFlag = -1;
        s->storageType = storageClass;
    }
    struct symbolNode *insertSymbol (struct symbolNode *head, struct symbolNode *newSymbol){
        //check for presence of struct with same name first
        if(newSymbol->identType == 2){
            
        }
        struct symbolNode *current = head;
        while(current->next != NULL){
            int localComp = strcmp(current->identName,newSymbol->identName);
            if(localComp == 0 && (current->identType == newSymbol->identType) && (current->type != newSymbol->type)){
                printf("This name is already in use, not inserting\n");
                return NULL;
            }
            current = current->next;

        }
        int localComp = strcmp(current->identName,newSymbol->identName);
        if(localComp == 0 && (current->identType == newSymbol->identType) && (current->type != newSymbol->type)){
            printf("This name is already in use, not inserting\n");
            return NULL;
        }
        current->next = newSymbol;
        return newSymbol;
    }
    //Need to figure out how to hide previous struct definitions with incomplete types
    /*struct symbolNode *findSymbol(struct symbolNode *head, char* ident, int identType, int nameSpace, int scope){  //need to figure out how to search from bottom up
        struct symbolNode *current = head;
        while(current != NULL){
            if(current->subHead != NULL){
                struct symbolNode *temp = findSymbol(current->subHead, ident, identType, nameSpace, scope);
                if (temp != NULL){
                    return temp;
                }
            }
            int localComp = strcmp(current->identName,ident);
            //int nameComp = strcmp(current->nameSpace, nameSpace);

            if(localComp == 0 && current->identType == identType){
               
                    return current;
                
                
              //  return current;
            }
            current = current->next;
        }
        return NULL;

    }*/
    struct symbolNode *findInStruct(struct symbolNode *head, char* ident, int scope){
        struct symbolNode *current = head;
        while(current != NULL){
            if(current->subHead != NULL){
                struct symbolNode *temp = findInStruct(current->subHead, ident, scope);
                if(temp != NULL){
                    return temp;
                }
            }
            int localComp = strcmp(current->identName,ident);
            if(localComp == 0 ){
                return current;
            }
            current = current->next;
        }

    }

    struct symbolNode *findSymbol(struct symbolNode *head, char* ident, int scope){
        struct symbolNode *current = head;
        while(current != NULL){
            int localComp = strcmp(current->identName, ident);
            if(localComp == 0){
                return current;
            }
            if(current->identType == 2 && current->subHead != NULL){
                struct symbolNode *temp = findInStruct(current->subHead, ident, scope);
                if(temp != NULL){
                    return temp;
                }
            }
            if(current->next == NULL && current->head->previousHead != current && current->head->previousHead != NULL){
                struct symbolNode *temp = findSymbol(head->previousHead, ident, scope);
                if(temp != NULL){
                    return temp;
                }
            }
            current = current->next;
        }
    }
    const char *scopeFromNum(int scope){
        switch (scope){
            case 0: return "global"; break;
            case 1: return "function"; break;
            case 2: return "block"; break;
        }
    }
    const char *identTypeString(int type){
        switch(type){
            case 0: return "variable"; break;
            case 1: return "function"; break;
            case 2: return "struct/union"; break;
            case 3: return "struct/union member"; break;
            case 4: return "label"; break;
        }
    }
    void printType(struct astnode *member ){
        switch(member->nodetype){
            case 15: printf("\t%s\t\n", member->scalarVar.dataType);
                break;
            case 16: 
                if(member->pointer.member->nodetype == 2){
                    printf("\tpointer to \n\t%s\n", member->pointer.type);
                }
                else{
                    printf("\tpointer to \n");
                    printType(member->pointer.member);
                }
                break;
            case 17: printf("\tarray of %d elements of type\n\t %s\t\n", member->array.size, member->array.type );
                break;
            case 18: //printf("\t%s returning unknown arguments", member->funcDec.type);
                if(member->funcDec.decNode->nodetype == 2){
                    printf("\t %s\n", member->funcDec.type);
                }
                else{
                    
                    printType(member->funcDec.decNode);
                    
                    printf("\t %s\n", member->funcDec.type);
                }
                break;
        }
    }

    char *getStorage(int storageClass, int scope, int identType){
        if(storageClass == 4){
            return "";   
        }
        else{
            if(scope == 0 && identType == 0 ){
                return " with stgclass extern ";
            }
            else{
                switch(storageClass){
                    case 0: return " with stgclass extern ";
                    break;
                    case 1: return " with stgclass static ";
                    break;
                    case 2: return " with stgclass auto ";
                    break;
                    case 3: return " with stgclass register ";
                    break;
                }
            }
        }
    }
    char *getParent(char *parentName){
        if(parentName == NULL){
            return "";
        }
        else{
            char* temp = malloc(1024);
            strcpy(temp, "of struct/union ");
            strcat(temp, parentName);
            return temp;
        }
    }

    void printSymbol(struct symbolNode* symbol){
        char *structName;
        struct symbolNode *structNode;
        struct symbolNode *lastChecked;
        if(symbol->identName != ""){
            if(symbol->identType ==2){
                printf("struct/union %s definition at %s:%d \n", symbol->identName,symbol->fileName, symbol->declaredLine);
            }
            else{
                printf("%s is defined at %s:%d [ in %s scope starting at %s: %d] as a\n %s %s %s of type:\n", symbol->identName, symbol->fileName, symbol->declaredLine, scopeFromNum(symbol->scope),symbol->fileName, symbol->scopeStart,identTypeString(symbol->identType), getStorage(symbol->storageType, symbol->scope, symbol->identType), getParent(symbol->parentName) );
                printType(symbol->member );
                if(strstr(symbol->type, "struct") != NULL || strstr(symbol->type, "union") != NULL ){
                    structName = strtok(symbol->type, " ");
                    //while(strcmp(structName, "struct") == 0){
                        structName = strtok(NULL, " ");
                    //}
                    lastChecked = symbol;
                    structNode = findSymbol(symbol->head, structName, symbol->scope); 
                    while(structNode == symbol && lastChecked->head->previousHead != NULL){
                        structNode = findSymbol(lastChecked->head->previousHead, structName, symbol->scope);
                        lastChecked = lastChecked->head->previousHead;
                    }
                    if(structNode == symbol){
                        structNode = NULL;
                    }
                   // if(structNode == symbol && symbol->head->previousHead != NULL )
                    //structNode = findSymbol(base, structName, 2, symbol->nameSpace, symbol->scope);  
                   // if(symbol->head->previousHead == NULL){
                  //     structNode = findSymbol(symbol->head, structName, symbol->scope); 
                //    }
                  //  else{
                 //       structNode = findSymbol(symbol->head->previousHead, structName, symbol->scope);
                 //   }
                    
                   // printf("STRUCT NAME IS %s", structName);
                    if(structNode == NULL){
                        printf("\t\tincomplete\n");
                    }
                    else{
                        if(structNode->structCompleteFlag == 0){
                            printf("\t\tincomplete\n");
                        }
                        else{
                            printf("\t\t(Defined at %s:%d)\n\t", symbol->fileName, structNode->declaredLine);
                        }
                        
                    }
                }
            }
            
        }
       /* if(symbol->subHead != NULL){
            printSymbol(symbol->subHead);
            
        }
        if(symbol->next!= NULL){
            printSymbol(symbol->next);
        }


        /*char *finalPrint = malloc(1028);
        switch(symbol->identType){
            case 0: switch(symbol->astType){
                    case 15: sprintf(finalPrint,"%s is defined at %s:%d [in %s scope starting at %s:%d] as a \n %s with type:\n\t %s\t\n", symbol->identName, symbol->fileName, symbol->declaredLine, scopeFromNum(symbol->scope),symbol->fileName, symbol->scopeStart,identTypeString(symbol->identType), symbol->type );
                        break;
                    case 17: sprintf(finalPrint,"%s is defined at %s:%d [in %s scope starting at %s:%d] as a \n %s with type:\n array of %d elements of type\n\t %s\t\n", symbol->identName, symbol->fileName, symbol->declaredLine, scopeFromNum(symbol->scope),symbol->fileName, symbol->scopeStart,identTypeString(symbol->identType),symbol->member->array.size, symbol->type );
                        break;
                    case 16: 
                } 
                
            
        }
        printf("%s", finalPrint);*/
        
    }

    
    
    void yyerror(const char *str)
    {
        fprintf(stderr,"error: %s\n",str);
    }
    
    
    
%}
//0 is binop, 1 is num, 2 is ident, 3 is string, 4 is ternary, 5 is logop, 6 is assignment, 7 is unary op, 8 is comparison op, 9 is general, 10 is select, 11 is type, 12 is funcarg and 13 is func
%code requires {
       // struct symbolNode *base = generateSymbol(0,0,0,"","");
        #include "parser.h"
    };

%union{
    struct number number;
    char *string;
    struct astnode *astnode_p;
    int operator;
}
%token <number> NUMBER
%token <number> CHARLIT
%token  INDSEL PLUSPLUS MINUSMINUS SHL SHR LTEQ GTEQ EQEQ NOTEQ LOGAND LOGOR ELLIPSIS TIMESEQ  DIVEQ MODEQ PLUSEQ MINUSEQ SHLEQ SHREQ
%token  ANDEQ OREQ XOREQ AUTO BREAK CASE CHAR CONST CONTINUE DEFAULT DO DOUBLE ELSE ENUM EXTERN FLOAT FOR GOTO IF INLINE INT LONG REGISTER
%token  RESTRICT RETURN SHORT SIGNED SIZEOF STATIC STRUCT SWITCH TYPEDEF UNION UNSIGNED VOID VOLATILE WHILE _BOOL _COMPLEX _IMAGINARY NAME ENDFILE
//%token <operator> TIMESEQ
%token <string> IDENT 
%token <string> newString;
%left '+' '-' 
%left '*' '/' '%'
%type <astnode_p> start  statement expr primexp postexp castexp unexp multexp addexp shiftexp relexp eqexp andexp exorexp inorexp logandexp logorexp condexp assexp constexp argexplist
%type <astnode_p> declaration declarator_list declaration_specifiers function_definition declarator compound_statement  direct_declarator struct_or_union_spec struct_declaration_list struct_declaration struct_declarator_list struct_declarator 
%type <astnode_p> spec_qual_list pointer decl_or_stmt_list decl_or_stmt identifier_list type_specifier type_qualifier open_scope  open_struct actually_opening direct_abstract_declarator abstract_declarator storage_class_spec
%type <operator> assop unaryop typename     struct_or_union function_specifier 
%%

/*start: statement
    | start statement
;*/
//start: declaration_or_fndef
//    | start declaration_or_fndef
//;
//declaration_or_fndef: declaration
start: dec_or_func
    | start dec_or_func

dec_or_func: declaration {  struct symbolNode *s = NULL;
                            struct symbolNode *tempInserted = NULL;
                            char *start;
                            
                            int insertCheck;
                            int localStart = lastSymbol[scopeNum+1]->head->scopeStart;
                            struct astnode *bigN = $1;
                            struct astnode *n = bigN;
                            while(n != NULL){
                                    switch(n->nodetype){
                                    case 15:
                                        if(strcmp(n->scalarVar.dataType,"incomplete type" ) == 0){
                                            s= generateSymbol(line, localStart, 0, 2,"", n->scalarVar.name, name, -2, NULL, NULL, 0, lastSymbol[scopeNum+1]->nameSpace,4 );
                                            s->structCompleteFlag = 0; 
                                            tempInserted= insertSymbol(lastSymbol[scopeNum+1]->head, s);
                                            if(tempInserted!= 0){
                                                lastSymbol[scopeNum+1] = tempInserted;
                                                printSymbol(lastSymbol[scopeNum+1]);
                                            }
                                        
                                        } 
                                        else{
                                            s = generateSymbol(line,localStart,0,0,n->scalarVar.dataType,n->scalarVar.name, name,15, n, lastSymbol[scopeNum+1]->head,0, lastSymbol[scopeNum+1]->nameSpace,n->scalarVar.storageClass);
                                            tempInserted= insertSymbol(lastSymbol[scopeNum+1]->head, s);
                                            if(tempInserted!= 0){
                                                lastSymbol[scopeNum+1] = tempInserted;
                                                printSymbol(lastSymbol[scopeNum+1]);
                                            }
                                        }
                                        /*  s = generateSymbol(line,localStart,0,0,n->scalarVar.dataType,n->scalarVar.name, name,15, n, lastSymbol[scopeNum+1]->head,0, lastSymbol[scopeNum+1]->nameSpace );
                                        tempInserted= insertSymbol(lastSymbol[scopeNum+1]->head, s);
                                        if(tempInserted!= 0){
                                            lastSymbol[scopeNum+1] = tempInserted;
                                            printSymbol(lastSymbol[scopeNum+1]);
                                        }*/
                                        break;
                                    case 16:// n->pointer.type = strdup(fullType);
                                        s = generateSymbol(line, localStart, 0,0, n->pointer.type, n->pointer.name,name,16, n, lastSymbol[scopeNum+1]->head,0, lastSymbol[scopeNum+1]->nameSpace,n->pointer.storageClass);
                                        
                                        tempInserted= insertSymbol(lastSymbol[scopeNum+1]->head, s);
                                        if(tempInserted!= 0){
                                            lastSymbol[scopeNum+1] = tempInserted;
                                            printSymbol(lastSymbol[scopeNum+1]);
                                        }
                                        break;
                                    case 17: //n->array.type = strdup(fullType); 
                                        s = generateSymbol(line, localStart, 0,0, n->array.type, n->array.name, name,17, n, lastSymbol[scopeNum+1]->head,0, lastSymbol[scopeNum+1]->nameSpace,n->array.storageClass);
                                        tempInserted= insertSymbol(lastSymbol[scopeNum+1]->head, s);
                                        if(tempInserted!= 0){
                                            lastSymbol[scopeNum+1] = tempInserted;
                                            printSymbol(lastSymbol[scopeNum+1]);
                                        }
                                        break;
                                    case 18: //n->funcDec.type = strdup(fullType);
                                        s = generateSymbol(line, localStart, 0,1, n->funcDec.type, n->funcDec.name,name,18, n, lastSymbol[scopeNum+1]->head,1, lastSymbol[scopeNum+1]->nameSpace,4);
                                        tempInserted= insertSymbol(lastSymbol[scopeNum+1]->head, s);
                                        if(tempInserted!= 0){
                                            lastSymbol[scopeNum+1] = tempInserted;
                                            printSymbol(lastSymbol[scopeNum+1]);
                                        }
                                        break;
                                }
                                n = n->next;
                            }
                            
                            lastSymbol[scopeNum+2] = NULL;

                            }//maybe move all symbol generation and type definition over here
    | function_definition
;
declaration:  declaration_specifiers declarator_list ';' { struct astnode *n;
                                                            struct astnode *bigN = $2;
                                                            n = bigN;
                                                            //struct astnode *n = malloc(sizeof(struct astnode));
                                                            char* fullType = malloc(1024);
                                                            char* temp = malloc(1024);
                                                            struct astnode *type = $1;
                                                            int storeType=2;
                                                            //int localComp = strcmp(current->identName,newSymbol->identName);
                                                            if(lastSymbol[scopeNum+1]->identType == 2){
                                                                if(scopeNum== -1){
                                                                    printSymbol(lastSymbol[scopeNum+1]);
                                                                }
                                                                if(type!=NULL && type->nodetype == 21){
                                                                    storeType = type->storageType.storageType;
                                                                }
                                                                sprintf(fullType, "struct %s", lastSymbol[scopeNum+1]->identName);
                                                                

                                                            }
                                                            else{

                                                                if(type->nodetype == 14 || type->nodetype == 21){
                                                                    while(type != NULL){
                                                                        if(type->nodetype != 21){
                                                                            sprintf(temp,"%s %s",fullType, stringFromDecType(type->decType.type));
                                                                            fullType = strdup(temp);
                                                                            type = type->decType.nextType;
                                                                        }
                                                                        else{
                                                                            storeType = type->storageType.storageType;
                                                                            type = type->storageType.nextType;
                                                                        }
                                                                        
                                                                    }
                                                                }
                                                                else if(type->nodetype == 2){
                                                                            sprintf(fullType, "%s", type->ident.ident);
                                                                }
                                                                
                                                                
                                                            }
                                                            //struct symbolNode *s = NULL;
                                                            while(n != NULL){
                                                                int insertCheck;
                                                                switch(n->nodetype){
                                                                    case 2: setupScalar(n,storeType, strdup(fullType),strdup(n->ident.ident));
                                                                            break;
                                                                    case 16: n->pointer.type = strdup(fullType);
                                                                        n->pointer.storageClass = storeType;
                                                                        switch(n->pointer.member->nodetype){
                                                                            case 2: n->pointer.name = n->pointer.member->ident.ident;
                                                                                break;
                                                                            case 17: n->pointer.member->array.type = strdup(fullType); 
                                                                                    n->pointer.name = n->pointer.member->array.name;
                                                                                    break;
                                                                            case 18: n->pointer.member->funcDec.type = strdup(fullType);
                                                                                    n->pointer.name = n->pointer.member->funcDec.name;
                                                                                    break;
                                                                        }
                                                                        //s = generateSymbol(-1, 0, 0,0, n->pointer.type, n->pointer.member->ident.ident,"tempName.c",16, n, base);
                                                                        //insertCheck = insertSymbol(base, s);
                                                                        break;
                                                                    case 17: n->array.type = strdup(fullType); 
                                                                            n->array.storageClass = storeType;
                                                                        //s = generateSymbol(-1, 0, 0,0, n->array.type, n->array.name,"tempName.c",17, n, base);
                                                                        //insertCheck = insertSymbol(base, s);
                                                                    break;
                                                                    case 18: n->funcDec.type = strdup(fullType);
                                                                    // s = generateSymbol(-1, 0, 0,1, n->funcDec.type, n->funcDec.name, "tempName.c",18, n, base);
                                                                    // insertCheck = insertSymbol(base, s);
                                                                        break;
                                                                }
                                                                n = n->next;
                                                            }
                                                            
                                                           
                                                            //lastType = -1;
                                                            
                                                            $$ = bigN;
                                                            } 
                                                            
    | declaration_specifiers ';' {  struct astnode *n = $1;
                                    struct symbolNode *s;
                                    //char *temp;
                                    char *structName;
                                    char* fullType = malloc(1024);
                                    char* temp = malloc(1024);
                                    struct astnode *type = $1;
                                    int storeType=2;
        
         
                                    if(lastSymbol[scopeNum+1]->identType == 2){
                                        printSymbol(lastSymbol[scopeNum+1]);
                                    }
                                    else{
                                        if(n->nodetype == 2){
                                            if(strstr(n->ident.ident, "struct") != NULL){
                                            structName = strtok(n->ident.ident, " ");
                                            //while(strcmp(structName, "struct") == 0){
                                            structName = strtok(NULL, " ");
                                            setupScalar(n,0, "incomplete type",structName);
                                            $$ = n;
                                        }
                                        }
                                        
                                        else{
                                            if(type->nodetype == 14 || type->nodetype == 21){
                                                while(type != NULL){
                                                    if(type->nodetype != 21){
                                                        sprintf(temp,"%s %s",fullType, stringFromDecType(type->decType.type));
                                                        fullType = strdup(temp);
                                                        type = type->decType.nextType;
                                                    }
                                                    else{
                                                        storeType = type->storageType.storageType;
                                                        type = type->storageType.nextType;
                                                    }
                                                    
                                                }
                                            }
                                            setupScalar(n,storeType, fullType, "anonymous");
                                            $$ = n;
                                        }
                                        
                                    }
                                    //printf("Just type here\n");
                                    
                                    } 
;

declarator_list: declarator { $$ = $1;}
    | declarator_list ',' declarator { struct astnode *n = $3;
                                        n->next = $1;
                                        $$ = n;
                                        }
function_definition: declaration_specifiers declarator compound_statement { struct astnode *n = $2;
                                                                            struct symbolNode *s;
                                                                            struct symbolNode *tempInserted = NULL;
                                                                            int localStart = lastSymbol[scopeNum+1]->head->scopeStart;
                                                                            char* fullType = malloc(1024);
                                                                            char* temp = malloc(1024);
                                                                            struct astnode *type = $1;
                                                                            int storeType=2;
                                                                            if(type->nodetype == 14 || type->nodetype == 21){
                                                                                while(type != NULL){
                                                                                    if(type->nodetype != 21){
                                                                                        sprintf(temp,"%s %s",fullType, stringFromDecType(type->decType.type));
                                                                                        fullType = strdup(temp);
                                                                                        type = type->decType.nextType;
                                                                                    }
                                                                                    else{
                                                                                        storeType = type->storageType.storageType;
                                                                                        type = type->storageType.nextType;
                                                                                    }
                                                                                    
                                                                                }
                                                                            }
                                                                            switch(n->nodetype){
                                                                                case 2: setupScalar(n,storeType, strdup(fullType),strdup(n->ident.ident));
                                                                                    s = generateSymbol(atoi($3->ident.ident),localStart,0,0,n->scalarVar.dataType,n->scalarVar.name, name,15, n, lastSymbol[scopeNum+1]->head,0, lastSymbol[scopeNum+1]->nameSpace,4 );
                                                                                    tempInserted= insertSymbol(lastSymbol[scopeNum+1]->head, s);
                                                                                    if(tempInserted!= 0){
                                                                                        lastSymbol[scopeNum+1] = tempInserted;
                                                                                        printSymbol(lastSymbol[scopeNum+1]);
                                                                                    }
                                                                                    break;
                                                                                case 16:// n->pointer.type = strdup(fullType);
                                                                                    n->pointer.type = strdup(fullType);
                                                                                    s = generateSymbol(atoi($3->ident.ident), localStart, 0,0, n->pointer.type, n->pointer.member->ident.ident,name,16, n, lastSymbol[scopeNum+1]->head,0, lastSymbol[scopeNum+1]->nameSpace,4);
                                                                                    tempInserted= insertSymbol(lastSymbol[scopeNum+1]->head, s);
                                                                                    if(tempInserted!= 0){
                                                                                        lastSymbol[scopeNum+1] = tempInserted;
                                                                                        printSymbol(lastSymbol[scopeNum+1]);
                                                                                    }
                                                                                    break;
                                                                                case 17: //n->array.type = strdup(fullType); 
                                                                                    n->array.type = strdup(fullType);
                                                                                    s = generateSymbol(atoi($3->ident.ident), localStart, 0,0, n->array.type, n->array.name,name,17, n, lastSymbol[scopeNum+1]->head,0, lastSymbol[scopeNum+1]->nameSpace,4);
                                                                                    tempInserted= insertSymbol(lastSymbol[scopeNum+1]->head, s);
                                                                                    if(tempInserted!= 0){
                                                                                        lastSymbol[scopeNum+1] = tempInserted;
                                                                                        printSymbol(lastSymbol[scopeNum+1]);
                                                                                    }
                                                                                    break;
                                                                                case 18: n->funcDec.type = strdup(fullType);
                                                                                    s = generateSymbol(atoi($3->ident.ident), localStart, 0,1, n->funcDec.type, n->funcDec.name, name ,18, n, lastSymbol[scopeNum+1]->head,1, lastSymbol[scopeNum+1]->nameSpace, 4);
                                                                                    tempInserted= insertSymbol(lastSymbol[scopeNum+1]->head, s);
                                                                                    if(tempInserted!= 0){
                                                                                        lastSymbol[scopeNum+1] = tempInserted;
                                                                                        scopeList[scopeNum+1]->previousHead = lastSymbol[scopeNum+1]->head;
                                                                                        lastSymbol[scopeNum+1]->subHead = scopeList[scopeNum+1];
                                                                                        printSymbol(lastSymbol[scopeNum+1]);
                                                                                        
                                                                                    }
                                                                                    
                                                                                    //scopeList[scopeNum+1] = NULL;
                                                                                    //need to actually store the last pointer inserted in a given scope
                                                                                    break;

                                                                                    
                                                                                }
                                                                                lastSymbol[scopeNum+2] = NULL;
                                                                                
                                                                            }
;


declaration_specifiers: storage_class_spec  declaration_specifiers { struct astnode *n = $1;
                                                                    n->storageType.nextType = $2;
                                                
                                                                    $$ = n;
                                                }
    | storage_class_spec 
    | type_specifier   declaration_specifiers { struct astnode *n = $1;
                                                    n->decType.nextType = $2;
                                                
                                                $$ = n;}
    | type_specifier { struct astnode *n = $1; 
                         $$ = n;}
    | type_qualifier declaration_specifiers { struct astnode *n = $1;
                                                    n->decType.nextType = $2;
                                                
                                                $$ = n;}
    | type_qualifier { struct astnode *n = $1; 
                         $$ = n;}
    | function_specifier declaration_specifiers 
    | function_specifier 
;

type_qualifier: CONST { struct astnode *n = malloc(sizeof(struct astnode));
                        setupDecType(n,11,NULL);
                        $$ = n;
                        }
    | RESTRICT  { struct astnode *n = malloc(sizeof(struct astnode));
                        setupDecType(n,12,NULL);
                        $$ = n;
                        }
    | VOLATILE { struct astnode *n = malloc(sizeof(struct astnode));
                        setupDecType(n,13,NULL);
                        $$ = n;
                        }
;
storage_class_spec: EXTERN {
                struct astnode *n = malloc(sizeof(struct astnode));
                                setupStorage(n, 0);
                                $$ = n;
                }
    | STATIC {
                struct astnode *n = malloc(sizeof(struct astnode));
                                setupStorage(n, 1);
                                $$ = n;}
    | AUTO { 
            struct astnode *n = malloc(sizeof(struct astnode));
                                setupStorage(n, 2);
                                $$ = n;
            }
    | REGISTER { 
                struct astnode *n = malloc(sizeof(struct astnode));
                                setupStorage(n, 3);
                                $$ = n;
                }
;
type_specifier: VOID {struct astnode *n = malloc(sizeof(struct astnode));
                        setupDecType(n, 0, NULL );
                        $$ = n;}
    | CHAR {struct astnode *n = malloc(sizeof(struct astnode));
                        setupDecType(n, 1, NULL );
                        $$ = n;}
    | SHORT { struct astnode *n = malloc(sizeof(struct astnode));
                        setupDecType(n, 2, NULL );
                        $$ = n;}
    | INT { struct astnode *n = malloc(sizeof(struct astnode));
                        setupDecType(n, 3, NULL );
                        $$ = n;}
    | LONG {struct astnode *n = malloc(sizeof(struct astnode));
                        setupDecType(n, 4, NULL );
                        $$ = n;}
    | FLOAT {struct astnode *n = malloc(sizeof(struct astnode));
                        setupDecType(n, 5, NULL );
                        $$ = n;}
    | DOUBLE {struct astnode *n = malloc(sizeof(struct astnode));
                        setupDecType(n, 6, NULL );
                        $$ = n;}
    | SIGNED { struct astnode *n = malloc(sizeof(struct astnode));
                        setupDecType(n, 7, NULL );
                        $$ = n;}
    | UNSIGNED { struct astnode *n = malloc(sizeof(struct astnode));
                        setupDecType(n, 8, NULL );
                        $$ = n;}
    | _BOOL {struct astnode *n = malloc(sizeof(struct astnode));
                        setupDecType(n, 9, NULL );
                        $$ = n;}    
    | _COMPLEX { struct astnode *n = malloc(sizeof(struct astnode));
                        setupDecType(n, 10, NULL );
                        $$ = n;}
    | struct_or_union_spec
;
struct_or_union_spec: struct_or_union actually_opening struct_declaration_list close_struct {  //need to check if struct with given name exists first
                                                                                struct symbolNode *temp;
                                                                                struct symbolNode *secondTemp;
                                                                                struct astnode *n = $2;
                                                                                
                                                                                if(scopeNum>0){
                                                                                    temp = findSymbol(scopeList[scopeNum], n->structDec.name, scopeList[scopeNum]->scope);
                                                                                    
                                                                                }
                                                                                else{
                                                                                    temp = findSymbol(lastSymbol[scopeNum+1]->head, n->structDec.name,lastSymbol[scopeNum+1]->scope);
                                                                                    //lastSymbol[scopeNum+1] = insertSymbol(lastSymbol[scopeNum+1]->head,s );
                                                                                }
                                                                                if(temp == lastSymbol[scopeNum+1]){
                                                                                    temp->structCompleteFlag = 1;
                                                                                    secondTemp = findSymbol(lastSymbol[scopeNum+1]->head->previousHead, n->structDec.name,lastSymbol[scopeNum+1]->scope);
                                                                                    if(secondTemp!= NULL && secondTemp->scope == lastSymbol[scopeNum+1]->scope){
                                                                                        secondTemp->structCompleteFlag = 1;
                                                                                        secondTemp->subHead = temp->subHead;
                                                                                        secondTemp->declaredLine = temp->declaredLine;
                                                                                    }
                                                                                }
                                                                                else if(temp != NULL){
                                                                                    temp->structCompleteFlag = 1;
                                                                                    
                                                                                }
                                                                                
                                                                                $$ = n;
                                                                       // printf("STRUCT\n");
                                                                    }
    | struct_or_union  open_struct struct_declaration_list close_struct  
    | struct_or_union IDENT  { struct astnode *n = malloc(sizeof(struct astnode));
                                char temp[100];
                                if($1 == STRUCT ){
                                    sprintf(temp, "struct %s", $2);
                                }
                                else{
                                    sprintf(temp, "union %s", $2);
                                }
                                
                                setupIdent(n,temp );
                                $$ = n;
                                }
;

actually_opening: IDENT  open_struct { 
                    struct symbolNode *s;
                    struct symbolNode *lastStructMem = NULL;
                    struct astnode *n = malloc(sizeof(struct astnode));
                    char buffer[100];
                    sprintf(buffer, "%d", line);
                    //setupIdent(n,$1);
                    setupStructDec(n,$1,buffer);
                    if(scopeNum == -1){
                        s = generateSymbol(line, lastSymbol[0]->head->scopeStart, 0,2, "", n->structDec.name, name,-2, NULL, lastSymbol[scopeNum+1]->head, 0, lastSymbol[scopeNum+1]->nameSpace, 4);
                        s->structCompleteFlag = 0;
                    }
                    else{
                        s = generateSymbol(line, lastSymbol[scopeNum+1]->head->scopeStart, lastSymbol[scopeNum+1]->scope,2, "", n->structDec.name, name,-2, NULL, lastSymbol[scopeNum+1]->head, 0, lastSymbol[scopeNum+1]->nameSpace, 4);
                        s->structCompleteFlag = 0;
                    }
                    scopeNum += 1;
                    nameSpaceNum +=1;
                
                    
                    
                  
                    
                    scopeList[scopeNum] = generateSymbol(line,lastSymbol[scopeNum]->head->scopeStart,lastSymbol[scopeNum]->scope,3,"","",name,-1,NULL, NULL,1, nameSpaceNum, 4); 
                                       
                    lastSymbol[scopeNum+1] = scopeList[scopeNum];
                    scopeList[scopeNum]->previousHead = s->head;
                    s->subHead  = scopeList[scopeNum];
                    if(scopeNum>0){
                        lastSymbol[scopeNum] = insertSymbol(scopeList[scopeNum-1], s);
                    }
                    else{
                        lastSymbol[scopeNum] = insertSymbol(lastSymbol[scopeNum]->head,s );
                    }
                    printSymbol(s);
                    /*if(scopeNum > 0){
                        scopeList[scopeNum-1]->subHead = scopeList[scopeNum];
                    }*/
                    $$ = n;
                }



open_struct: '{'/* { scopeNum += 1;
                    nameSpaceNum +=1;
                    char temp[1024];
                    char buffer[100];
                    struct astnode *n = malloc(sizeof(struct astnode));
                   // sprintf(temp, "nameSpace %d", nameSpaceNum);
                    
                    scopeList[scopeNum] = generateSymbol(line,line,lastSymbol[scopeNum]->scope,3,"","",name,-1,NULL, NULL,1, nameSpaceNum); 
                                       
                    lastSymbol[scopeNum+1] = scopeList[scopeNum];
                    sprintf(buffer, "%d", line);
                    setupIdent(n,buffer );
                    $$ = n;
                    /*if(scopeNum > 0){
                        scopeList[scopeNum-1]->subHead = scopeList[scopeNum];
                    }
                }*/
;

close_struct: '}' {scopeNum-=1;}
;
struct_or_union: STRUCT {$$ = STRUCT;}
    | UNION {$$ = UNION;}
;
struct_declaration_list: struct_declaration { struct symbolNode *s = NULL;
                                                struct symbolNode *lastStructMem = NULL;
                                                            int insertCheck;
                                                            int localStart = scopeList[scopeNum]->head->scopeStart;
                                                            struct astnode *bigN = $1;
                                                            struct astnode *n = bigN;
                                                            //int storeType=2;
                                                            //struct astnode *n = $1;
                                                            while(n != NULL){
                                                                switch(n->nodetype){
                                                                    case 15: s = generateSymbol(line,localStart,lastSymbol[scopeNum+1]->scope,3,n->scalarVar.dataType,n->scalarVar.name, name,15, n, scopeList[scopeNum]->head,0, lastSymbol[scopeNum+1]->nameSpace, 4 );
                                                                        s->parentName = lastSymbol[scopeNum]->identName;
                                                                        lastStructMem = insertSymbol(scopeList[scopeNum], s);
                                                                    
                                                                        printSymbol(lastStructMem);
                                                                        break;
                                                                    case 16:// n->pointer.type = strdup(fullType);
                                                                        s = generateSymbol(line, localStart,lastSymbol[scopeNum+1]->scope,3, n->pointer.type, n->pointer.member->ident.ident,name,16, n, scopeList[scopeNum]->head,0, lastSymbol[scopeNum+1]->nameSpace,4);
                                                                        s->parentName = lastSymbol[scopeNum]->identName;
                                                                        lastStructMem = insertSymbol(scopeList[scopeNum], s);
                                                                        printSymbol(lastStructMem);
                                                                        break;
                                                                    case 17: //n->array.type = strdup(fullType); 
                                                                        s = generateSymbol(line, localStart, lastSymbol[scopeNum+1]->scope,3, n->array.type, n->array.name, name,17, n, scopeList[scopeNum]->head,0, lastSymbol[scopeNum+1]->nameSpace, 4);
                                                                        s->parentName = lastSymbol[scopeNum]->identName;
                                                                        lastStructMem = insertSymbol(scopeList[scopeNum], s);
                                                                        printSymbol(lastStructMem);
                                                                        break;
                                                                    case 18: //n->funcDec.type = strdup(fullType);
                                                                        s = generateSymbol(line, localStart, lastSymbol[scopeNum+1]->scope,1, n->funcDec.type, n->funcDec.name,name,18, n, scopeList[scopeNum]->head,1, lastSymbol[scopeNum+1]->nameSpace, 4);
                                                                        s->parentName = lastSymbol[scopeNum]->identName;
                                                                        lastStructMem = insertSymbol(scopeList[scopeNum], s);
                                                                        printSymbol(lastStructMem);
                                                                        break;
                                                                }
                                                                n = n->next;
                                                            }
                                                            
                                                            //lastSymbol[scopeNum+2] = NULL;

                                                }
    | struct_declaration_list struct_declaration { struct symbolNode *s = NULL;
                                                struct symbolNode *lastStructMem = NULL;
                                                            int insertCheck;
                                                            int localStart = scopeList[scopeNum]->head->scopeStart;
                                                            struct astnode *bigN = $2;
                                                            struct astnode *n = bigN;
                                                            //struct astnode *n = $2;
                                                            while(n != NULL){
                                                                switch(n->nodetype){
                                                                    case 15: s = generateSymbol(line,localStart,lastSymbol[scopeNum+1]->scope,3,n->scalarVar.dataType,n->scalarVar.name, name,15, n, scopeList[scopeNum]->head,0, lastSymbol[scopeNum+1]->nameSpace, 4 );
                                                                        s->parentName = lastSymbol[scopeNum]->identName;
                                                                        lastStructMem = insertSymbol(scopeList[scopeNum], s);
                                                                        printSymbol(lastStructMem);
                                                                        break;
                                                                    case 16:// n->pointer.type = strdup(fullType);
                                                                        s = generateSymbol(line, localStart,lastSymbol[scopeNum+1]->scope,3, n->pointer.type, n->pointer.member->ident.ident,name,16, n, scopeList[scopeNum]->head,0, lastSymbol[scopeNum+1]->nameSpace, 4);
                                                                        s->parentName = lastSymbol[scopeNum]->identName;
                                                                        lastStructMem = insertSymbol(scopeList[scopeNum], s);
                                                                        printSymbol(lastStructMem);
                                                                        break;
                                                                    case 17: //n->array.type = strdup(fullType); 
                                                                        s = generateSymbol(line, localStart, lastSymbol[scopeNum+1]->scope,3, n->array.type, n->array.name, name,17, n, scopeList[scopeNum]->head,0, lastSymbol[scopeNum+1]->nameSpace, 4);
                                                                        s->parentName = lastSymbol[scopeNum]->identName;
                                                                        lastStructMem = insertSymbol(scopeList[scopeNum], s);
                                                                        printSymbol(lastStructMem);
                                                                        break;
                                                                    case 18: //n->funcDec.type = strdup(fullType);
                                                                        s = generateSymbol(line, localStart, lastSymbol[scopeNum+1]->scope,1, n->funcDec.type, n->funcDec.name,name,18, n, scopeList[scopeNum]->head,1, lastSymbol[scopeNum+1]->nameSpace, 4);
                                                                        s->parentName = lastSymbol[scopeNum]->identName;
                                                                        lastStructMem = insertSymbol(scopeList[scopeNum], s);
                                                                        printSymbol(lastStructMem);
                                                                        break;
                                                                }
                                                                n = n->next;
                                                            }
                                                            
                                                            //lastSymbol[scopeNum+2] = NULL;

                                                }
;
struct_declaration: spec_qual_list struct_declarator_list ';' { //struct astnode *n = $2;
                                                                struct astnode *n;
                                                                struct astnode *bigN = $2;
                                                                n = bigN;
                                                                char* fullType = malloc(1024);
                                                                char* temp = malloc(1024);
                                                                struct astnode *type = $1;
                                                                int storeType=2;
                                                                if(type->nodetype == 2){
                                                                    sprintf(fullType, "%s", type->ident.ident);
                                                                }
                                                                else if(type->nodetype == 20){
                                                                    sprintf(fullType, "struct %s", type->structDec.name);
                                                                }
                                                                
                                                                else{
                                                                    if(type->nodetype == 14 || type->nodetype == 21){
                                                                        while(type != NULL){
                                                                            if(type->nodetype != 21){
                                                                                sprintf(temp,"%s %s",fullType, stringFromDecType(type->decType.type));
                                                                                fullType = strdup(temp);
                                                                                type = type->decType.nextType;
                                                                            }
                                                                            else{
                                                                                storeType = type->storageType.storageType;
                                                                                type = type->storageType.nextType;
                                                                            }
                                                                            
                                                                        }
                                                                    }
                                                                }
                                                                while(n!= NULL){
                                                                    switch(n->nodetype){
                                                                        case 2: setupScalar(n,storeType, strdup(fullType),strdup(n->ident.ident));
                                                                                break;
                                                                        case 16: n->pointer.type = strdup(fullType);
                                                                            n->pointer.storageClass = storeType;
                                                                            break;
                                                                        case 17: n->array.type = strdup(fullType); 
                                                                            n->array.storageClass = storeType;
                                                                            break;
                                                                        case 18: n->funcDec.type = strdup(fullType);
                                                                            break;
                                                                    }
                                                                    n = n->next;
                                                                }
                                                            
                                                            
                                                            $$ = bigN;

                                                            }
;
spec_qual_list: type_specifier spec_qual_list { struct astnode *n = $2;
                                                    n->decType.nextType = $1;
                                                
                                                $$ = n;
                                            }
    | type_specifier 
   // | type_qualifier spec_qual_list
  //  | type_qualifier 
;

struct_declarator_list: struct_declarator
    | struct_declarator_list ',' struct_declarator  { struct astnode *n = $3;
                                                        n->next = $1;
                                                        $$ = n;
                                                    }
;
struct_declarator: declarator
    | declarator ':' constexp 
    | ':' constexp 
;
declarator:  pointer direct_declarator { struct astnode *n = malloc(sizeof(struct astnode));
                                        struct astnode *temp = $2;
                                            setupPointer(n, temp);
                                            n->pointer.member = temp;
                                           // lastType = n->nodetype;
                                            $$ = n;
                                            }
    |  direct_declarator  {
                            
                            }
;
direct_declarator: IDENT { struct astnode *n = malloc(sizeof(struct astnode));
                                        setupIdent(n,$1);
                                        $$ = n;
                           }
    | '(' declarator ')'
    | direct_declarator '[' STATIC assexp ']' { struct astnode *n = malloc(sizeof(struct astnode));
                                            setupArray(n, $4->num.number, $1->ident.ident);
                                            $$ = n;

                                            }
    | direct_declarator '[' assexp ']' { struct astnode *n = malloc(sizeof(struct astnode));
                                            setupArray(n, $3->num.number, $1->ident.ident);
                                            $$ = n;

                                            }
    | direct_declarator '[' ']' { struct astnode *n = malloc(sizeof(struct astnode));
                                            setupArray(n, 0,$1->ident.ident);
                                            $$ = n;

                                            }
   
    //| direct_declarator '[' '*' ']'
    //| direct_declarator '(' parameter_type_list ')'
    //| direct_declarator '(' identifier_list ')'
    | direct_declarator '(' ')' { struct astnode *n = malloc(sizeof(struct astnode));
                                //$1 can either be just ident, pointer, or function pointer
                                   /* switch($1->nodetype){
                                        case 2:  setupFuncDec(n,2, $1);
                                        structOrFunc = 1;
                                        
                                        //funcHead = generateSymbol(0,0,1,1,"","","placeholder.c",-1,NULL, funcHead,1);
                                        break;
                                        case 16: setupFuncDec(n,)
                                    }*/
                                    setupFuncDec(n,$1);
                                    if(n->funcDec.isSub == 0){
                                        $$ = n;
                                    }
                                    else{
                                        $$ = $1;
                                    }

                                    //setupFuncDec(n, $1)
                                    }
;

identifier_list: IDENT
    | identifier_list ',' IDENT
;
/*
parameter_type_list: parameter_list
    | parameter_list ',' ELLIPSIS
;
parameter_list: parameter_declaration
    | parameter_list ',' parameter_declaration
;
parameter_declaration: declaration_specifiers declarator
    | declaration_specifiers abstract_declarator
    | declaration_specifiers
;*/
abstract_declarator: pointer
    | pointer direct_abstract_declarator
    | direct_abstract_declarator
;
direct_abstract_declarator: '(' abstract_declarator ')'
    | direct_abstract_declarator '[' assexp ']' { struct astnode *n = malloc(sizeof(struct astnode));
                                            setupArray(n, $3->num.number, $1->ident.ident);
                                            $$ = n;

                                            }
                                            
    | direct_abstract_declarator '[' ']' { struct astnode *n = malloc(sizeof(struct astnode));
                                            setupArray(n, 0,$1->ident.ident);
                                            $$ = n;

                                            }
    | '[' assexp ']' { struct astnode *n = malloc(sizeof(struct astnode));
                                            setupArray(n, $2->num.number,"anonymous");
                                            $$ = n;

                                            }
    | '[' ']' { struct astnode *n = malloc(sizeof(struct astnode));
                                            setupArray(n,0,"anonymous");
                                            $$ = n;

                                            }
    | direct_abstract_declarator '[' '*' ']'
    | '[' '*' ']'
  //  | direct_abstract_declarator '(' parameter_type_list ')'
    | direct_abstract_declarator '('  ')'  { struct astnode *n = malloc(sizeof(struct astnode));
                                //$1 can either be just ident, pointer, or function pointer
                                   /* switch($1->nodetype){
                                        case 2:  setupFuncDec(n,2, $1);
                                        structOrFunc = 1;
                                        
                                        //funcHead = generateSymbol(0,0,1,1,"","","placeholder.c",-1,NULL, funcHead,1);
                                        break;
                                        case 16: setupFuncDec(n,)
                                    }*/
                                    setupFuncDec(n,$1);
                                    if(n->funcDec.isSub == 0){
                                        $$ = n;
                                    }
                                    else{
                                        $$ = $1;
                                    }

                                    
                                    }
   // | '(' parameter_type_list ')' 
    | '(' ')' //no clue what this means
;
pointer: '*' 
    | '*' pointer
;
function_specifier:  INLINE {$$ = INLINE;}
;



compound_statement: '{' '}' 
    | open_scope decl_or_stmt_list close_scope 
;
decl_or_stmt_list: decl_or_stmt
    | decl_or_stmt_list decl_or_stmt
;
open_scope: '{' {   int test = line;
                    char buffer[100];
                    scopeNum += 1; 
                    struct astnode *n = malloc(sizeof(struct astnode));
                    scopeList[scopeNum] = generateSymbol(line-1,test-1,1,1,"","",name,-1,NULL, NULL,1, lastSymbol[scopeNum]->nameSpace,4); 
                    lastSymbol[scopeNum+1] = scopeList[scopeNum];
                    sprintf(buffer, "%d", line);
                    setupIdent(n, buffer);
                    $$ = n;
                    }
;
close_scope: '}' {scopeNum-= 1;}
;
decl_or_stmt: declaration { struct symbolNode *s;
                            struct astnode *bigN = $1;
                            //struct astnode *n = $1;
                            struct astnode *n = bigN;
                            struct symbolNode *tempInserted;
                            int localScope;
                            int localStart = scopeList[scopeNum]->declaredLine;
                            //int typeStore = 2;
                            if(scopeNum ==0){
                                localScope = 1;
                            }
                            else{
                                localScope = 2;
                                scopeList[scopeNum]->previousHead = scopeList[scopeNum-1]->head;
                                scopeList[scopeNum-1]->subHead = scopeList[scopeNum];
                            } 
                            while(n != NULL){
                                switch(n->nodetype){
                                
                                    case 15:
                                    if(strcmp(n->scalarVar.dataType,"incomplete type" ) == 0){
                                        s= generateSymbol(line, localStart, localScope, 2,"", n->scalarVar.name, name, -2, NULL, lastSymbol[scopeNum+1]->head, 0, lastSymbol[scopeNum+1]->nameSpace,4 );
                                        s->structCompleteFlag = 0; 
                                        tempInserted= insertSymbol(lastSymbol[scopeNum+1]->head, s);
                                        if(tempInserted!= 0){
                                            lastSymbol[scopeNum+1] = tempInserted;
                                            printSymbol(lastSymbol[scopeNum+1]);
                                        }
                                    
                                    } 
                                    else{
                                        s = generateSymbol(line,localStart,localScope,0,n->scalarVar.dataType,n->scalarVar.name, name,15, n, scopeList[scopeNum],0, lastSymbol[scopeNum+1]->nameSpace,n->scalarVar.storageClass );
                                        //lastSymbol[scopeNum+1] = insertSymbol(scopeList[scopeNum],s); 
                                        tempInserted= insertSymbol(scopeList[scopeNum], s);
                                        if(tempInserted!= 0){
                                            lastSymbol[scopeNum+1] = tempInserted;
                                            printSymbol(lastSymbol[scopeNum+1]);
                                        }
                                        break;
                                    }
                                        break;
                                    case 16:// n->pointer.type = strdup(fullType);
                                        s = generateSymbol(line, localStart, localScope,0, n->pointer.type, n->pointer.member->ident.ident,name,16, n, scopeList[scopeNum],0, lastSymbol[scopeNum+1]->nameSpace,n->pointer.storageClass);
                                        //lastSymbol[scopeNum+1] = insertSymbol(scopeList[scopeNum], s);
                                        tempInserted= insertSymbol(scopeList[scopeNum], s);
                                        if(tempInserted!= 0){
                                            lastSymbol[scopeNum+1] = tempInserted;
                                            printSymbol(lastSymbol[scopeNum+1]);
                                        }
                                        break;
                                    case 17: //n->array.type = strdup(fullType); 
                                        s = generateSymbol(line, localStart, localScope,0, n->array.type, n->array.name,name,17, n, scopeList[scopeNum],0, lastSymbol[scopeNum+1]->nameSpace, n->array.storageClass);
                                        //lastSymbol[scopeNum+1] = insertSymbol(scopeList[scopeNum], s);
                                        tempInserted= insertSymbol(scopeList[scopeNum], s);
                                        if(tempInserted!= 0){
                                            lastSymbol[scopeNum+1] = tempInserted;
                                            printSymbol(lastSymbol[scopeNum+1]);
                                        }
                                        break;
                                    case 18: //n->funcDec.type = strdup(fullType);
                                        s = generateSymbol(line, localStart, localScope,1, n->funcDec.type, n->funcDec.name, name,18, n, scopeList[scopeNum],1, lastSymbol[scopeNum+1]->nameSpace,4);
                                        //lastSymbol[scopeNum+1] = insertSymbol(scopeList[scopeNum+1], s);
                                        tempInserted= insertSymbol(scopeList[scopeNum], s);
                                        if(tempInserted!= 0){
                                            lastSymbol[scopeNum+1] = tempInserted;
                                            printSymbol(lastSymbol[scopeNum+1]);
                                        }
                                        
                                        break;
                                }
                                n = n->next;
                            }   
                            
                                    
                                

                            
                            
                            //ignore below, not an option because no actual direct function declaration before the compound statement. Need to instead bundled together astnodes
                            }//keep pointer to last inserted symbol. Then when I get here, check type of that symbol to see what scope, then insert as needed

                                 
    | statement

;
statement: compound_statement
    | expr ';'  {printAST($1,0);}
;

//statement: expr ';'{
//                    printAST($1,0);}

//;
expr: assexp 
    | expr ',' assexp {  struct astnode *n = malloc(1024);
                                
                        setupBinop(n,',',$1,$3);
                                
                        $$= n;

                    }

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
    | postexp '[' expr ']' {  struct astnode *sub = malloc(1024);
                                //Need to add in a dereference AST node above the binop.
                                setupBinop(sub,'+',$1,$3);
                                struct astnode *n = malloc(1024);
                                setupGeneral(n, 0, sub);
                                
                                $$= n;

                            }
    | postexp '(' argexplist ')'    {   struct astnode *n = malloc(1024);
                                        setupFunc(n,$1,$3);
                                        
                                        $$ = n;
                                        }
                                     //this is where the functions go

    | postexp '.' IDENT     {struct astnode *n = malloc(1024);
                                setupSelect(n,0,$1,$3);
                                $$= n;
                                }
    | postexp INDSEL IDENT  {struct astnode *n = malloc(1024);
                            //FIX THIS WITH THE EQUIVALENCY
                                setupSelect(n,1,$1,$3);
                                $$= n;
                                }
    | postexp PLUSPLUS      {struct astnode *n = malloc(1024);
                            setupUnop(n,PLUSPLUS,$1);
                            $$ = n;
                        }
    | postexp MINUSMINUS    {struct astnode *n = malloc(1024);
                            setupUnop(n,MINUSMINUS,$1);
                            $$ = n;
                        }
    


;
argexplist : assexp     { struct astnode *n = malloc(1024);
                            setupFuncarg(n,$1,n);
                            n->funcarg.head = n;
                            $$ = n;
                            }
    | argexplist ',' assexp {  struct astnode *n = malloc(1024);
                                
                                setupFuncarg(n,$3,$1);
                                n->funcarg.argCount = $1->funcarg.argCount + 1;
                                n->funcarg.head = $1->funcarg.head;
                                $1->funcarg.next = n;
                                
                            $$= n;

                    }
castexp: unexp  
    | '('typename')' castexp    {   struct astnode *n = malloc(1024);
                                    setupType(n,$2,$4);
                                    $$ = n;
                                }
;

/*
typename: CHAR  {$$ = CHAR;}
    | INT   {$$ = INT;}
    | LONG  { $$ = LONG;}
    | DOUBLE    { $$ = DOUBLE;}
    | FLOAT { $$ = FLOAT;}


;*/
typename: spec_qual_list abstract_declarator
    | spec_qual_list
unaryop: '+'   {$$ = '+';}
    | '-'   {$$ = '-';}
    | '~'   {$$ = '~';}
    | '!'   {$$ = '!';}
;
unexp: postexp
    | PLUSPLUS unexp    {struct astnode *n = malloc(1024);
                            struct astnode *sub = malloc(1024);
                            struct number tempNum;
                            tempNum.value.intVal = 1;
                            tempNum.type = 0;
                            setupNumber(sub,tempNum);
                            setupAssignment(n,PLUSEQ, $2,sub );
                            $$ = n;
                        }
    | MINUSMINUS unexp  {struct astnode *n = malloc(1024);
                        struct astnode *sub = malloc(1024);
                        struct number tempNum;
                        tempNum.value.intVal = 1;
                        tempNum.type = 0;
                        setupNumber(sub,tempNum);
                        setupAssignment(n,MINUSEQ, $2,sub );
                        $$ = n;
                        }
    | unaryop castexp   {struct astnode *n = malloc(1024);
                        setupUnop(n,$1,$2);
                        $$ = n;
                        }
    | '&' castexp       { struct astnode *n = malloc(1024);
                            setupGeneral(n,1,$2);
                            $$ = n;
                            }
    | '*' castexp       { struct astnode *n = malloc(1024);
                            setupGeneral(n,0,$2);
                            $$= n;
                            } 
    | SIZEOF unexp  {struct astnode *n = malloc(1024);
                        setupGeneral(n,2,$2);
                        $$ = n;
                        }
    | SIZEOF '('typename')' {struct astnode *n = malloc(1024);
                                struct astnode *type = malloc(1024);
                                setupType(type,$3,NULL);
                            setupGeneral(n,2,type);
                            $$ = n;
                            }
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
                                
                                $$= n;

                            }
    | addexp '-' multexp    {  struct astnode *n = malloc(1024);
                                
                                setupBinop(n,'-',$1,$3);
                                
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
    | relexp '<' shiftexp { struct astnode *n = malloc(1024);
                            setupCompop(n,'<', $1,$3);
                            $$ = n;

                            }
    | relexp '>' shiftexp   { struct astnode *n = malloc(1024);
                            setupCompop(n,'>', $1,$3);
                            $$ = n;

                            }
    | relexp LTEQ shiftexp  { struct astnode *n = malloc(1024);
                            setupCompop(n,LTEQ, $1,$3);
                            $$ = n;

                            }
    | relexp GTEQ shiftexp  { struct astnode *n = malloc(1024);
                            setupCompop(n,GTEQ, $1,$3);
                            $$ = n;

                            }
;
eqexp: relexp 
    | eqexp EQEQ relexp { struct astnode *n = malloc(1024);
                            setupCompop(n,EQEQ, $1,$3);
                            $$ = n;

                            }
    | eqexp NOTEQ relexp    { struct astnode *n = malloc(1024);
                            setupCompop(n,NOTEQ, $1,$3);
                            $$ = n;

                            }
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
    | logorexp LOGOR logandexp  {  struct astnode *n = malloc(1024);
                                
                                setupLogop(n,LOGOR,$1,$3);
                                
                                $$= n;

                            }
;
condexp: logorexp
    | logorexp '?' expr ':' condexp {  struct astnode *n = malloc(1024);
                                        
                                        setupTernary(n,$1,$3,$5);
                                        
                                        $$= n;

                                    }
;
assexp: condexp 
    | unexp assop assexp    {  struct astnode *n = malloc(1024);
                                        
                                setupAssignment(n,$2,$1,$3);
                                        
                                $$= n;

                            }
   
;
assop: '=' {$$ = '=';}
    | TIMESEQ {$$ = TIMESEQ;}
    | DIVEQ {$$ = DIVEQ;}
    | MODEQ {$$ = MODEQ;}
    | PLUSEQ {$$ = PLUSEQ;}
    | MINUSEQ   {$$ = MINUSEQ;}
    | SHLEQ { $$ = SHLEQ;}
    | SHREQ { $$ = SHREQ;}
    | ANDEQ {$$ = ANDEQ;}
    | XOREQ {$$ = XOREQ;}
    | OREQ  {$$ = OREQ;}

;
constexp: condexp
;
%%
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
void setupDecType(struct astnode *n, int type, struct astnode *next ){
    n->nodetype = 14;
    n->decType.type = type;
    n->decType.nextType = next;
}
void setupScalar(struct astnode *n, int storage, char* type, char* name){
    n->nodetype = 15;
    n->scalarVar.storageClass = storage;
    n->scalarVar.dataType = type;
    n->scalarVar.name = name;
}
void setupPointer(struct astnode *n, struct astnode *pointerMember){
    n->nodetype = 16;
    n->pointer.member = pointerMember;
    n->array.type = "";
}
void setupArray(struct astnode *n, int size, char* name){
    n->nodetype = 17;
    n->array.size = size;
    n->array.name = name;
    n->array.type = "";
}
void setupFuncDec(struct astnode *n, struct astnode *node){
    n->nodetype = 18;
    struct astnode *temp;
    n->funcDec.type = "int ";
    n->funcDec.astType = node->nodetype;
    n->funcDec.isSub = 0;
    switch(node->nodetype){
        case 2: n->funcDec.name = node->ident.ident;
        break;
        case 16: n->funcDec.name = node->pointer.name;
        break;
        case 18: temp = node->funcDec.decNode; 
        n->funcDec.isSub = 1;
        node->funcDec.decNode = n;
       
        break;
        
    }
    if(node->nodetype == 18){
        n->funcDec.decNode = temp;
    }
    else{
        n->funcDec.decNode = node;
    }
    
}

void setupStructDec(struct astnode *n, char* name, char* line){
    n->nodetype = 20;
    n->structDec.name = name;
    n->structDec.lineNum = line;
}

void setupStorage(struct astnode *n, int storageType){
    n->nodetype = 21;
    n->storageType.storageType = storageType;
}

int main(){
    int t;
    
    base = generateSymbol(0,1,0,0,"","",name,-1,NULL, base,0, 0, 4);
    lastSymbol[0] = base;
   // generateSymbol(int decLine, int scopeStart, int scope, char* type, char* name,char* fileName,int astType, struct astnode *member, struct symbolNode *head)
    funcHead = NULL;
    last = NULL;
    lastType = -1;
    structOrFunc = -1;
    scopeNum = -1;
    scopeNum = -1;
    nameSpaceNum = 0;
    yyparse();



}