/*
   Please use git log for copyright holder and year information

   This file is part of libbash.

   libbash is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 2 of the License, or
   (at your option) any later version.

   libbash is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with libbash.  If not, see <http://www.gnu.org/licenses/>.
*/
///
/// \file return_builtin.h
/// \brief implementation for the return builtin
///
#ifndef LIBBASH_BUILTINS_RETURN_BUILTIN_H_
#define LIBBASH_BUILTINS_RETURN_BUILTIN_H_

#include "cppbash_builtin.h"

class return_builtin : public virtual cppbash_builtin
{
public:
  BUILTIN_CONSTRUCTOR(return)
  virtual int exec(const std::vector<std::string>& );
};

#endif
