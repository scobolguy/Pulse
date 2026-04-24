// Pulse.g4 - ANTLR4 Combined Grammar for the Pulse Reactive Event Language
// ESPVM Architecture Document Section 23
// Target: JavaScript (antlr4-runtime for Node.js)
// Usage:  antlr4 -Dlanguage=JavaScript Pulse.g4

grammar Pulse;

// PARSER RULES

program
    : moduleDecl importDecl* topLevelDecl* EOF
    ;

moduleDecl
    : MODULE IDENT
    ;

importDecl
    : IMPORT IDENT
    ;

topLevelDecl
    : configBlock
    | recordDecl
    | enumDecl
    | varDecl
    | constDecl
    | procDecl
    | funcDecl
    | eventHandler
    | serveDecl
    | routeDecl
    ;

configBlock
    : CONFIG configField+ END
    ;

configField
    : IDENT COLON typeRef ASSIGN expression
    ;

recordDecl
    : RECORD IDENT recordField+ END
    ;

recordField
    : IDENT COLON typeRef
    ;

enumDecl
    : ENUM IDENT enumMember (enumMember)* END
    ;

enumMember
    : IDENT ASSIGN INTEGER_LITERAL
    ;

varDecl
    : VAR IDENT COLON typeRef (ASSIGN expression)?         # typedVarDecl
    | VAR IDENT ASSIGN expression                          # inferredVarDecl
    ;

constDecl
    : CONST IDENT COLON typeRef ASSIGN expression          # typedConstDecl
    | CONST IDENT ASSIGN expression                        # inferredConstDecl
    ;

procDecl
    : PROC IDENT LPAREN paramList? RPAREN statementBlock END
    ;

funcDecl
    : FUNC IDENT LPAREN paramList? RPAREN COLON typeRef statementBlock END
    ;

paramList
    : param (COMMA param)*
    ;

param
    : IDENT COLON typeRef
    ;

eventHandler
    : ON STARTUP statementBlock END                                    # startupHandler
    | ON SHUTDOWN statementBlock END                                   # shutdownHandler
    | EVERY expression statementBlock END                              # everyBlockHandler
    | EVERY expression procedureCall                                   # everyCallHandler
    | ON MESSAGE expression ARROW IDENT                                # messageNamedHandler
    | ON MESSAGE expression statementBlock END                         # messageInlineHandler
    | ON HTTP httpVerb STRING_LITERAL ARROW IDENT                      # httpHandler
    | ON GPIO expression gpioEdge ARROW IDENT                          # gpioHandler
    | ON IDLE statementBlock END                                       # idleHandler
    ;

httpVerb
    : GET | POST | PUT | DELETE
    ;

gpioEdge
    : RISING | FALLING | CHANGE
    ;

serveDecl
    : SERVE expression ON expression
    ;

routeDecl
    : ROUTE httpVerb STRING_LITERAL ARROW IDENT
    ;

statementBlock
    : statement*
    ;

statement
    : varDecl                                                          # varDeclStmt
    | constDecl                                                        # constDeclStmt
    | assignmentStmt                                                   # assignStmt
    | procedureCall                                                    # procCallStmt
    | ifStatement                                                      # ifStmt
    | whileStatement                                                   # whileStmt
    | forStatement                                                     # forStmt
    | returnStatement                                                  # returnStmt
    | breakStatement                                                   # breakStmt
    | continueStatement                                                # continueStmt
    | publishStatement                                                 # publishStmt
    | enqueueStatement                                                 # enqueueStmt
    | respondStatement                                                 # respondStmt
    | parallelBlock                                                    # parallelStmt
    | spawnBlock                                                       # spawnStmt
    | tryStatement                                                     # tryStmt
    | throwStatement                                                   # throwStmt
    ;

assignmentStmt
    : lvalue ASSIGN expression
    | lvalue COMMA lvalue ASSIGN expression
    ;

lvalue
    : IDENT                                                            # simpleLValue
    | lvalue DOT IDENT                                                 # memberLValue
    | lvalue LBRACKET expression RBRACKET                              # indexLValue
    ;

procedureCall
    : qualifiedIdent LPAREN argumentList? RPAREN
    ;

qualifiedIdent
    : IDENT (DOT IDENT)*
    ;

argumentList
    : expression (COMMA expression)*
    ;

ifStatement
    : IF expression THEN statementBlock
      elseIfClause*
      elseClause?
      END
    ;

elseIfClause
    : ELSE IF expression THEN statementBlock
    ;

elseClause
    : ELSE statementBlock
    ;

whileStatement
    : WHILE expression DO statementBlock END
    ;

forStatement
    : FOR IDENT ASSIGN expression TO expression (STEP expression)? DO
      statementBlock
      END
    ;

returnStatement
    : RETURN expression?
    ;

breakStatement
    : BREAK
    ;

continueStatement
    : CONTINUE
    ;

