%{
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include "left_factor_helper.h"

Symbols *symbol_sentinel;

void left_recursion();
%}

%%
.+/[\n %] {AddGrammar(symbol_sentinel,yytext);}
.+ {AddGrammar(symbol_sentinel,yytext);}
%%

int yywrap()
{
    return 1;
}

void left_recursion()
{
    char non_terminal, productions[10][100], splits[10][10];
    int num;
    FILE *f,*fp;
    f=fopen("input.txt","r");
    fp=fopen("output1.txt","w");
    int z=0;
    while(!feof(f))
    {
        fscanf(f,"%s",productions[z]);
        z++;
    }
    printf("\nGiven grammar is\n");
    for(int i = 0; i < z; i++)
    {
        printf("%s\n", productions[i]);
    }
    printf("\nAfter removing left-recursion,the grammar is\n");
    for(int i = 0; i < z; i++)
    {
        non_terminal = productions[i][0];
        char production[100], *token;
        int j, flag = 0;
        for(j = 0; productions[i][j + 3] != '\0'; j++)
        {
            production[j] = productions[i][j + 3];
        }
        production[j] = '\0';
        j = 0;
        token = strtok(production, "|");
        while(token != NULL)
        {
            strcpy(splits[j], token); 
            if(token[0] == non_terminal && flag == 0)flag = 1;  
            else if(token[0] != non_terminal && flag == 1)flag = 2;
            j++;
            token = strtok(NULL, "|");
        }
        
        if(flag==0)
        {
            fputs(productions[i],fp);
            fputs("\n",fp);
            printf("%s\n", productions[i]);
        }
        if(flag==2)
        {
            flag = 0;
            for(int k = 0; k < j; k++)
            {
                if(splits[k][0] != non_terminal) {
                    if(flag != 0)
                    {
                        fputs("|",fp);
                        fputs(splits[k],fp);
                        fputc(non_terminal,fp);
                        fputs("'",fp);
                        printf("|%s%c\'", splits[k], non_terminal);
                    }
                    else
                    {
                        flag = 1;
                        fputc(non_terminal,fp);
                        fputs("->",fp);
                        fputs(splits[k],fp);
                        fputc(non_terminal,fp);
                        fputs("'",fp);
                        printf("%c->%s%c\'", non_terminal, splits[k], non_terminal);
                    }
                }
            }
            fputs("\n",fp);
            printf("\n");
            flag = 0;
            for(int k = 0; k < j; k++)
            {
                if(splits[k][0] == non_terminal) {
                    if(flag != 0)
                    {
                        fputs("|",fp);
                        fputs(splits[k]+1,fp);
                        fputc(non_terminal,fp);
                        fputs("'",fp);
                        printf("|%s%c\'", splits[k] + 1, non_terminal);
                    }
                    else
                    {
                        flag = 1;
                        fputc(non_terminal,fp);
                        fputs("'",fp);
                        fputs("->",fp);
                        fputs(splits[k]+1,fp);
                        fputc(non_terminal,fp);                    
                        fputs("'",fp);
                        printf("%c\'->%s%c\'", non_terminal, splits[k] + 1, non_terminal);
                    }
                }
            }        
            fputs("|#\n",fp);
            printf("|#\n");
        }
    }
    printf("\n");
    fclose(fp);
    FILE *fpp;
    fpp=fopen("output1.txt","r");
}


int main()
{
    left_recursion();
    extern FILE *yyin;
    yyin = fopen("input.txt","r");
    symbol_sentinel = createSymbolSentinel();
    yylex();
    leftfactor(symbol_sentinel);
    printf("\n");
    PrintSymbols(symbol_sentinel);
    return 0;
}