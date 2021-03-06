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
/// \file libbash.cpp
/// \brief implementation for libbash interface
///

#include "libbash.h"

#include <fstream>

#include <boost/numeric/conversion/cast.hpp>

#include "core/interpreter.h"
#include "core/bash_ast.h"

namespace internal
{
  int interpret(interpreter& walker,
                const std::string& path,
                std::unordered_map<std::string, std::vector<std::string>>& variables,
                std::vector<std::string>& functions)
  {
    // Initialize bash environment
    for(auto iter = variables.begin(); iter != variables.end(); ++iter)
      walker.define(iter->first, (iter->second)[0]);
    walker.define("0", path, true);
    variables.clear();

    bash_ast ast(path);
    ast.interpret_with(walker);

    for(auto iter = walker.begin(); iter != walker.end(); ++iter)
      iter->second->get_all_values<std::string>(variables[iter->first]);
    walker.get_all_function_names(functions);

    return walker.get_status();
  }
}

namespace libbash
{
  int interpret(const std::string& target_path,
                std::unordered_map<std::string, std::vector<std::string>>& variables,
                std::vector<std::string>& functions)
  {
    interpreter walker;
    return internal::interpret(walker, target_path, variables, functions);
  }

  int interpret(const std::string& target_path,
                const std::string& preload_path,
                std::unordered_map<std::string, std::vector<std::string>>& variables,
                std::vector<std::string>& functions)
  {
    interpreter walker;

    // Preloading
    bash_ast preload_ast(preload_path);
    preload_ast.interpret_with(walker);

    return internal::interpret(walker, target_path, variables, functions);
  }
}
