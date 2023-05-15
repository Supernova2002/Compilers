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
    
    int endBlock;
    enum sections{
        unknown,
        data,
        text,
        ro_data
    }section;
    struct symbolNode *base;
    struct symbolNode *last;
    struct symbolNode *funcHead;
    int lastOpcode;
    char *lastSize;
    int isArraySet;
    int scratchReg;
    struct quad *firstQuad;
    struct symbolNode *scopeList[1024];
    struct symbolNode *lastSymbol[1024];
    struct symbolNode *scopeList[1024];
    struct symbolNode *allScopes[1024];
    char *stringList[1024];
    int scratchStart[1024];
    struct quad *blockList[1024];
    struct quad *globalList;
    int quadStringCount;
    int assStringCount;
    struct quad *lastGlobal;
    int blockNums[1024];
    int lastType;
    int funcCount;
    struct astnode *lastDim;
    struct astnode *rightOp;
    int cur_bb;
    int bbToInsert;
    int start_loop;
    int end_loop;
    int numDim;
    int lastScopeType;
    int scopeNum;
    int scopeTotal;
    int quadScopeCount;
    int nameSpaceNum;
    int isFunction;
    int isDeref;
    int ebpOffset;
    int isPointer;
    int tempVarCountNum; //number of temporary variable for quads list
    int branchNum; //number of branches 
    int structOrFunc; //0 if struct, 1 if funct, -1 if neither
    FILE *fp;
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
        s->ebpOffset = -1;
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
            case 17: 
                if(member->array.nextDimension != NULL){
                    printf("\tarray of %d elements of type\n", member->array.size );
                    printType(member->array.nextDimension);
                }
                else{
                    printf("\tarray of %d elements of type\n\t %s\t\n", member->array.size, member->array.type );
                }
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
        if(symbol->identName != "" && symbol->astType != 24 ){
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
    char *getOpcodeString(int opcode){
        switch(opcode){
            case opLEA: return "LEA";
            case opADD: return "ADD";
            case opSUB: return "SUB";
            case opMUL: return "MUL";
            case opDIV: return "DIV";
            case opMOD: return "MOD";
            case opINC: return "INC";
            case opDEC: return "DEC";
            case opLOAD: return "LOAD";
            case opBR: return "BR";
            case opBRGE: return "BRGE";
            case opBRLE: return "BRLE";
            case opBRNE: return "BRNE";
            case opBREQ: return "BREQ";
            case opBRGT: return "BRGT";
            case opBRLT: return "BRLT";
            case opRET: return "RET";
            case opARGBEGIN: return "ARGBEGIN";
            case opARG: return "ARG";
            case opCALL: return "CALL";
            case opMOV: return "MOV";
            case opSTORE: return "STORE";
            case opCMP: return "CMP";
            case opCOMM: return "COMM";
            case opFUNC: return "FUNC";
            case opSTRING: return "STRING";
        }
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
%left IF
%left ELSE
%type <astnode_p> start  statement expr primexp postexp castexp unexp multexp addexp shiftexp relexp eqexp andexp exorexp inorexp logandexp logorexp condexp assexp constexp argexplist
%type <astnode_p> declaration declarator_list declaration_specifiers function_definition declarator compound_statement  direct_declarator struct_or_union_spec struct_declaration_list struct_declaration struct_declarator_list struct_declarator 
%type <astnode_p> spec_qual_list pointer decl_or_stmt_list decl_or_stmt identifier_list type_specifier type_qualifier open_scope  open_struct actually_opening direct_abstract_declarator abstract_declarator storage_class_spec
%type <astnode_p> labeled_statement selection_statement iteration_statement jump_statement open_function_param typename
%type <operator> assop unaryop      struct_or_union function_specifier 
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

                            }
    | function_definition
;
declaration:  declaration_specifiers declarator_list ';' { struct astnode *n;
                                                            struct astnode *bigN = $2;
                                                            n = bigN;
                                                            //struct astnode *n = malloc(sizeof(struct astnode));
                                                            char* fullType = malloc(1024);
                                                            sprintf(fullType, "");
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
                                                                            case 17: //n->pointer.member->array.type = strdup(fullType);
                                                                                    struct astnode *tempNext = n->next; 
                                                                                    struct astnode *tempArray = n->pointer.member;
                                                                                    while(tempArray != NULL){
                                                                                        char *pointerTemp = malloc(1024);
                                                                                        sprintf(pointerTemp,"pointer to %s", strdup(fullType));
                                                                                       // strcat(tempArray->array.type, strdup(fullType))
                                                                                        tempArray->array.storageClass = storeType;
                                                                                        tempArray->array.type = strdup(pointerTemp);
                                                                                        tempArray = tempArray->array.nextDimension;
                                                                                    }
                                                                                    
                                                                                    n = n->pointer.member;
                                                                                    n->next = tempNext;
                                                                                    bigN = n;
                                                                                    //n->pointer.name = n->pointer.member->array.name;
                                                                                    break;
                                                                            case 18: n->pointer.member->funcDec.type = strdup(fullType);
                                                                                    n->pointer.name = n->pointer.member->funcDec.name;
                                                                                    break;
                                                                        }
                                                                        //s = generateSymbol(-1, 0, 0,0, n->pointer.type, n->pointer.member->ident.ident,"tempName.c",16, n, base);
                                                                        //insertCheck = insertSymbol(base, s);
                                                                        break;
                                                                    case 17:
                                                                    
                                                                        struct astnode *tempArray = n;
                                                                        while(tempArray != NULL){
                                                                            tempArray->array.type = strdup(fullType); 
                                                                            tempArray->array.storageClass = storeType;
                                                                            tempArray = tempArray->array.nextDimension;
                                                                        }
                                                                             
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
                                    sprintf(fullType, "");
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
                                                                            
                                                                            struct symbolNode *symbolTemp;
                                                                            int localStart = lastSymbol[scopeNum+1]->head->scopeStart;
                                                                            char* fullType = malloc(1024);
                                                                            sprintf(fullType, "");
                                                                            char* temp = malloc(1024);
                                                                            struct astnode *type = $1;
                                                                            int storeType=2;
                                                                            if($3){
                                                                                struct astnode *exprChain = $3->multDec.right;
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
                                                                                        s = generateSymbol(atoi($3->multDec.left->ident.ident),localStart,0,0,n->scalarVar.dataType,n->scalarVar.name, name,15, n, lastSymbol[scopeNum+1]->head,0, lastSymbol[scopeNum+1]->nameSpace,4 );
                                                                                        tempInserted= insertSymbol(lastSymbol[scopeNum+1]->head, s);
                                                                                        if(tempInserted!= 0){
                                                                                            lastSymbol[scopeNum+1] = tempInserted;
                                                                                            printSymbol(lastSymbol[scopeNum+1]);
                                                                                        }
                                                                                        break;
                                                                                    case 16:// n->pointer.type = strdup(fullType);
                                                                                        n->pointer.type = strdup(fullType);
                                                                                        s = generateSymbol(atoi($3->multDec.left->ident.ident), localStart, 0,0, n->pointer.type, n->pointer.member->ident.ident,name,16, n, lastSymbol[scopeNum+1]->head,0, lastSymbol[scopeNum+1]->nameSpace,4);
                                                                                        tempInserted= insertSymbol(lastSymbol[scopeNum+1]->head, s);
                                                                                        if(tempInserted!= 0){
                                                                                            lastSymbol[scopeNum+1] = tempInserted;
                                                                                            printSymbol(lastSymbol[scopeNum+1]);
                                                                                        }
                                                                                        break;
                                                                                    case 17: //n->array.type = strdup(fullType); 
                                                                                        n->array.type = strdup(fullType);
                                                                                        s = generateSymbol(atoi($3->multDec.left->ident.ident), localStart, 0,0, n->array.type, n->array.name,name,17, n, lastSymbol[scopeNum+1]->head,0, lastSymbol[scopeNum+1]->nameSpace,4);
                                                                                        tempInserted= insertSymbol(lastSymbol[scopeNum+1]->head, s);
                                                                                        if(tempInserted!= 0){
                                                                                            lastSymbol[scopeNum+1] = tempInserted;
                                                                                            printSymbol(lastSymbol[scopeNum+1]);
                                                                                        }
                                                                                        break;
                                                                                    case 18: n->funcDec.type = strdup(fullType);
                                                                                        
                                                                                        s = generateSymbol(atoi($3->multDec.left->ident.ident), localStart, 0,1, n->funcDec.type, n->funcDec.name, name ,18, n, lastSymbol[scopeNum+1]->head,1, lastSymbol[scopeNum+1]->nameSpace, 4);
                                                                                        symbolTemp = findSymbol(lastSymbol[scopeNum+1]->head, s->identName, 0);
                                                                                        if(symbolTemp == NULL){
                                                                                            tempInserted= insertSymbol(lastSymbol[scopeNum+1]->head, s);
                                                                                            if(tempInserted!= 0){
                                                                                                lastSymbol[scopeNum+1] = tempInserted;
                                                                                                scopeList[scopeNum+1]->previousHead = lastSymbol[scopeNum+1]->head;
                                                                                                lastSymbol[scopeNum+1]->subHead = scopeList[scopeNum+1];
                                                                                                
                                                                                                
                                                                                                printSymbol(lastSymbol[scopeNum+1]);
                                                                                                
                                                                                            }
                                                                                        }
                                                                                        else{
                                                                                            symbolTemp = s;
                                                                                            
                                                                                            scopeList[scopeNum+1]->previousHead = symbolTemp->head;
                                                                                            symbolTemp->subHead = scopeList[scopeNum+1];
                                                                                            printSymbol(symbolTemp);
                                                                                        }
                                                                                        
                                                                                        
                                                                                        //scopeList[scopeNum+1] = NULL;
                                                                                        //need to actually store the last pointer inserted in a given scope
                                                                                        break;

                                                                                        
                                                                                    }
                                                                                    lastSymbol[scopeNum+2] = NULL;
                                                                                    scratchStart[funcCount] = ebpOffset;
                                                                                    branchNum++;
                                                                                    cur_bb++;
                                                                                    bbToInsert++;
                                                                                    quadScopeCount++;
                                                                                    gen_quad(exprChain);
                                                                                    
                                                                                    //printAST(exprChain,0,s->subHead);
                                                                                 last = last->next;
                                                                                    while(last){
                                                                                        
                                                                                        gen_dec(last->member);
                                                                                        last = last->next;
                                                                                    }
                                                                                    if(!lastGlobal){
                                                                                        lastGlobal = globalList;
                                                                                    }
                                                                                    else{
                                                                                        lastGlobal = lastGlobal->nextQuad;
                                                                                    }
                                                                                    print_globals(lastGlobal);
                                                                                    if(lastGlobal){
                                                                                        while(lastGlobal->nextQuad){
                                                                                            lastGlobal = lastGlobal->nextQuad;
                                                                                        }
                                                                                    }
                                                                                    
                                                                                    last = lastSymbol[scopeNum+1];
                                                                                    
                                                                                    
                                                                                    
                                                                                    print_quads(blockList,endBlock, branchNum,blockNums);
                                                                                    emit(opRET,NULL,NULL,NULL);
                                                                                    endBlock = cur_bb;
                                                                                    quadScopeCount++;
                                                                                    ebpOffset = 4;
                                                                                    funcCount++;
                                                                                    //printf("GET ME THE FUCK OUT OF HERE\n");
                                                                                    /*while(exprChain != NULL){
                                                                                        printAST(exprChain,0,lastSymbol[scopeNum+1]->subHead);
                                                                                        exprChain = exprChain->next;
                                                                                    }*/
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
                                                                                switch(n->nodetype){
                                                                                    case 2: setupScalar(n,storeType, strdup(fullType),strdup(n->ident.ident));
                                                                                        s = generateSymbol(line,localStart,0,0,n->scalarVar.dataType,n->scalarVar.name, name,15, n, lastSymbol[scopeNum+1]->head,0, lastSymbol[scopeNum+1]->nameSpace,4 );
                                                                                        tempInserted= insertSymbol(lastSymbol[scopeNum+1]->head, s);
                                                                                        if(tempInserted!= 0){
                                                                                            lastSymbol[scopeNum+1] = tempInserted;
                                                                                            printSymbol(lastSymbol[scopeNum+1]);
                                                                                        }
                                                                                        break;
                                                                                    case 16:// n->pointer.type = strdup(fullType);
                                                                                        n->pointer.type = strdup(fullType);
                                                                                        s = generateSymbol(line, localStart, 0,0, n->pointer.type, n->pointer.member->ident.ident,name,16, n, lastSymbol[scopeNum+1]->head,0, lastSymbol[scopeNum+1]->nameSpace,4);
                                                                                        tempInserted= insertSymbol(lastSymbol[scopeNum+1]->head, s);
                                                                                        if(tempInserted!= 0){
                                                                                            lastSymbol[scopeNum+1] = tempInserted;
                                                                                            printSymbol(lastSymbol[scopeNum+1]);
                                                                                        }
                                                                                        break;
                                                                                    case 17: //n->array.type = strdup(fullType); 
                                                                                        n->array.type = strdup(fullType);
                                                                                        s = generateSymbol(line, localStart, 0,0, n->array.type, n->array.name,name,17, n, lastSymbol[scopeNum+1]->head,0, lastSymbol[scopeNum+1]->nameSpace,4);
                                                                                        tempInserted= insertSymbol(lastSymbol[scopeNum+1]->head, s);
                                                                                        if(tempInserted!= 0){
                                                                                            lastSymbol[scopeNum+1] = tempInserted;
                                                                                            printSymbol(lastSymbol[scopeNum+1]);
                                                                                        }
                                                                                        break;
                                                                                    case 18: n->funcDec.type = strdup(fullType);
                                                                                        
                                                                                        s = generateSymbol(line, localStart, 0,1, n->funcDec.type, n->funcDec.name, name ,18, n, lastSymbol[scopeNum+1]->head,1, lastSymbol[scopeNum+1]->nameSpace, 4);
                                                                                        symbolTemp = findSymbol(lastSymbol[scopeNum+1]->head, s->identName, 0);
                                                                                        if(symbolTemp == NULL){
                                                                                            tempInserted= insertSymbol(lastSymbol[scopeNum+1]->head, s);
                                                                                            if(tempInserted!= 0){
                                                                                                lastSymbol[scopeNum+1] = tempInserted;
                                                                                                //scopeList[scopeNum+1]->previousHead = lastSymbol[scopeNum+1]->head;
                                                                                                //lastSymbol[scopeNum+1]->subHead = scopeList[scopeNum+1];
                                                                                                
                                                                                                
                                                                                                printSymbol(lastSymbol[scopeNum+1]);
                                                                                                
                                                                                            }
                                                                                        }
                                                                                        else{
                                                                                            symbolTemp = s;
                                                                                            
                                                                                            scopeList[scopeNum+1]->previousHead = symbolTemp->head;
                                                                                            symbolTemp->subHead = scopeList[scopeNum+1];
                                                                                            printSymbol(symbolTemp);
                                                                                        }
                                                                                        
                                                                                        
                                                                                        //scopeList[scopeNum+1] = NULL;
                                                                                        //need to actually store the last pointer inserted in a given scope
                                                                                        break;

                                                                                        
                                                                                    }
                                                                                    lastSymbol[scopeNum+2] = NULL;
                                                                            }
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
struct_or_union_spec: struct_or_union actually_opening struct_declaration_list close_struct {  
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
                    scopeTotal +=1;
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
                    allScopes[scopeTotal] = lastSymbol[scopeNum+1]->head;
                    
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

close_struct: '}' {scopeNum-=1;
                    scopeTotal +=1;
                    allScopes[scopeTotal] = lastSymbol[scopeNum+1]->head;
                    }
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
                                                                sprintf(fullType, "");
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
    | '(' declarator ')' {$$ = $2; }
    | direct_declarator '[' STATIC assexp ']' { struct astnode *n = malloc(sizeof(struct astnode));
                                            setupArray(n, $4->num.number, $1->ident.ident);
                                            $$ = n;

                                            }
    | direct_declarator '[' assexp ']' { struct astnode *n = malloc(sizeof(struct astnode));
                                            if($1->nodetype ==17){
                                                struct astnode *previous = $1;
                                                while(previous->array.nextDimension != NULL){
                                                    previous = previous->array.nextDimension;
                                                }
                                                setupArray(n, $3->num.number, $1->array.name);
                                                previous->array.nextDimension = n;
                                                $$ = previous;
                                            }
                                            else{
                                               setupArray(n, $3->num.number, $1->ident.ident); 
                                               $$ = n;
                                            }
                                            

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



compound_statement: '{' '}'  {$$ = NULL;}
    | open_scope decl_or_stmt_list close_scope  { struct astnode *n = malloc(sizeof(struct astnode));
                                                    setupMult(n, $1, $2);
                                                    $$ = n;}
;
decl_or_stmt_list: decl_or_stmt
    | decl_or_stmt_list decl_or_stmt {struct astnode *n = $1;
                                        struct astnode *littleN = n;
                                        while(littleN->next != NULL){
                                            littleN = littleN->next;
                                        }
                                        littleN->next = $2;
                                        $$ = n;
                                        }
;
open_scope: '{' {   int test = line;
                    
                    char buffer[100];
                    scopeNum += 1; 
                    scopeTotal +=1;
                    struct astnode *n = malloc(sizeof(struct astnode));
                    scopeList[scopeNum] = generateSymbol(line-1,test-1,1,1,"","",name,-1,NULL, NULL,1, lastSymbol[scopeNum]->nameSpace,4); 
                    lastSymbol[scopeNum+1] = scopeList[scopeNum];
                    
                    sprintf(buffer, "%d", line);
                    setupIdent(n, buffer);
                    if(scopeNum == 0){
                        scopeList[scopeNum]->previousHead = base;
                    }
                    else{
                        scopeList[scopeNum]->previousHead = scopeList[scopeNum-1]->head;
                                scopeList[scopeNum-1]->subHead = scopeList[scopeNum];
                    }
                    allScopes[scopeTotal] = lastSymbol[scopeNum+1]->head;
                    $$ = n;
                    }
;
close_scope: '}' {scopeNum-= 1;
                    
                    scopeTotal++;
                    allScopes[scopeTotal] = lastSymbol[scopeNum+1]->head;
                }
;
decl_or_stmt: declaration { struct symbolNode *s;
                            struct astnode *bigN = $1;
                            struct astnode *n = bigN;
                            struct symbolNode *tempInserted;
                            int localScope;
                            int localStart = scopeList[scopeNum]->declaredLine;
                            if(scopeNum ==0){
                                localScope = 1;
                                
                            }
                            else{
                                localScope = 2;
                                
                            } 
                            while(n != NULL){
                                switch(n->nodetype){
                                
                                    case 15:
                                    if(strcmp(n->scalarVar.dataType,"incomplete type" ) == 0){
                                        s= generateSymbol(line, localStart, localScope, 2,"", n->scalarVar.name, name, -2, NULL, lastSymbol[scopeNum+1]->head, 0, lastSymbol[scopeNum+1]->nameSpace,4 );
                                        s->structCompleteFlag = 0; 
                                        tempInserted= insertSymbol(lastSymbol[scopeNum+1]->head, s);
                                        if(tempInserted!= 0){
                                            ebpOffset +=4;
                                            if(ebpOffset%4 !=0){
                                                ebpOffset+=ebpOffset%4;
                                            }
                                            lastSymbol[scopeNum+1] = tempInserted;
                                            printSymbol(lastSymbol[scopeNum+1]);
                                        }
                                    
                                    } 
                                    else{
                                        s = generateSymbol(line,localStart,localScope,0,n->scalarVar.dataType,n->scalarVar.name, name,15, n, scopeList[scopeNum],0, lastSymbol[scopeNum+1]->nameSpace,n->scalarVar.storageClass );
                                        s->ebpOffset  = ebpOffset;
                                        
                                        //lastSymbol[scopeNum+1] = insertSymbol(scopeList[scopeNum],s); 
                                        tempInserted= insertSymbol(scopeList[scopeNum], s);
                                        if(tempInserted!= 0){
                                            ebpOffset +=4;
                                            if(ebpOffset%4 !=0){
                                                ebpOffset+=ebpOffset%4;
                                            }
                                            lastSymbol[scopeNum+1] = tempInserted;
                                            printSymbol(lastSymbol[scopeNum+1]);
                                        }
                                        break;
                                    }
                                        break;
                                    case 16:// n->pointer.type = strdup(fullType);
                                        s = generateSymbol(line, localStart, localScope,0, n->pointer.type, n->pointer.member->ident.ident,name,16, n, scopeList[scopeNum],0, lastSymbol[scopeNum+1]->nameSpace,n->pointer.storageClass);
                                        s->ebpOffset = ebpOffset;
                                        //lastSymbol[scopeNum+1] = insertSymbol(scopeList[scopeNum], s);
                                        tempInserted= insertSymbol(scopeList[scopeNum], s);
                                        if(tempInserted!= 0){
                                            ebpOffset +=4;
                                            if(ebpOffset%4 !=0){
                                                ebpOffset+=ebpOffset%4;
                                            }
                                            lastSymbol[scopeNum+1] = tempInserted;
                                            printSymbol(lastSymbol[scopeNum+1]);
                                        }
                                        break;
                                    case 17: //n->array.type = strdup(fullType); 
                                        s = generateSymbol(line, localStart, localScope,0, n->array.type, n->array.name,name,17, n, scopeList[scopeNum],0, lastSymbol[scopeNum+1]->nameSpace, n->array.storageClass);
                                        s->ebpOffset = ebpOffset;
                                        //lastSymbol[scopeNum+1] = insertSymbol(scopeList[scopeNum], s);
                                        tempInserted= insertSymbol(scopeList[scopeNum], s);
                                        if(tempInserted!= 0){
                                            ebpOffset += (4*n->array.size);
                                            if(ebpOffset%(4*n->array.size)!= 0){
                                                ebpOffset+=ebpOffset%(4*n->array.size);
                                            }
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

                                 
    | statement {struct astnode *n = $1;
                    $$ = n;
                    }

;
statement: compound_statement
    | labeled_statement
    | selection_statement
    | iteration_statement
    | jump_statement
    | expr ';' // {printAST($1,0);}
;

labeled_statement: IDENT ':' statement  {  //need to allow for forward declarations, i.e use in a goto before actual def, which installs it as incomplete
                                            //similar to how I handled structs
                                         struct symbolNode *temp;
                                         struct symbolNode *secondTemp;
                                         struct astnode *n = malloc(sizeof(struct astnode));
                                         setupLabel(n,$1,$3);
                                         struct symbolNode *s = generateSymbol(line,lastSymbol[scopeNum+1]->scopeStart, lastSymbol[scopeNum+1]->scope, 4, "", $1, name, 24, n, lastSymbol[scopeNum+1]->head, 0, lastSymbol[scopeNum+1]->nameSpace, 2);

                                         lastSymbol[scopeNum+1] = insertSymbol(lastSymbol[scopeNum+1]->head, s);
                                         temp = findSymbol(scopeList[scopeNum], n->label.name, scopeList[scopeNum]->scope);
                                         if(temp == lastSymbol[scopeNum+1]){
                                            temp->structCompleteFlag = 1;
                                            secondTemp = findSymbol(lastSymbol[scopeNum+1]->head->previousHead, n->structDec.name,lastSymbol[scopeNum+1]->scope);
                                            if(secondTemp!= NULL && secondTemp->scope == lastSymbol[scopeNum+1]->scope){
                                                secondTemp->structCompleteFlag = 1;
                                                secondTemp->member->label.labeled  = temp->member->label.labeled;
                                                secondTemp->declaredLine = temp->declaredLine;
                                            }
                                        }
                                        else if(temp != NULL){
                                            temp->structCompleteFlag = 1;
                                            
                                        }
                                        
                                        
                                         

                                         $$ = n;
                                            }
    | CASE constexp ':' statement  {  struct astnode *n = malloc(sizeof(struct astnode));
                                        if($4->nodetype == 19){
                                            setupCase(n,$2,$4->multDec.right);
                                        }
                                        else{
                                            setupCase(n,$2, $4 );
                                        }
                                        $$ = n;
                                        }

    | DEFAULT ':' statement  {  struct astnode *n = malloc(sizeof(struct astnode));
                                        if($3->nodetype == 19){
                                            setupCase(n,NULL,$3->multDec.right);
                                        }
                                        else{
                                            setupCase(n,NULL, $3 );
                                        }
                                        $$ = n;
                                        }



selection_statement: IF '(' expr ')' statement %prec IF   { struct astnode *n = malloc(sizeof(struct astnode));
                                                            struct astnode *temp = $5;
                                                            if(temp->nodetype == 19){
                                                                setupIf(n,$3,$5->multDec.right,NULL);
                                                            }
                                                            else{
                                                                setupIf(n,$3,$5,NULL);
                                                            }
                                                            
                                                            $$ = n;

                                                                }
    | IF '(' expr ')' statement ELSE statement{ struct astnode *n = malloc(sizeof(struct astnode));
                                                            struct astnode *temp = $5;
                                                            if(temp->nodetype == 19){
                                                                setupIf(n,$3,$5->multDec.right,$7->multDec.right);
                                                            }
                                                            else{
                                                                setupIf(n,$3,$5,$7->multDec.right);
                                                            }
                                                            
                                                            $$ = n;

                                                                }
    | SWITCH '(' expr ')' statement {  struct astnode *n = malloc(sizeof(struct astnode));
                                        if($5->nodetype == 19){
                                            setupSwitch(n,$3,$5->multDec.right);
                                        }
                                        else{
                                            setupSwitch(n,$3, $5 );
                                        }
                                        $$ = n;
                                        }


iteration_statement: WHILE '(' expr ')' statement { struct astnode *n = malloc(sizeof(struct astnode));
                                            struct astnode *temp = $5;
                                            if(temp->nodetype == 19){
                                                setupIterator(n,$3, NULL,NULL, $5->multDec.right,2 );
                                            }
                                            else{
                                                setupIterator(n,$3, NULL,NULL, $5,1 );
                                            }
                                            
                                            $$ = n;

                                            }
    | DO statement WHILE '(' expr ')' ';' { struct astnode *n = malloc(sizeof(struct astnode));
                                            struct astnode *temp = $2;
                                            if(temp->nodetype == 19){
                                                setupIterator(n,$2->multDec.right,NULL ,NULL, $5,1 );
                                            }
                                            else{
                                                setupIterator(n,$2, NULL,NULL, $5,1 );
                                            }
                                            
                                            $$ = n;

                                            }
    | FOR '(' expr ';' expr ';' expr  ')' statement     { struct astnode *n = malloc(sizeof(struct astnode));
                                                            struct astnode *temp = $9;
                                                            if(temp->nodetype == 19){
                                                               setupIterator(n,$3,$5,$7,$9->multDec.right, 0); 
                                                            }
                                                            else{
                                                                setupIterator(n,$3,$5,$7,$9, 0);
                                                            }
                                                            $$ = n;

                                                        }
    | FOR '(' expr ';' expr ';'   ')' statement { struct astnode *n = malloc(sizeof(struct astnode));
                                                            struct astnode *temp = $8;
                                                            if(temp->nodetype == 19){
                                                               setupIterator(n,$3,$5,NULL,$8->multDec.right, 0); 
                                                            }
                                                            else{
                                                                setupIterator(n,$3,$5,NULL,$8, 0);
                                                            }
                                                            $$ = n;

                                                        }
    | FOR '(' expr ';'  ';' expr ')' statement { struct astnode *n = malloc(sizeof(struct astnode));
                                                            struct astnode *temp = $8;
                                                            if(temp->nodetype == 19){
                                                               setupIterator(n,$3,NULL,$6,$8->multDec.right, 0); 
                                                            }
                                                            else{
                                                                setupIterator(n,$3,NULL,$6,$8, 0);
                                                            }
                                                            $$ = n;

                                                        }
    | FOR '('  ';' expr ';' expr ')' statement { struct astnode *n = malloc(sizeof(struct astnode));
                                                            struct astnode *temp = $8;
                                                            if(temp->nodetype == 19){
                                                               setupIterator(n,NULL,$4,$6,$8->multDec.right, 0); 
                                                            }
                                                            else{
                                                                setupIterator(n,NULL,$4,$6,$8, 0);
                                                            }
                                                            $$ = n;

                                                        }
    | FOR '(' expr ';'  ';'   ')' statement { struct astnode *n = malloc(sizeof(struct astnode));
                                                            struct astnode *temp = $7;
                                                            if(temp->nodetype == 19){
                                                               setupIterator(n,$3,NULL,NULL,$7->multDec.right, 0); 
                                                            }
                                                            else{
                                                                setupIterator(n,$3,NULL,NULL,$7, 0);
                                                            }
                                                            $$ = n;

                                                        }
    | FOR '('  ';' expr ';'   ')' statement { struct astnode *n = malloc(sizeof(struct astnode));
                                                            struct astnode *temp = $7;
                                                            if(temp->nodetype == 19){
                                                               setupIterator(n,NULL,$4,NULL,$7->multDec.right, 0); 
                                                            }
                                                            else{
                                                                setupIterator(n,NULL,$4,NULL,$7, 0);
                                                            }
                                                            $$ = n;

                                                        }
    | FOR '('  ';'  ';' expr  ')' statement { struct astnode *n = malloc(sizeof(struct astnode));
                                                            struct astnode *temp = $7;
                                                            if(temp->nodetype == 19){
                                                               setupIterator(n,NULL,NULL,$5,$7->multDec.right, 0); 
                                                            }
                                                            else{
                                                                setupIterator(n,NULL,NULL,$5,$7, 0);
                                                            }
                                                            $$ = n;

                                                        }
   //might be dropping support for below as only seems to work with initialized declarations
   /* | FOR '(' declaration expr ';' expr ')' statement  { struct symbolNode *s;
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
                            struct astnode *newN = malloc(sizeof(struct astnode));
                            struct astnode *temp = $7;
                            if(temp->nodetype == 19){
                                setupIterator(n,$4,NULL,$5,$7->multDec.right); 
                            }
                            else{
                                setupIterator(n,NULL,NULL,$5,$7);
                            }
                            $$ = n;
                        }
    | FOR '(' declaration expr ';'  ')' statement
    | FOR '(' declaration  ';' expr ')' statement
    | FOR '(' declaration  ';'  ')' statement */


jump_statement: GOTO IDENT ';' { struct astnode *n = malloc(sizeof(struct astnode));
                                int labelLine;
                                struct symbolNode *labelSymbol = findSymbol(scopeList[scopeNum],$2,0);
                                if(labelSymbol == NULL){
                                    labelLine = -1;
                                    struct symbolNode *s = generateSymbol(line,lastSymbol[scopeNum+1]->scopeStart, lastSymbol[scopeNum+1]->scope, 4, "", $2, name, 24, NULL, lastSymbol[scopeNum+1]->head, 0, lastSymbol[scopeNum+1]->nameSpace, 2);
                                    lastSymbol[1] = insertSymbol(lastSymbol[1]->head, s);
                                }
                                else{
                                    labelLine = labelSymbol->declaredLine;
                                }
                                setupJump(n, 0, $2, NULL,labelLine);

                                $$ = n;

                                    }
    | CONTINUE ';' { struct astnode *n = malloc(sizeof(struct astnode));
                                setupJump(n, 1, NULL, NULL,-1);
                                
                                $$ = n;

                                    }
    | BREAK ';' { struct astnode *n = malloc(sizeof(struct astnode));
                                setupJump(n, 2, NULL, NULL,-1);
                                
                                $$ = n;

                                    }
    | RETURN expr ';' { struct astnode *n = malloc(sizeof(struct astnode));
                                setupJump(n, 3, NULL, $2,-1);
                                
                                $$ = n;

                                    }
    | RETURN ';'{ struct astnode *n = malloc(sizeof(struct astnode));
                                setupJump(n, 4, NULL, NULL,-1);
                                
                                $$ = n;

                                    }

//statement: expr ';'{
//                    printAST($1,0);}

//;
expr: assexp 
    | expr ',' assexp {  struct astnode *n = malloc(sizeof(struct astnode));
                                
                        setupBinop(n,',',$1,$3);
                                
                        $$= n;

                    }

;


primexp: IDENT {
                if(!isFunction){

  
                struct symbolNode *varSymbol = findSymbol(scopeList[scopeNum],$1,0);
                    if(varSymbol == NULL){
                        exit(0);
                    }
                } 
                struct astnode *n = malloc(sizeof(struct astnode));
                 setupIdent(n,$1);
                 $$ = n;
                isFunction = 0;
                }    
    | NUMBER   {struct astnode *n =malloc(sizeof(struct astnode));
                         setupNumber(n,$1);
                $$ = n;
                }
    | CHARLIT   {struct astnode *n = malloc(sizeof(struct astnode));
                         setupNumber(n,$1);
                $$ = n;
                }
    | newString { struct astnode *n = malloc(sizeof(struct astnode));
                 setupString(n,$1);
                 $$ = n;
                 }  
    | '(' expr ')' {$$ = $2;}
                 
;
postexp:  primexp
    | postexp '[' expr ']' {  struct astnode *sub = malloc(sizeof(struct astnode));
                                
                                setupBinop(sub,'+',$1,$3);
                                struct astnode *n = malloc(sizeof(struct astnode));
                                setupGeneral(n, 0, sub);
                                
                                $$= n;

                            }
    | open_function_param argexplist ')'    {   struct astnode *n   = malloc(sizeof(struct astnode));
                                        struct symbolNode *s;
                                        struct symbolNode *varSymbol = findSymbol(lastSymbol[0]->head,$1->ident.ident,0);
                                        if(varSymbol == NULL){
                                            s = generateSymbol(line, lastSymbol[scopeNum+1]->declaredLine, 0,1, "int", $1->ident.ident, name ,18, NULL, lastSymbol[scopeNum+1]->head,1, lastSymbol[scopeNum+1]->nameSpace, 4);
                                            lastSymbol[scopeNum+1]= insertSymbol(lastSymbol[scopeNum+1]->head, s);
                                        }
                                        
                                        setupFunc(n,$1,$2);
                                        
                                        $$ = n;
                                        }
                                     //this is where the functions go

    | open_function_param ')'   {   struct astnode *n   = malloc(sizeof(struct astnode));
                                        struct symbolNode *s;
                                        struct symbolNode *varSymbol = findSymbol(lastSymbol[0]->head,$1->ident.ident,0);
                                        if(varSymbol == NULL){
                                            s = generateSymbol(line, lastSymbol[scopeNum+1]->declaredLine, 0,1, "int", $1->ident.ident, name ,18, NULL, lastSymbol[scopeNum+1]->head,1, lastSymbol[scopeNum+1]->nameSpace, 4);
                                            lastSymbol[scopeNum+1]= insertSymbol(lastSymbol[scopeNum+1]->head, s);
                                        }
                                        
                                    setupFunc(n,$1, NULL);
                                        
                                        $$ = n;
                                }

    | postexp '.' IDENT     {struct astnode *n = malloc(sizeof(struct astnode));
                                setupSelect(n,0,$1,$3);
                                $$= n;
                                }
    | postexp INDSEL IDENT  {struct astnode *n =malloc(sizeof(struct astnode));
                            //FIX THIS WITH THE EQUIVALENCY
                                setupSelect(n,1,$1,$3);
                                $$= n;
                                }
    | postexp PLUSPLUS      {struct astnode *n = malloc(sizeof(struct astnode));
                            setupUnop(n,PLUSPLUS,$1);
                            $$ = n;
                        }
    | postexp MINUSMINUS    {struct astnode *n = malloc(sizeof(struct astnode));
                            setupUnop(n,MINUSMINUS,$1);
                            $$ = n;
                        }
    


;
open_function_param: IDENT '(' { // isFunction = 1;
                                    struct astnode *n = malloc(sizeof(struct astnode));
                                    setupIdent(n,$1);
                                    $$ = n;
                                    
                            }

argexplist : assexp     { struct astnode *n = malloc(sizeof(struct astnode));
                            setupFuncarg(n,$1,n);
                            n->funcarg.head = n;
                            $$ = n;
                            }
    | argexplist ',' assexp {  struct astnode *n = malloc(sizeof(struct astnode));
                                
                                setupFuncarg(n,$3,$1);
                                n->funcarg.argCount = $1->funcarg.argCount + 1;
                                n->funcarg.head = $1->funcarg.head;
                                $1->funcarg.next = n;
                                
                            $$= n;

                    }
castexp: unexp  
    | '('typename')' castexp    {   struct astnode *n = malloc(sizeof(struct astnode));
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
    | PLUSPLUS unexp    {struct astnode *n = malloc(sizeof(struct astnode));
                            struct astnode *sub = malloc(sizeof(struct astnode));
                            struct number tempNum;
                            tempNum.value.intVal = 1;
                            tempNum.type = 0;
                            setupNumber(sub,tempNum);
                            setupAssignment(n,PLUSEQ, $2,sub );
                            $$ = n;
                        }
    | MINUSMINUS unexp  {struct astnode *n = malloc(sizeof(struct astnode));
                        struct astnode *sub = malloc(sizeof(struct astnode));
                        struct number tempNum;
                        tempNum.value.intVal = 1;
                        tempNum.type = 0;
                        setupNumber(sub,tempNum);
                        setupAssignment(n,MINUSEQ, $2,sub );
                        $$ = n;
                        }
    | unaryop castexp   {struct astnode *n = malloc(sizeof(struct astnode));
                        setupUnop(n,$1,$2);
                        $$ = n;
                        }
    | '&' castexp       { struct astnode *n = malloc(sizeof(struct astnode));
                            setupGeneral(n,1,$2);
                            $$ = n;
                            }
    | '*' castexp       { struct astnode *n = malloc(sizeof(struct astnode));
                            setupGeneral(n,0,$2);
                            $$= n;
                            } 
    | SIZEOF unexp  {struct astnode *n = malloc(sizeof(struct astnode));
                        setupGeneral(n,2,$2);
                        $$ = n;
                        }
    | SIZEOF '('typename')' {struct astnode *n = malloc(sizeof(struct astnode));
                                struct astnode *typeView = $3;
                                struct astnode *type = malloc(sizeof(struct astnode));
                                //setupType(type,$3,NULL);
                            setupGeneral(n,2,typeView);
                            $$ = n;
                            }
;
multexp:castexp
    | multexp '*' castexp   {  struct astnode *n = malloc(sizeof(struct astnode));
                                
                                setupBinop(n,'*',$1,$3);
                                
                                $$= n;

                            }
    | multexp '/' castexp   {  struct astnode *n = malloc(sizeof(struct astnode));
                                
                                setupBinop(n,'/',$1,$3);
                                
                                $$= n;

                            }
    | multexp '%' castexp   {  struct astnode *n = malloc(sizeof(struct astnode));
                                
                                setupBinop(n,'%',$1,$3);
                                
                                $$= n;

                            }
;
addexp: multexp
    | addexp '+' multexp    {  struct astnode *n = malloc(sizeof(struct astnode));
                                
                                setupBinop(n,'+',$1,$3);
                                
                                $$= n;

                            }
    | addexp '-' multexp    {  struct astnode *n = malloc(sizeof(struct astnode));
                                
                                setupBinop(n,'-',$1,$3);
                                
                                $$= n;

                            }
;
shiftexp: addexp
    | shiftexp  SHL addexp {  struct astnode *n = malloc(sizeof(struct astnode));
                                
                                setupBinop(n,SHL,$1,$3);
                                
                                $$= n;

                            }
    | shiftexp SHR addexp   {  struct astnode *n = malloc(sizeof(struct astnode));
                                
                                setupBinop(n,SHR,$1,$3);
                                
                                $$= n;

                            }
;
relexp: shiftexp
    | relexp '<' shiftexp { struct astnode *n = malloc(sizeof(struct astnode));
                            setupCompop(n,'<', $1,$3);
                            $$ = n;

                            }
    | relexp '>' shiftexp   { struct astnode *n = malloc(sizeof(struct astnode));
                            setupCompop(n,'>', $1,$3);
                            $$ = n;

                            }
    | relexp LTEQ shiftexp  { struct astnode *n = malloc(sizeof(struct astnode));
                            setupCompop(n,LTEQ, $1,$3);
                            $$ = n;

                            }
    | relexp GTEQ shiftexp  { struct astnode *n = malloc(sizeof(struct astnode));
                            setupCompop(n,GTEQ, $1,$3);
                            $$ = n;

                            }
;
eqexp: relexp 
    | eqexp EQEQ relexp { struct astnode *n = malloc(sizeof(struct astnode));
                            setupCompop(n,EQEQ, $1,$3);
                            $$ = n;

                            }
    | eqexp NOTEQ relexp    { struct astnode *n = malloc(sizeof(struct astnode));
                            setupCompop(n,NOTEQ, $1,$3);
                            $$ = n;

                            }
;
andexp:eqexp
    | andexp '&' eqexp  {  struct astnode *n = malloc(sizeof(struct astnode));
                                
                                setupBinop(n,'&',$1,$3);
                                
                                $$= n;

                            }
;
exorexp: andexp
    | exorexp '^' andexp    {  struct astnode *n = malloc(sizeof(struct astnode));
                                
                                setupBinop(n,'^',$1,$3);
                                
                                $$= n;

                            }
;
inorexp:exorexp
    | inorexp '|' exorexp   {  struct astnode *n = malloc(sizeof(struct astnode));
                                
                                setupBinop(n,'|',$1,$3);
                                
                                $$= n;

                            }
;
logandexp: inorexp
    | logandexp LOGAND inorexp  {  struct astnode *n = malloc(sizeof(struct astnode));
                                
                                setupLogop(n,LOGAND,$1,$3);
                                
                                $$= n;

                            }
;
logorexp: logandexp
    | logorexp LOGOR logandexp  {  struct astnode *n = malloc(sizeof(struct astnode));
                                
                                setupLogop(n,LOGOR,$1,$3);
                                
                                $$= n;

                            }
;
condexp: logorexp
    | logorexp '?' expr ':' condexp {  struct astnode *n = malloc(sizeof(struct astnode));
                                        
                                        setupTernary(n,$1,$3,$5);
                                        
                                        $$= n;

                                    }
;
assexp: condexp 
    | unexp assop assexp    {  struct astnode *n = malloc(sizeof(struct astnode));
                                        
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
void printAST(struct astnode* n, int indent, struct symbolNode *head){
        char temp[1000];
        struct symbolNode *varSymbol;
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
                
                printAST(n->binop.left, indent+1,head);
                printAST(n->binop.right, indent+1,head);
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
                varSymbol = findSymbol(head,n->ident.ident,0);
                if(varSymbol == NULL){
                    printf("variable %s\n", n->ident.ident);
                }
                else{
                    printf("variable %s def @ <%s>:%d\n",n->ident.ident,varSymbol->fileName,varSymbol->declaredLine);
                }
                 break;
            case 3: 
                printf("STRING %s\n", n->string.string); break;
            case 4:
                printf("TERNARY OP, IF\n");
                printAST(n->ternop.opIf,indent+1,head);
                printf("THEN\n");
                printAST(n->ternop.opThen,indent+1,head);
                printf("ELSE\n");
                printAST(n->ternop.opElse,indent+1,head);
                break;
            case 5:
                
                switch(n->logop.operator){
                    case LOGAND: strcpy(temp, "&&"); break;
                    case LOGOR: strcpy(temp, "||"); break;
                }
                printf("LOGICAL OP %s\n", temp);
                printAST(n->logop.left, indent+1,head);
                printAST(n->logop.right, indent+1,head);
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
                printAST(n->assop.left, indent+1,head);
                printAST(n->assop.right, indent+1,head);
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
                

                printAST(n->unop.operand,indent+1,head);
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
                printAST(n->compop.left, indent+1,head);
                printAST(n->compop.right,indent+1,head);

                break;
            case 9: 
                switch(n->general.genType){
                    case 0: printf("DEREF\n"); break;
                    case 1: printf("ADDRESSOF\n"); break;
                    case 2: printf("SIZEOF\n"); break;
                }
                printAST(n->general.next, indent + 1,head);
                break;
            case 10:
                switch(n->select.indirectFlag){
                    case 0: printf("SELECT, MEMBER %s\n", n->select.member); break;
                    case 1: printf("INDIRECT SELECT, MEMBER %s\n", n->select.member); break;
                }
                printAST(n->select.parent,indent+1,head);
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
                    
                    printAST(n->type.next, indent + 1,head);
                }
                break;
            case 13:   
                if(n->func.args){
                    printf("FUNCTION CALL,%i arguments\n",n->func.args->funcarg.argCount);
                    printAST(n->func.name, indent + 1,head);
                    int i;
                    i = 1;
                    struct astnode *copy = n->func.args->funcarg.head;
                    while (copy!= NULL){
                        for (int i = 0; i<indent; i++){
                                    printf("\t");
                        }
                        printf("arg #%i=\n",i);
                        printAST(copy->funcarg.current,indent+1,head);
                        copy = copy->funcarg.next;
                        i++;
                    }
                }
                else{
                    printf("FUNCTION CALL, 0 arguments\n");
                } 
                
                break;




            case 14:
                sprintf(temp, stringFromDecType(n->decType.type));
                printf("%s\n",temp);
                if(n->decType.nextType != NULL){
                    printAST(n->decType.nextType, indent+1,head);
                } 
                break;
            case 22: 
                printf("LIST {\n");
                switch(n->iterator.iterType){
            
                    case 0: 
                        printf("FOR\n");
                        if(n->iterator.first != NULL){
                            printf("INIT:\n");
                            printAST(n->iterator.first,indent+1,head);
                        }
                        if(n->iterator.second != NULL){
                            for (int i = 0; i<indent; i++){
                                printf("\t");
                            }
                            printf("CONDITION:\n");
                            printAST(n->iterator.second, indent + 1,head);
                        }
                        if(n->iterator.body != NULL){
                            for (int i = 0; i<indent; i++){
                                printf("\t");
                            }
                            printf("BODY:\n");
                            printAST(n->iterator.body, indent + 1,head);
                        }
                        if(n->iterator.third != NULL){
                            for (int i = 0; i<indent; i++){
                                printf("\t");
                            }
                            printf("INCR:\n");
                            printAST(n->iterator.third, indent+1,head);
                        }
                        break;
                    case 1: 
                        printf("DO:\n");
                        printAST(n->iterator.first,indent+1,head);
                        for (int i = 0; i<indent; i++){
                                printf("\t");
                        }
                        printf("WHILE:\n");
                        printAST(n->iterator.body, indent+1, head);
                        break;
                    case 2: 
                        printf("WHILE:\n");
                        for (int i = 0; i<indent; i++){
                                printf("\t");
                            }
                        printf("COND:\n");
                        printAST(n->iterator.first,indent+1,head);
                        for (int i = 0; i<indent; i++){
                                printf("\t");
                            }
                        printf("BODY:\n");
                        for (int i = 0; i<indent; i++){
                                printf("\t");
                            }
                        printAST(n->iterator.body, indent+1, head);
                        
                }
                printf("}\n");
                break;
            case 23: 
                printf("LIST {\n");
                for (int i = 0; i<indent; i++){
                                printf("\t");
                            }
                printf("IF\n");
                for (int i = 0; i<indent; i++){
                                printf("\t");
                            }
                printf("COND:\n");
                printAST(n->ifNode.condition,indent+1, head);
                for (int i = 0; i<indent; i++){
                                printf("\t");
                            }
                printf("THEN:\n");
                printAST(n->ifNode.body,indent+1,head);
                if(n->ifNode.elseBody != NULL){
                    for (int i = 0; i<indent; i++){
                                printf("\t");
                            }
                    printf("ELSE:\n");
                    printAST(n->ifNode.elseBody, indent+1, head);
                }
                printf("}\n");
                break;
                
            case 24:
                printf("LABEL(%s):\n", n->label.name);
                printAST(n->label.labeled, indent+1, head);
                break;
            case 25:
                switch(n->jump.jumpType){
                    
                    
                    case 0: 
                        if(n->jump.labelLine < 0){
                            printf("GOTO %s (DEF)\n", n->jump.label);
                        }
                        else{
                            printf("GOTO %s (DEF @ <%s>:%d)\n", n->jump.label,name,n->jump.labelLine);
                        }
                        break;
                        
                    case 1:
                        printf("CONTINUE\n");
                        break;
                    case 2:  printf("BREAK\n");
                        break;
                    case 3: 
                        printf("RETURN:\n");
                        printAST(n->jump.returnNode, indent+1, head);
                        break;
                    case 4:
                        printf("RETURN\n");
                        break;
                    
                }
                break;
            case 26: 
                printf("SWITCH,EXPR\n");
                printAST(n->switchNode.expression,indent+1,head);
                for (int i = 0; i<indent; i++){
                                printf("\t");
                            }
                printf("BODY:\n");
                for (int i = 0; i<indent; i++){
                                printf("\t");
                            }
                printf("LIST {\n");
                printAST(n->switchNode.statement, indent+1, head);
                for (int i = 0; i<indent; i++){
                                printf("\t");
                            }
                printf("}\n");
                break;
            case 27:
                if(n->caseNode.expression == NULL){
                    printf("DEFAULT\n");
                    printAST(n->caseNode.statement, indent+1, head);
                }
                else{
                    printf("CASE, EXPR: \n");
                    printAST(n->caseNode.expression, indent+1, head);
                    for (int i = 0; i<indent; i++){
                                printf("\t");
                            }
                    printf("STATEMENT {\n");
                    printAST(n->caseNode.statement, indent+1, head);
                    for (int i = 0; i<indent; i++){
                                printf("\t");
                            }
                    printf("}\n");
                }
                
                break;
            
        }
        if(n->next != NULL){
            printAST(n->next, indent, head);
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
    n->array.nextDimension = NULL;
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
void setupMult(struct astnode *n, struct astnode *left, struct astnode *right){
    n->nodetype = 19;
    n->multDec.left = left;
    n->multDec.right = right;
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

void setupIterator(struct astnode *n, struct astnode *first, struct astnode *second, struct astnode *third, struct astnode *body, int type){
    n->nodetype = 22;
    n->iterator.iterType = type;
    n->iterator.first = first;
    n->iterator.second = second;
    n->iterator.third = third;
    n->iterator.body = body;
}

void setupIf(struct astnode *n, struct astnode *condition, struct astnode *body, struct astnode *elseNode){
    n->nodetype = 23;
    n->ifNode.condition = condition;
    n->ifNode.body = body;
    n->ifNode.elseBody = elseNode;
}

void setupLabel(struct astnode *n, char* name, struct astnode *labeled){
    n->nodetype = 24;
    n->label.name = name;
    n->label.labeled = labeled;
}

void setupJump(struct astnode *n, int jumpType, char* label, struct astnode *returnNode, int labelLine ){
    n->nodetype = 25;
    n->jump.jumpType = jumpType;
    n->jump.label = label;
    n->jump.returnNode = returnNode;
    n->jump.labelLine = labelLine;
}

void setupSwitch(struct astnode *n, struct astnode *expression, struct astnode *statement){
    n->nodetype = 26;
    n->switchNode.expression = expression;
    n->switchNode.statement = statement;
}

void setupCase(struct astnode *n, struct astnode *expression, struct astnode *statement){
    n->nodetype = 27;
    n->caseNode.expression = expression;
    n->caseNode.statement = statement;
}

char *gen_rvalue(struct astnode *node, char *target){
    char *buffer = malloc(10000);
    //target is the destination astnode, so if it's NULL it's an intermediate expression
    if(node->nodetype == 2 ){
        struct symbolNode *localSymbol = findSymbol(allScopes[quadScopeCount],node->ident.ident , 0);
        if(localSymbol){
             lastScopeType = localSymbol->scope;
        }
       
        if(localSymbol && localSymbol->member !=NULL && localSymbol->member->nodetype == 15 && isPointer ){
            lastSize = getSize(localSymbol->type);
        }

        if(localSymbol && localSymbol->member !=NULL && localSymbol->member->nodetype == 15 && isDeref ){
            if(!target){
                target = new_temp();
            }
            
            emit(opLEA, node->ident.ident, NULL, target);
            return target;
        }


        if(localSymbol && localSymbol->member != NULL && localSymbol->member->nodetype == 16 && !isDeref){
            lastSize = getSize(localSymbol->type);
            if(!target){
                target = new_temp();
            }
            
            //emit(opLEA, node->ident.ident, NULL, target);
            return node->ident.ident;
            //printf("POINTER\n");
            return target;
        }
        else if(localSymbol && localSymbol->member && localSymbol->member->nodetype == 17){
            lastSize = getSize(localSymbol->type);
            if(!target){
                target = new_temp();
            }
            
            emit(opLEA, node->ident.ident, NULL, target);
            //then if numDim>1, call gen_rvalue on localSymbol->member->nextDimension to get new offset, then need to figure
            //out how to chain that up to the previous addition (might just store that value in a global and do the addition here)
            if(numDim > 1 && lastDim){

                char *newTemp = gen_rvalue(localSymbol->member->array.nextDimension,NULL);
                char *newerTemp = new_temp();
                emit(opADD,newTemp,target,newerTemp);
                target = newerTemp;
            }
            return target;
        }
        else{
            return node->ident.ident;
        }
        
    }
    if(node->nodetype == 3){
        
        char *tempString = malloc(1024);
        sprintf(tempString, "$.str%d", quadStringCount);
        emit(opSTRING,node->string.string, NULL, tempString );
        quadStringCount++;
        //deal with once Hak tells me how
        return tempString;
    }
    if(node->nodetype == 1){
        
        sprintf(buffer, "%d", node->num.number);
        
        return buffer;
    }
    if(node->nodetype == 17){
        //for 2d arrays
        if(!target){
            target = new_temp();
        }
        int typeSize = atoi(getSize(node->array.type));
        int totalSize = typeSize * node->array.size;
        char *bufferSize = malloc(1024);
        sprintf(bufferSize,"%d",totalSize);
        if(rightOp->nodetype == 1){
            char *numBuffer = malloc(1024);
            sprintf(numBuffer,"%d",rightOp->num.number);
            emit(opMUL,numBuffer,bufferSize,target);
        }
        if(rightOp->nodetype == 2){
            emit(opMUL,node->ident.ident,bufferSize,target);
        }
        return target;
        

    }
    if(node->nodetype == 0){
        rightOp = node->binop.right;
        sprintf(lastSize,"1");
        int isLeft = 0; //checks whether pointer is left operand or not
        char *left = gen_rvalue(node->binop.left,NULL);
        
        if(strcmp(lastSize, "1") != 0){
            isLeft = 1;
        }
        char *right = malloc(1024);
        if(lastDim->nodetype != -1){
            right = gen_rvalue(lastDim,NULL);
            //printf("2d array\n");
        }
        else{
            right = gen_rvalue(node->binop.right,NULL);
        }
        
        if(isLeft){
            char *multTemp = new_temp();
            emit(opMUL, strdup(lastSize), right, multTemp);
            sprintf(lastSize,"");
            right = multTemp;
        }
        else{
            if(strcmp(lastSize, "1") != 0){
                char *multTemp = new_temp();
                emit(opMUL, strdup(lastSize), right, multTemp);
                sprintf(lastSize,"");
                left = multTemp;
            }
        }
        if(!target){
            target = new_temp();
        }
        emit(getOpcode(node), left, right, target);
        return target;
    }
    if(node->nodetype == 9){
        if(node->general.genType == 0){
            if(node->general.next->nodetype == 0){
                //char *temp = new_temp();
                
                if(node->general.next->binop.left->nodetype == 9){
                    lastDim = node->general.next->binop.right;
                    numDim++;
                    target = gen_rvalue(node->general.next->binop.left,NULL);
                    return target;
                }
                else{
                    char *temp_target = gen_rvalue(node->general.next,NULL); 
                    
                    //target = gen_rvalue(node->general.next,NULL); 
                    if(!isArraySet){
                        if(!target){
                        target = new_temp();
                    }
                        emit(opLOAD,temp_target,NULL,target);
                    }
                    else{
                        target = temp_target;
                        isArraySet = 0;
                    }
                    
                    
                    return target;
                }
                
                //for 2d arrays I need to make it so if more than one binop, it cuts off the case where the left of the binop is 
                //just an ident


                //get the symbol corresponding to the name of the array, then get type from that, and then perform needed operations
                /*struct symbolNode *localSymbol = findSymbol(scopeList[0],node->general.next->binop.left->ident.ident , 0);
                if(localSymbol && localSymbol->member != NULL && localSymbol->member->nodetype == 17){


                    
                    char *size = getSize(localSymbol->member->array.type);
                    emit(opLEA,node->general.next->binop.left->ident.ident, NULL, temp);
                    char *offset = malloc(1024);
                    sprintf(offset, "%lld", node->general.next->binop.right->num.number);
                    char *secondTemp = new_temp();
                    emit(opMUL,offset, size, secondTemp);
                    char *thirdTemp = new_temp();
                    emit(opADD, temp, secondTemp, thirdTemp);
                    return thirdTemp;
                }  */
            }
            else{
                isDeref = 1;
                char *addr = gen_rvalue(node->general.next, NULL);
                
                
                isDeref = 0;
                if(!target){
                    target = new_temp();
                }
                emit(opLOAD, addr, NULL, target);
                return target;
            }
            
        }
        if(node->general.genType == 1){
            if(node->general.next->nodetype == 2){
                isPointer = 1;
            }
            
            char *addresse = gen_rvalue(node->general.next,NULL);
            isPointer = 0;
            //need to set lastSize here

            if(!target){
                target = new_temp();
            }
            emit(opLEA,addresse,NULL,target);
            return target;
        }
        return target;
    }
    if(node->nodetype == 25){
        char *tempBB = malloc(1024);
        if(node->jump.jumpType == 2){ //break
            sprintf(tempBB,"BB%d",end_loop);
            emit(opBR,tempBB,NULL,NULL);
        }
        if(node->jump.jumpType == 1){ //continue
            sprintf(tempBB,"BB%d",start_loop);
            emit(opBR,tempBB,NULL,NULL);
        }
        if(node->jump.jumpType == 3 || node->jump.jumpType == 4){ //return
            
            
            char *retValue = malloc(1024);
            if(node->jump.returnNode){
                retValue = gen_rvalue(node->jump.returnNode,NULL);
            }
            else{
                sprintf(retValue,"");
            }
            emit(opRET,retValue,NULL,NULL);
            return "RET";
        } 
        
        
    }
    if(node->nodetype == 13){//function call
        if(!target){
            target = new_temp();
            
        }
        struct astnode *arg = malloc(sizeof(struct astnode));
        char *num_arg = malloc(1024);
        if(node->func.args){
            
            sprintf(num_arg,"%d",node->func.args->funcarg.argCount);
            arg = node->func.args->funcarg.head;
        }
        else{
            sprintf(num_arg,"");
        }
        emit(opARGBEGIN,num_arg, NULL, NULL);
        
        int argNum = 0;
        char *arg_num = malloc(1024);
        sprintf(arg_num,"%d",argNum);
        
        if(node->func.args){
            
            struct astnode *flipHead =malloc(sizeof(struct astnode));
            
            while(arg){
                if(flipHead->nodetype == 0){
                    *flipHead = *arg;
                    flipHead->funcarg.next = NULL;
                }
                else{
                    struct astnode *tempArg =malloc(sizeof(struct astnode));
                    *tempArg = *flipHead;
                    *flipHead = *arg;
                    flipHead->funcarg.next = tempArg;
                }
                //flipHead = arg;
                arg = arg->funcarg.next;
            }
            arg = flipHead;
            while(arg){
                argNum++;
                sprintf(arg_num,"%d",argNum);
                char *tempArgValue = gen_rvalue(arg->funcarg.current,NULL);
                emit(opARG,strdup(arg_num),tempArgValue,NULL);
                arg = arg->funcarg.next;
                
            }
        }
        emit(opCALL,gen_rvalue(node->func.name,NULL),strdup(arg_num),target);
       /* int callBB = new_bb();
        char *bbName = malloc(1024);
        sprintf(bbName, "BB%d",callBB);
        emit(opBR,bbName,NULL,NULL);
        cur_bb = callBB;*/
        return target;
    } 
    if(node->nodetype == 7){
        if(node->unop.operator == PLUSPLUS){
            char *operand = gen_rvalue(node->unop.operand,NULL);
            
            emit(opINC,NULL,NULL,operand);
        }
        if(node->unop.operator == MINUSMINUS){
            char *operand = gen_rvalue(node->unop.operand,NULL);
            emit(opDEC,NULL,NULL,operand);
        }
        
    }
    if(node->nodetype == 8 || node->nodetype == 5){
        if(!target){
            target = new_temp();
        }
        int bt = new_bb();
        char *btName = malloc(1024);
        sprintf(btName, "BB%d",bt);
        int bf = new_bb();
        char *bfName = malloc(1024);
        sprintf(bfName, "BB%d",bf);
        int be = new_bb();
        char *beName = malloc(1024);
        sprintf(beName, "BB%d",be);
        gen_condexpr(node, btName,bfName);
        cur_bb = bt;
        emit(opMOV,"1",NULL,target);
        emit(opBR,beName,NULL,NULL);
        cur_bb = bf;
        emit(opMOV,"0",NULL,target);
        emit(opBR,beName,NULL,NULL);
        cur_bb = be;
        return target;
        //gen_localcond(node->compop,btName,bfName);
    }
   
   
    
}




void gen_quad(struct astnode *node){
    if(node->nodetype == 23){
        printf("If statement");
        gen_if(node);
    }
    else if(node->nodetype == 6){
        gen_assign(node);
    }
    else if(node->nodetype == 22){
        gen_while(node);
    }
    else if(node->nodetype != 15 &&node->nodetype != 16&&  node->nodetype != 17 ){
        gen_rvalue(node, NULL);
    }


    if(node->next != NULL){
        gen_quad(node->next);
    }
    
}

void gen_global(struct astnode *node){
    switch(node->nodetype){
        case 15: 

    }
}

char *getSize(char *type){
    int placeholder = 0;
    char *tempString = malloc(1024);
    char *intCheck = strstr(type, "int");
    if(intCheck){
        //return "4";
        if(placeholder == 0){
            placeholder = 1;
        }
        placeholder *=4;
    }
    char *charCheck = strstr(type, "char");
    if(charCheck){
        if(placeholder == 0){
            placeholder = 1;
        }
        //return "1";
        
    }
    char *longCheck = strstr(type, "long");
    if(longCheck){
       // return "8";
       if(placeholder == 0){
            placeholder = 1;
        }
        placeholder *=8;
    }
    
    if(placeholder == 0){
        return "0";
    }
    else{
        sprintf(tempString, "%d", placeholder);
        return tempString;
    }
    
    
    
}

char *gen_assign(struct astnode *node){
    numDim = 1;
    int dstmode = -1;
    char *temp = malloc(1024);
    char *dst = gen_lvalue(node->assop.left,&dstmode);
    if(dstmode == -1){
        exit(0);
    }
    if(dstmode == 1){
        if(node->assop.assType == '='){
           temp = gen_rvalue(node->assop.right,dst);
           if(temp != dst){
                
                emit(opMOV,temp,NULL,dst);
            }
            
           
        }
        else{
            
            temp = gen_rvalue(node->assop.right,NULL);
            
        }
        
        if(node->assop.assType != '='){
            char *newTemp = new_temp();
            switch(node->assop.assType){
                case TIMESEQ: emit(opMUL,temp,dst,newTemp); break;
                case DIVEQ: emit(opDIV, temp, dst, newTemp); break;
                case MODEQ: emit(opMOD, temp, dst, newTemp); break;
                case PLUSEQ: emit(opADD, temp, dst, newTemp); break;
                case MINUSEQ: emit(opSUB, temp, dst, newTemp); break;
            }
            temp = newTemp;
            emit(opMOV, temp, NULL,dst);
        }
        
      /*  if(node->assop.right->nodetype == 1 || node->assop.right->nodetype == 2){
            emit(opSTORE, temp, NULL,dst);
        }*/
        
    }
    else{
        char *t1 = gen_rvalue(node->assop.right, NULL);
        
        emit(opSTORE,t1,dst,NULL);
    }
    
    
}


char *gen_lvalue(struct astnode *node, int *mode){
    if(node->nodetype == 2){
        *mode = 1;
        return node->ident.ident;
    }
    if(node->nodetype == 1){
        return NULL;
    }
    if(node->nodetype == 9){
        if(node->general.genType == 0){
            *mode = 0;
            if(node->general.next->nodetype == 0){
                isArraySet = 1;
                return gen_rvalue(node, NULL);
            }
            else{
                //return gen_rvalue(node->general.next, NULL);
                return node->general.next->ident.ident;
            }
            
        }
    }
}

char *new_temp(){
    
    char *temp = malloc(100);
    sprintf(temp, "%cT%d",37, tempVarCountNum);
    tempVarCountNum = tempVarCountNum + 1;
    return temp;
    //do I make it an assignment operator? Seems like it would make the most sense
}

int new_bb(){
    //char *temp = malloc(10);
    branchNum++;
    //sprintf(temp, "BB%d", branchNum);
    
    return branchNum;
}


void emit(int opcode, char *left, char *right, char *target){
    //sprintf(lastOpcode,"%s",opcode);
    lastOpcode = opcode;
    if(!right){
        right = malloc(1024);
        sprintf(right, "");
    }
    if(!left){
        left = malloc(1024);
        sprintf(left, "");
    }
    if(!target){
        target = malloc(1024);
        sprintf(target,"");
    }
    struct symbolNode *leftSymbol = findSymbol(allScopes[quadScopeCount],left , 0);
    int leftScope=-1;
    if(leftSymbol){
        leftScope = leftSymbol->scope;
    }
    struct symbolNode *rightSymbol = findSymbol(allScopes[quadScopeCount],right , 0);
    int rightScope=-1;
    if(rightSymbol){
        rightScope = rightSymbol->scope;
    }
    struct symbolNode *targetSymbol = findSymbol(allScopes[quadScopeCount],target , 0);
    int targetScope=-1;
    if(targetSymbol){
        targetScope = targetSymbol->scope;
    }
    
    struct quad *newQuad= setup_quad(target, opcode, left, right, leftScope, rightScope, targetScope, leftSymbol, rightSymbol, targetSymbol);
    //if(blockList[cur_bb] == NULL){
    //if(blockList[bbToInsert] == NULL){
    if(!checkBB( blockNums, cur_bb)){  
        blockList[bbToInsert] = newQuad;
        blockNums[bbToInsert] = cur_bb;
        bbToInsert++;
    }
    else{
        insertQuad(blockList[checkBB( blockNums, cur_bb)], newQuad);
    }
    /*if(!target){
        printf("\t\t%s %s %s\n",opcode,left, right );
    }
    else{
        printf("\t%s= \t %s %s %s\n", target,opcode,left, right );
    }*/
    
    
    
    

}

void globalEmit(int opcode, char *left, char *right, char *target){
    lastOpcode = opcode;
    if(!right){
        right = malloc(1024);
        sprintf(right, "");
    }
    if(!left){
        left = malloc(1024);
        sprintf(left, "");
    }
    if(!target){
        target = malloc(1024);
        sprintf(target,"");
    }
    struct quad *newQuad= setup_quad(target, opcode, left, right, -1, -1, -1, NULL, NULL, NULL);
    struct quad *currentQuad = globalList;
    if(!currentQuad){
        globalList = newQuad;
    }
    else{
        while(currentQuad->nextQuad){
            currentQuad = currentQuad->nextQuad;
        }
        currentQuad->nextQuad = newQuad;
    }
}
int checkBB(int *bbList,int bbToCheck){
    int current = bbList[0];
    for (int i =0;i<bbToInsert; i++){
        if(bbList[i] == bbToCheck){
            return i;
        }
    }
    return 0;
}
int getOpcode(struct astnode *node){
    if(node->nodetype == 0){
        switch(node->binop.operator){
            case '+' : return opADD;break;
            case '-' : return opSUB;break;
            case '*' : return opMUL;break;
            case '/' : return opDIV;break;
            
        }
    }
    if(node->nodetype == 8){
        switch(node->compop.operator){
            case '<' : return opBRGE; break;
            case '>' : return opBRLE; break;
            case EQEQ: return opBRNE; break;
            case NOTEQ: return opBREQ; break;
            case LTEQ: return opBRGT; break;
            case GTEQ: return opBRLT; break;
        }
    }
    
}

struct quad *setup_quad(char *target, int opcode, char *left, char *right, int leftScope, int rightScope, int targetScope, struct symbolNode *leftSymbol, struct symbolNode *rightSymbol, struct symbolNode *targetSymbol){
    struct quad *newQuad = malloc(sizeof(struct quad));
    newQuad->target = target;
    newQuad->opcode = opcode;
    newQuad->left = left;
    newQuad->right =  right;
    newQuad->leftScope = leftScope;
    newQuad->rightScope = rightScope;
    newQuad->targetScope = targetScope;
    newQuad->leftSymbol = leftSymbol;
    newQuad->rightSymbol = rightSymbol;
    newQuad->targetSymbol  = targetSymbol;
    return newQuad;
}

void insertQuad(struct quad *quad, struct quad *newQuad){
    if(quad){
        while(quad->nextQuad != NULL){
            quad = quad->nextQuad;
        }
        quad->nextQuad = newQuad;
    }
    else{
        
        blockList[cur_bb] = newQuad;
    }
    
}

//handles generating the basic blocks
void gen_if(struct astnode *if_node){
    
    int bt = new_bb();
    char *btName = malloc(1024);
    sprintf(btName, "BB%d",bt);
    int bf = new_bb();
    char *bfName = malloc(1024);
    sprintf(bfName, "BB%d",bf);
    int bn;
    char *bnName = malloc(1024);
    if(if_node->ifNode.elseBody){
        bn = new_bb();
    }
    else{
        bn = bf;
    }
    
    sprintf(bnName, "BB%d",bn);
    //this 
    gen_condexpr(if_node->ifNode.condition,btName,bfName);
    cur_bb = bt;
    quadScopeCount++;
    gen_quad(if_node->ifNode.body);
    quadScopeCount++;
    if(if_node->ifNode.elseBody){
        quadScopeCount++;
        emit(opBR,bnName,NULL,NULL);
        cur_bb = bf;
        gen_quad(if_node->ifNode.elseBody);
        quadScopeCount++;
    }
    
    cur_bb = bn;


}

void gen_while(struct astnode *while_node){
    int bStart = new_bb();
    char *curName = malloc(1024);
    cur_bb = bStart;
    sprintf(curName, "BB%d",cur_bb);
    
    int bt = new_bb();
    start_loop = bStart;
    char *btName = malloc(1024);
    sprintf(btName, "BB%d",bt);
    int bf = new_bb();
    int end_loop = bf;
    char *bfName = malloc(1024);
    sprintf(bfName, "BB%d",bf);
    
    gen_condexpr(while_node->iterator.first,btName,bfName);
    cur_bb = bt;
    quadScopeCount++;
    gen_quad(while_node->iterator.body);
    quadScopeCount++;
    emit(opBR,curName,NULL,NULL );
    cur_bb = bf;

}




void gen_condexpr(struct astnode *condition, char *bt, char *bf){
    //branchNum-=2;
    //need to handle case where it's just an ident

    if(condition->nodetype == 8){ //compop
        emit(opCMP, gen_rvalue(condition->compop.left,NULL), gen_rvalue(condition->compop.right,NULL), NULL);
        emit(getOpcode(condition), bf, bt, NULL);
    }
    if(condition->nodetype == 5 ){
        
        if(condition->logop.operator == LOGAND){    
            int btNew = new_bb();
            char *newName = malloc(1024);
            sprintf(newName, "BB%d",btNew);
            gen_condexpr(condition->logop.left, newName,bf);
            cur_bb = btNew;
            gen_condexpr(condition->logop.right,bt,bf);

        }
        if(condition->logop.operator == LOGOR){
            int bfNew = new_bb();
            char *newName = malloc(1024);
            sprintf(newName, "BB%d",bfNew);
            gen_condexpr(condition->logop.left,bt,newName);
            cur_bb = bfNew;
            gen_condexpr(condition->logop.right,bt,bf);
        }
        
    }
   // branchNum+=2;
}

void gen_dec(struct astnode *dec_node){
   if(dec_node->nodetype == 15){
    globalEmit(opCOMM, "4", "4", dec_node->scalarVar.name);
   }
   else if(dec_node->nodetype == 17){
    char *size = getSize(dec_node->array.type);
    int totalSize = atoi(size) * dec_node->array.size;
    char *totalSizeString = malloc(1024);
    sprintf(totalSizeString, "%d", totalSize);
    globalEmit(opCOMM, totalSizeString,totalSizeString, dec_node->array.name);

   }
   else if(dec_node->nodetype == 16){
    globalEmit(opCOMM, "4","4", dec_node->pointer.name);
   }
   else if(dec_node->nodetype == 18){
    globalEmit(opFUNC,NULL, NULL, dec_node->funcDec.name);
   }
}

void print_quads(struct quad **blocks,int lowerBlock, int numBuckets, int *numList){
    int isReturn = 0;
    for (int i = lowerBlock+1; i<=numBuckets+1 ;i++){
        struct quad *currentQuad = blocks[i];
        if(currentQuad){
            printf("BB%d:",numList[i]);
            char *assBlock = malloc(1024);
            sprintf(assBlock, ".BB%d:\n", numList[i]);
            fputs(assBlock, fp);
            while(currentQuad){
                outputAss(currentQuad);
                char *targetPrint = malloc(1024);
                strcpy(targetPrint, currentQuad->target);
                char *leftPrint = malloc(1024);
                strcpy(leftPrint, currentQuad->left);
                char *rightPrint = malloc(1024);
                strcpy(rightPrint, currentQuad->right);
                char *tempScope = malloc(1024);
                char *offsetString = malloc(1024);
                if(currentQuad->opcode == opRET){
                    isReturn = 1;
                }
                if(currentQuad->leftSymbol && strcmp(currentQuad->left,"") != 0){
                    sprintf(tempScope,"{%s}", scopeFromNum(currentQuad->leftSymbol->scope));
                    strcat(leftPrint, tempScope );
                    if(currentQuad->leftSymbol->ebpOffset != -1){
                        sprintf(offsetString, "(%c%d)", 37,currentQuad->leftSymbol->ebpOffset  );
                        strcat(leftPrint, offsetString);
                    }
                }
                
                if(currentQuad->rightSymbol && strcmp(currentQuad->right,"") != 0){
                    sprintf(tempScope,"{%s}", scopeFromNum(currentQuad->rightSymbol->scope));
                    strcat(rightPrint, tempScope);
                    if(currentQuad->rightSymbol->ebpOffset != -1){
                        sprintf(offsetString, "(%c%d)", 37,currentQuad->rightSymbol->ebpOffset  );
                        strcat(rightPrint, offsetString);
                    }
                }
                if(currentQuad->targetSymbol  && strcmp(currentQuad->target,"") != 0 ){
                    sprintf(tempScope,"{%s}", scopeFromNum(currentQuad->targetSymbol->scope));
                    strcat(targetPrint, tempScope);
                    if(currentQuad->targetSymbol->ebpOffset != -1){
                        sprintf(offsetString, "(%c%d)", 37,currentQuad->targetSymbol->ebpOffset  );
                        strcat(targetPrint, offsetString);
                    }
                }

                
                if(strcmp(currentQuad->target,"") == 0){
                    printf("\t\t%s %s %s\n",getOpcodeString(currentQuad->opcode),leftPrint, rightPrint);
                }
                else{
                    printf("\t%s= \t %s %s %s\n", targetPrint,getOpcodeString(currentQuad->opcode),leftPrint,rightPrint);
                }
                currentQuad = currentQuad->nextQuad;
            }
        
        }
        
    }
    if(!isReturn){
        struct astnode *retQuad  = setup_quad(NULL, opRET, NULL, NULL, -1, -1, -1, NULL, NULL, NULL);
        outputAss(retQuad);
    }
}

void print_globals(struct quad *currentGlobal){
    while(currentGlobal){
        printf("%s = \t %s %s %s\n", currentGlobal->target,getOpcodeString(currentGlobal->opcode), currentGlobal->left, currentGlobal->right);
        outputAss(currentGlobal);
        currentGlobal = currentGlobal->nextQuad;
    }
}

void outputAss(struct quad *currentQuad){
    char *tempTarget = malloc(1024);
    sprintf(tempTarget, "");
    char *tempRight = malloc(1024);
    sprintf(tempRight, "");
    int leftTest = 0;
    int rightTest = 0;
    int targetTest = 0;
    char *assCommand = malloc(1024);
    sprintf(assCommand, "");
    char *leftOperand = malloc(1024);
    sprintf(leftOperand, "");
    char *rightOperand = malloc(1024);
    sprintf(rightOperand, "");
    char *targetOperand = malloc(1024);
    sprintf(targetOperand, "");
    int scratchBase = scratchStart[funcCount];
    switch (currentQuad->opcode){
        case opCOMM: 
            if(section != data){
                section = data;
                sprintf(assCommand, "\t.data\n");
                fputs(assCommand, fp);
            }
            sprintf(assCommand, "\t.comm %s,%s,%s\n", currentQuad->target,currentQuad->left,currentQuad->right);
            fputs(assCommand, fp);
            break;
        case opFUNC:
            if(section != text){
                section = text;
                sprintf(assCommand, "\t.text\n");
                fputs(assCommand, fp);
            }
            sprintf(assCommand, "\t.globl %s\n", currentQuad->target);
            fputs(assCommand, fp);
            for (int i = endBlock+1; i<= branchNum+1; i++){
                sprintf(assCommand, "\t.globl .BB%d\n",blockNums[i]);
                fputs(assCommand, fp);
            }
            sprintf(assCommand, "\t.type\t%s,@function\n%s:\n",currentQuad->target,currentQuad->target );
            fputs(assCommand, fp);
            sprintf(assCommand, "\tpushl %cebp\n\tmovl %cesp,%cebp\n", 37, 37, 37);
            fputs(assCommand,fp);
            sprintf(assCommand,"\tsubl\t$%d, %cesp\n", scratchBase, 37);
            fputs(assCommand, fp);
            
            break;
        case opMOV://four cases for operand: integer, global variable, local variable, and temp reg i.e. scratch variable
                    //in case of global variable just pass in name of operand as  usual
            if(section != text){
                section = text;
                sprintf(assCommand, "\t.text\n");
                fputs(assCommand, fp);
            }
            leftOperand = getOperand(currentQuad->left, currentQuad->leftSymbol, scratchBase);
            if(!strstr(leftOperand,"$" )){
                
                sprintf(assCommand, "\tmovl\t%s, %c%s\n", leftOperand, 37, getRegFromScratch(scratchReg));
                fputs(assCommand,fp);
                sprintf(leftOperand, "%c%s", 37, getRegFromScratch(scratchReg));
                scratchReg++;
                leftTest = 1;
            }
            targetOperand = getOperand(currentQuad->target, currentQuad->targetSymbol, scratchBase);
            sprintf(assCommand, "\tmovl\t%s, %s\n", leftOperand, targetOperand);
            fputs(assCommand, fp);
            if(leftTest){
                scratchReg--;
                leftTest = 0;
                sprintf(assCommand, "\tmovl\t$0, %c%s\n",37, getRegFromScratch(scratchReg));
                
                fputs(assCommand, fp);
            } 
            break;
        case opSTRING:
           
            stringList[assStringCount] = currentQuad->left;
            assStringCount++;



            break;
        case opARG:
            char *tempTest = malloc(1024);
            sprintf(tempTest, "%c", 37);
            if(section != text){
                    section = text;
                    sprintf(assCommand, "\t.text\n");
                    fputs(assCommand, fp);
            }
            char *argOperand = getOperand(currentQuad->right, currentQuad->rightSymbol, scratchBase);
            if(!strstr(argOperand,"$" )){
                
                sprintf(assCommand, "\tmovl\t%s, %c%s\n", argOperand, 37, getRegFromScratch(scratchReg));
                fputs(assCommand,fp);
                sprintf(argOperand, "%c%s", 37, getRegFromScratch(scratchReg));
                scratchReg++;
                leftTest = 1;
            }
            long argNum = strtol(currentQuad->left,NULL, 10)-1;
            sprintf(assCommand, "\tpush\t%s\n", argOperand);
            fputs(assCommand, fp);
            if(leftTest){
                scratchReg--;
                leftTest = 0;
                sprintf(assCommand, "\tmovl\t$0, %c%s\n",37, getRegFromScratch(scratchReg));
                
                fputs(assCommand, fp);
            } 
            break;
        case opCALL:
            targetOperand = getOperand(currentQuad->target, currentQuad->targetSymbol, scratchBase);
            if(section != text){
                    section = text;
                    sprintf(assCommand, "\t.text\n");
                    fputs(assCommand, fp);
            }
            if(!isdigit(currentQuad->left[0])){
                sprintf(assCommand, "\tcall\t%s\n", currentQuad->left);
                fputs(assCommand, fp);
                int testCmp = strcmp(targetOperand, "");
                if(testCmp){
                    sprintf(assCommand, "\tmovl\t%ceax, %s\n", 37, targetOperand);
                    fputs(assCommand, fp);
                }
            }
            break;
        case opRET:
            if(currentQuad->left){

                leftOperand = getOperand(currentQuad->left, currentQuad->leftSymbol, scratchBase);
                sprintf(assCommand, "\tmovl %s, %ceax\n",leftOperand, 37);
                fputs(assCommand, fp);
            }
            sprintf(assCommand, "\tleave\n\tret\n");
            fputs(assCommand, fp);

            break;
        case opINC:
            targetOperand= getOperand(currentQuad->target, currentQuad->targetSymbol, scratchBase);
            sprintf(assCommand, "\tincl\t%s\n", targetOperand);
            fputs(assCommand, fp);
            break;
        case opDEC:
            targetOperand= getOperand(currentQuad->target, currentQuad->targetSymbol, scratchBase);
            sprintf(assCommand, "\tdecl\t%s\n", targetOperand);
            fputs(assCommand, fp);
            break;
        case opCMP:
            leftOperand = getOperand(currentQuad->left, currentQuad->leftSymbol, scratchBase);
            if(!strstr(leftOperand,"$" )){
                
                sprintf(assCommand, "\tmovl\t%s, %c%s\n", leftOperand, 37, getRegFromScratch(scratchReg));
                fputs(assCommand,fp);
                sprintf(leftOperand, "%c%s", 37, getRegFromScratch(scratchReg));
                scratchReg++;
                leftTest = 1;
            }
            rightOperand = getOperand(currentQuad->right, currentQuad->rightSymbol, scratchBase);
            if(!strstr(rightOperand,"$" )){
                
                sprintf(assCommand, "\tmovl\t%s, %c%s\n", rightOperand, 37, getRegFromScratch(scratchReg));
                fputs(assCommand,fp);
                sprintf(rightOperand, "%c%s", 37, getRegFromScratch(scratchReg));
                scratchReg++;
                rightTest = 1;
            }
            
            
            sprintf(assCommand,"\tcmpl\t%s, %s\n", rightOperand, leftOperand );
            fputs(assCommand, fp);
            if(rightTest){
                scratchReg--;
                rightTest = 0;
                sprintf(assCommand, "\tmovl\t$0, %c%s\n", 37,getRegFromScratch(scratchReg));
                fputs(assCommand, fp);
            } 
            if(leftTest){
                scratchReg--;
                leftTest = 0;
                sprintf(assCommand, "\tmovl\t$0, %c%s\n",37, getRegFromScratch(scratchReg));
                
                fputs(assCommand, fp);
            } 
            
            break;
        case opBR:
            leftOperand = getOperand(currentQuad->left, currentQuad->leftSymbol, scratchBase);
            sprintf(assCommand,"\tjmp\t.%s\n", leftOperand );
            fputs(assCommand, fp);
            break;
        case opBRGE:
            leftOperand = getOperand(currentQuad->left, currentQuad->leftSymbol, scratchBase);
            rightOperand = getOperand(currentQuad->right, currentQuad->rightSymbol, scratchBase);
            sprintf(assCommand, "\tjge\t.%s\n", leftOperand);
            fputs(assCommand, fp);
            sprintf(assCommand, "\tjl\t.%s\n", rightOperand);
            fputs(assCommand,fp);
            break;
        case opBRLE:
            leftOperand = getOperand(currentQuad->left, currentQuad->leftSymbol, scratchBase);
            rightOperand = getOperand(currentQuad->right, currentQuad->rightSymbol, scratchBase);
            sprintf(assCommand, "\tjle\t.%s\n", leftOperand);
            fputs(assCommand, fp);
            sprintf(assCommand, "\tjg\t.%s\n", rightOperand);
            fputs(assCommand,fp);
            break;
        case opBRNE:
            leftOperand = getOperand(currentQuad->left, currentQuad->leftSymbol, scratchBase);
            rightOperand = getOperand(currentQuad->right, currentQuad->rightSymbol, scratchBase);
            sprintf(assCommand, "\tjne\t.%s\n", leftOperand);
            fputs(assCommand, fp);
            sprintf(assCommand, "\tje\t.%s\n", rightOperand);
            fputs(assCommand,fp);
            break;
        case opBREQ:
            leftOperand = getOperand(currentQuad->left, currentQuad->leftSymbol, scratchBase);
            rightOperand = getOperand(currentQuad->right, currentQuad->rightSymbol, scratchBase);
            sprintf(assCommand, "\tjee\t.%s\n", leftOperand);
            fputs(assCommand, fp);
            sprintf(assCommand, "\tjne\t.%s\n", rightOperand);
            fputs(assCommand,fp);
            break;
        case opBRGT: 
            leftOperand = getOperand(currentQuad->left, currentQuad->leftSymbol, scratchBase);
            rightOperand = getOperand(currentQuad->right, currentQuad->rightSymbol, scratchBase);
            sprintf(assCommand, "\tjg\t.%s\n", leftOperand);
            fputs(assCommand, fp);
            sprintf(assCommand, "\tjle\t.%s\n", rightOperand);
            fputs(assCommand,fp);
            break;
        case opBRLT: 
            leftOperand = getOperand(currentQuad->left, currentQuad->leftSymbol, scratchBase);
            rightOperand = getOperand(currentQuad->right, currentQuad->rightSymbol, scratchBase);
            sprintf(assCommand, "\tjl\t.%s\n", leftOperand);
            fputs(assCommand, fp);
            sprintf(assCommand, "\tjge\t.%s\n", rightOperand);
            fputs(assCommand,fp);
            break;
        case opADD:
            scratchReg++;
            leftOperand = getOperand(currentQuad->left, currentQuad->leftSymbol, scratchBase);
            if(!strstr(leftOperand,"$" )){
                
                sprintf(assCommand, "\tmovl\t%s, %c%s\n", leftOperand, 37, getRegFromScratch(scratchReg));
                fputs(assCommand,fp);
                sprintf(leftOperand, "%c%s", 37, getRegFromScratch(scratchReg));
                scratchReg++;
                leftTest = 1;
            }
            rightOperand = getOperand(currentQuad->right, currentQuad->rightSymbol, scratchBase);
            if(!strstr(rightOperand,"$" )){
                
                sprintf(assCommand, "\tmovl\t%s, %c%s\n", rightOperand, 37, getRegFromScratch(scratchReg));
                fputs(assCommand,fp);
                sprintf(rightOperand, "%c%s", 37, getRegFromScratch(scratchReg));
                scratchReg++;
                rightTest = 1;
            }
            targetOperand = getOperand(currentQuad->target, currentQuad->targetSymbol, scratchBase);
            sprintf(assCommand, "\tmovl\t%s, %ceax\n", leftOperand, 37 );
            fputs(assCommand, fp);
            sprintf(assCommand, "\taddl\t%s, %ceax\n",rightOperand,37 );
            fputs(assCommand, fp);
            sprintf(assCommand, "\tmovl\t %ceax, %s\n",37,targetOperand);
            fputs(assCommand, fp);
            if(rightTest){
                scratchReg--;
                rightTest = 0;
                sprintf(assCommand, "\tmovl\t$0, %c%s\n", 37,getRegFromScratch(scratchReg));
                fputs(assCommand, fp);
            } 
            if(leftTest){
                scratchReg--;
                leftTest = 0;
                sprintf(assCommand, "\tmovl\t$0, %c%s\n",37, getRegFromScratch(scratchReg));
                
                fputs(assCommand, fp);
            } 
            scratchReg--;
            sprintf(assCommand, "\tmovl\t$0,%ceax\n",37);
            fputs(assCommand,fp);
            break;
        case opSUB:
            scratchReg++;
            leftOperand = getOperand(currentQuad->left, currentQuad->leftSymbol, scratchBase);
            if(!strstr(leftOperand,"$" )){
                
                sprintf(assCommand, "\tmovl\t%s, %c%s\n", leftOperand, 37, getRegFromScratch(scratchReg));
                fputs(assCommand,fp);
                sprintf(leftOperand, "%c%s", 37, getRegFromScratch(scratchReg));
                scratchReg++;
                leftTest = 1;
            }
            rightOperand = getOperand(currentQuad->right, currentQuad->rightSymbol, scratchBase);
            if(!strstr(rightOperand,"$" )){
                
                sprintf(assCommand, "\tmovl\t%s, %c%s\n", rightOperand, 37, getRegFromScratch(scratchReg));
                fputs(assCommand,fp);
                sprintf(rightOperand, "%c%s", 37, getRegFromScratch(scratchReg));
                scratchReg++;
                rightTest = 1;
            }
            targetOperand = getOperand(currentQuad->target, currentQuad->targetSymbol, scratchBase);
            sprintf(assCommand, "\tmovl\t%s, %ceax\n", leftOperand, 37 );
            fputs(assCommand, fp);
            sprintf(assCommand, "\tsubl\t%s, %ceax\n",rightOperand,37 );
            fputs(assCommand, fp);
            sprintf(assCommand, "\tmovl\t %ceax, %s\n",37,targetOperand);
            fputs(assCommand, fp);
            if(rightTest){
                scratchReg--;
                rightTest = 0;
                sprintf(assCommand, "\tmovl\t$0, %c%s\n", 37,getRegFromScratch(scratchReg));
                fputs(assCommand, fp);
            } 
            if(leftTest){
                scratchReg--;
                leftTest = 0;
                sprintf(assCommand, "\tmovl\t$0, %c%s\n",37, getRegFromScratch(scratchReg));
                
                fputs(assCommand, fp);
            } 
            scratchReg--;
            sprintf(assCommand, "\tmovl\t$0,%ceax\n",37);
            fputs(assCommand,fp);
            break;
        case opMUL:
            scratchReg++;
            leftOperand = getOperand(currentQuad->left, currentQuad->leftSymbol, scratchBase);
            if(!strstr(leftOperand,"$" )){
                
                sprintf(assCommand, "\tmovl\t%s, %c%s\n", leftOperand, 37, getRegFromScratch(scratchReg));
                fputs(assCommand,fp);
                sprintf(leftOperand, "%c%s", 37, getRegFromScratch(scratchReg));
                scratchReg++;
                leftTest = 1;
            }
            rightOperand = getOperand(currentQuad->right, currentQuad->rightSymbol, scratchBase);
            if(!strstr(rightOperand,"$" )){
                
                sprintf(assCommand, "\tmovl\t%s, %c%s\n", rightOperand, 37, getRegFromScratch(scratchReg));
                fputs(assCommand,fp);
                sprintf(rightOperand, "%c%s", 37, getRegFromScratch(scratchReg));
                scratchReg++;
                rightTest = 1;
            }
            targetOperand = getOperand(currentQuad->target, currentQuad->targetSymbol, scratchBase);
            sprintf(assCommand, "\tmovl\t%s, %ceax\n", leftOperand, 37 );
            fputs(assCommand, fp);
            sprintf(assCommand, "\timul\t%s, %ceax\n",rightOperand,37 );
            fputs(assCommand, fp);
            sprintf(assCommand, "\tmovl\t %ceax, %s\n",37,targetOperand);
            fputs(assCommand, fp);
            if(rightTest){
                scratchReg--;
                rightTest = 0;
                sprintf(assCommand, "\tmovl\t$0, %c%s\n", 37,getRegFromScratch(scratchReg));
                fputs(assCommand, fp);
            } 
            if(leftTest){
                scratchReg--;
                leftTest = 0;
                sprintf(assCommand, "\tmovl\t$0, %c%s\n",37, getRegFromScratch(scratchReg));
                
                fputs(assCommand, fp);
            } 
            scratchReg--;
            sprintf(assCommand, "\tmovl\t$0,%ceax\n",37);
            fputs(assCommand,fp);
            break;
        case opDIV:
            scratchReg++;
            leftOperand = getOperand(currentQuad->left, currentQuad->leftSymbol, scratchBase);
            if(!strstr(leftOperand,"$" )){
                
                sprintf(assCommand, "\tmovl\t%s, %c%s\n", leftOperand, 37, getRegFromScratch(scratchReg));
                fputs(assCommand,fp);
                sprintf(leftOperand, "%c%s", 37, getRegFromScratch(scratchReg));
                scratchReg++;
                leftTest = 1;
            }
            rightOperand = getOperand(currentQuad->right, currentQuad->rightSymbol, scratchBase);
            
                
            sprintf(assCommand, "\tmovl\t%s, %cebx\n", rightOperand, 37);
            fputs(assCommand,fp);
            sprintf(rightOperand, "%cebx", 37);
            scratchReg++;
            rightTest = 1;
        
            targetOperand = getOperand(currentQuad->target, currentQuad->targetSymbol, scratchBase);
            sprintf(assCommand, "\tmovl\t%s, %ceax\n", leftOperand, 37 );
            fputs(assCommand, fp);
            
            sprintf(assCommand, "\tdiv\t%s\n",rightOperand );
            fputs(assCommand, fp);
            sprintf(assCommand, "\tmovl\t %ceax, %s\n",37,targetOperand);
            fputs(assCommand, fp);
            if(rightTest){
                scratchReg--;
                rightTest = 0;
                sprintf(assCommand, "\tmovl\t$0, %cebx\n", 37);
                fputs(assCommand, fp);
            } 
            if(leftTest){
                scratchReg--;
                leftTest = 0;
                sprintf(assCommand, "\tmovl\t$0, %c%s\n",37, getRegFromScratch(scratchReg));
                
                fputs(assCommand, fp);
            } 
            scratchReg--;
            sprintf(assCommand, "\tmovl\t$0,%ceax\n",37);
            fputs(assCommand,fp);
            break;
        case opLEA:
            leftOperand = getOperand(currentQuad->left, currentQuad->leftSymbol, scratchBase);
            targetOperand = getOperand(currentQuad->target, currentQuad->targetSymbol, scratchBase);
            
            strcpy(tempTarget, targetOperand);
            sprintf(assCommand, "\tmovl\t%s, %c%s\n", targetOperand, 37, getRegFromScratch(scratchReg));
            fputs(assCommand,fp);
            sprintf(targetOperand, "%c%s", 37, getRegFromScratch(scratchReg));
           // scratchReg++;
            //targetTest = 1;
            sprintf(assCommand, "\tLEA\t%s, %s\n",leftOperand, targetOperand);
            fputs(assCommand, fp);
            sprintf(assCommand, "\tmovl %c%s, %s\n", 37, getRegFromScratch(scratchReg), tempTarget);
            fputs(assCommand, fp);
            if(targetTest){
               // scratchReg--;
                targetTest = 0;
                sprintf(assCommand, "\tmovl\t$0, %c%s\n", 37, getRegFromScratch(scratchReg));
                fputs(assCommand, fp);
            } 
            break;  
        case opLOAD:
            leftOperand = getOperand(currentQuad->left, currentQuad->leftSymbol, scratchBase);
            
                
            sprintf(assCommand, "\tmovl\t%s, %c%s\n", leftOperand, 37, getRegFromScratch(scratchReg));
            fputs(assCommand,fp);
            sprintf(leftOperand, "%c%s", 37, getRegFromScratch(scratchReg));
            scratchReg++;
            leftTest = 1;
            
            targetOperand = getOperand(currentQuad->target, currentQuad->targetSymbol, scratchBase);
            
            strcpy(tempTarget, targetOperand);
           // sprintf(assCommand, "\tmovl\t%s, %c%s\n", targetOperand, 37, getRegFromScratch(scratchReg));
            //fputs(assCommand,fp);
            sprintf(targetOperand, "%c%s", 37, getRegFromScratch(scratchReg));
            scratchReg++;
            targetTest = 1;
            sprintf(assCommand, "\tmovl\t(%s), %s\n", leftOperand, targetOperand);
            fputs(assCommand, fp);
            sprintf(assCommand, "\tmovl\t%s, %s\n", targetOperand, tempTarget);
            fputs(assCommand, fp);
            if(targetTest){
                scratchReg--;
                targetTest = 0;
                sprintf(assCommand, "\tmovl\t$0, %c%s\n",37, getRegFromScratch(scratchReg));
                
                fputs(assCommand, fp);
            } 
            if(leftTest){
                scratchReg--;
                leftTest = 0;
                sprintf(assCommand, "\tmovl\t$0, %c%s\n",37, getRegFromScratch(scratchReg));
                
                fputs(assCommand, fp);
            } 
            break;
        case opSTORE:
            leftOperand = getOperand(currentQuad->left, currentQuad->leftSymbol, scratchBase);
            
                
            if(!strstr(leftOperand,"$" )){
                
                sprintf(assCommand, "\tmovl\t%s, %c%s\n", leftOperand, 37, getRegFromScratch(scratchReg));
                fputs(assCommand,fp);
                sprintf(leftOperand, "%c%s", 37, getRegFromScratch(scratchReg));
                scratchReg++;
                leftTest = 1;
            }
            
            rightOperand = getOperand(currentQuad->right, currentQuad->rightSymbol, scratchBase);
            if(!strstr(rightOperand,"$" )){
                
                sprintf(assCommand, "\tmovl\t%s, %c%s\n", rightOperand, 37, getRegFromScratch(scratchReg));
                fputs(assCommand,fp);
                sprintf(rightOperand, "%c%s", 37, getRegFromScratch(scratchReg));
                scratchReg++;
                rightTest = 1;
            }
           /* strcpy(tempRight, rightOperand);
            sprintf(assCommand, "\tmovl\t%s, %c%s\n", rightOperand, 37, getRegFromScratch(scratchReg));
            fputs(assCommand,fp);
            sprintf(rightOperand, "%c%s", 37, getRegFromScratch(scratchReg));
            scratchReg++;
            targetTest = 1;*/
            sprintf(assCommand, "\tmovl\t%s, (%s)\n", leftOperand, rightOperand);
            fputs(assCommand, fp);
           // sprintf(assCommand, "\tmovl\t%s, %s\n", targetOperand, tempTarget);
            //fputs(assCommand, fp);
            if(rightTest){
                scratchReg--;
                rightTest = 0;
                sprintf(assCommand, "\tmovl\t$0, %cebx\n", 37);
                fputs(assCommand, fp);
            } 
            if(leftTest){
                scratchReg--;
                leftTest = 0;
                sprintf(assCommand, "\tmovl\t$0, %c%s\n",37, getRegFromScratch(scratchReg));
                
                fputs(assCommand, fp);
            } 
            break;
        case opMOD:
            leftOperand = getOperand(currentQuad->left, currentQuad->leftSymbol, scratchBase);
            rightOperand = getOperand(currentQuad->right, currentQuad->rightSymbol, scratchBase);
            targetOperand = getOperand(currentQuad->target, currentQuad->targetSymbol, scratchBase);
            sprintf(assCommand, "\tmovl\t%s, %ceax\n", rightOperand,37);
            fputs(assCommand, fp);
            sprintf(rightOperand, "%ceax", 37);

            sprintf(assCommand, "\tmovl\t%s, %cebx\n", leftOperand,37);
            fputs(assCommand, fp);
            sprintf(leftOperand, "%cebx", 37);
            
            sprintf(assCommand, "\txor\t%cedx, %cedx\n", 37,37);
            fputs(assCommand,fp);

            sprintf(assCommand, "\tdiv\t%s\n", leftOperand);
            fputs(assCommand, fp);

            sprintf(assCommand, "\tmovl %cedx, %s\n", 37, targetOperand);
            fputs(assCommand, fp);

            
            break;
    }
}

char *getOperand(char *quadOperand, struct symbolNode *quadSymbol, int scratchBase){
    char *operand = malloc(1024);
    if(isdigit(quadOperand[0])){
        sprintf(operand, "$%s", quadOperand);
    }
    else if(quadSymbol){
                if(quadSymbol->scope != global){
                    sprintf(operand, "-%d(%cebp)", quadSymbol->ebpOffset, 37);
                }
                else{
                    strcpy(operand,quadOperand);
                }
    }
    else if(strstr(quadOperand, "%") != NULL){
        long temp = strtol(quadOperand+2,NULL, 10);
        long scratchOffset = temp*4 + scratchBase;
        sprintf(operand, "-%d(%cebp)", scratchOffset, 37);
        //need to extract number of temp variable, and then add multiply by 4 and add to scratchBase
    }
    else{
        strcpy(operand, quadOperand);
    }
    return operand;

}

void rodataStrings(){
    char *assCommand = malloc(1024);
    section = ro_data;
    sprintf(assCommand, "\t.section .rodata\n");
    fputs(assCommand, fp);
    for (int i=0; i<assStringCount; i++){
        sprintf(assCommand, ".str%d:\n", i);
        fputs(assCommand,fp);
        sprintf(assCommand, "\t.string\t \"%s\"\n", stringList[i]);
        fputs(assCommand,fp);
    }
}

char *getRegFromScratch(int regNum){
    switch(regNum){
        case 0: return "eax";
        case 1: return "ecx";
        case 2: return "edx";
    }
}

int main(){
    int t;
    
    base = generateSymbol(0,1,0,0,"","",name,-1,NULL, base,0, 0, 4);
    firstQuad = NULL;
    globalList = NULL;
    lastGlobal = NULL;
    lastSymbol[0] = base;
    last = base;
    lastOpcode = -1;
    lastSize = malloc(1024);
    sprintf(lastSize,"1");
   // generateSymbol(int decLine, int scopeStart, int scope, char* type, char* name,char* fileName,int astType, struct astnode *member, struct symbolNode *head)
    funcHead = NULL;
    section = 0;
    lastType = -1;
    structOrFunc = -1;
    scopeNum = -1;
    scopeTotal = -1;
    quadScopeCount = -1;
    scopeNum = -1;
    nameSpaceNum = 0;
    isFunction = 0;
    isDeref = 0;
    isPointer = 0;
    tempVarCountNum = 1;
    numDim = 1;
    lastScopeType = -1;
    branchNum = 0;
    cur_bb = 0;
    funcCount = 0;
    ebpOffset = 4;
    lastDim = malloc(sizeof(struct astnode));
    lastDim->nodetype = -1;
    rightOp = malloc(sizeof(struct astnode));
    rightOp->nodetype = -1;
    bbToInsert = 0;
    endBlock = 0;
    scratchReg = 0;
    isArraySet = 0;
    quadStringCount = 0;
    assStringCount = 0;
    fp = fopen("./dscc.s", "w");
    //cur_bb = malloc(1024);
    yyparse();
    rodataStrings();
    fclose(fp);
    //print_quads(blockList,branchNum, blockNums);


}