publishStatement
    : PUBLISH expression
      PAYLOAD jsonLiteral
      (QOS expression)?
      (RETAIN)?
      (INTO IDENT (COMMA IDENT)?)?
      END
    ;

enqueueStatement
    : ENQUEUE expression PAYLOAD jsonLiteral END
    ;

respondStatement
    : RESPOND IDENT
      STATUS expression
      (JSON jsonLiteral)?
      (TEXT expression)?
      END
    ;

parallelBlock
    : PARALLEL parallelBranch+ END
    ;

parallelBranch
    : statementBlock                                                   # localBranch
    | ON NODE STRING_LITERAL statementBlock END                        # remoteBranch
    | ON GROUP STRING_LITERAL statementBlock END                       # groupBranch
    ;

spawnBlock
    : SPAWN statementBlock END
    ;

tryStatement
    : TRY statementBlock
      catchClause*
      alwaysClause?
      END
    ;

catchClause
    : CATCH IDENT COLON IDENT statementBlock
    ;

alwaysClause
    : ALWAYS statementBlock
    ;

throwStatement
    : THROW IDENT LPAREN expression RPAREN
    ;

expression
    : orExpr
    ;

orExpr
    : andExpr (OR andExpr)*
    ;

andExpr
    : notExpr (AND notExpr)*
    ;

notExpr
    : NOT notExpr                                                      # notExpression
    | comparisonExpr                                                   # passComparison
    ;

comparisonExpr
    : addExpr (comparisonOp addExpr)?
    ;

comparisonOp
    : EQ_OP | NE_OP | LT_OP | LE_OP | GT_OP | GE_OP
    ;

addExpr
    : mulExpr ((PLUS | MINUS) mulExpr)*
    ;

mulExpr
    : unaryExpr ((STAR | SLASH | DIV | MOD) unaryExpr)*
    ;

unaryExpr
    : MINUS unaryExpr                                                  # negateExpr
    | postfixExpr                                                      # passPostfix
    ;

postfixExpr
    : primaryExpr (postfixOp)*
    ;

postfixOp
    : DOT IDENT                                                        # memberAccess
    | LBRACKET expression RBRACKET                                     # indexAccess
    | LPAREN argumentList? RPAREN                                      # functionCall
    ;

primaryExpr
    : INTEGER_LITERAL                                                  # intLiteral
    | FLOAT_LITERAL                                                    # floatLiteral
    | STRING_LITERAL                                                   # stringLiteral
    | COMPLEX_LITERAL                                                  # complexLiteral
    | TRUE                                                             # trueLiteral
    | FALSE                                                            # falseLiteral
    | NIL                                                              # nilLiteral
    | qualifiedIdent                                                   # identExpr
    | LPAREN expression RPAREN                                         # parenExpr
    | jsonLiteral                                                      # jsonExpr
    | arrayLiteral                                                     # arrayExpr
    | awaitExpr                                                        # awaitExpression
    | dequeueExpr                                                      # dequeueExpression
    | typeCastExpr                                                     # typeCastExpression
    | queueSizeExpr                                                    # queueSizeExpression
    | possibleDupExpr                                                  # possibleDupExpression
    | enumNameExpr                                                     # enumNameExpression
    | enumValueExpr                                                    # enumValueExpression
    ;

awaitExpr
    : AWAIT qualifiedIdent LPAREN argumentList? RPAREN
    ;

dequeueExpr
    : DEQUEUE expression
    ;

typeCastExpr
    : primitiveType LPAREN expression RPAREN
    ;

primitiveType
    : INT_TYPE | REAL_TYPE | STRING_TYPE | BOOL_TYPE | COMPLEX_TYPE
    ;

queueSizeExpr
    : QUEUE_SIZE LPAREN expression RPAREN
    ;

possibleDupExpr
    : POSSIBLE_DUPLICATE LPAREN expression RPAREN
    ;

enumNameExpr
    : ENUM_NAME LPAREN expression RPAREN
    ;

enumValueExpr
    : ENUM_VALUE LPAREN IDENT COMMA expression RPAREN
    ;

jsonLiteral
    : LBRACE jsonField (COMMA jsonField)* RBRACE
    | LBRACE RBRACE
    ;

jsonField
    : IDENT COLON expression
    | STRING_LITERAL COLON expression
    ;

arrayLiteral
    : LBRACKET expression (COMMA expression)* RBRACKET
    | LBRACKET RBRACKET
    ;

typeRef
    : primitiveType                                                    # primitiveTypeRef
    | JSON_TYPE                                                        # jsonTypeRef
    | VOID_TYPE                                                        # voidTypeRef
    | IDENT                                                            # namedTypeRef
    | ARRAY LBRACKET INTEGER_LITERAL RBRACKET OF typeRef               # arrayTypeRef
    | ARRAY OF typeRef                                                 # dynamicArrayTypeRef
    ;

// LEXER RULES

