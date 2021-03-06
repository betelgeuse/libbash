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
/// \file boolean_builtins.cpp
/// \brief implementations for the true and false builtins
///
#ifndef LIBBASH_BUILTINS_BOOLEAN_BUILTINS_H_
#define LIBBASH_BUILTINS_BOOLEAN_BUILTINS_H_

#include "cppbash_builtin.h"

struct true_builtin : public virtual cppbash_builtin
{
  BUILTIN_CONSTRUCTOR(true)
  virtual int exec(const std::vector<std::string>& ) { return 0; }
};

struct false_builtin : public virtual cppbash_builtin
{
  BUILTIN_CONSTRUCTOR(false)
  virtual int exec(const std::vector<std::string>& ) { return 1; }
};

#endif
