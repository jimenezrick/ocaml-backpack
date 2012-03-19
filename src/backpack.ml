(*
 * My personal OCaml backpack
 *
 * I never leave home without it!
 *)

module StringMap = Map.Make (String)

module IntMap = Map.Make (struct type t = int let compare = compare end)

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

        (* Function composition operator *)
        let ( |. ) f g = fun x -> f (g x)

        (* Reduce function application precedence operator *)
        let ( $ ) f x = f x

        (* Reverse function application operator *)
        let ( |< ) x f = f x
    end

module Str =
    struct
        let explode s =
            let rec explode' i l =
                if i < 0 then l else explode' (i - 1) (s.[i] :: l)
            in explode' (String.length s - 1) []

        let implode l =
            let res = String.create (List.length l) in
            let rec implode' i = function
                | [] -> res
                | c :: l -> res.[i] <- c; implode' (i + 1) l
            in implode' 0 l
    end

module InfiniteList =
    struct
        type 'a t =
            | Nil
            | Cons of 'a * (unit -> 'a t)

        let head = function
            | Nil         -> None
            | Cons (x, _) -> Some x

        let tail = function
            | Nil         -> None
            | Cons (_, f) -> Some (f ())

        let rec range n0 inc = Cons (n0, fun () -> range (n0 + inc) inc)

        let range0 inc = range 0 inc

        let range_naturals = range0 1
    end

module LazyList =
    struct
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
    end
