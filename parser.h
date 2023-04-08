#ifndef PARSER_H
#define PARSER_H

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
        int number;
        long double realNum;
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
        // 0 is DEREF, 1 is ADDRESSOF, 2 is SIZEOF
    };
    struct astnode_select{
        int indirectFlag;
        //0 if direct, 1 if indirect
        struct astnode *parent;
        char* member;
    };
    struct astnode_type{
        int type;
        struct astnode *next;
    };
    struct astnode_funcarg{
        struct astnode *current;
        struct astnode *next;
        struct astnode *head;
        int argCount;
    };
    struct astnode_func{
        struct astnode *name;
        struct astnode *args;
    };
    struct astnode_declarationType{
        enum decTypes{
            decVOID,
            decCHAR,
            decSHORT,
            decINT,
            decLONG,
            decFLOAT,
            decDOUBLE,
            decSIGNED,
            decUNSIGNED,
            dec_BOOL,
            dec_COMPLEX,
            decConst,
            decRestrict,
            decVolatile
        }type;
        struct astnode *nextType;

    };

    struct astnode_scalarVar{// need to store storage class(can assume extern for now), data type 
        //char* storageClass;
        int storageClass;
        char* dataType;
        char* name;
       // int structCompleteFlag; // only used if 0, meaning it is incomplete

    };
    struct astnode_pointer{
        struct astnode *member;
        char* type;
        char* name;
        int storageClass;
    };
    struct astnode_array{
        char* type;
        int size;
        char* name;
        int storageClass;
    };
    struct astnode_funcDec{
        char* type;
        char* name;
        int astType;
        int isSub;
        struct astnode *decNode;
    };
    struct astnode_multDec{
        struct astnode *left;
        struct astnode *right;
    };
    struct astnode_structDec{
        char* name;
        char* lineNum;
    };
    struct astnode_storage{
        enum astStorage{
            astExtern,
            astStatic,
            astAuto,
            astRegister,
            astElse
        }storageType;
        struct astnode *nextType;
    };
    struct astnode_iterator{
        enum iterType{
            iterWhile,
            iterDoWhile,
            iterFor
        }iterType;
        struct astnode *first;
        struct astnode *second;
        struct astnode *third;
        struct astnode *body;
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
            struct astnode_type type;
            struct astnode_funcarg funcarg;
            struct astnode_func func;
            struct astnode_declarationType decType; //14
            struct astnode_scalarVar scalarVar; //15
            struct astnode_pointer pointer ; //16
            struct astnode_array array; //17
            struct astnode_funcDec funcDec; //18
            struct astnode_multDec multDec; //19
            struct astnode_structDec structDec; //20
            struct astnode_storage storageType; //21
            struct astnode_iterator iterator; //22

        };
        struct astnode *next;
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

    struct symbolNode{
        int declaredLine;
        int scopeStart;
        
        enum scopes{
            global,
            function,
            block,
            prototype
        }scope;
        enum identTypes{
            varName, //arrays here
            funcName,
            struct_union_tag,
            struct_union_member,
            label
        }identType;
        enum storageClass{
            externStore,
            staticStore,
            autoStore,
            registerStore,
            elseStore
        }storageType;
        char* type;
        char* identName;
        char* fileName;
        int astType;
        struct astnode *member;
        struct symbolNode *next;
        struct symbolNode *head;
        struct symbolNode *previousHead;
        struct symbolNode *subHead;
        struct symbolNode *blockHead;
        struct astnode *firstStatement;
        char* parentName;
        int structCompleteFlag; // 0 if struct incomplete, 1 if complete, not touched if neither of those
        int nameSpace;
    };
   
extern int line;
extern char name[1024];
//extern struct symbolNode *base;

void printAST(struct astnode *n, int indent);
void setupBinop(struct astnode *n, int operator,struct astnode* left, struct astnode* right);
void setupLogop(struct astnode *n, int operator,struct astnode* left, struct astnode* right);
void setupNumber(struct astnode *n,struct number number);
void setupIdent(struct astnode *n, char *string);
void setupString(struct astnode *n, char *string);
void setupTernary(struct astnode *n, struct astnode *opIf,struct astnode *opThen, struct astnode *opElse );
void setupAssignment(struct astnode *n, int operator,struct astnode* left, struct astnode* right);
void setupUnop(struct astnode *n, int operator,struct astnode* operand);
void setupCompop(struct astnode *n, int operator,struct astnode* left, struct astnode* right);
void setupGeneral(struct astnode *n, int type, struct astnode *sub);
void setupSelect(struct astnode *n, int flag, struct astnode *parent, char* member);
void setupType(struct astnode *n, int type, struct astnode *next);
void setupFuncarg(struct astnode *n, struct astnode *current, struct astnode* head);
void setupFunc(struct astnode *n, struct astnode *name, struct astnode *args);
int numberProcessing(int realCheck);

void setupDecType(struct astnode *n, int type, struct astnode *next );
void setupScalar(struct astnode *n, int storage, char* type, char* name);
void setupPointer(struct astnode *n, struct astnode *member);
void setupArray(struct astnode *n, int size, char* name);
void setupFuncDec(struct astnode *n, struct astnode *node);

void setupStructDec(struct astnode *n, char* name, char* line);
void setupStorage(struct astnode *n, int storageType);
void setupMult(struct astnode *n, struct astnode *left, struct astnode *right);

void setupIterator(struct astnode *n, struct astnode *first, struct astnode *second, struct astnode *third, struct astnode *body);
#endif
