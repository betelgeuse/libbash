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
grammar bashast;
options
{
	backtrack	= true;
	output	= AST;
	language	= Java;
	ASTLabelType	= CommonTree;
	memoize		= true;
}
tokens{
	ARG;
	ARRAY;
	ARRAY_SIZE;
	BRACE_EXP;
	EMPTY_BRACE_EXPANSION_ATOM;
	COMMAND_SUB;
	CASE_PATTERN;
	CASE_COMMAND;
	SUBSHELL;
	CURRENT_SHELL;
	COMPOUND_ARITH;
	COMPOUND_COND;
	CFOR;
	FOR_INIT;
	FOR_COND;
	FOR_MOD;
	IF_STATEMENT;
	FNAME;
	OP;
	PRE_INCR;
	PRE_DECR;
	POST_INCR;
	POST_DECR;
	PROCESS_SUBSTITUTION;
	VAR_REF;
	NEGATION;
	LIST;
	STRING;
	COMMAND;
	FILE_DESCRIPTOR;
	FILE_DESCRIPTOR_MOVE;
	REDIR;
	ARITHMETIC_CONDITION;
	ARITHMETIC_EXPRESSION;
	KEYWORD_TEST;
	BUILTIN_TEST;
	MATCH_ANY_EXCEPT;
	EXTENDED_MATCH_EXACTLY_ONE;
	EXTENDED_MATCH_AT_MOST_ONE;
	EXTENDED_MATCH_NONE;
	EXTENDED_MATCH_ANY;
	EXTENDED_MATCH_AT_LEAST_ONE;
	MATCH_PATTERN;
	NOT_MATCH_PATTERN;
	MATCH_ANY;
	MATCH_ANY_EXCEPT;
	MATCH_ALL;
	MATCH_ONE;
	CHARACTER_CLASS;
	EQUIVALENCE_CLASS;
	COLLATING_SYMBOL;
	SINGLE_QUOTED_STRING;
	DOUBLE_QUOTED_STRING;
	VARIABLE_DEFINITIONS;
	// parameter expansion operators
	USE_DEFAULT_WHEN_UNSET;
	USE_ALTERNATE_WHEN_UNSET;
	DISPLAY_ERROR_WHEN_UNSET;
	ASSIGN_DEFAULT_WHEN_UNSET;
	USE_DEFAULT_WHEN_UNSET_OR_NULL;
	USE_ALTERNATE_WHEN_UNSET_OR_NULL;
	DISPLAY_ERROR_WHEN_UNSET_OR_NULL;
	ASSIGN_DEFAULT_WHEN_UNSET_OR_NULL;
	OFFSET;
	LIST_EXPAND;
	REPLACE_FIRST;
	REPLACE_ALL;
	REPLACE_AT_START;
	REPLACE_AT_END;
	LAZY_REMOVE_AT_START;
	LAZY_REMOVE_AT_END;
	// Avoid ambiguity (being a sign or an operator)
	PLUS_SIGN;
	MINUS_SIGN;
	// Operators
	NOT_EQUALS;
}

start	:	(flcomment)? EOL* clist BLANK* (SEMIC|AMP|EOL)? EOF -> clist;
//Because the comment token doesn't handle the first comment in a file if it's on the first line, have a parser rule for it
flcomment
	:	POUND ~(EOL)* EOL;
clist
	:	list_level_2 -> ^(LIST list_level_2);
list_level_1
	:	pipeline (BLANK!*(LOGICAND^|LOGICOR^)BLANK!* pipeline)*;
// ';' '&' and EOL have lower operator precedence than '&&' and '||' so we need level2 here
list_level_2
	:	list_level_1 (BLANK!? command_separator (BLANK!? EOL!)* BLANK!? list_level_1)*;
command_separator
	:	SEMIC!
	|	AMP^
	|	EOL!;
pipeline
	:	BLANK!* time? ((BANG) => (BANG BLANK!+))? command^ (BLANK!* PIPE^ BLANK!* command)*;
time	:	TIME^ BLANK!+ ((time_posix) => time_posix)?;
time_posix
	:	TIME_POSIX BLANK!+;
