{
module Parser where
import Data.Char
import WhileGrammar

-- Op precedence: https://en.cppreference.com/w/cpp/language/operator_precedence
-- Happy precedence: https://www.haskell.org/happy/doc/html/sec-Precedences.html

}

%name calc
%tokentype { Token }
%error { parseError }
%nonassoc '<=' '<' '>' '>='

%left 'or'
%left 'and'

%left '+' '-'
%left '*'
%left NEG 'not'

%left 'do' -- do is stronger than else
%left 'else' -- else is stronger than ;
%right ';'

%token 
      int             { TokenInt $$ }
      var             { TokenVar $$ }
      bool            { TokenBoolConst $$ }
      
      'skip'          { TokenSkip }

      'if'            { TokenIf }
      'then'          { TokenThen }
      'else'          { TokenElse }

      'while'         { TokenWhile }
      'do'            { TokenDo }
      
      '+'             { TokenPlus }
      '-'             { TokenMinus }
      '*'             { TokenTimes }
      
      '('             { TokenOB }
      ')'             { TokenCB }
      
      ':='            { TokenAssign }
      ';'             { TokenSemi }
      
      '='             { TokenEq }
      'not'           { TokenNot }
      'and'           { TokenAnd }
      'or'            { TokenOr }

      '<='            { TokenLessEq }
      '>='            { TokenGreaterEq }
      '<'             { TokenLess }
      '>'             { TokenGreater }

%%

Stmt  : '(' Stmt ')'    { $2 }
      | var ':=' AExpr  { Assign $1 $3 }
      | Stmt ';' Stmt   { Seq $1 $3 }
      | 'skip'          { Skip }
      | 'if' BExpr 'then' Stmt 'else' Stmt { If $2 $4 $6 }
      | 'while' BExpr 'do' Stmt {While $2 $4 }

AExpr : int           { IntConst $1 }
      | '(' AExpr ')' { $2 }
      | var           { Var $1}
      | '-' AExpr %prec NEG     {Neg $2}
      | AExpr '+' AExpr         {ABinary Add $1 $3}
      | AExpr '-' AExpr         {ABinary Subtract $1 $3}
      | AExpr '*' AExpr         {ABinary Multiply $1 $3}

BExpr : '(' BExpr ')'           { $2 }
      | bool                    { BoolConst $1 }
      | 'not' BExpr             { Not $2 }
      | BExpr 'and' BExpr       { BooleanBinary And $1 $3 }
      | BExpr 'or' BExpr        { BooleanBinary Or $1 $3 }
      | AExpr '=' AExpr         { ArithmeticBinary IsEqual $1 $3 }
      | AExpr '<=' AExpr        { ArithmeticBinary LessEq $1 $3 }
      | AExpr '>=' AExpr        { ArithmeticBinary GreaterEq $1 $3 }
      | AExpr '<' AExpr         { ArithmeticBinary Less $1 $3 }
      | AExpr '>' AExpr         { ArithmeticBinary Greater $1 $3 }

{

parseError :: [Token] -> a
parseError _ = error "Parse error"

data Token
    = TokenInt Integer
    | TokenBoolConst Bool
    | TokenVar String
    | TokenAssign
    | TokenPlus
    | TokenMinus
    | TokenTimes
    | TokenEq
    | TokenOB
    | TokenCB
    | TokenSemi
    | TokenSkip
    | TokenIf
    | TokenThen
    | TokenElse
    | TokenNot
    | TokenAnd
    | TokenOr
    | TokenLessEq
    | TokenLess
    | TokenGreaterEq
    | TokenGreater
    | TokenWhile
    | TokenDo
    deriving Show

lexer :: String -> [Token]
lexer [] = []
lexer (c:cs) 
        | isSpace c = lexer cs
        | isAlpha c = lexVar (c:cs)
        | isDigit c = lexNum (c:cs)
-- note that is important for pattern matching to have >= upper than >
lexer ('<':'=':cs) = TokenLessEq : lexer cs
lexer ('>':'=':cs) = TokenGreaterEq : lexer cs
lexer ('<':cs) = TokenLess : lexer cs
lexer ('>':cs) = TokenGreater : lexer cs
lexer (':':'=':cs) = TokenAssign : lexer cs
lexer ('+':cs) = TokenPlus : lexer cs
lexer ('-':cs) = TokenMinus : lexer cs
lexer ('*':cs) = TokenTimes : lexer cs
lexer ('(':cs) = TokenOB : lexer cs
lexer (')':cs) = TokenCB : lexer cs
lexer (';':cs) = TokenSemi : lexer cs
lexer ('=':cs) = TokenEq : lexer cs

lexNum cs = TokenInt (read num) : lexer rest
        where (num,rest) = span isDigit cs

lexVar cs =
    case span isAlpha cs of
        ("if",rest) -> TokenIf : lexer rest
        ("then",rest) -> TokenThen : lexer rest
        ("else",rest) -> TokenElse : lexer rest
        ("skip",rest) -> TokenSkip : lexer rest
        ("true",rest) -> TokenBoolConst True : lexer rest
        ("false",rest) -> TokenBoolConst False : lexer rest
        ("not",rest) -> TokenNot : lexer rest
        ("and",rest) -> TokenAnd : lexer rest
        ("or",rest) -> TokenOr : lexer rest
        ("while",rest) -> TokenWhile : lexer rest
        ("do",rest) -> TokenDo : lexer rest
        (var,rest)   -> TokenVar var : lexer rest

-- main = getContents >>= print . calc . lexer

parse string = (calc . lexer) string

}