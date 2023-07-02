#include "kernel/fcntl.h"
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int addUserToGroup(char *groupname, char *username);
void intToStr(int num, char *str);
int ft_strncmp(char *s1, char *s2, unsigned int n);
int compare(unsigned int i, char *s1, char *s2, unsigned int n);
char *ft_strcat(char *dest, char *src);

int main(int argc, char *argv[])
{
    char buf[512];
    int fd;
    int gid;
    int max_uid = -1;
    int n;

    if (argc != 3)
    {
        fprintf(2, "Usage: adduser <username> <groupname>\n");
        exit(1);
    }

    if ((fd = open("/passwd", O_RDONLY)) < 0)
    {
        fprintf(2, "adduser: cannot open /passwd\n");
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
                    int uid = 0;
                    for (i = i + 1; i < n && buf[i] != ':'; i++)
                    {
                        uid = uid * 10 + (buf[i] - '0');
                    }
                    if (uid > max_uid)
                    {
                        max_uid = uid;
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
        fprintf(2, "adduser: read error\n");
        exit(1);
    }

    close(fd);

    if ((fd = open("/passwd", O_RDWR)) < 0)
    {
        fprintf(2, "adduser: cannot open /passwd\n");
        exit(1);
    }

    while ((n = read(fd, buf, sizeof(buf))) > 0)
        ;

    if (n < 0)
    {
        fprintf(2, "adduser: read error\n");
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
    char max_uid_str[10];
    intToStr(max_uid + 1, max_uid_str);
    for (int j = 0; max_uid_str[j] != '\0'; j++)
    {
        buf[i++] = max_uid_str[j];
    }
    buf[i++] = ':';
    gid = addUserToGroup(argv[2], argv[1]);
    if (gid == -1)
    {
        fprintf(2, "adduser: group not found\n");
        exit(1);
    }
    char gid_str[10];
    intToStr(gid, gid_str);
    for (int j = 0; gid_str[j] != '\0'; j++)
    {
        buf[i++] = gid_str[j];
    }
    buf[i++] = '\n';
    buf[i] = '\0';

    if (write(fd, buf, strlen(buf)) != strlen(buf))
    {
        fprintf(2, "adduser: write error\n");
        exit(1);
    }

    close(fd);
    exit(0);
}

int addUserToGroup(char *groupname, char *username)
{
    char buf[1024];
    char buf2[1024] = "";
    int fd;
    int gid = -1;
    int n, remain = 0;

    if ((fd = open("/group", O_RDONLY)) < 0)
    {
        fprintf(2, "adduser: cannot open /group\n");
        exit(1);
    }

    while (1)
    {
        n = read(fd, buf + remain, sizeof(buf) - 1 - remain);
        if (n <= 0)
            break;

        n += remain;
        int start = 0;

        for (int i = 0; i < n; i++)
        {
            if (buf[i] == '\n')
            {
                buf[i] = '\0';

                if (ft_strncmp(buf + start, groupname, strlen(groupname)) == 0)
                {
                    char *gid_str = strchr(buf + start, ':');
                    gid_str = strchr(gid_str + 1, ':');
                    gid_str++;
                    char *gid_end = strchr(gid_str, ':');
                    *gid_end = '\0';
                    gid = atoi(gid_str);
                    *gid_end = ':';

                    ft_strcat(buf2, buf + start);
                    ft_strcat(buf2, ",");
                    ft_strcat(buf2, username);
                    ft_strcat(buf2, "\n");
                }
                else
                {
                    ft_strcat(buf2, buf + start);
                    ft_strcat(buf2, "\n");
                }

                start = i + 1;
            }
        }

        if (start < n)
        {
            remain = n - start;
            memmove(buf, buf + start, remain);
        }
        else
        {
            remain = 0;
        }
    }

    if (n < 0)
    {
        fprintf(2, "adduser: read error\n");
        exit(1);
    }

    close(fd);

    if ((fd = open("/group", O_WRONLY | O_TRUNC)) < 0)
    {
        fprintf(2, "adduser: cannot open /group\n");
        exit(1);
    }

    if (write(fd, buf2, strlen(buf2)) != strlen(buf2))
    {
        fprintf(2, "adduser: write error\n");
        exit(1);
    }

    close(fd);

    return gid;
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

int ft_strncmp(char *s1, char *s2, unsigned int n)
{
    unsigned int i;
    int result;

    i = 0;
    while (s1[i] && s2[i] && i < n)
    {
        if (s1[i] < s2[i])
        {
            return (-1);
        }
        if (s1[i] > s2[i])
        {
            return (1);
        }
        i++;
    }
    result = compare(i, s1, s2, n);
    return (result);
}

int compare(unsigned int i, char *s1, char *s2, unsigned int n)
{
    if (n == i)
    {
        return (0);
    }
    if (s1[i] < s2[i])
    {
        return (-1);
    }
    if (s1[i] > s2[i])
    {
        return (1);
    }
    return (0);
}

char *ft_strcat(char *dest, char *src)
{
    int i;
    int j;

    i = 0;
    while (dest[i])
    {
        i++;
    }
    j = 0;
    while (src[j])
    {
        dest[i] = src[j];
        i++;
        j++;
    }
    dest[i] = '\0';
    return (dest);
}