//The structure of a command in bash
command
	:	compound_command
	|	function
	|	simple_command;
//Simple bash commands
simple_command
	:	variable_definitions BLANK!+ bash_command^ redirect*
	|	variable_definitions -> ^(VARIABLE_DEFINITIONS variable_definitions)
	|	bash_command^ redirect*;
variable_definitions
	:	var_def (BLANK!+ var_def)*
	|	LOCAL BLANK!+ local_item (BLANK!+ local_item)*
	|	EXPORT! (BLANK!+ export_item)+;
local_item
	:var_def
	|name -> ^(EQUALS name);
export_item
	:var_def
	|name ->;
bash_command
	:	fname_no_res_word (BLANK+ fname)* -> ^(COMMAND fname_no_res_word fname*);
redirect:	BLANK!* here_string_op^ BLANK!* fname
	|	BLANK!* here_doc_op^ BLANK!* fname EOL! heredoc
	|	BLANK* redir_op BLANK* redir_dest -> ^(REDIR redir_op redir_dest)
	|	BLANK!* process_substitution;
redir_dest
	:	file_desc_as_file //handles file descriptors
	|	fname; //path to a file
file_desc_as_file
	:	DIGIT -> ^(FILE_DESCRIPTOR DIGIT)
	|	DIGIT MINUS -> ^(FILE_DESCRIPTOR_MOVE DIGIT);
heredoc	:	(fname EOL!)*;
here_string_op
	:	HERE_STRING_OP;
here_doc_op
	:	LSHIFT MINUS -> OP["<<-"]
	|	LSHIFT -> OP["<<"];
redir_op:	AMP LESS_THAN -> OP["&<"]
	|	GREATER_THAN AMP -> OP[">&"]
	|	LESS_THAN AMP -> OP["<&"]
	|	LESS_THAN GREATER_THAN -> OP["<>"]
	|	RSHIFT -> OP[">>"]
	|	AMP GREATER_THAN -> OP["&>"]
	|	AMP RSHIFT -> OP ["&>>"]
	|	LESS_THAN
	|	GREATER_THAN
	|	DIGIT redir_op;
brace_expansion
	:	LBRACE BLANK* brace_expansion_inside BLANK* RBRACE -> ^(BRACE_EXP brace_expansion_inside);
brace_expansion_inside
	:	commasep|range;
range	:	DIGIT DOTDOT^ DIGIT
	|	LETTER DOTDOT^ LETTER;
brace_expansion_part
	:	(((~COMMA) => fname_part)+ -> ^(STRING fname_part+))+
	|	brace_expansion
	|	-> EMPTY_BRACE_EXPANSION_ATOM;
commasep:	brace_expansion_part(COMMA! brace_expansion_part)+;
command_sub
	:	DOLLAR LPAREN clist BLANK? RPAREN -> ^(COMMAND_SUB clist)
	|	TICK clist BLANK? TICK -> ^(COMMAND_SUB clist) ;
//compound commands
compound_command
	:	for_expr
	|	sel_expr
	|	if_expr
	|	while_expr
	|	until_expr
	|	case_expr
	|	subshell
	|	current_shell
	|	arith_comparison
	|	cond_comparison;
//Expressions allowed inside a compound command
for_expr:	FOR BLANK+ name (wspace IN (BLANK+ fname)+)? semiel DO wspace* clist semiel DONE -> ^(FOR name (fname+)? clist)
	|	FOR BLANK* LLPAREN EOL? (BLANK* init=arithmetic BLANK*|BLANK+)? (SEMIC (BLANK? fcond=arithmetic BLANK*|BLANK+)? SEMIC|DOUBLE_SEMIC) (BLANK* mod=arithmetic)? wspace* RRPAREN semiel DO wspace clist semiel DONE
		-> ^(CFOR ^(FOR_INIT $init)? ^(FOR_COND $fcond)? clist ^(FOR_MOD $mod)?)
	;
sel_expr:	SELECT BLANK+ name (wspace IN BLANK+ word)? semiel DO wspace* clist semiel DONE -> ^(SELECT name (word)? clist)
	;
