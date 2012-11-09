module Main where

main :: IO ()
main = print (root Z)

ack m n = case m of S m -> case n of S n -> ack m (ack (S m) n)
                                     Z   -> ack m (S Z)
                    Z   -> S n

root x = ack (S (S Z)) x

-- Optimal output:
--   root x = ackSSZ x
--   ackSSZ n = case n of S n -> ackSZ (ackSSZ n)
--                        Z   -> ackSZ (S Z)
--   ackSZ n = case n of S n -> ackZ (ackSZ n)
--                       Z   -> ackZ (S Z)
--   ackZ n = S n

-- Optimal output with some extra evaluation in ungeneralized branches:
--   root x = ackSSZ x
--   ackSSZ n = case n of S n -> ackSZ (ackSSZ n)
--                        Z   -> S (S (S Z))
--   ackSZ n = case n of S n -> ackZ (ackSZ n)
--                       Z   -> S (S Z)
--   ackZ n = S n

-- Supercompiler trace:
--   <ack (S (S Z)) n>
--   case n of Z   -> <ack (S Z) (S Z)>
--             S n -> <ack (S Z) (ack (S (S Z)) n)>
--   case n of Z   -> <ack Z (ack (S Z) Z)>
--             S n -> <case ack (S (S Z)) n of Z   -> ack Z (S Z)
--                                             S n -> ack Z (ack (S Z) n)>
--   case n of Z   -> S <ack (S Z) Z>
--             S n -> <case (case n of
--                             Z   -> ack (S Z) (S Z)
--                             S n -> ack (S Z) (ack (S (S Z)) n)) of
--                       Z   -> ack Z (S Z)
--                       S n -> ack Z (ack (S Z) n)>
--   case n of Z   -> S <ack Z (S Z)>
--             S n -> case n of
--                      Z   -> <case ack (S Z) (S Z) of
--                                Z   -> ack Z (S Z)
--                                S n -> ack Z (ack (S Z) n)>
--                      S n -> <case ack (S Z) (ack (S (S Z)) n)) of
--                                Z   -> ack Z (S Z)
--                                S n -> ack Z (ack (S Z) n)>
--   case n of Z   -> S (S (S Z))
--             S n -> case n of
--                      Z   -> <case ack Z (ack (S Z) Z) of
--                                Z   -> ack Z (S Z)
--                                S n -> ack Z (ack (S Z) n)>
--                      S n -> <case (case ack (S (S Z)) n) of
--                                      Z   -> ack Z (S Z)
--                                      S n -> ack Z (ack (S Z) n)) of
--                                Z   -> ack Z (S Z)
--                                S n -> ack Z (ack (S Z) n)>
--   case n of Z   -> S (S (S Z))
--             S n -> case n of
--                      Z   -> <ack Z (ack (S Z) (ack (S Z) Z))>
--                      S n -> <case (case ack (S (S Z)) n of -- Generalise? Two stack frames with same tag ==> whistle blows
--                                      Z   -> ack Z (S Z)
--                                      S n -> ack Z (ack (S Z) n)) of
--                                Z   -> ack Z (S Z)
--                                S n -> ack Z (ack (S Z) n)>


tests = [
    (root Z, S (S (S Z)))
  ]

data Nat = Z | S Nat
         deriving (Eq, Show)