module List = BackpackList

type 'a digit =
    | One of 'a
    | Two of 'a * 'a
    | Three of 'a * 'a * 'a
    | Four of 'a * 'a * 'a * 'a

type 'a node =
    | Node2 of 'a * 'a
    | Node3 of 'a * 'a * 'a

type 'a t =
    | Empty
    | Single of 'a
    | Deep of 'a digit * 'a node t * 'a digit

let cons_digit x = function
    | One y           -> Two (x, y)
    | Two (y, z)      -> Three (x, y, z)
    | Three (y, z, w) -> Four (x, y, z, w)
    | Four _          -> failwith "cons_digit"

let snoc_digit x = function
    | One y           -> Two (y, x)
    | Two (z, y)      -> Three (z, y, x)
    | Three (w, z, y) -> Four (w, z, y, x)
    | Four _          -> failwith "snoc_digit"

let head_digit = function
    | One x             -> x
    | Two (x, _)        -> x
    | Three (x, _, _)   -> x
    | Four (x, _, _, _) -> x

let daeh_digit = function
    | One x             -> x
    | Two (_, x)        -> x
    | Three (_, _, x)   -> x
    | Four (_, _, _, x) -> x

let tail_digit = function
    | One _             -> None
    | Two (_, y)        -> Some (One y)
    | Three (_, y, z)   -> Some (Two (y, z))
    | Four (_, y, z, w) -> Some (Three (y, z, w))

let empty = Empty

let is_empty = function
    | Empty -> true
    | _     -> false

let rec cons : 'a. 'a -> 'a t -> 'a t =
    fun x ftree ->
        match ftree with
        | Empty                -> Single x
        | Single y             -> Deep (One x, Empty, One y)
        | Deep (Four (y, z, w, u), mid, suf) ->
                let mid' = cons (Node3 (z, w, u)) mid in
                Deep (Two (x, y), mid', suf)
        | Deep (pre, mid, suf) -> Deep (cons_digit x pre, mid, suf)

let rec snoc : 'a. 'a -> 'a t -> 'a t =
    fun x ftree ->
        match ftree with
        | Empty                -> Single x
        | Single y             -> Deep (One y, Empty, One x)
        | Deep (pre, mid, Four (u, w, z, y)) ->
                let mid' = snoc (Node3 (u, w, z)) mid in
                Deep (pre, mid', Two (y, x))
        | Deep (pre, mid, suf) -> Deep (pre, mid, snoc_digit x suf)

let foldl_digit f acc = function
    | One x             -> f acc x
    | Two (x, y)        -> f (f acc x) y
    | Three (x, y, z)   -> f (f (f acc x) y) z
    | Four (x, y, z, w) -> f (f (f (f acc x) y) z) w

let foldr_digit f acc = function
    | One x             -> f x acc
    | Two (x, y)        -> f x (f y acc)
    | Three (x, y, z)   -> f x (f y (f z acc))
    | Four (x, y, z, w) -> f x (f y (f z (f w acc)))

let foldl_node f acc = function
    | Node2 (x, y)    -> f (f acc x) y
    | Node3 (x, y, z) -> f (f (f acc x) y) z

let foldr_node f acc = function
    | Node2 (x, y)    -> f x (f y acc)
    | Node3 (x, y, z) -> f x (f y (f z acc))

let rec foldl : 'a. ('acc -> 'a -> 'acc) -> 'acc -> 'a t -> 'acc =
    fun f acc -> function
        | Empty                -> acc
        | Single x             -> f acc x
        | Deep (pre, mid, suf) ->
                let acc = foldl_digit f acc suf in
                let acc = foldl (fun acc elem -> foldl_node f acc elem) acc mid in
                let acc = foldl_digit f acc pre in
                acc

let rec foldr : 'a. ('a -> 'acc -> 'acc) -> 'acc -> 'a t -> 'acc =
    fun f acc -> function
        | Empty                -> acc
        | Single x             -> f x acc
        | Deep (pre, mid, suf) ->
                let acc = foldr_digit f acc suf in
                let acc = foldr (fun elem acc -> foldr_node f acc elem) acc mid in
                let acc = foldr_digit f acc pre in
                acc

let of_digit = function
    | One x             -> Single x
    | Two (x, y)        -> Deep (One x, Empty, One y)
    | Three (x, y, z)   -> Deep (Two (x, y), Empty, One z)
    | Four (x, y, z, w) -> Deep (Two (x, y), Empty, Two (z, w))

let digit_of_node = function
    | Node2 (x, y)    -> Two (x, y)
    | Node3 (x, y, z) -> Three (x, y, z)

let of_list l = List.fold_right cons l Empty

let to_list ftree = foldr List.cons [] ftree

type ('h, 't) viewl =
    | Nill
    | Consl of 'h * 't

let rec viewl : 'a. 'a t -> ('a, 'a t) viewl = function
    | Empty                -> Nill
    | Single x             -> Consl (x, Empty)
    | Deep (pre, mid, suf) -> Consl (head_digit pre, deepl (tail_digit pre) mid suf)
and deepl : 'a. 'a digit option -> 'a node t -> 'a digit -> 'a t =
    fun pre mid suf ->
        match pre with
        | None -> (
            match viewl mid with
            | Nill            -> of_digit suf
            | Consl (x, mid') -> Deep (digit_of_node x, mid', suf)
        )
        | Some pre' -> Deep (pre', mid, suf)

let head = function
    | Empty            -> failwith "head"
    | Single x         -> x
    | Deep (pre, _, _) -> head_digit pre

let daeh = function
    | Empty            -> failwith "head"
    | Single x         -> x
    | Deep (_, _, suf) -> daeh_digit suf

let tail ftree =
    match viewl ftree with
    | Nill              -> failwith "tail"
    | Consl (_, ftree') -> ftree'




(* TODO: liat *)

(* XXX: Hacer test a todo y meter en los tests *)
let () =
    let ft = of_list [1; 2; 3] in
    let ft = snoc 4 ft in
    assert (to_list ft = [1; 2; 3; 4])
