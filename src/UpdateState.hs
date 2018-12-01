module UpdateState
    (update_state,overwrite_entry)
where

import WhileGrammar
import State
import EvalAExpr


update_state :: String -> AExpr -> State -> State
update_state identifier aexpr s =
    overwrite_entry (identifier,evaluated_aexpr) s
    where evaluated_aexpr = eval_aexpr aexpr s

overwrite_entry :: Entry -> State -> State
overwrite_entry (identifier,value) s
    | identifier_in_state identifier s = 
        assign_entry_in_state (identifier,value) s 
    | otherwise = 
        add_entry_to_state (identifier,value) s 

identifier_in_state :: String -> State -> Bool
identifier_in_state identifier (Def [])  = False
identifier_in_state identifier (Def ((first_identifier,first_value):entries)) = 
    (first_identifier == identifier) || identifier_in_state identifier (state entries)
    
add_entry_to_state :: Entry -> State -> State
add_entry_to_state entry (Def entries) = (state (entry:entries)) 

assign_entry_in_state :: Entry -> State -> State
assign_entry_in_state (identifier,value) (Def entries) =
    state [ update_entry entry | entry <- entries]
    where update_entry (id,v) = if id == identifier then (identifier,value) else (id,v)