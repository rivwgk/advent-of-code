#include <fstream>
#include <vector>
#include <cstring>
#include <cstdio>

enum class Type {
   UNKNOWN,
   ACC,
   JMP,
   NOP
};

struct Instruction {
   Instruction(Type t, long arg) : t(t), arg(arg) {}

   Type t;
   long arg;
};

class Programme {
public:
   Programme() {}

   int
   run()
   {
      m_vis.shrink_to_fit();
      while (!m_vis[pc] && pc < m_instr.size()) {
         m_vis[pc] = true;
         if (m_instr[pc].t == Type::JMP) {
            pc += m_instr[pc].arg;
            continue;
         } else if (m_instr[pc].t == Type::ACC)
            acc += m_instr[pc].arg;

         ++pc;
      }
      return acc;
   }

   int
   correct_program()
   {
      int p;
      int k=-1;
      do {
         ++k;
         if (m_instr[k].t == Type::NOP)
            m_instr[k].t = Type::JMP;
         else if (m_instr[k].t == Type::JMP)
            m_instr[k].t = Type::NOP;

         reset();
         p = run();

         if (m_instr[k].t == Type::NOP)
            m_instr[k].t = Type::JMP;
         else if (m_instr[k].t == Type::JMP)
            m_instr[k].t = Type::NOP;

      } while (pc < m_instr.size());
      printf("%d, %d\n", k, p);
      return p;
   }

   void
   add_instruction(const char*s)
   {
      Type t=Type::UNKNOWN;
      if (strncmp(s, "jmp", 3) == 0)
         t=Type::JMP;
      else if (strncmp(s, "acc", 3) == 0)
         t=Type::ACC;
      else if (strncmp(s, "nop", 3) == 0)
         t=Type::NOP;
      else
         fprintf(stderr, "warning: unknown instruction in %s\n", s); 

      int a = strtol(s+5, nullptr, 10);
      a *= s[4] == '-' ? -1 : 1;
      m_instr.emplace_back(t, a);
      m_vis.push_back(false);
   }
private:
   void
   reset()
   {
      pc = 0;
      acc = 0;
      for (size_t i=0; i<m_vis.size(); ++i)
         m_vis[i] = false;
   }

   int pc=0;
   int acc=0;
   std::vector<Instruction> m_instr;
   std::vector<bool> m_vis;
};

void
usage(const char*s)
{
   printf("usage: %s\n", s);
   exit(EXIT_FAILURE);
}

int
main(int argc, const char**argv)
{
   if (argc != 2)
      usage(*argv);

   std::ifstream file{std::string{argv[1]}};
   Programme p{};
   while (!file.eof()) {
      char s[12] = {0};
      file.getline(s, 11, '\n');

      if (*s != '\0')
         p.add_instruction(s);
   }
   int r = p.run();
   printf("accumulator: %d\n", r);

   int c = p.correct_program();
   printf("accumulator: %d\n", c);
}
