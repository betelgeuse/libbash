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
#include <boost/algorithm/string/classification.hpp>
#include <boost/algorithm/string/split.hpp>
#include <boost/algorithm/string/trim.hpp>
#include <boost/range/adaptor/filtered.hpp>
#include <boost/range/adaptor/map.hpp>
#include <boost/range/algorithm/find.hpp>

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
  using namespace boost::spirit::karma;

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
    {
      std::vector<std::string> formatted;
      boost::trim_if(iter_value->second[0], boost::is_any_of(" \t\n"));
      boost::split(formatted,
                   iter_value->second[0],
                   boost::is_any_of(" \t\n"),
                   boost::token_compress_on);
      std::cout << format(string % ' ', formatted) << std::endl;
    }
    else
    {
      std::cout << std::endl;
    }
  }

  using namespace boost::adaptors;

  auto defined_phases = phases | filtered([&functions] (const std::pair<std::string, std::string>& phase) -> bool {
    return boost::find(functions, phase.first) != functions.end();
  }) | map_values;

  std::set<std::string> sorted_phases(defined_phases.begin(), defined_phases.end());

  std::cout << format(string % ' ', sorted_phases) << std::endl;

  // Print empty lines
  std::cout << std::endl << std::endl << std::endl << std::endl << std::endl;

  return EXIT_SUCCESS;
}
