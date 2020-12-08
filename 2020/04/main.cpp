#include <fstream>
#include <iostream>
#include <vector>
#include <string>
#include <array>
#include <cstdlib>
#include <cstring>
#include <cctype>
#include <algorithm>
#include <optional>

struct Passport {
   bool SI;
   std::optional<int> byr, iyr, eyr, hgt;
   std::optional<std::string> hcl;
   std::optional<char *> ecl;
   std::optional<std::string> pid, cid;
};

bool
is_hexdigit(char c)
{
   return ('A' <= c and c <= 'F') or ('a' <= c and c <= 'f')
       or ('0' <= c and c <= '9');
}

bool
passport_validate(const struct Passport& pp)
{
   
   if (bool(pp.byr) and bool(pp.iyr) and bool(pp.eyr) and bool(pp.hgt)
                    and bool(pp.hcl) and bool(pp.ecl) and bool(pp.pid))
   {
      if (!(1920 <= pp.byr and pp.byr <= 2002))
         return false;
      if (!(2010 <= pp.iyr and pp.iyr <= 2020))
         return false;
      if (!(2020 <= pp.eyr and pp.eyr <= 2030))
         return false;
      if (!(pp.SI and (150 <= pp.hgt and pp.hgt <= 193)
        or !pp.SI and ( 59 <= pp.hgt and pp.hgt <=  76)))
         return false;
      if (strcmp(*pp.ecl, "amb") != 0 and strcmp(*pp.ecl, "blu") != 0 and
          strcmp(*pp.ecl, "brn") != 0 and strcmp(*pp.ecl, "gry") != 0 and
          strcmp(*pp.ecl, "grn") != 0 and strcmp(*pp.ecl, "hzl") != 0 and
          strcmp(*pp.ecl, "oth") != 0)
         return false;
      if (pp.pid->size()!=9 or !std::all_of(pp.pid->begin(),pp.pid->end(),isdigit))
         return false;
      if (!((*pp.hcl)[0] == '#' and std::all_of(pp.hcl->begin()+1, pp.hcl->end(), is_hexdigit)))
         return false;


      return true;
   }
   return false;
}

void
passport_set_value(struct Passport& pp,size_t i,const char*b,const char*e)
{
   char*s;
   switch (i) {
   case 0:
      s=strndup(b,b-e);
      pp.byr=strtol(s,NULL,10);
      free(s);
      return;
   case 1:
      s=strndup(b,b-e);
      pp.iyr=strtol(s,NULL,10);
      free(s);
      return;
   case 2:
      s=strndup(b,b-e);
      pp.eyr=strtol(s,NULL,10);
      free(s);
      return;
   case 3:
      s=strndup(b,b-e-2);
      pp.hgt=strtol(s,NULL,10);
      if (strncmp(e-2, "cm", 2) == 0)
         pp.SI = true;
      else if (strncmp(e-2, "in", 2) == 0)
         pp.SI = false;
      else
         pp.hgt = {};
      free(s);
      return;
   case 4:
      s=strndup(b,e-b);
      pp.hcl=std::string{s};
      free(s);
      return;
   case 5:
      s=strndup(b,e-b);
      pp.ecl=s;
      return;
   case 6:
      s=strndup(b,e-b);
      pp.pid=std::string{s};
      free(s);
      return;
   case 7:
      s=strndup(b,e-b);
      pp.cid=std::string{s};
      free(s);
      return;
   }
}

void
usage(const char *s)
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
   std::vector<Passport> passports;
   std::array<const char[4],8> symb = {"byr", "iyr", "eyr", "hgt",
                                       "hcl", "ecl", "pid", "cid"};
   struct Passport pp;
   while (!file.eof()) {
      std::string s;
      std::getline(file, s, '\n');

      const char*p=s.c_str();
      const char*o=s.c_str();
      while (*p != '\0') {
         p=strchrnul(p, ' ');
         const char*c=strchr(o, ':');
         for (size_t i=0; i<8; ++i) {
            if (strncmp(o, symb[i], 3) == 0) {
               passport_set_value(pp, i, c+1, p);
               break;
            }
         }
         if (*p == ' ')
            ++p;
         o=p;
      }
      
      if (s.empty()) {
         passports.push_back(pp);
         pp = Passport{};
         std::cout << "push\n";
      }
   }
   passports.push_back(pp);

   size_t valid=0;
   for (auto& p : passports) {
      if (passport_validate(p))
         ++valid;
   }

   std::cout << valid << " of " << passports.size() <<  "\n"; 

   exit(EXIT_SUCCESS);
}
