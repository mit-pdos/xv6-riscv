#include "kernel/fcntl.h"
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int getuidbyname(char *username);
int ft_strncmp(char *s1, char *s2, unsigned int n);
int compare(unsigned int i, char *s1, char *s2, unsigned int n);

int main(int argc, char *argv[])
{
    if (argc != 2)
    {
        fprintf(2, "Usage: su <username>\n");
        exit(1);
    }

    int uid = getuidbyname(argv[1]);
    if (uid < 0)
    {
        fprintf(2, "User not found\n");
        exit(1);
    }

    int pid = fork();
    if (pid < 0)
    {
        fprintf(2, "su: fork failed\n");
        exit(1);
    }
    else if (pid == 0)
    {
        setuid(uid);
        if (getuid() != uid)
        {
            fprintf(2, "su: setuid failed\n");
            exit(1);
        }
        char *args[] = {"sh", 0};
        exec(args[0], args);
        fprintf(2, "su: failed to switch user\n");
        exit(1);
    }
    else
    {
        int status;
        wait(&status);
    }

    exit(0);
}

int getuidbyname(char *username)
{
    int fd, n, i, j, uid;
    char buf[512], name[512], line[512];

    if ((fd = open("/passwd", 0)) < 0)
    {
        printf("getuidbyname: cannot open /passwd\n");
        return -1;
    }

    while ((n = read(fd, buf, sizeof(buf))) > 0)
    {
        for (i = 0; i < n;)
        {
            j = 0;
            while (i < n && buf[i] != '\n')
                line[j++] = buf[i++];
            line[j] = '\0';
            i++;
            j = 0;
            while (line[j] != ':')
            {
                name[j] = line[j];
                j++;
            }
            name[j] = '\0';
            if (ft_strncmp(name, username, strlen(username)) == 0)
            {
                while (line[j] != ':')
                    j++;
                j++;
                while (line[j] != ':')
                    j++;
                uid = atoi(&line[j + 1]);
                close(fd);
                return uid;
            }
        }
    }

    if (n < 0)
    {
        printf("getuidbyname: read error\n");
        close(fd);
        return -1;
    }

    close(fd);
    return -1;
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
