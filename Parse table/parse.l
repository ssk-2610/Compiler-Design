%{
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<ctype.h>
int count = 0; int n=0; int m=0;
int first_arr[10][100];
int follow_arr[10][100];
char productions[10][10];
char first[10]; char first2[10];
char cc;
%}

%%
%%

int yywrap()
{
    return 1;
}

void follow(char c);

void first_fun(char c ,int q1 , int q2)
{
    int j;
    if(!(isupper(c))){
        first[n++]=c;
    }
    for(j=0;j<count;j++)
    {
        if(productions[j][0]==c)
        {
            if(productions[j][2]=='#'){
                if(productions[q1][q2] == '\0')
                    first[n++]='#';
                else if(productions[q1][q2] != '\0' && (q1 != 0 || q2 != 0))
                {
                    first_fun(productions[q1][q2], q1, (q2+1));
                }
                else
                    first[n++]='#';
            }
            else if(!isupper(productions[j][2])){
                first[n++]=productions[j][2];
            }
            else {
                first_fun(productions[j][2], j, 3);
            }
        }
    }
}

void followfirst(char c, int c1 , int c2)
{
    int k;
    if(!(isupper(c)))
        first2[m++]=c;
    else{
        int i=0,j=1;
        for(i=0;i<count;i++)
        {
            if(first_arr[i][0] == c)
                break;
        }
        while(first_arr[i][j] != '!')
        {
            if(first_arr[i][j] != '#'){
                first2[m++] = first_arr[i][j];
            }
            else{
                if(productions[c1][c2] == '\0'){
                    follow(productions[c1][0]);
                }
                else{
                    followfirst(productions[c1][c2],c1,c2+1);
                }
            }
            j++;
        }
    }
}

void follow(char c)
{
    int i ,j;
    if(productions[0][0]==c){
        first2[m++]='$';
    }
    for(i=0;i<10;i++)
    {
        for(j=2;j<10;j++)
        {
            if(productions[i][j]==c)
            {
                if(productions[i][j+1]!='\0'){
                    followfirst(productions[i][j+1],i,(j+2));
                }
                if(productions[i][j+1]=='\0'&&c!=productions[i][0]){
                    follow(productions[i][0]);
                }
            }
        }
    }
}

