#include <fstream>
#include <iostream>
#include <vector>
#include <cstdlib>
#include <cstring>

struct Item {
   long index;
   long value;
};

long
strsubtol(const char*begin, const char*end)
{
   long result = 0;
   for (const char*p = begin; p!= end; ++p)
      result = result*10 + (*p - '0');
   return result;
}

long
ggt(long a, long& m, long b, long& n)
{
   if (b == 0) {
      m = 1;
      n = 0;
      return a;
   }

   long d = ggt(b, m, a%b, n);
   long old_n = n;
   n = m - a/b * n;
   m = old_n;

   return d;
}

void
usage(const char*s)
{
   std::cout << "usage: " << s << " data \n";
   exit(EXIT_FAILURE);
}

int
main(int argc, const char**argv)
{
   if (argc != 2)
      usage(*argv);

   std::ifstream file{std::string{argv[1]}};
   std::vector<Item> ids;
   long timestamp;

   std::string s;
   std::getline(file, s, '\n');
   timestamp = strtol(s.c_str(), nullptr, 10);

   std::getline(file, s, '\n');
   const char*p = s.c_str();
   const char*q;
   long index = 0;
   do {
      q = strchrnul(p, ',');
      if (isdigit(*p))
         ids.push_back(Item{index, strsubtol(p, q)});
      p = q+1;
      ++index;
   } while (*q != '\0');

   long min = timestamp + ((ids[0].value - (timestamp % ids[0].value))
            % ids[0].value);
   long minid = 0;
   std::cout << "min: " << min << '\n';
   for (size_t i=1; i<ids.size(); ++i) {
      long o = timestamp + ((ids[i].value - (timestamp % ids[i].value))
             % ids[i].value);
      minid = o < min ? i : minid;
      min = o < min ? o : min;
   }
   std::cout << "result 1: " << ids[minid].value << " : " << min-timestamp
             << " => " << ids[minid].value * (min-timestamp) << '\n';

   long t;
   long M = 1;
   for (size_t i=0; i<ids.size(); ++i)
      M *= ids[i].value;

   t = 0;
   for (long i=0; i<ids.size(); ++i) {
      long d,v,m,n,Mi;
      Mi = M/ids[i].value;
      d = ggt(Mi, m, ids[i].value, n);
      v = -ids[i].index;
      std::cout << ids[i].value << " : " << v << '\n';
      t += m*Mi * v;
   }
   std::cout << "result 2: " << t % M << '\n';
}
