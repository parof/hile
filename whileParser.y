{
module Main where
import Data.Char
}

%name calc
%tokentype { Token }
%error { parseError }
%nonassoc '>' '<'
%left '+' '-'
%left '*'
%left NEG
%right ';'

%token 
      int             { TokenInt $$ }
      var             { TokenVar $$ }
      '+'             { TokenPlus }
      '-'             { TokenMinus }
      '*'             { TokenTimes }
      '('             { TokenOB }
      ')'             { TokenCB }
      ':='            { TokenAssign }
      ';'             { TokenSemi }
      '='             { TokenEq }

%%

Stmt  : var ':=' AExpr  { Assign $1 $3 }
      | Stmt ';' Stmt   { Seq $1 $3 }

AExpr : int {IntConst $1}
      | var {Var $1}
      | '-' AExpr %prec NEG     {Neg $2}
      | AExpr '+' AExpr         {ABinary Add $1 $3}
      | AExpr '-' AExpr         {ABinary Subtract $1 $3}
      | AExpr '*' AExpr         {ABinary Multiply $1 $3}

{

parseError :: [Token] -> a
parseError _ = error "Parse error"

data Stmt = Assign String AExpr
          | Seq Stmt Stmt
          deriving (Show,Eq)

data AExpr = Var      String
           | IntConst Integer
           | Neg      AExpr
           | ABinary  AArithemticBinOperator AExpr AExpr
           deriving (Show,Eq)

data AArithemticBinOperator = Add
                            | Subtract
                            | Multiply
                            deriving (Show,Eq)

data Token
    = TokenInt Integer
    | TokenVar String
    | TokenAssign
    | TokenPlus
    | TokenMinus
    | TokenTimes
    | TokenEq
    | TokenOB
    | TokenCB
    | TokenSemi
    deriving Show

lexer :: String -> [Token]
lexer [] = []
lexer (c:cs) 
        | isSpace c = lexer cs
        | isAlpha c = lexVar (c:cs)
        | isDigit c = lexNum (c:cs)
lexer (':':'=':cs) = TokenAssign : lexer cs
lexer ('+':cs) = TokenPlus : lexer cs
lexer ('-':cs) = TokenMinus : lexer cs
lexer ('*':cs) = TokenTimes : lexer cs
lexer ('(':cs) = TokenOB : lexer cs
lexer (')':cs) = TokenCB : lexer cs
lexer (';':cs) = TokenSemi : lexer cs
-- lexer ('=':cs) = TokenEq : lexer cs

lexNum cs = TokenInt (read num) : lexer rest
        where (num,rest) = span isDigit cs

lexVar cs =
    case span isAlpha cs of
        -- ("let",rest) -> TokenLet : lexer rest
        -- ("in",rest)  -> TokenIn : lexer rest
        (var,rest)   -> TokenVar var : lexer rest

main = getContents >>= print . calc . lexer

p string = (print . calc . lexer) string
}