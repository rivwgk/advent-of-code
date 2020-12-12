#include <fstream>
#include <iostream>
#include <string>
#include <vector>
#include <algorithm>

size_t
num_paths(std::vector<size_t>& last)
{
   if (last.size() == 0)
      return 1;
   std::vector<size_t> np{};
   for (size_t i=0; i<=last.size(); ++i)
      np.push_back(0);

   np[np.size() - 1] = 1;
   for (size_t i=np.size() - 1; i > 0; --i) {
      size_t diff = last[i-1];
      for (size_t j=i-1; diff <= 3; --j) {
         np[j] += np[i];
         diff += last[j];
         if (j == 0)
            break;
      }
   }
   return np[0];
}

void
usage(const char*s)
{
   std::cout << "usage: " << s << " data\n";
   exit(EXIT_FAILURE);
}

int
main(int argc,const char**argv)
{
   if (argc != 2)
      usage(*argv);

   std::ifstream file{std::string{argv[1]}};
   std::vector<size_t> v{};
   while (!file.eof()) {
      std::string s;
      std::getline(file, s, '\n');
      if (!s.empty())
         v.push_back(strtoul(s.c_str(), nullptr, 10));
   }
   std::sort(v.begin(), v.end());
   size_t d1=0, d2=0, d3=0;
   std::vector<size_t> diffs{};
   diffs.push_back(v[0]);
   for (size_t i=0; i<v.size()-1; ++i) {
      diffs.push_back(v[i+1] - v[i]);
   }
   diffs.push_back(3);
   for (size_t d : diffs) {
      if (d == 1)
         ++d1;
      else if (d == 2)
         ++d2;
      else if (d == 3)
         ++d3;
      else
         std::cout << "warn\n";
   }
   std::cout << d1 << " : " << d2 << " : " << d3 << '\n';
   std::cout << d1 * d3 << "\n";

   size_t prod = 1;
   std::vector<size_t> factors;
   std::vector<size_t> last;
   for (size_t i=0; i<diffs.size(); ++i) {
      if (diffs[i] != 3)
         last.push_back(diffs[i]);
      else {
         for (auto& v : last)
            std::cout << v << ' ';
         std::cout << '\n';
         factors.push_back(num_paths(last));
         last = std::vector<size_t>{};
      }
   }
   for (size_t i=0; i<factors.size(); ++i) {
      std::cout << "factor: " << factors[i] << '\n';
      prod *= factors[i];
   }
   std::cout << "num paths: " << prod << '\n';
}
