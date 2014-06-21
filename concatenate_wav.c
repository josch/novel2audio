#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include <error.h>
#include <limits.h>

void my_splice(int in, int out) {
    int pipefd[2], nr, ret;
    if (pipe(pipefd) < 0)
        error(1, errno, "cannot create pipe");
    for (;;) {
        nr = splice(in, 0, pipefd[1], 0, INT_MAX, 0);
        if (nr == -1)
            error(1, errno, "cannot read input");
        if (nr == 0)
            break;
        do {
            ret = splice(pipefd[0], 0, out, 0, nr, 0);
            if (ret == -1)
                error(1, errno, "cannot write");
            nr -= ret;
        } while (nr);
    }
    close(pipefd[0]);
    close(pipefd[1]);
}

int main(int argc, char **argv) {
    int i;
    char **argvp = argv+1;
    int fd, ret;
    ssize_t ret2;
    for (i = 1; i < argc; i++, argvp++) {
        fd = open(*argvp, O_RDONLY);
        if (fd == -1)
            error(1, errno, "cannot open file %s", *argvp);
        ret = lseek(fd, 46, SEEK_SET);
        if (ret == -1)
            error(1, errno, "cannot seek in file %s", *argvp);
        for (;;) {
            ret2 = sendfile(STDOUT_FILENO, fd, 0, INT_MAX);
            if (ret2 == -1)
                error(1, errno, "cannot copy", *argvp);
            if (ret2 < 4096)
                break;
        }
        /* my_splice(fd, STDOUT_FILENO);*/
        ret = close(fd);
        if (ret == -1)
            error(1, errno, "cannot close file %s", *argvp);
    }
    return 0;
}
