module EvalTests
    (tests) where

import Test.Tasty
import Test.Tasty.HUnit

import ParseWhile
import WhileGrammar
import Evaluator
import State
import Lib

s1    = state [("x",1), ("y",2), ("z",3)]
empty = state []

tests = [
    assign1,
    assign2,
    skip1,
    skip2,
    if1,
    if2,
    if4,
    wh1
    ]

build_test program s expected_result = 
    testCase program (assertEqual "" expected_result result)
    where result = interpret program s

assign1 = build_test "x:=1" empty (state [("x",1)])

assign2 = build_test "x:=300;y:=2" empty (state [("x",300),("y",2)])

skip1 = build_test "skip;skip;skip" s1 s1

skip2 = build_test "skip;x:=2;skip; y:=123" empty (state [("x",2),("y",123)])

if1 = build_test "x:=1; if x=1 then y:=1 else y:=0" empty (state [("x",1),("y",1)])

if2 = build_test "x:=100; if x<=1 then y:=1 else y:=0" empty (state [("y",0),("x",100)])

if3 = build_test "if true and true then x:=1;y:=1 else x:=0;y:=0" empty (state [("y",1),("x",1)])

if4 = build_test "if not true then skip;x:=1;y:=1;skip else skip;x:=0;y:=0;skip" empty (state [("y",0),("x",0)])

wh1 = build_test "x:=0; y:=1; while y<=10 do x := x+1; y := y+1 " empty (state [("x",10),("y",11)])