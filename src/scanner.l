%state IN_LINE_COMMENT
%state IN_BLOCK_COMMENT
%state IN_STRING
%{
#include <vslc.h>
extern YYSTYPE yylval;
%}
%option noyywrap
%option array
%option yylineno

%%
<INITIAL>{
    "//"                    { BEGIN(IN_LINE_COMMENT); }
    "/*"                    { BEGIN(IN_BLOCK_COMMENT); }
    ["]                     { BEGIN(IN_STRING); }
    "def"                   { return FUNC; }
    "begin"                 { return OPENBLOCK; }
    "end"                   { return CLOSEBLOCK; }
    "return"                { return RETURN; }
    "print"                 { return PRINT; }
    "if"                    { return IF; }
    "then"                  { return THEN; }
    "else"                  { return ELSE; }
    "while"                 { return WHILE; }
    "do"                    { return DO; }
    "continue"              { return CONTINUE; }
    "var"                   { return VAR; }
    "<<"                    { return LSHIFT; }
    ">>"                    { return RSHIFT; }
    ":="                    { return ASSIGNMENT;}
    [0-9]+                  { sscanf(yytext, "%l", &yylval.number);
                              return NUMBER; 
                            }
    [_a-zA-Z][_a-zA-Z0-9]*  { yylval.string = yytext; return IDENTIFIER; }
    [\t\n\r\v ]+            ;
    .                       { return yytext[0]; }
}

<IN_LINE_COMMENT>{
    \n                      { BEGIN(INITIAL); }
    .                       ;
}

<IN_BLOCK_COMMENT>{
    "*\\"                   { BEGIN(INITIAL); }
    \n                      ;
    .                       ;
}

<IN_STRING>{
    "\\\""                  { yymore(); }
    "\""                    { yylval.string = yytext; BEGIN(INITIAL); return STRING;}
    .                       { yymore(); }
}
%%

void send_number_node(void){
    long* node_data = malloc(sizeof(long));
    sscanf(yytext, "%l", node_data);
    yylval = node_create(NUMBER_DATA, node_data, 0);
}

void send_string_node(void){
    char* node_data = strdup(yytext));
    yylval = node_create(STRING_DATA, node_data, 0);
}

void send_identifier_node(void){
    char* node_data = strdup(yytext));
    yylval = node_create(IDENTIFIER_DATA, node_data, 0);
}

// // Debug code
// int main(void) {
//     int token;
//     while (1) {
//         token = yylex();
//         switch(token){
//             case FUNC:{
//                 printf("FUNC\n");
//                 break;
//             }
//             case OPENBLOCK:{
//                 printf("OPENBLOCK\n");
//                 break;
//             }
//             case CLOSEBLOCK:{
//                 printf("CLOSEBLOCK\n");
//                 break;
//             }
//             case RETURN:{
//                 printf("RETURN\n");
//                 break;
//             }
//             case PRINT:{
//                 printf("PRINT\n");
//                 break;
//             }
//             case IF:{
//                 printf("IF\n");
//                 break;
//             }
//             case THEN:{
//                 printf("THEN\n");
//                 break;
//             }
//             case ELSE:{
//                 printf("ELSE\n");
//                 break;
//             }
//             case WHILE:{
//                 printf("WHILE\n");
//                 break;
//             }
//             case DO:{
//                 printf("DO\n");
//                 break;
//             }
//             case CONTINUE:{
//                 printf("CONTINUE\n");
//                 break;
//             }
//             case VAR:{
//                 printf("VAR\n");
//                 break;
//             }
//             case LSHIFT:{
//                 printf("LSHIFT\n");
//                 break;
//             }
//             case RSHIFT:{
//                 printf("RSHIFT\n");
//                 break;
//             }
//             case ASSIGNMENT:{
//                 printf("ASSIGNMENT\n");
//                 break;
//             }
//             case NUMBER:{
//                 printf("NUMBER\n");
//                 break;
//             }
//             case IDENTIFIER:{
//                 printf("IDENTIFIER\n");
//                 break;
//             }
//             case STRING:{
//                 printf("STRING\n");
//                 break;
//             }
//         }
//     }
// }