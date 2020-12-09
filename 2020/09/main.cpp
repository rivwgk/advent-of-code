#include <fstream>
#include <vector>
#include <array>
#include <cstdlib>
#include <algorithm>

bool
sums(const size_t value, const size_t*array, size_t size)
{
   for (int i=0; i<size; ++i) {
      for (int j=0; j<size; ++j) {
         if (i==j) continue;
         if (array[i] + array[j] == value)
            return true;
      }
   }
   return false;
}

size_t
sum(const std::vector<size_t>& v, size_t begin, size_t end)
{
   size_t p = v[begin];
   for (size_t i=begin+1; i<end; ++i)
      p += v[i];
   return p;
}

void
csums(size_t value, const std::vector<size_t>& v, size_t pos,
      size_t& begin,size_t& end)
{
   for (size_t i=0; i<pos; ++i) {
      begin = i;
      for (size_t j=i; j<pos; ++j) {
         size_t p=sum(v,i,j);
         if (p > value)
            break;
         else if (p < value)
            continue;
         else {
            end = j;
            return;
         }
      }
   }
}

void
usage(const char*s)
{
   fprintf(stderr, "usage: %s data preamble\n", s);
   exit(EXIT_FAILURE);
}

int
main(int argc, const char**argv)
{
   if (argc != 3)
      usage(*argv);

   std::ifstream file{std::string{argv[1]}};
   long psize = strtol(argv[2], nullptr, 10);
   std::vector<size_t> input{};
   while (!file.eof()) {
      std::string s;
      std::getline(file, s, '\n');
      input.push_back(strtoul(s.c_str(), nullptr, 10));
   }
   size_t*prev = new size_t[psize];
   for (size_t i=0; i<psize; ++i)
      prev[i] = input[i];

   size_t dpos;
   for (size_t i=psize; i<input.size(); ++i) {
      if (!sums(input[i], prev, psize)) {
         dpos = i;
         printf("first differing with %u\n", input[i]);
         break;
      }

      for (size_t j=1; j<psize; ++j)
         prev[j-1] = prev[j];
      prev[psize-1] = input[i];
   }

   size_t begin, end;
   csums(input[dpos], input, dpos, begin, end);
   size_t min=input[begin], max=input[begin];
   for (size_t i=begin+1; i<=end; ++i) {
      min = std::min(min, input[i]);
      max = std::max(max, input[i]);
   }
   printf("sum from %u to %u equals %u\n"
          "with %u at %u and %u at %u\n"
          "sum is: %u\n", begin, end, sum(input,begin,end),
          input[begin], begin, input[end], end, min+max);
}
