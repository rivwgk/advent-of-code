#include <fstream>
#include <iostream>
#include <string>
#include <array>
#include <vector>
#include <cstdlib>
#include <optional>

std::optional<std::array<size_t,2>>
part1(std::vector<size_t> v, int sum)
{
   int i=0,j=0;
   for (i=0; i<v.size(); ++i)
      for (j=i+1; j<v.size(); ++j)
         if (v[i] + v[j] == 2020)
            return std::optional{std::array<size_t,2>{v[i], v[j]}};
   return {};
}

std::optional<std::array<size_t,3>>
part2(std::vector<size_t> v, int sum)
{
   int i,j,k;
   for (i=0; i<v.size(); ++i)
      for (j=0; j<v.size(); ++j)
         for (k=0; k<v.size(); ++k)
            if (v[i]+v[j]+v[k] == sum)
               return std::optional{std::array<size_t,3>{v[i],v[j],v[k]}};
   return {};
}

int
main(int argc, char**argv)
{
   if (argc != 2)
      exit(EXIT_FAILURE);
   
   std::vector<size_t> numbers{};
   std::fstream data{std::string{argv[1]}, std::ios::in};
   while (!data.eof()) {
      std::string s;
      std::getline(data, s, '\n');
      numbers.push_back(atoi(s.c_str()));
   }
   numbers.pop_back();

   auto p1 = *part1(numbers, 2020);
   auto p2 = *part2(numbers, 2020);

   std::cout << p1[0] << " " << p1[1] << " => "
             << p1[0]*p1[1] << "\n";
   std::cout << p2[0] << " " << p2[1] << " " << p2[2] << " => "
             << p2[0]*p2[1]*p2[2] << '\n';
   exit(EXIT_SUCCESS);

}