if_expr	:	IF wspace+ ag=clist semiel THEN wspace+ iflist=clist semiel EOL* (elif_expr)* (ELSE wspace+ else_list=clist semiel EOL*)? FI
		-> ^(IF_STATEMENT ^(IF $ag $iflist) (elif_expr)* ^(ELSE $else_list)?)
	;
elif_expr
	:	ELIF BLANK+ ag=clist semiel THEN wspace+ iflist=clist semiel -> ^(IF["if"] $ag $iflist);
while_expr
	:	WHILE wspace? istrue=clist semiel DO wspace dothis=clist semiel DONE -> ^(WHILE $istrue $dothis)
	;
until_expr
	:	UNTIL wspace? istrue=clist semiel DO wspace dothis=clist semiel DONE -> ^(UNTIL $istrue $dothis)
	;
// double semicolon is optional for the last alternative
case_expr
	:	CASE BLANK+ word wspace IN wspace case_body? ESAC -> ^(CASE word case_body?);
case_body
	:	case_stmt (wspace* DOUBLE_SEMIC case_stmt)* wspace* DOUBLE_SEMIC? wspace* -> case_stmt*;
case_stmt
	:	wspace* (LPAREN BLANK*)? case_pattern (BLANK* PIPE BLANK? case_pattern)* BLANK* RPAREN (wspace* clist)?
		-> ^(CASE_PATTERN case_pattern+ (CASE_COMMAND clist)?);
case_pattern
	:	command_sub
	|	fname
	|	TIMES;
//A grouping of commands executed in a subshell
subshell:	LPAREN wspace? clist (BLANK* SEMIC)? (BLANK* EOL)* BLANK* RPAREN redirect* -> ^(SUBSHELL clist redirect*);
//A grouping of commands executed in the current shell
current_shell
	:	LBRACE wspace clist semiel wspace* RBRACE redirect* -> ^(CURRENT_SHELL clist redirect*);
//comparison using arithmetic
arith_comparison
	:	LLPAREN wspace? arithmetic wspace? RRPAREN -> ^(COMPOUND_ARITH arithmetic);
cond_comparison
	:	cond_expr -> ^(COMPOUND_COND cond_expr);
//Variables
//Defining a variable
//It's not legal to do FOO[1]=(a b c)
var_def
	:	name LSQUARE BLANK? explicit_arithmetic BLANK* RSQUARE EQUALS fname? -> ^(EQUALS ^(name explicit_arithmetic) fname?)
	|	name EQUALS^ value?
	|	name PLUS_ASSIGN fname_part? -> ^(EQUALS name ^(STRING ^(VAR_REF name) fname_part?));
//Possible values of a variable
value	:	fname
	|	LPAREN! wspace!* arr_val RPAREN!;
//allow the parser to create array variables
arr_val	:
	|	(ag+=array_atom wspace*)+ -> ^(ARRAY $ag+);
array_atom
	:	(LSQUARE) => LSQUARE! BLANK!* explicit_arithmetic BLANK!? RSQUARE! EQUALS^ fname
	|	fname;
//Referencing a variable (different possible ways/special parameters)
var_ref
	:	DOLLAR LBRACE BLANK* var_exp BLANK* RBRACE -> ^(VAR_REF var_exp)
	|	DOLLAR name -> ^(VAR_REF name)
	|	DOLLAR num -> ^(VAR_REF num)
	|	DOLLAR TIMES -> ^(VAR_REF TIMES)
	|	DOLLAR AT -> ^(VAR_REF AT)
	|	DOLLAR POUND -> ^(VAR_REF POUND)
	|	DOLLAR QMARK -> ^(VAR_REF QMARK)
	|	DOLLAR MINUS -> ^(VAR_REF MINUS)
	|	DOLLAR DOLLAR -> ^(VAR_REF DOLLAR)
	|	DOLLAR BANG -> ^(VAR_REF BANG);
