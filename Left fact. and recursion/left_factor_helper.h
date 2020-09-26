#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "helper.h"


typedef struct node
{
    char production[100];
    struct node *next;
} list;

typedef struct symbols
{
    char symbol[100];
    list *productions;
    struct symbols *next;
} Symbols;

//Productions Functions
list *CreateNode(char *str)
{
    list *l = (list *)malloc(sizeof(list));
    strcpy(l->production, str);
    l->next = NULL;

    return l;
}

list *createSentinel()
{
    return CreateNode("\0");
}

void AddUnique(list *head, char *str)
{
    list *curr = head;
    while (curr->next != NULL)
    {
        curr = curr->next;
        if (strcmp(curr->production, str) == 0)
            return;
    }
    // printf("curr = %s , adding = %s\n", curr->str, str);
    list *l = CreateNode(str);
    curr->next = l;
}

void AddUniqueSorted(list *head, char *str)
{
    list *curr = head;
    int c = 0;
    while (curr->next != NULL && (c = strcmp(curr->next->production, str)) <= 0)
    {
        curr = curr->next;
        if (c == 0)
            return;
    }
    // printf("curr = %s , adding = %s\n", curr->str, str);
    list *l = CreateNode(str);
    l->next = curr->next;
    curr->next = l;
}

void DeleteList(list *head, char *str)
{
    list *curr = head;
    while (curr->next != NULL)
    {
        if (strcmp(curr->next->production, str) == 0)
        {
            // printf("parent : %s ,  deleting : %s\n", curr->production, curr->next->production);
            list *t = curr->next;
            // printf("%s\n", curr->next->next != NULL ? curr->next->next->production : "NULL");
            curr->next = curr->next->next;
            // printf("%s , %s\n", curr->production, curr->next->production);
            t->next = NULL;
            free(t);
            return;
        }
        curr = curr->next;
    }
}

void PrintList(list *head)
{
    list *curr = head;
    while (curr->next != NULL)
    {
        curr = curr->next;
        if (curr->next == NULL)
            printf("%s\n", curr->production);
        else
            printf("%s|", curr->production);
    }
}

//Symbols Functions
Symbols *createSymbol(char *str)
{
    Symbols *s = (Symbols *)malloc(sizeof(Symbols));
    strcpy(s->symbol, str);
    s->productions = createSentinel();
    s->next = NULL;

    return s;
}

Symbols *createSymbolSentinel()
{
    return createSymbol("\0");
}

void AddSymbol(Symbols *head, char *symbol)
{
    Symbols *curr = head;
    while (curr->next != NULL)
    {
        curr = curr->next;
    }
    Symbols *s = createSymbol(symbol);
    curr->next = s;
}

void AddFinal(Symbols *symbol, char *production)
{
    char p[100];
    int c = 0;
    for (int i = 0; production[i] != '\0'; i++)
    {
        if (production[i] == '|' || production[i + 1] == '\0')
        {
            if (production[i + 1] == '\0')
            {
                p[c] = production[i];
                c++;
            }
            p[c] = '\0';
            AddUniqueSorted(symbol->productions, p);
            c = 0;
            strcpy(p, "");
        }
        else
        {
            p[c] = production[i];
            c++;
        }
    }
}

void AddProductions(Symbols *head, char *symbol, char *production)
{
    Symbols *curr = head;
    while (curr->next != NULL)
    {
        curr = curr->next;
        if (strcmp(curr->symbol, symbol) == 0)
        {
            AddFinal(curr, production);
            return;
        }
    }
    Symbols *s = createSymbol(symbol);
    curr->next = s;
    AddFinal(s, production);
}

void AddGrammar(Symbols *head, char *gram)
{
    char sym[20];
    char prod[100];
    int i = 0, c = 0;
    for (; i < strlen(gram); i++)
    {
        if (gram[i] == '-')
        {
            sym[c] = '\0';
            strcpy(prod, substring(gram, i + 2, 0));
            // printf("%s , %s , %s\n", gram, sym, prod);
            AddProductions(head, sym, prod);
            return;
        }
        sym[c] = gram[i];
        c++;
    }
}

void PrintSymbols(Symbols *head)
{
    Symbols *curr = head;
    while (curr->next != NULL)
    {
        curr = curr->next;
        printf("%s -> ", curr->symbol);
        PrintList(curr->productions);
    }
}

void DeleteProduction(Symbols *head, char *symbol, char *production)
{
    Symbols *curr = head;
    while (curr->next != NULL)
    {
        curr = curr->next;
        if (strcmp(curr->symbol, symbol) == 0)
        {
            DeleteList(curr->productions, production);
            return;
        }
    }
}

int isSymbol(Symbols *head, char *symbol)
{
    Symbols *curr = head;
    while (curr->next != NULL)
    {
        curr = curr->next;
        if (strcmp(curr->symbol, symbol) == 0)
            return 1;
    }
    return 0;
}

char *genSymbol(Symbols *head, char symbol[])
{
    char s[20];
    strcpy(s, symbol);
    do
    {
        strcat(s, "\'");
    } while (isSymbol(head, s));
    char *p = s;
    return p;
}
//Left Factoring functions

char *getMaxPrefix(char s1[], char s2[])
{
    char s[100];
    strcpy(s, "");
    int m1 = getVariablesCount(s1);
    int m2 = getVariablesCount(s2);
    int count = m1;
    char smin[100];
    strcpy(smin, s1);
    if (m2 < m1)
    {
        count = m2;
        strcpy(smin, s2);
    }
    for (int i = 0; i < count; i++)
    {
        char p[100];
        strcpy(p, subVar(smin, i, i + 1));
        int d = strlen(s) + strlen(p);
        char sr1[100];
        strcpy(sr1, subVar(s1, 0, i + 1));
        char sr2[100];
        strcpy(sr2, subVar(s2, 0, i + 1));
        if (strcmp(sr1, sr2) == 0)
        {
            strcat(s, p);
        }
        else
        {
            char *k = s;
            return k;
        }
    }
    char *k = s;
    return k;
}

void left_factor_productions(Symbols *head, Symbols *curr)
{
    char *sym = curr->symbol;
    list *curr_prod = curr->productions;
    while (curr_prod->next != NULL && curr_prod->next->next != NULL)
    {
        char prefix[100];
        char si1[100];
        char si2[100];
        strcpy(si1, curr_prod->next->production);
        strcpy(si2, curr_prod->next->next->production);
        strcpy(prefix, getMaxPrefix(si1, si2));
        if (strcmp(prefix, "") != 0)
        {
            char nsym[20];
            strcpy(nsym, genSymbol(head, sym));
            char new_production[100];
            strcpy(new_production, prefix);
            strcat(new_production, nsym);
            char changed_production[100];
            char s1[100];
            strcpy(s1, substring(si1, strlen(prefix), 0));
            if (strcmp(s1, "") == 0)
                strcpy(s1, "#");
            strcpy(changed_production, s1);
            strcat(changed_production, "|");
            strcpy(s1, substring(si2, strlen(prefix), 0));
            if (strcmp(s1, "") == 0)
                strcpy(s1, "#");
            strcat(changed_production, s1);
            DeleteList(curr->productions, si1);
            DeleteList(curr->productions, si2);
            AddProductions(head, nsym, changed_production);
            AddUniqueSorted(curr->productions, new_production);
        }
        else
            curr_prod = curr_prod->next;
    }
}

void leftfactor(Symbols *head)
{
    Symbols *curr = head;
    while (curr->next != NULL)
    {
        curr = curr->next;
        left_factor_productions(head, curr);
    }
}

