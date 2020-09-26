#include <stdio.h>
#include <string.h>

char *substring(char str[], int start, int end)
{
    end = end < 1 ? strlen(str) : end;
    char substr[100];
    int c = 0;
    for (int i = start; i < end; i++)
    {
        substr[c] = str[i];
        c++;
    }
    substr[c] = '\0';
    char *p = substr;
    return p;
}

char *subVar(char str[], int start, int end)
{
    // printf("%s , %d %d\n", str, start, end);
    char substr[100];
    strcpy(substr, "");
    int c = 0, k = 0;
    for (int i = 0; k < end && str[i] != '\0'; i++)
    {
        if (str[i] != '\'')
            k++;
        if (k > start)
        {
            // printf("%d , %d\n", k, end);
            // printf("Adding : %c\n", str[i]);
            substr[c] = str[i];
            c++;
            if (k == end)
            {
                i++;
                while (str[i] == '\'')
                {
                    substr[c] = str[i];
                    i++;
                    c++;
                }
            }
        }
    }
    substr[c] = '\0';
    char *p = substr;
    return p;
}

int getVariablesCount(char str[])
{
    int c = 0;
    for (int i = 0; str[i] != '\0'; i++)
    {
        c += str[i] == '\'' ? 0 : 1;
    }
    return c;
}