//Variable expansions
var_exp	:	var_name (
				  parameter_value_operator parameter_word
					-> ^(parameter_value_operator var_name parameter_word)
				| COLON wspace* os=explicit_arithmetic (COLON len=explicit_arithmetic)?
					-> ^(OFFSET var_name $os ^($len)?)
				| parameter_delete_operator parameter_pattern_part+
					-> ^(parameter_delete_operator var_name ^(STRING parameter_pattern_part+))
				| parameter_replace_operator parameter_replace_pattern (SLASH parameter_replace_string?)?
					-> ^(parameter_replace_operator var_name parameter_replace_pattern parameter_replace_string?)
				| -> var_name
			 )
	|	BANG var_name_for_bang  (
					   TIMES -> ^(BANG var_name_for_bang TIMES)
					 | AT -> ^(BANG var_name_for_bang AT)
					 | LSQUARE (op=TIMES|op=AT) RSQUARE -> ^(LIST_EXPAND var_name_for_bang $op)
					 | -> ^(VAR_REF var_name_for_bang)
					)
	|	var_size_ref;
parameter_delete_operator
	:	POUND -> LAZY_REMOVE_AT_START
	|	POUNDPOUND -> REPLACE_AT_START
	|	PCT -> LAZY_REMOVE_AT_END
	|	PCTPCT -> REPLACE_AT_END;
parameter_value_operator
	:	COLON MINUS -> USE_DEFAULT_WHEN_UNSET_OR_NULL
	|	COLON EQUALS -> ASSIGN_DEFAULT_WHEN_UNSET_OR_NULL
	|	COLON QMARK -> DISPLAY_ERROR_WHEN_UNSET_OR_NULL
	|	COLON PLUS -> USE_ALTERNATE_WHEN_UNSET_OR_NULL
	|	MINUS -> USE_DEFAULT_WHEN_UNSET
	|	EQUALS -> ASSIGN_DEFAULT_WHEN_UNSET
	|	QMARK -> DISPLAY_ERROR_WHEN_UNSET
	|	PLUS -> USE_ALTERNATE_WHEN_UNSET;
parameter_word
	:	word
	|	-> ^(STRING);
parameter_replace_pattern
	:	((~SLASH) => parameter_pattern_part)+ -> ^(STRING parameter_pattern_part+);
parameter_pattern_part
	:	fname_part|BLANK|SEMIC;
parameter_replace_string
	:	parameter_pattern_part+ -> ^(STRING parameter_pattern_part+);
parameter_replace_operator
	:	SLASH SLASH -> REPLACE_ALL
	|	SLASH PCT -> REPLACE_AT_END
	|	SLASH POUND -> REPLACE_AT_START
	|	SLASH -> REPLACE_FIRST;
//Allowable refences to values
//either directly or through array
var_name
	:	num
	|	var_name_no_digit
	|	TIMES
	|	DOLLAR
	|	AT;
//Inside arithmetic we can't allow digits
var_name_no_digit
	:	name^ LSQUARE! (AT|TIMES|explicit_arithmetic) RSQUARE!
	|	name
	|	POUND;
//with bang the array syntax is used for array indexes
var_name_for_bang
	:	num|name|POUND;
var_size_ref
	:	POUND name LSQUARE array_size_index RSQUARE -> ^(POUND ^(name array_size_index))
	|	POUND^ name;
array_size_index
	:	DIGIT+
	|	(AT|TIMES) -> ARRAY_SIZE;
//Conditional Expressions
cond_expr
	:	LSQUARE LSQUARE wspace keyword_cond wspace RSQUARE RSQUARE -> ^(KEYWORD_TEST keyword_cond)
	|	LSQUARE wspace builtin_cond wspace RSQUARE -> ^(BUILTIN_TEST builtin_cond)
	|	TEST_EXPR wspace builtin_cond-> ^(BUILTIN_TEST builtin_cond);
cond_primary
	:	LPAREN! BLANK!* keyword_cond BLANK!* RPAREN!
	|	keyword_cond_binary
	|	keyword_cond_unary
	|	fname;
keyword_cond_binary
	:	cond_part BLANK!* binary_str_op_keyword^ BLANK!? cond_part;
keyword_cond_unary
	:	uop^ BLANK!+ cond_part;
builtin_cond_primary
	:	LPAREN! BLANK!* builtin_cond BLANK!* RPAREN!
	|	builtin_cond_binary
	|	builtin_cond_unary
	|	fname;
