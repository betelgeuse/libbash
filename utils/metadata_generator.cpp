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
/// \file metadata_generator.cpp
/// \author Mu Qiao
/// \brief a simple utility for generating metadata
///
#include <iostream>
#include <set>
#include <string>
#include <vector>

#include <boost/spirit/include/karma.hpp>

#include "libbash.h"

static const std::vector<std::string> metadata_names = {"DEPEND", "RDEPEND", "SLOT", "SRC_URI",
                                                        "RESTRICT",  "HOMEPAGE",  "LICENSE", "DESCRIPTION",
                                                        "KEYWORDS",  "INHERITED", "IUSE", "REQUIRED_USE",
                                                        "PDEPEND",   "PROVIDE", "EAPI", "PROPERTIES"};

static const std::unordered_map<std::string, std::string> phases = {
  {"pkg_pretend", "ppretend"},
  {"pkg_setup", "setup"},
  {"src_unpack", "unpack"},
  {"src_prepare", "prepare"},
  {"src_configure", "configure"},
  {"src_compile", "compile"},
  {"src_test", "test"},
  {"src_install", "install"},
  {"pkg_preinst", "preinst"},
  {"pkg_postinst", "postinst"},
  {"pkg_prerm", "prerm"},
  {"pkg_postrm", "postrm"},
  {"pkg_config", "config"},
  {"pkg_info", "info"},
  {"pkg_nofetch", "nofetch"}
};

int main(int argc, char** argv)
{
  if(argc != 2)
  {
    std::cerr<<"Please provide your script as an argument"<<std::endl;
    exit(EXIT_FAILURE);
  }

  std::unordered_map<std::string, std::vector<std::string>> variables;
  std::vector<std::string> functions;
  libbash::interpret(argv[1], variables, functions);

  for(auto iter_name = metadata_names.begin(); iter_name != metadata_names.end(); ++iter_name)
  {
    auto iter_value = variables.find(*iter_name);
    if(iter_value != variables.end())
      std::cout << iter_value->second[0] << std::endl;
    else
      std::cout << std::endl;
  }

  // Print defined phases
  std::set<std::string> defined_phases;
  for(auto iter = functions.begin(); iter != functions.end(); ++iter)
  {
    auto iter_phase = phases.find(*iter);
    if(iter_phase != phases.end())
      defined_phases.insert(iter_phase->second);
  }

  using namespace boost::spirit::karma;
  std::cout << format(string % ' ', defined_phases) << std::endl;

  // Print empty lines
  std::cout << std::endl << std::endl << std::endl << std::endl << std::endl;

  return EXIT_SUCCESS;
}