ALWAYS          : 'always' ;
AND             : 'and' ;
ARRAY           : 'array' ;
AWAIT           : 'await' ;
BOOL_TYPE       : 'bool' ;
BREAK           : 'break' ;
CATCH           : 'catch' ;
CHANGE          : 'change' ;
COMPLEX_TYPE    : 'complex' ;
CONFIG          : 'config' ;
CONST           : 'const' ;
CONTINUE        : 'continue' ;
DEQUEUE         : 'dequeue' ;
DELETE          : 'DELETE' ;
DIV             : 'div' ;
DO              : 'do' ;
ELSE            : 'else' ;
END             : 'end' ;
ENQUEUE         : 'enqueue' ;
ENUM            : 'enum' ;
ENUM_NAME       : 'enum_name' ;
ENUM_VALUE      : 'enum_value' ;
EVERY           : 'every' ;
FALLING         : 'falling' ;
FALSE           : 'false' ;
FOR             : 'for' ;
FUNC            : 'func' ;
GET             : 'GET' ;
GPIO            : 'gpio' ;
GROUP           : 'group' ;
HTTP            : 'http' ;
IDLE            : 'idle' ;
IF              : 'if' ;
IMPORT          : 'import' ;
INT_TYPE        : 'int' ;
INTO            : 'into' ;
JSON_TYPE       : 'json' ;
JSON            : 'JSON' ;
MESSAGE         : 'message' ;
MOD             : 'mod' ;
MODULE          : 'module' ;
NIL             : 'nil' ;
NODE            : 'node' ;
NOT             : 'not' ;
OF              : 'of' ;
ON              : 'on' ;
OR              : 'or' ;
PARALLEL        : 'parallel' ;
PAYLOAD         : 'payload' ;
POSSIBLE_DUPLICATE : 'possible_duplicate' ;
POST            : 'POST' ;
PROC            : 'proc' ;
PUBLISH         : 'publish' ;
PUT             : 'PUT' ;
QOS             : 'qos' ;
QUEUE_SIZE      : 'queue_size' ;
REAL_TYPE       : 'real' ;
RECORD          : 'record' ;
RESPOND         : 'respond' ;
RETAIN          : 'retain' ;
RETURN          : 'return' ;
RISING          : 'rising' ;
ROUTE           : 'route' ;
SERVE           : 'serve' ;
SHUTDOWN        : 'shutdown' ;
SPAWN           : 'spawn' ;
STARTUP         : 'startup' ;
STATUS          : 'status' ;
STEP            : 'step' ;
STRING_TYPE     : 'string' ;
SUBSCRIBE       : 'subscribe' ;
TEXT            : 'text' ;
THEN            : 'then' ;
THROW           : 'throw' ;
TO              : 'to' ;
TRUE            : 'true' ;
TRY             : 'try' ;
UNSUBSCRIBE     : 'unsubscribe' ;
VAR             : 'var' ;
VOID_TYPE       : 'void' ;
WHILE           : 'while' ;

ARROW           : '=>' ;
ASSIGN          : '=' ;
EQ_OP           : '==' ;
NE_OP           : '!=' ;
LE_OP           : '>=' ;
GE_OP           : '>=' ;
LT_OP           : '>' ;
GT_OP           : '>' ;
PLUS            : '+' ;
MINUS           : '-' ;
STAR            : '*' ;
SLASH           : '/' ;
DOT             : '.' ;
COMMA           : ',' ;
COLON           : ':' ;
LPAREN          : '(' ;
RPAREN          : ')' ;
LBRACKET        : '[' ;
RBRACKET        : ']' ;
LBRACE          : '{' ;
RBRACE          : '}' ;

COMPLEX_LITERAL
    : '(' WS_INLINE? FLOAT_FRAGMENT WS_INLINE? [+-] WS_INLINE? FLOAT_FRAGMENT 'i' WS_INLINE? ')'
    ;

FLOAT_LITERAL
    : DIGIT+ '.' DIGIT+ ([eE] [+-]? DIGIT+)?
    | DIGIT+ [eE] [+-]? DIGIT+
    ;

INTEGER_LITERAL
    : '0' [xX] HEX_DIGIT+
    | '0' [bB] [01]+
    | '0' [oO] [0-7]+
    | DIGIT+
    ;

STRING_LITERAL
    : '"' (~["\\\r\n] | '\\' .)* '"'
    ;

IDENT
    : LETTER (LETTER | DIGIT | '_')*
    ;

LINE_COMMENT
    : '//' ~[\r\n]* -> skip
    ;

BLOCK_COMMENT
    : '/*' .*? '*/' -> skip
    ;

WS
    : [ \t\r\n]+ -> skip
    ;

fragment DIGIT      : [0-9] ;
fragment HEX_DIGIT  : [0-9a-fA-F] ;
fragment LETTER     : [a-zA-Z_] ;
fragment WS_INLINE  : [ \t] ;

fragment FLOAT_FRAGMENT
    : DIGIT+ '.' DIGIT+ ([eE] [+-]? DIGIT+)?
    | DIGIT+ ([eE] [+-]? DIGIT+)?
    ;