builtin_cond_binary
	:	cond_part BLANK!* binary_string_op_builtin^ BLANK!* cond_part;
builtin_cond_unary
	:	uop^ BLANK!+ cond_part;
keyword_cond
	:	(negate_primary|cond_primary) (BLANK!* (LOGICOR^|LOGICAND^) BLANK!* keyword_cond)?;
builtin_cond
	:	(negate_builtin_primary|builtin_cond_primary) (BLANK!* (LOGICOR^|LOGICAND^) BLANK!* builtin_cond)?;
negate_primary
	:	BANG BLANK+ cond_primary -> ^(NEGATION cond_primary);
negate_builtin_primary
	:	BANG BLANK+ builtin_cond_primary -> ^(NEGATION builtin_cond_primary);
binary_str_op_keyword
	:	bop
	|	EQUALS EQUALS -> MATCH_PATTERN
	|	EQUALS
	|	BANG EQUALS -> NOT_MATCH_PATTERN
	|	LESS_THAN
	|	GREATER_THAN;
binary_string_op_builtin
	:	bop
	|	EQUALS EQUALS -> EQUALS
	|	EQUALS
	|	BANG EQUALS -> NOT_EQUALS
	|	ESC_LT
	|	ESC_GT;
bop	:	MINUS! NAME^;
unary_cond
	:	uop^ BLANK! cond_part;
uop	:	MINUS! LETTER;
//Allowable parts of conditions
cond_part:	brace_expansion
	|	fname;
//Rules for whitespace/line endings
wspace	:	BLANK+|EOL+;
semiel	:	BLANK* (SEMIC EOL?|EOL) BLANK*;

//definition of word.  this is just going to grow...
word	:	(brace_expansion) => brace_expansion
	|	(command_sub) => command_sub
	|	(var_ref) => var_ref
	|	(num) => num
	|	(arithmetic_expansion) => arithmetic_expansion
	|	fname;

num
options{k=1;backtrack=false;}
	:	DIGIT|NUMBER;
//A rule for filenames/strings
res_word_str
	:	CASE|DO|DONE|ELIF|ELSE|ESAC|FI|FOR|FUNCTION|IF|IN|SELECT|THEN|UNTIL|WHILE|TIME;
//Any allowable part of a string, including slashes, no pounds
str_part
	:	ns_str_part
	|	SLASH;
//Parts of strings, no slashes, no reserved words
//Using negation leads to code that doesn't compile with the C backend
//Should be investigated and filed upstream
//Problematic: ~(CASE|DO|DONE|ELIF|ELSE|ESAC|FI|FOR|FUNCTION|IF|IN|SELECT|THEN|UNTIL|WHILE|TIME)
ns_str_part
	:	num
	|	name
	|	esc_char
	|OTHER|EQUALS|PCT|PCTPCT|MINUS|DOT|DOTDOT|COLON|TEST_EXPR
	|TILDE|MUL_ASSIGN|DIVIDE_ASSIGN|MOD_ASSIGN|PLUS_ASSIGN|MINUS_ASSIGN
	|TIME_POSIX|LSHIFT_ASSIGN|RSHIFT_ASSIGN|AND_ASSIGN|XOR_ASSIGN
	|OR_ASSIGN|CARET|POUND|POUNDPOUND|COMMA|EXPORT|LOCAL;

//Generic strings/filenames.
fname	:	(~POUND) => fname_part fname_part* -> ^(STRING fname_part+);
//A string that is NOT a bash reserved word
fname_no_res_word
	:	(~POUND) => nqstr_part+ fname_part* -> ^(STRING nqstr_part+ fname_part*);
fname_part
	:	nqstr_part
	|	res_word_str;
//non-quoted string part rule, allows expansions
nqstr_part
	:	extended_pattern_match
	|	bracket_pattern_match
	|	var_ref
	|	command_sub
	|	arithmetic_expansion
	|	brace_expansion
	|	dqstr
	|	sqstr
	|	str_part
	|	pattern_match_trigger
	|	BANG;
