#include <fstream>
#include <iostream>
#include <string>
#include <vector>
#include <array>

class Matrix {
public:
   Matrix(size_t m, size_t n) : m_rows(m),m_cols(n)
   {
      m_elements = new char[m*n];
   }

   const char
   operator()(size_t i,size_t j) 
   const {
      return m_elements[index(i,j)];
   }
   char&
   operator()(size_t i,size_t j)
   {
      return m_elements[index(i,j)];
   }

   size_t
   rows()
   const {
      return m_rows;
   }

   size_t
   cols()
   const {
      return m_cols;
   }
private:
   size_t
   index(size_t i,size_t j)
   const {
      return i*m_cols+j;
   }

   size_t m_rows,m_cols;
   char*m_elements;
};

void
help(const char*s)
{
   std::cout << "usage: " << s << " file\n";
   exit(EXIT_FAILURE);
}

void
solve1(const Matrix& m, size_t dx, size_t dy, size_t&n_trees, size_t&pos)
{
   pos=0;
   n_trees=0;
   for (int i=0; i<m.rows(); i+=dy) {
      if (m(i,pos) == '#')
         ++n_trees;
      pos += dx;
      pos %= m.cols();
   }
}

template<size_t N>
size_t
prod(std::array<size_t,N>& a)
{
   size_t p=a[0];
   for (int i=1;i<N; ++i)
      p*=a[i];
   return p;
}

int
main(int argc,char**argv)
{
   if (argc != 2)
      help(*argv);

   std::fstream file{std::string{argv[1]}};
   std::vector<std::string> lines;
   while (!file.eof()) {
      std::string line;
      std::getline(file, line, '\n');
      if (!line.empty())
         lines.push_back(line);
   }

   Matrix m{lines.size(), lines[0].size()};
   for (int i=0; i<lines.size(); ++i)
      for (int j=0; j<lines[i].size(); ++j)
         m(i,j) = lines[i][j];

   std::array<size_t,5> num_trees, place;
   solve1(m, 1, 1, num_trees[0], place[0]);
   solve1(m, 3, 1, num_trees[1], place[1]);
   solve1(m, 5, 1, num_trees[2], place[2]);
   solve1(m, 7, 1, num_trees[3], place[3]);
   solve1(m, 1, 2, num_trees[4], place[4]);

   std::cout << num_trees[0] << "\n";
   std::cout << num_trees[1] << "\n";
   std::cout << num_trees[2] << "\n";
   std::cout << num_trees[3] << "\n";
   std::cout << num_trees[4] << "\n";
   std::cout << prod(num_trees) << "\n";
}
