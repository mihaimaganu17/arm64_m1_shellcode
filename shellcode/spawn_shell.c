/*
 * Source file that spawns a `bash` shell
 * Created at 19 June 2022
 * Written by Mihai Maganu
 */
#include <stdio.h>
#include <unistd.h>

int main() {
    execv("/bin/bash", NULL);
}