//double quoted string rule, allows expansions
dqstr	:	DQUOTE dqstr_part* DQUOTE -> ^(DOUBLE_QUOTED_STRING dqstr_part*);
dqstr_part
	:	var_ref
	|	command_sub
	|	arithmetic_expansion
	| 	ESC DQUOTE
	|	~(DOLLAR|TICK|DQUOTE);
//single quoted string rule, no expansions
sqstr_part
	: ~SQUOTE*;
sqstr	:	SQUOTE sqstr_part SQUOTE -> ^(SINGLE_QUOTED_STRING sqstr_part);
//certain tokens that trigger pattern matching
pattern_match_trigger
	:	LSQUARE
	|	RSQUARE
	|	QMARK
	|	PLUS
	|	TIMES
	|	AT;
//Pattern matching using brackets
bracket_pattern_match
	:	LSQUARE RSQUARE (BANG|CARET) pattern_match* RSQUARE -> ^(MATCH_ANY_EXCEPT RSQUARE pattern_match*)
	|	LSQUARE RSQUARE pattern_match* RSQUARE -> ^(MATCH_ANY RSQUARE pattern_match*)
	|	LSQUARE (BANG|CARET) pattern_match+ RSQUARE -> ^(MATCH_ANY_EXCEPT pattern_match+)
	|	LSQUARE pattern_match+ RSQUARE -> ^(MATCH_ANY pattern_match+)
	|	TIMES -> MATCH_ALL
	|	QMARK -> MATCH_ONE;
//allowable patterns with bracket pattern matching
pattern_match
	:	pattern_class_match
	|	pattern_string_part+;
pattern_string_part
	:	var_ref
	|	command_sub
	|	arithmetic_expansion
	|	ns_str_part;

//special class patterns to match: [:alpha:] etc
pattern_class_match
	:	LSQUARE COLON NAME COLON RSQUARE -> ^(CHARACTER_CLASS NAME)
	|	LSQUARE EQUALS pattern_char EQUALS RSQUARE -> ^(EQUIVALENCE_CLASS pattern_char)
	|	LSQUARE DOT NAME DOT RSQUARE -> ^(COLLATING_SYMBOL NAME);
//Characters allowed in matching equivalence classes
pattern_char
	:	LETTER|DIGIT|OTHER|QMARK|COLON|AT|SEMIC|POUND|SLASH|BANG|TIMES|COMMA|PIPE|AMP|MINUS|PLUS|PCT|EQUALS|LSQUARE|RSQUARE|RPAREN|LPAREN|RBRACE|LBRACE|DOLLAR|TICK|DOT|LESS_THAN|GREATER_THAN|SQUOTE|DQUOTE;
//extended pattern matching
extended_pattern_match
	:	QMARK LPAREN fname (PIPE fname)* RPAREN -> ^(EXTENDED_MATCH_AT_MOST_ONE fname+)
	|	TIMES LPAREN fname (PIPE fname)* RPAREN -> ^(EXTENDED_MATCH_ANY fname+)
	|	PLUS LPAREN fname (PIPE fname)* RPAREN -> ^(EXTENDED_MATCH_AT_LEAST_ONE fname+)
	|	AT LPAREN fname (PIPE fname)* RPAREN -> ^(EXTENDED_MATCH_EXACTLY_ONE fname+)
	|	BANG LPAREN fname (PIPE fname)* RPAREN -> ^(EXTENDED_MATCH_NONE fname+);
//The base of the arithmetic operator.  Used for order of operations
arithmetic_var_ref:
	var_ref -> ^(VAR_REF var_ref);
primary	:	num
	|	var_ref
	|	command_sub
	|	var_name_no_digit -> ^(VAR_REF var_name_no_digit)
	|	LPAREN! (arithmetics) RPAREN!;
pre_post_primary:	arithmetic_var_ref | primary;
post_inc_dec
	:	pre_post_primary BLANK? PLUS PLUS -> ^(POST_INCR pre_post_primary)
	|	pre_post_primary BLANK? MINUS MINUS -> ^(POST_DECR pre_post_primary);
pre_inc_dec
	:	PLUS PLUS BLANK? pre_post_primary -> ^(PRE_INCR pre_post_primary)
	|	MINUS MINUS BLANK? pre_post_primary -> ^(PRE_DECR pre_post_primary);
