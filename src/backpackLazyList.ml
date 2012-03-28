type 'a node =
    | Nil
    | Cons of 'a * 'a t
and 'a t = 'a node Lazy.t

let force = Lazy.force

let nil = Lazy.lazy_from_val Nil

let cons h t = Lazy.lazy_from_val (Cons (h, t))

let hd l =
    match force l with
    | Nil         -> failwith "Empty lazy list"
    | Cons (h, _) -> h

let tl l =
    match force l with
    | Nil         -> failwith "Empty lazy list"
    | Cons (_, t) -> t

let next l =
    match force l with
    | Nil         -> failwith "Empty lazy list"
    | Cons (h, t) -> (h, t)

let is_empty l =
    match force l with
    | Nil -> true
    | _   -> false

let rec map f l = lazy (
    match force l with
        | Nil         -> Nil
        | Cons (h, t) -> Cons (f h, map f t)
)

let rec filter p l =
    match force l with
    | Nil         -> nil
    | Cons (h, t) ->
            if p h then cons h t
            else filter p t

let rec take n l = lazy (
    match n, force l with
    | _, Nil | 0, _  -> Nil
    | n, Cons (h, t) -> Cons (h, (take (n - 1) t))
)

let rec drop n l =
    match n, force l with
    | _, Nil         -> nil
    | 0, _           -> l
    | n, Cons (h, t) -> drop (n - 1) t

let rec iter f l =
    match force l with
    | Nil         -> ()
    | Cons (h, t) -> (f h; iter f t)

let fold_left f init l =
    let rec aux acc rest =
        match force rest with
        | Nil         -> acc
        | Cons (h, t) -> aux (f acc h) t
    in aux init l

let fold_right f init l =
    let rec aux rest =
        match force rest with
        | Nil         -> init
        | Cons (h, t) -> f h (aux t)
    in aux l

let rec find p l =
    match force l with
    | Nil         -> raise Not_found
    | Cons (h, t) -> if p h then h else find p t

let rec append l1 l2 =
    match force l1 with
    | Nil         -> l2
    | Cons (h, t) -> cons h (append t l2)

let rec concat ll =
    match force ll with
    | Nil          -> nil
    | Cons (l, ls) -> append l (concat ls)

let to_list l = fold_right (fun h acc -> h :: acc) [] l

let from f =
    let rec next n =
        match f n with
        | None   -> Nil
        | Some x -> Cons (x, lazy (next (n + 1)))
    in lazy (next 0)

let rec of_list l = lazy (
    match l with
    | []      -> Nil
    | x :: xs -> Cons (x, of_list xs)
)

let of_string s =
    let rec next n =
        try Cons (s.[n], lazy (next (n + 1))) with
        | Invalid_argument _ -> Nil
    in lazy (next 0)

let rec of_stream s = lazy (
    try Cons (Stream.next s, of_stream s) with
    | Stream.Failure -> Nil
)

let of_channel c = of_stream (Stream.of_channel c)
