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

let prepend_digit x = function
    | One y           -> Two (x, y)
    | Two (y, z)      -> Three (x, y, z)
    | Three (y, z, w) -> Four (x, y, z, w)
    | Four _          -> failwith "prepend_digit"

let append_digit x = function
    | One y           -> Two (y, x)
    | Two (z, y)      -> Three (z, y, x)
    | Three (w, z, y) -> Four (w, z, y, x)
    | Four _          -> failwith "append_digit"

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
        | Deep (pre, mid, suf) -> Deep (prepend_digit x pre, mid, suf)

let rec snoc : 'a. 'a -> 'a t -> 'a t =
    fun x ftree ->
        match ftree with
        | Empty                -> Single x
        | Single y             -> Deep (One y, Empty, One x)
        | Deep (pre, mid, Four (u, w, z, y)) ->
                let mid' = snoc (Node3 (u, w, z)) mid in
                Deep (pre, mid', Two (y, x))
        | Deep (pre, mid, suf) -> Deep (pre, mid, append_digit x suf)







(* TODO: head, daeh, tail, liat *)


let foldr_node f acc = function
    | Node2 (x, y)    -> f x (f y acc)
    | Node3 (x, y, z) -> f x (f y (f z acc))





let foldr_digit f acc = function
    | One x             -> f x acc
    | Two (x, y)        -> f x (f y acc)
    | Three (x, y, z)   -> f x (f y (f z acc))
    | Four (x, y, z, w) -> f x (f y (f z (f w acc)))





let rec foldr : 'acc 'a. ('a -> 'acc -> 'acc) -> 'acc -> 'a t -> 'acc =
    fun f acc -> function
        | Empty                -> acc
        | Single x             -> f x acc
        | Deep (pre, mid, suf) ->
                let acc = foldr_digit f acc suf in
                let acc = foldr (fun elem acc -> foldr_node f acc elem) acc mid in
                let acc = foldr_digit f acc pre in
                acc

let of_list l = List.fold_right cons l Empty

let to_list ftree = foldr List.cons [] ftree






let () =
    let ft = of_list [1; 2; 3] in
    let ft = snoc 4 ft in
    assert (to_list ft = [1; 2; 3; 4])