unary	:	post_inc_dec
	|	pre_inc_dec
	|	primary BLANK!*
	|	PLUS BLANK* unary -> ^(PLUS_SIGN unary)
	|	MINUS BLANK* unary -> ^(MINUS_SIGN unary)
	|	(TILDE|BANG)^ BLANK!* unary;
exponential
	:	unary (EXP^ BLANK!* unary)* ;
times_division_modulus
	:	exponential ((TIMES^|SLASH^|PCT^) BLANK!* exponential)*;
addsub	:	times_division_modulus ((PLUS^|MINUS^) BLANK!* times_division_modulus)*;
shifts	:	addsub ((LSHIFT^|RSHIFT^) BLANK!* addsub)*;
compare	:	shifts ((LEQ^|GEQ^|LESS_THAN^|GREATER_THAN^) BLANK!* shifts)?;
bitwiseand
	:	compare (AMP^ BLANK!* compare)*;
bitwisexor
	:	bitwiseand (CARET^ BLANK!* bitwiseand)*;
bitwiseor
	:	bitwisexor (PIPE^ BLANK!* bitwisexor)*;
logicand:	bitwiseor (LOGICAND^ BLANK!* bitwiseor)*;
logicor	:	logicand (LOGICOR^ BLANK!* logicand)*;

arithmetic_condition
	:	cnd=logicor QMARK t=logicor COLON f=logicor -> ^(ARITHMETIC_CONDITION $cnd $t $f);

arithmetic_assignment_operator
	:	EQUALS|MUL_ASSIGN|DIVIDE_ASSIGN|MOD_ASSIGN|PLUS_ASSIGN|MINUS_ASSIGN|LSHIFT_ASSIGN|RSHIFT_ASSIGN|AND_ASSIGN|XOR_ASSIGN|OR_ASSIGN;

arithmetic_assignment
	:	((var_name_no_digit|arithmetic_var_ref) BLANK!* arithmetic_assignment_operator^ BLANK!*)? logicor;
arithmetic
	:	arithmetic_condition
	|	arithmetic_assignment;
//The comma operator for arithmetic expansions
arithmetics
	:	arithmetic (COMMA! BLANK!* arithmetic)*;
//explicit arithmetic in places like array indexes
explicit_arithmetic
	:	(DOLLAR LLPAREN BLANK*)? arithmetics RRPAREN? -> arithmetics
	|	(DOLLAR LSQUARE BLANK*)? arithmetics RSQUARE? -> arithmetics;
//Arithmetic expansion
//the square bracket from is deprecated
//http://permalink.gmane.org/gmane.comp.shells.bash.bugs/14479
arithmetic_expansion
	:	DOLLAR LLPAREN BLANK* arithmetics BLANK* RRPAREN -> ^(ARITHMETIC_EXPRESSION arithmetics)
	|	DOLLAR LSQUARE BLANK* arithmetics BLANK* RSQUARE -> ^(ARITHMETIC_EXPRESSION arithmetics);

process_substitution
	:	(dir=LESS_THAN|dir=GREATER_THAN)LPAREN clist BLANK* RPAREN -> ^(PROCESS_SUBSTITUTION $dir clist);
//the biggie: functions
function:	FUNCTION BLANK+ function_name ((BLANK* parens wspace*)|wspace) compound_command -> ^(FUNCTION ^(STRING function_name) compound_command)
	|	function_name BLANK* parens wspace* compound_command -> ^(FUNCTION["function"] ^(STRING function_name) compound_command);
//http://article.gmane.org/gmane.comp.shells.bash.bugs/16424
//the rules from bash 3.2 general.c:
//Make sure that WORD is a valid shell identifier, i.e.
//does not contain a dollar sign, nor is quoted in any way.  Nor
//does it consist of all digits.
function_name
	:	(NUMBER|DIGIT)? ~(DOLLAR|SQUOTE|DQUOTE|LPAREN|RPAREN|BLANK|EOL|NUMBER|DIGIT) ~(DOLLAR|SQUOTE|DQUOTE|LPAREN|RPAREN|BLANK|EOL)*;