int main(){
    int i,j,k;
    int jm=0,km=0;


    FILE* filePointer;
    int bufferLength = 255;
    char buffer[bufferLength];

    filePointer = fopen("test_case.txt", "r");

    count=0;
    while(fgets(buffer, bufferLength, filePointer)) {
        buffer[strlen(buffer)-1] = '\0';
        strcpy(productions[count],buffer);
        count++;
    }

    printf("Count is %d\n",count );

    fclose(filePointer);


    

    for(j=0; j<count; j++){
        for(k=0; k<100; k++){
            first_arr[j][k]='!';
        }
    }

    char left_check[count]; int letter_check_arr_index = -1; char c;int flag;
    int p=0; int q;
    for(k=0; k<count; k++){
        c=productions[k][0];q=0;

        flag=0;
        for(j=0;j<=letter_check_arr_index;j++){
            if(c==left_check[j])
                flag=1;
        }

        if(flag==1)
            continue;
        first_fun(c,0,0);
        letter_check_arr_index++;
        left_check[letter_check_arr_index]=c;

        printf("first(%c) = { ", c);

        first_arr[p][q++]=c;

        for(i=0+jm;i<n;i++){

            int flag2=0;
            for(j=0;j<q;j++){
                if(first[i]==first_arr[p][j]){
                    flag2=1;
                    break;
                }
            }
            if(flag2==0){
                printf("%c, ",first[i]);
                first_arr[p][q++]=first[i];
            }
        }
        printf("}\n");
        jm=n;
        p++;

    }

    printf("\n");

    char letter_check1[count]; letter_check_arr_index = -1;
    for(j=0; j<count; j++){
        for(k=0; k<100; k++){
            follow_arr[j][k]='!';
        }
    }

    p=0; int N=0;
    for(k=0;k<count;k++){
        cc=productions[k][0];
        q=0; flag=0;

        for(j=0; j<=letter_check_arr_index; j++){
            if(cc == letter_check1[j])
                flag=1;
        }
        if(flag == 1)
            continue;
        N++;
        follow(cc);
        letter_check_arr_index++;
        letter_check1[letter_check_arr_index]=cc;
        printf("follow(%c):{ ",cc);

        follow_arr[p][q++]=cc;
        for(i=0+km;i<m;i++){
            int flag2=0;
            for(j=0; j<q; j++){
                if(first2[i] == follow_arr[p][j]){
                    flag2=1;
                    break;
                }
            }
            if(flag2==0){
                printf("%c, ",first2[i]);
                follow_arr[p][q++]=first2[i];
            }
        }
        printf("}\n");
        km=m;
        p++;

    }

    char terminals[10];
    for(k=0;k<10;k++){
        terminals[k] = '!';
    }

    int ap,vp,terminal_count = 0;
    for(k=0;k<count;k++){
        for(j=0;j<count;j++){
            if(!isupper(productions[k][j]) && productions[k][j]!= '#' && productions[k][j] != '=' && productions[k][j] != '\0'){
                vp = 0;
                for(ap = 0;ap < terminal_count; ap++){
                    if(productions[k][j] == terminals[ap]){
                        vp = 1;
                        break;
                    }
                }
                if(vp == 0){
                    terminals[terminal_count] = productions[k][j];
                    terminal_count ++;
                }
            }
        }
    }
    terminals[terminal_count]='$';
    terminal_count++;

    printf("\n\t\t\t\t\t\t\t The LL(1) Parsing Table for the above grammer :-");
    printf("\n\t\t\t\t\t\t\t^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n");
    printf("\n\t\t\t=====================================================================================================================\n");
    printf("\t\t\t\t|\t");
    for(ap = 0;ap < terminal_count; ap++){
        printf("%c\t\t",terminals[ap]);
    }
    printf("\n\t\t\t=====================================================================================================================\n");
    char first_prod[count][terminal_count];

    for(ap=0;ap<count;ap++){
        int B = 0;
        k = 2;
        int ct = 0;
        char tem[100];
        while(productions[ap][k] != '\0'){
            if(!isupper(productions[ap][k])){
                tem[ct++] = productions[ap][k];
                tem[ct++] = '_';
                tem[ct++] = '\0';
                k++;
                break;
            }
            else{
                int zap=0;
                int tuna = 0;
                for(zap=0;zap<count;zap++){
                    if(first_arr[zap][0] == productions[ap][k]){
                        for(tuna=1;tuna<100;tuna++){
                            if(first_arr[zap][tuna] != '!'){
                                tem[ct++] = first_arr[zap][tuna];
                            }
                            else
                                break;
                        }
                    break;
                    }
                }
                tem[ct++] = '_';
            }
            k++;
        }
        int zap = 0,tuna;
        for(tuna = 0;tuna<ct;tuna++){
            if(tem[tuna] == '#'){
                zap = 1;
            }
            else if(tem[tuna] == '_'){
                if(zap == 1){
                    zap = 0;
                }
                else
                    break;
            }
            else{
                first_prod[ap][B++] = tem[tuna];
            }
        }
    }

    char table[N][terminal_count+1];
    letter_check_arr_index=-1;
    for(ap=0; ap<N;ap++){
        for(j=0; j<terminal_count+1; j++){
            table[ap][j]=0;
        }
    }

    for(ap=0; ap<count; ap++){
        cc = productions[ap][0];
        flag = 0;
        for(i = 0; i <= letter_check_arr_index; i++)
            if(cc == table[i][0])
                flag = 1;
        if (flag == 1)
            continue;
        else{
            letter_check_arr_index = letter_check_arr_index + 1;
            table[letter_check_arr_index][0] = cc;
        }
    }

    for(ap = 0; ap < count ; ap++){
        int tuna = 0;
        while(first_prod[ap][tuna] != '\0'){
            int t,flag3=0;
            for(t=0;t<terminal_count;t++){
                if(first_prod[ap][tuna] == terminals[t]){
                    flag3 = 1;
                }
            }
            if(flag3 == 1){
                char xz = productions[ap][0];
                int cz=0;
                while(table[cz][0] != xz){
                    cz = cz + 1;
                }
                int vz=0;
                while(terminals[vz] != first_prod[ap][tuna]){
                    vz = vz + 1;
                }
                table[cz][vz+1] = (char)(ap + 65);
            }
            tuna++;
        }
    }

    for(k=0;k<terminal_count;k++){
        for(int kay=0;kay<100;kay++){
            if(first_arr[k][kay] == '!'){
                break;
            }
            else if(first_arr[k][kay] == '#'){
                int fz = 1;
                while(follow_arr[k][fz] != '!'){
                    char xz = productions[k][0];
                    int cz=0;
                    while(table[cz][0] != xz){
                        cz = cz + 1;
                    }
                    int vz=0;
                    while(terminals[vz] != follow_arr[k][fz]){
                        vz = vz + 1;
                    }
                    table[k][vz+1] = '#';
                    fz++;
                }
                break;
            }
        }
    }

    for(ap = 0; ap < N ; ap++){
        printf("\t\t\t   %c\t|\t",table[ap][0]);
        for(k = 1; k < (terminal_count + 1) ; k++){
            if(table[ap][k] == '!')
                printf("\t\t");
            else if(table[ap][k] == '#'){
                printf("%c=#\t\t",table[ap][0]);
            }
            else{
                int ma = (int)(table[ap][k]);
                ma -= 65;
                printf("%s\t\t",productions[ma]);
            }
        }
        printf("\n");
        printf("\t\t\t---------------------------------------------------------------------------------------------------------------------");
        printf("\n");
    }
}
