#include <stdarg.h>
#include <stdio.h>
#define DEBUG 2
#define TEMP_MAX 1

// Определение кодов для цветного принта
#define RED "\033[0;31m"
#define YELLOW "\033[0;33m"
#define GREEN "\033[0;32m"
#define RESET "\033[0m"

typedef enum
{
    ERR_OK,
    ERR_INVALID_ARG_COUNT
} errors_t;

void print_error_message(int arg)
{
    switch (arg)
    {
        case ERR_INVALID_ARG_COUNT:
            printf("%sОшибка в количестве аргументов%s\n", RED, RESET);
    }
}

/*int count_lines(size_t count, const char **empty, ...)
{
    (void)empty;
    int rc = ERR_OK;
    va_list va;
    va_start(va, empty);

    const char *filename  = NULL;
    size_t read_count = 0;
    // size_t global_string_count = 0;
    while (read_count < count)
    {
        filename  = va_arg(va, const char *);
        printf("%s\n", filename );
        read_count++;
    }

    va_end(va);

    return rc;
    
}

int main(int argc, char **argv)
{
    int rc = ERR_OK;
    if (argc <= 1)
    {
        print_error_message(ERR_INVALID_ARG_COUNT);
        return ERR_INVALID_ARG_COUNT;
    }

    const char **test = NULL;
    if ((rc = count_lines(argc - 1, test, argv++)) != ERR_OK)
    {
        print_error_message(rc);
        return rc;
    }
    return rc;
}
*/

void count_lines(int num_files, ...) {
    va_list files;
    va_start(files, num_files);
    
    for (int i = 0; i < num_files; i++) {
        const char *filename = va_arg(files, const char*);
        printf("%s\n", filename);
        FILE *file = fopen(filename, "r");
        
        if (file == NULL) {
            perror("Error opening file");
            continue;
        }
        
        int lines = 0;
        char ch;
        while ((ch = fgetc(file)) != EOF) {
            if (ch == '\n') {
                lines++;
            }
        }
        
        fclose(file);
        printf("File: %s has %d lines.\n", filename, lines);
    }
    
    va_end(files);
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <file1> <file2> ... <fileN>\n", argv[0]);
        return 1;
    }

    // Передаем количество файлов и их названия в функцию
    count_lines(argc - 1, argv + 1);
    
    return 0;
}