parens	:	LPAREN BLANK* RPAREN;
name	:	NAME
	|	LETTER
	|	UNDERSCORE;
esc_char:	ESC (DIGIT DIGIT? DIGIT?|LETTER ALPHANUM ALPHANUM?|.);

//****************
// TOKENS/LEXER RULES
//****************

//Bash "reserved words"
BANG	:	'!';
CASE	:	'case';
DO	:	'do';
DONE	:	'done';
ELIF	:	'elif';
ELSE	:	'else';
ESAC	:	'esac';
FI	:	'fi';
FOR	:	'for';
FUNCTION:	'function';
IF	:	'if';
IN	:	'in';
SELECT	:	'select';
THEN	:	'then';
UNTIL	:	'until';
WHILE	:	'while';
LBRACE	:	'{';
RBRACE	:	'}';
TIME	:	'time';

//Other special useful symbols
RPAREN	:	')';
LPAREN	:	'(';
LLPAREN	:	'((';
RRPAREN	:	'))';
LSQUARE	:	'[';
RSQUARE	:	']';
TICK	:	'`';
DOLLAR	:	'$';
AT	:	'@';
DOT	:	'.';
DOTDOT	:	'..';
//Arith ops
TIMES	:	'*';
EQUALS	:	'=';
MINUS	:	'-';
PLUS	:	'+';
EXP	:	'**';
AMP	:	'&';
LEQ	:	'<=';
GEQ	:	'>=';
CARET	:	'^';
LESS_THAN	:	'<';
GREATER_THAN	:	'>';
LSHIFT	:	'<<';
RSHIFT	:	'>>';
MUL_ASSIGN	:	'*=';
DIVIDE_ASSIGN	:	'/=';
MOD_ASSIGN	:	'%=';
PLUS_ASSIGN	:	'+=';
MINUS_ASSIGN	:	'-=';
LSHIFT_ASSIGN	:	'<<=';
RSHIFT_ASSIGN	:	'>>=';
AND_ASSIGN	:	'&=';
XOR_ASSIGN	:	'^=';
OR_ASSIGN	:	'|=';
//some separators
SEMIC	:	';';
DOUBLE_SEMIC
	:	';;';
PIPE	:	'|';
DQUOTE	:	'"';
SQUOTE	:	'\'';
COMMA	:	',';
//Because bash isn't exactly whitespace dependent... need to explicitly handle blanks
//We handle comments through here so that it's possible to do BLANK?
//Otherwise you would end up with token sequences like BLANK COMMENT BLANK
BLANK	:	(' '|'\t')+ COMMENT?;
EOL	:	('\r'?'\n')+ COMMENT?;
fragment
COMMENT :	'#' ~('\n'|'\r')*;
//some fragments for creating words...
DIGIT	:	'0'..'9';
NUMBER	:	DIGIT DIGIT+;
LETTER	:	('a'..'z'|'A'..'Z');
fragment
ALPHANUM:	(DIGIT|LETTER);
//Some special redirect operators
TILDE	:	'~';
HERE_STRING_OP
	:	'<<<';
//Tokens for parameter expansion
POUND	:	'#';
POUNDPOUND
	:	'##';
PCT	:	'%';
PCTPCT	:	'%%';
SLASH	:	'/';
COLON	:	':';
QMARK	:	'?';
//Operators for conditional statements
TEST_EXPR	:	'test';
LOCAL	:	'local';
EXPORT	:	'export';
LOGICAND :	'&&';
LOGICOR	:	'||';
//Tokens for strings
CONTINUE_LINE
	:	(ESC EOL)+{$channel=HIDDEN;};
ESC_RPAREN
	:	ESC RPAREN;
ESC_LPAREN
	:	ESC LPAREN;
ESC_LT	:	ESC'<';
ESC_GT	:	ESC'>';
//For pipeline
TIME_POSIX
	:	'-p';
//Handle ANSI C escaped characters: escaped octal, escaped hex, escaped ctrl+ chars, then all others
ESC	:	'\\';
UNDERSCORE : '_';
NAME	:	(LETTER|UNDERSCORE)(ALPHANUM|UNDERSCORE)+;
OTHER	:	.;
