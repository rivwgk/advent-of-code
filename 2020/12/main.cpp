#include <fstream>
#include <iostream>
#include <vector>
#include <string>

enum class Type {
   NORTH,
   SOUTH,
   EAST,
   WEST,
   LEFT,
   RIGHT,
   FORWARD,
};

struct Instruction {
   Instruction(const char*s)
   {
      switch (*s) {
      case 'N': type = Type::NORTH; break;
      case 'S': type = Type::SOUTH; break;
      case 'E': type = Type::EAST; break;
      case 'W': type = Type::WEST; break;
      case 'L': type = Type::LEFT; break;
      case 'R': type = Type::RIGHT; break;
      case 'F': type = Type::FORWARD; break;
      }
      imm = strtol(s+1, nullptr, 10);
   }

   Type type;
   long imm;
};

class Ship {
public:
   Ship(const std::vector<Instruction> instructions)
   {
      m_instructions = instructions;
   }

   void
   run1()
   {
      for (const Instruction& i : m_instructions)
         run1(i);
   }

   void
   run1(const Instruction& i)
   {
      switch (i.type) {
      case Type::NORTH: m_ypos += i.imm; break;
      case Type::SOUTH: m_ypos -= i.imm; break;
      case Type::EAST: m_xpos += i.imm; break;
      case Type::WEST: m_xpos -= i.imm; break;
      case Type::LEFT: m_dir = (m_dir + i.imm) % 360; break;
      case Type::RIGHT: m_dir = (m_dir - i.imm + 360) % 360; break;
      case Type::FORWARD:
         switch (m_dir) {
         case 0: m_xpos += i.imm; break;
         case 90: m_ypos += i.imm; break;
         case 180: m_xpos -= i.imm; break;
         case 270: m_ypos -= i.imm; break;
         default: std::cout << "wrong direction: " << m_dir << '\n'; break;
         } break;
      default: std::cout << "unknown instruction\n"; break; 
      }
   }

   void
   run2()
   {
      for (const Instruction& i : m_instructions)
         run2(i);
   }

   void
   run2(const Instruction& i)
   {
      long rotated_x, rotated_y;
      switch (i.type) {
      case Type::NORTH: m_wypos += i.imm; break;
      case Type::SOUTH: m_wypos -= i.imm; break;
      case Type::EAST: m_wxpos += i.imm; break;
      case Type::WEST: m_wxpos -= i.imm; break;
      case Type::LEFT:
         switch (i.imm) {
         case 0: break;
         case 90:
            rotated_x = -m_wypos;
            rotated_y = m_wxpos;
            m_wxpos = rotated_x;
            m_wypos = rotated_y;
            break;
         case 180:
            m_wxpos = -m_wxpos;
            m_wypos = -m_wypos;
            break;
         case 270:
            rotated_x = m_wypos;
            rotated_y = -m_wxpos;
            m_wxpos = rotated_x;
            m_wypos = rotated_y;
            break;
         default: std::cout << "wrong direction: " << m_dir << '\n'; break;
         } break;
      case Type::RIGHT:
         switch (i.imm) {
         case 0: break;
         case 90:
            rotated_x = m_wypos;
            rotated_y = -m_wxpos;
            m_wxpos = rotated_x;
            m_wypos = rotated_y;
            break;
         case 180:
            m_wxpos = -m_wxpos;
            m_wypos = -m_wypos;
            break;
         case 270:
            rotated_x = -m_wypos;
            rotated_y = m_wxpos;
            m_wxpos = rotated_x;
            m_wypos = rotated_y;
            break;
         default: std::cout << "wrong direction: " << m_dir << '\n'; break;
         } break;
      case Type::FORWARD:
         m_xpos += i.imm * m_wxpos;
         m_ypos += i.imm * m_wypos;
         break;
      default: std::cout << "unknown instruction\n"; break; 
      }
   }

   void
   query_pos(long& x, long& y)
   const {
      x = m_xpos;
      y = m_ypos;
   }
private:
   long m_wxpos = 10, m_wypos = 1;
   long m_xpos = 0, m_ypos = 0, m_dir = 0; 
   std::vector<Instruction> m_instructions;
};

long
abs(long m)
{
   return m<0 ? -m : m;
}

void
usage(const char*s)
{
   std::cout << "usage: " << s << " data\n";
   exit(EXIT_FAILURE);
}

int
main(int argc,char**argv)
{
   if (argc != 2)
      usage(*argv);

   std::ifstream file{std::string{argv[1]}};
   std::vector<Instruction> instructions{};
   while (!file.eof()) {
      std::string s;
      std::getline(file, s, '\n');
      if (!s.empty())
         instructions.push_back(Instruction{s.c_str()});
   }
   Ship s{instructions};
   s.run2();
   long x, y;
   s.query_pos(x, y);
   std::cout << "ship at position (" << x << ", " << y << "); d_1="
             << abs(x)+abs(y) << '\n';
}
