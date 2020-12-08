#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

void
usage(const char *s)
{
   fprintf(stderr, "usage: %s data\n", s);
   exit(EXIT_FAILURE);
}

void
error(const char *s)
{
   fprintf(stderr, "error: %s\n", s);
   exit(EXIT_FAILURE);
}

int
main(int argc, const char**argv)
{
   if (argc != 2)
      usage(*argv);

   FILE *f = fopen(argv[1], "r");
   if (!f)
      error("could not open specified file");
   char c;
   long pos=0;
   long basement_pos=0;
   bool first = true;
   do {
      c = fgetc(f);
      ++basement_pos;
      if (c == '(')
         ++pos;
      else if (c == ')')
         --pos;
      if (first && pos < 0) {
         first = false;
         printf("entering basement at: %d\n", basement_pos);
      }
   } while (!feof(f));
   printf("end position: %d\n", pos);
}
