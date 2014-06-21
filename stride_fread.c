#include <stdio.h>

#define BUF_SIZE 16384

int main(int argc, char **argv)
{
    size_t len, i;
    char buf[BUF_SIZE];
    char *pos;

    /*
    for (i=0; fread(buf, 1, 4, stdin) == 4; i++)
        if (i%2 == 0 && fwrite(buf, 1, 2, stdout) != 2)
            return 1;
            */

    while (1) {
        len = fread(buf, 1, BUF_SIZE, stdin);

        pos = buf;
        for (i = 0; i < len; pos+=4, i+=4)
            if (fwrite(pos, 1, 2, stdout) != 2)
                break;

        if (len != BUF_SIZE || i != len)
            break;
    }

    return 0;
}
