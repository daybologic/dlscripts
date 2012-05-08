#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

int main(int argc, char* argv[])
{
  int i;
  bool filemode = false;
  
  for ( i = 1; i < argc; i++ ) {
    char* forwardslash;

    if ( filemode ) { /* Argument is a filename */
      FILE* f = fopen(argv[i], "rt");
      if ( f ) {
        while ( !feof(f) ) {
          char str[8192];
          if ( fgets(str, sizeof(str), f) ) {
            forwardslash = strrchr(str, '/');
            if ( forwardslash )
              strcpy(str, forwardslash+1);
            printf(str);
          }
        }
        fclose(f);
      }
      else
        fputs("Error: Can\'t open -f file", stderr);

      break;
    }

    if ( strcmp(argv[i], "-f") == 0 ) {
      filemode = true;
      continue;
    }
    forwardslash = strrchr(argv[i], '/');
    if ( forwardslash )
      strcpy(argv[i], forwardslash + 1);
    puts(argv[i]);
    filemode = false;
  }
  return EXIT_SUCCESS;
}
