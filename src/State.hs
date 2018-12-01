module State
    (Entry,
     State(..),
     state,
     bottom,
     empty_state
    )
where

data State = Undef
           | Def [Entry]
           deriving (Show,Read)

type Entry = (String, Integer)

instance Eq State where
    (Def entries1) == (Def entries2) =
        entries1 `is_contained` entries2 && entries2 `is_contained` entries1
    Undef == Undef = True
    _ == _ = False

state :: [Entry] -> State
state entries = Def entries

is_contained :: [Entry] -> [Entry] -> Bool
is_contained [] _ = True
is_contained (first_entry:other_entries) entries2 =
    (entries2 `contains` first_entry) && (other_entries `is_contained` entries2)

contains :: [Entry] -> Entry -> Bool
contains []      entry = False
contains (first_entry:other_entries) entry =
    (first_entry == entry) || (other_entries `contains` entry)

bottom :: State -> State
bottom = \s -> Undef

empty_state :: State
empty_state = state []