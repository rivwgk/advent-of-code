#include <fstream>
#include <iostream>
#include <array>
#include <vector>
#include <algorithm>
#include <optional>

class Seat {
public:
   Seat(const char*s)
   {
      m_row=0, m_col=0;
      for (unsigned i=0; i<7; ++i)
         m_row += s[i] == 'B' ? (1<<(6-i)) : 0;
      for (unsigned i=0; i<3; ++i)
         m_col += s[7+i] == 'R' ? (1<<(2-i)) : 0;
   }

   size_t
   get_id()
   const {
      return m_row * 8 + m_col;
   }

   unsigned
   row()
   const {
      return m_row;
   }

   unsigned
   col()
   const {
      return m_col;
   }
private:
   unsigned m_row, m_col;
};

void
usage(char *s)
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
   std::vector<Seat> vector;
   size_t max = 0;
   std::array<std::array<std::optional<bool>,8>,128> seats;
   for (unsigned i=0; i<128; ++i)
      for (unsigned j=0; j<8; ++j)
         seats[i][j] = {};
   while (!file.eof()) {
      std::getline(file, s, '\n');
      if (s.empty())
         continue;
      vector.push_back(Seat(s.c_str()));
      max = std::max(vector.back().get_id(), max);
      seats[vector.back().row()][vector.back().col()] = true;
      std::cout << s << " : "<< vector.back().get_id() << "\n";
   }
   for (unsigned i=1; i<127; ++i)
      for (unsigned j=1; j<7; ++j)
         if (seats[i][j-1] and !seats[i][j] and seats[i][j+1])
            std::cout << i << " : " << j << "\n";

   std::cout << "maximum: " << max << "\n";
}
