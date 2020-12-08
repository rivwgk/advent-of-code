#include <fstream>
#include <iostream>
#include <vector>
#include <array>
#include <optional>
#include <algorithm>

void
usage(const char*s)
{
   std::cout << "usage: " << s << " data\n";
   exit(EXIT_FAILURE);
}

int
main(int argc, char**argv)
{
   if (argc != 2)
      usage(*argv);

   std::fstream file{std::string{argv[1]}};
   std::string s;
   std::vector<std::array<bool,26>> forms;
   bool init=true;
   forms.push_back(std::array<bool,26>{false});
   while (!file.eof()) {
      std::getline(file, s, '\n');
      std::sort(s.begin(), s.end());
      if (s.empty()) {
         forms.push_back(std::array<bool,26>{false});
         init = true;
         continue;
      }

      if (init) {
         init = false;
         for (size_t i=0; i<s.size(); ++i)
            (forms.back())[s[i]-'a'] = true;
      } else {
         size_t i=0;
         for (char c='a'; c <= 'z'; ++c) {
            if (c == s[i]) {
               (forms.back())[c-'a'] &= true;
               ++i;
            } else
               (forms.back())[c-'a'] &= false;
         }
         for (i=0; i<26; ++i)
            std::cout << forms.back()[i];
      }
      std::cout <<"\n";
   }

   size_t count=0;
   for (auto& f : forms)
      for (size_t i=0; i<26; ++i)
         if (f[i])
            ++count;

   std::cout << count << "\n";
}
