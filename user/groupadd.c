#include "kernel/fcntl.h"
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

void intToStr(int num, char *str);

int main(int argc, char *argv[])
{
    int fd;
    char buf[512];
    int n;
    int max_gid = -1;

    if (argc != 2)
    {
        fprintf(2, "Usage: groupadd <groupname>\n");
        exit(1);
    }

    if ((fd = open("/group", O_RDONLY)) < 0)
    {
        fprintf(2, "groupadd: cannot open /group\n");
        exit(1);
    }

    while ((n = read(fd, buf, sizeof(buf))) > 0)
    {
        int delimiter_count = 0;
        for (int i = 0; i < n; i++)
        {
            if (buf[i] == ':')
            {
                delimiter_count++;
                if (delimiter_count == 2)
                {
                    int gid = 0;
                    for (i = i + 1; i < n && buf[i] != ':'; i++)
                    {
                        gid = gid * 10 + (buf[i] - '0');
                    }
                    if (gid > max_gid)
                    {
                        max_gid = gid;
                    }
                }
            }
            else if (buf[i] == '\n')
            {
                delimiter_count = 0;
            }
        }
    }

    if (n < 0)
    {
        fprintf(2, "groupadd: read error1\n");
        exit(1);
    }

    close(fd);

    if ((fd = open("/group", O_RDWR)) < 0)
    {
        fprintf(2, "groupadd: cannot open /group\n");
        exit(1);
    }

    while ((n = read(fd, buf, sizeof(buf))) > 0)
        ;

    if (n < 0)
    {
        fprintf(2, "groupadd: read error2\n");
        exit(1);
    }

    int i = 0;
    for (; argv[1][i] != '\0'; i++)
    {
        buf[i] = argv[1][i];
    }
    buf[i++] = ':';
    buf[i++] = 'x';
    buf[i++] = ':';
    char max_gid_str[10];
    intToStr(max_gid + 1, max_gid_str);
    for (int j = 0; max_gid_str[j] != '\0'; j++)
    {
        buf[i++] = max_gid_str[j];
    }
    buf[i++] = ':';
    buf[i++] = '\n';
    buf[i] = '\0';

    if (write(fd, buf, strlen(buf)) != strlen(buf))
    {
        fprintf(2, "groupadd: write error\n");
        exit(1);
    }

    close(fd);
    exit(0);
}

void reverse(char *str, int len)
{
    int start = 0;
    int end = len - 1;

    while (start < end)
    {
        char temp = *(str + start);
        *(str + start) = *(str + end);
        *(str + end) = temp;

        start++;
        end--;
    }
}

void intToStr(int num, char *str)
{
    int i = 0;

    if (num == 0)
    {
        str[i++] = '0';
        str[i] = '\0';
        return;
    }

    while (num != 0)
    {
        int rem = num % 10;
        str[i++] = rem + '0';
        num = num / 10;
    }

    str[i] = '\0';
    reverse(str, i);
}
