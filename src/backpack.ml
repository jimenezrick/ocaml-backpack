let finally h f x =
    let r =
        try f x with
        | e -> h (); raise e
    in h (); r

module Int =
    struct
        type t = int

        let compare x y = if x < y then -1 else if x > y then 1 else 0
    end

module IntMap = Map.Make (Int)

module StringMap = Map.Make (String)

module IntSet = Set.Make (Int)

module StringSet = Set.Make (String)

module Pretty = BackpackPretty

module Digest = BackpackDigest

module Unix =
    struct
        include BackpackUnix

        module Terminal = BackpackTerminal
    end

module OptionMonad =
    struct
        let ( >>= ) o f =
            match o with
            | Some x -> f x
            | None   -> None

        let ( >> ) o o' = o >>= fun _ -> o'

        let return x = Some x

        let fail = failwith
    end

module Op =
    struct
        let id x = x

        let flip f x y = f y x

        let ( |. ) f g = fun x -> f (g x)

        let ( |.| ) f g = fun (x, y) -> (f x, g y)

        let ( |..| ) f g = fun x y -> (f x, g y)

        (* Reduce function application precedence operator *)
        let ( @@ ) f x = f x

        let ( |> ) x f = f x
    end

module Char =
    struct
        include Char

        let is_blank c = c = ' ' || c = '\t'

        let is_num c = c >= '0' && c <= '9'

        let is_alpha c = c >= 'a' && c <= 'z' || c >= 'A' && c <= 'Z'

        let is_alphanum c = is_alpha c || is_num c
    end

module String = BackpackString

module List = BackpackList

module LazyList = BackpackLazyList

module FingerTree = BackpackFingerTree
