#include <fstream>
#include <iostream>
#include <string>
#include <vector>

struct Rule {
   size_t min,max;
   char needed_char;
};

int
strpos(const char*s, char c)
{
   const char*p=s;
   while (*p != c) {
      if (*p == '\0')
         return -1;
      ++p;
   }
   return p-s;
}

int
strlen(const char*s)
{
   const char*p=s;
   while (*p) ++p;
   return p-s;
}

int
strparttoint(const char*s, int begin, int end)
{
   if (end < begin)
      return -1;
   int r = 0;
   bool neg = s[begin] == '-';
   for (int i=begin+(neg ? 1 : 0); i<=end; ++i)
      r = r*10 + s[i]-'0';
   return r * (neg ? -1 : 1);
}

int
strcharocc(const char*s, char c)
{
   const char*p=s;
   size_t num=0;
   while (*p) {
      if (*p == c) ++num;
      ++p;
   }
   return num;
}

bool
validitycheck1(const char*s, char c, int min, int max)
{
   return min <= strcharocc(s, c) and strcharocc(s, c) <= max;
}

bool
validitycheck2(const char*s, char c, int p1, int p2)
{
   return s[p1-1]==c ^ s[p2-1]==c;
}

int
main(int argc, char**argv)
{
   if (argc != 2)
      exit(EXIT_FAILURE);

   std::fstream file{std::string{argv[1]}, std::ios::in};
   std::vector<std::string> input;
   while (!file.eof()) {
      std::string s;
      std::getline(file, s, '\n');
      if (!s.empty())
         input.push_back(s);
   }
   
   std::vector<std::pair<struct Rule,std::string>> db;
   for (auto v : input) {
      int dashpos = strpos(v.c_str(), '-');
      int spacepos = strpos(v.c_str(), ' ');
      struct Rule r;
      r.min=strparttoint(v.c_str(), 0, dashpos-1);
      r.max=strparttoint(v.c_str(), dashpos+1, spacepos-1);
      r.needed_char=v[spacepos+1];
      std::string passwd = v.substr(spacepos+4);
      db.push_back(std::pair<struct Rule,std::string>{r, passwd});
   }

   size_t valid1=0, valid2=0;
   for (auto element : db) {
      struct Rule& r = element.first;
      std::string& s = element.second;
      if (validitycheck1(s.c_str(), r.needed_char, r.min, r.max))
         ++valid1;
      if (validitycheck2(s.c_str(), r.needed_char, r.min, r.max))
         ++valid2;
   }
   std::cout << valid1 << " | " << valid2 << '\n';
   exit(EXIT_SUCCESS);
}
