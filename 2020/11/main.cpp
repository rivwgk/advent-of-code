#include <fstream>
#include <iostream>
#include <string>
#include <vector>

class CAutomaton {
public:
   CAutomaton(size_t nrows, size_t ncols) : nrows(nrows), ncols(ncols)
   {
      m_fields = new char[2*nrows*ncols];
   }
   CAutomaton(const CAutomaton& other) : nrows{other.nrows}, ncols{other.ncols}
   {
      m_fields = new char[2*nrows*ncols];
      for (size_t x=0; x<nrows*ncols; ++x)
         m_fields[x] = other.m_fields[x];
   }
   ~CAutomaton()
   {
      delete[] m_fields;
   }

   char&
   operator()(size_t i, size_t j, bool dbuffer=false)
   {
      return m_fields[field_index(i, j) + (dbuffer ? ncols*nrows : 0)];
   }

   char
   operator()(size_t i, size_t j, bool dbuffer=false)
   const {
      return m_fields[field_index(i, j) + (dbuffer ? ncols*nrows : 0)];
   }

   bool
   step()
   {
      bool change = false;
      for (size_t i=0; i<nrows; ++i)
         for (size_t j=0; j<ncols; ++j) {
            size_t occupied = occ_neighbours(i,j);
            if ((*this)(i,j) == 'L' and occupied == 0) {
               (*this)(i,j,true) = '#';
               change = true;
            } else if ((*this)(i,j) == '#' and occupied >= 5) {
               (*this)(i,j,true) = 'L';
               change = true;
            } else {
               (*this)(i,j,true) = (*this)(i,j);
            }
         }

      for (size_t x=0; x<nrows*ncols; ++x)
         m_fields[x] = m_fields[x+nrows*ncols];
      return change;
   }

   size_t
   run_till_stop()
   {
      while (step()) ;

      size_t c=0;
      for (size_t i=0; i<nrows; ++i)
         for (size_t j=0; j<ncols; ++j)
            if ((*this)(i,j) == '#')
               ++c;
      return c;
   }
private:
   size_t
   occ_neighbours(size_t i, size_t j)
   const {
      size_t c = 0; size_t offset=1;
      for (offset=1; (*this)(i,j-offset) == '.'; ++offset) ; 
      if (j >= offset && (*this)(i,j-offset) == '#')
         ++c;
      for (offset=1; (*this)(i,j+offset) == '.'; ++offset) ; 
      if (j < ncols-offset && (*this)(i,j+offset) == '#')
         ++c;
      for (offset=1; (*this)(i-offset,j) == '.'; ++offset) ; 
      if (i >= offset && (*this)(i-offset,j) == '#')
         ++c;
      for (offset=1; (*this)(i+offset,j) == '.'; ++offset) ; 
      if (i < nrows-offset && (*this)(i+offset,j) == '#')
         ++c;
      for (offset=1; (*this)(i-offset,j-offset) == '.'; ++offset) ; 
      if (j >= offset && i >= offset && (*this)(i-offset,j-offset) == '#')
         ++c;
      for (offset=1; (*this)(i+offset,j-offset) == '.'; ++offset) ; 
      if (j >= offset && i < nrows-offset && (*this)(i+offset,j-offset) == '#')
         ++c;
      for (offset=1; (*this)(i-offset,j+offset) == '.'; ++offset) ; 
      if (j < ncols-offset && i >= offset && (*this)(i-offset,j+offset) == '#')
         ++c;
      for (offset=1; (*this)(i+offset,j+offset) == '.'; ++offset) ; 
      if (j < ncols-offset && i < nrows-offset && (*this)(i+offset,j+offset) == '#')
         ++c;
      return c;
   }

   size_t
   field_index(size_t i, size_t j)
   const {
      return i*ncols + j;
   }

   size_t nrows, ncols;
   char *m_fields;
};

void
usage(const char*s)
{
   std::cout << "usage: " << s << " data\n";
   exit(EXIT_FAILURE);
}

int
main(int argc, const char**argv)
{
   if (argc != 2)
      usage(*argv);

   std::ifstream file{std::string{argv[1]}};
   std::vector<std::string> lines{};
   while (!file.eof()) {
      std::string s;
      std::getline(file, s, '\n');
      if (!s.empty())
         lines.push_back(s);
   }
   CAutomaton ca{lines.size(), lines[0].size()};
   for (size_t i=0; i<lines.size(); ++i)
      for (size_t j=0; j<lines[i].size(); ++j)
         ca(i,j) = lines[i][j];

   size_t steps = ca.run_till_stop();
   std::cout << "num steps: " << steps << '\n';
   return EXIT_SUCCESS;
}
