#include "kernel/types.h"
#include "user/user.h"

#define BUFFER_SIZE 128

int main(int argc, char *argv[])
{
    char buffer[BUFFER_SIZE];

    int k = 0;

    while (1)
    {
        char c;
        int res_read = read(0, &c, 1);

        if (res_read < 0)
        {
            fprintf(2, "Input read failed\n");
            exit(1);
        }

        if (res_read == 0 || c == '\n')
        {
            break;
        }

        if (k == BUFFER_SIZE - 1) 
        {
            fprintf(2, "Input is too long\n");
            exit(1);
        }

        buffer[k++] = c; 
    }

    buffer[k] = '\0';

    printf("|%s|\n", buffer);

    int start_first = 0;
    while (buffer[start_first] == ' ') ++start_first;

    if (buffer[start_first] == '\0')
    {
        fprintf(2, "Empty input\n");
        exit(1);
    }

    int space = -1;
    for (int i = start_first; buffer[i] != '\0'; ++i)
    {
        if (buffer[i] == ' ')
        {
            space = i;
            break;
        }
    }

    if (space == -1) 
    {
        fprintf(2, "A space between two numbers is required\n");
        exit(1);
    }

    int start_second = space + 1;
    while (buffer[start_second] == ' ') ++start_second;

    if (buffer[start_second] == '\0')
    {
        fprintf(2, "Second number is missing\n");
        exit(1);
    }


    buffer[space] = '\0';

    int result = atoi(buffer + start_first) + atoi(buffer + start_second);

    printf("%d\n", result);


    exit(0);
}