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
/// \file parser_builder.cpp
/// \author Mu Qiao
/// \brief a class that helps build libbashParser from istream
///

#include "core/parser_builder.h"

#include <sstream>

#include "core/interpreter_exception.h"
#include "libbashLexer.h"
#include "libbashParser.h"
#include "walker_builder.h"

parser_builder::parser_builder(std::istream& source)
{
  std::stringstream stream;
  stream << source.rdbuf();
  script = stream.str();

  input = antlr3NewAsciiStringInPlaceStream(
      reinterpret_cast<pANTLR3_UINT8>(const_cast<char*>(script.c_str())),
      script.size(),
      NULL);
  init_parser();
}

parser_builder::~parser_builder()
{
  nodes->free(nodes);
  psr->free(psr);
  tstream->free(tstream);
  lxr->free(lxr);
  input->close(input);
}

void parser_builder::init_parser()
{
  lxr = libbashLexerNew(input);
  if ( lxr == NULL )
    throw interpreter_exception("Unable to create the lexer due to malloc() failure");

  tstream = antlr3CommonTokenStreamSourceNew(
      ANTLR3_SIZE_HINT, lxr->pLexer->rec->state->tokSource);
  if (tstream == NULL)
    throw interpreter_exception("Out of memory trying to allocate token stream");

  psr = libbashParserNew(tstream);
  if (psr == NULL)
    throw interpreter_exception("Out of memory trying to allocate parser");

  langAST.reset(new libbashParser_start_return(psr->start(psr)));
  nodes = antlr3CommonTreeNodeStreamNewTree(langAST->tree, ANTLR3_SIZE_HINT);
}

walker_builder parser_builder::create_walker_builder()
{
  return walker_builder(nodes);
}

std::string parser_builder::get_dot_graph()
{
  pANTLR3_STRING graph = nodes->adaptor->makeDot(nodes->adaptor, langAST->tree);
  return std::string(reinterpret_cast<char*>(graph->chars));
}

std::string parser_builder::get_string_tree()
{
  return std::string(reinterpret_cast<char*>(
        langAST->tree->toStringTree(langAST->tree)->chars));
}

std::string parser_builder::get_tokens(std::function<std::string(ANTLR3_INT32)> token_map)
{
  std::stringstream result;
  int line_counter = 1;

  // output line number for the first line
  result << line_counter++ << "\t";

  pANTLR3_VECTOR token_list = tstream->getTokens(tstream);
  unsigned token_size = token_list->size(token_list);

  for(unsigned i = 0; i != token_size; ++i)
  {
    pANTLR3_COMMON_TOKEN token = reinterpret_cast<pANTLR3_COMMON_TOKEN>
      (token_list->get(token_list, i));
    std::string tokenName = token_map(token->getType(token));

    if(tokenName != "EOL" && tokenName != "COMMENT" && tokenName != "CONTINUE_LINE")
    {
      result << tokenName << " ";
    }
    // Output \n and line number before each COMMENT token for better readability
    else if(tokenName == "COMMENT")
    {
      char* text = reinterpret_cast<char*>(token->getText(token)->chars);
      for(int i = 0; text[i] == '\n'; ++i)
        result << '\n' << line_counter++ << "\t";
      result << tokenName;
    }
    // Output \n and line number after each CONTINUE_LINE token for better readability
    else if(tokenName == "CONTINUE_LINE")
    {
      result << tokenName;
      char* text = reinterpret_cast<char*>(token->getText(token)->chars);
      for(int i = 1; text[i] == '\n'; ++i)
        result << '\n' << line_counter++ << "\t";
    }
    // Output \n and line number after each EOL token for better readability
    // omit the last \n and line number
    else if(i + 1 != token_size)
    {
      result << tokenName;
      char* text = reinterpret_cast<char*>(token->getText(token)->chars);
      for(int i = 0; text[i] == '\n'; ++i)
        result << '\n' << line_counter++ << "\t";
    }
  }

  return result.str();
}
