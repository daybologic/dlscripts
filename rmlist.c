#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char* argv[])
{
  int i;

  for ( i = 1; i < argc; i++ ) {
    FILE* handle = fopen(argv[i], "rt");
    if ( handle ) {
      while ( !feof(handle) ) {
        char str[8192];

        if ( fgets(str, sizeof(str), handle) ) {
          char* newLine = strrchr(str, '\n');
          if ( newLine )
            *newLine = '\0';
          printf("Deleting \"%s\"... ", str);
          if ( remove(str) == -1 )
            printf("Failed\n");
          else
            printf("OK\n");
        }
      }
      fclose(handle);
    }
    else {
      printf("Cannot open \"%s\"\n", argv[i]);
      return EXIT_FAILURE;
    }
  }

  return EXIT_SUCCESS;
}
