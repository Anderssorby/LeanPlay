import Leanpkg

#eval Leanpkg.leanVersionString


/- Declare some constants. -/

constant m  : Nat   -- m is a natural number
constant n  : Nat
constant b1 : Bool  -- b1 is a Boolean
constant b2 : Bool

/- Check their types. -/

#check m            -- output: Nat
#check n
#check n + 0        -- Nat
#check m * (n + 0)  -- Nat
#check b1           -- Bool
#check b1 && b2     -- "&&" is the Boolean and
#check b1 || b2     -- Boolean or
#check true         -- Boolean "true"
