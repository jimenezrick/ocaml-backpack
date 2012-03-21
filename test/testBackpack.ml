open Backpack.Unix
open Backpack.OptionMonad
open Backpack.Op
open Backpack.Str
open Backpack.LazyList


(* Unix *)

let () =

    let fd = Unix.openfile "Makefile" [] 0 in
    fsync fd






(* OptionMonad *)

let () =
    let good x = Some x in
    let bad _  = None in
    begin
        assert (good 6 >>= good >>= good = Some 6);
        assert (good 6 >>= bad >>= good = None);
        assert (good 6 >>= good >> return 3 = Some 3);
        assert (good 6 >>= bad >> return 3 = None)
    end

(* Op *)

let () =
    let f x    = x + 1 in
    let g y    = y + 2 in
    let f' a b = a * b in
    let g' c   = c + 1 in
    begin
        assert ((f |. g) 8 = 11);
        assert (f' 2 $ g' 3 = 8);
        assert (1 |< f = 2)
    end

(* Str *)

let () =
    begin
        assert (explode "abc" = ['a'; 'b'; 'c']);
        assert (implode ['a'; 'b'; 'c'] = "abc")
    end

(* LazyList *)

let () =
    let l  = [1; 2; 3] in
    let l2 = ['1'; '2'; '3'] in
    begin
        assert (to_list (of_list l) = l);
        assert (to_list (of_string "123") = l2);
        assert (to_list (of_stream (Stream.of_list l)) = l)
    end

let () =
    let l   = [0; 1; 2] in
    let f n = if n < 3 then Some n else None
    in assert (to_list (from f) = l)

let () =
    let zl = lazy (Cons (1, lazy (Cons (2, nil)))) in
    let l  = [1; 2] in
    begin
        assert (to_list zl = l);
        assert (to_list (cons (hd zl) (tl zl)) = l)
    end

let () =
    let l      = [1; 2; 3] in
    let incr x = x + 1 in
    assert (to_list (map incr (of_list l)) = List.map incr l)

let () =
    let l    = [1; 2; 3] in
    let l2   = [2; 3] in
    let l3   = [1] in
    let zl   = of_list l in
    let p x  = x > 1 in
    let p' x = x = 3 in
    begin
        assert (to_list (filter p (of_list l)) = l2);
        assert (to_list (take 1 (of_list l)) = l3);
        assert (to_list (drop 1 (of_list l)) = l2);
        assert (iter ignore (of_list l) = ());
        assert (fold_left (+) 0 (of_list l) = 6);
        assert (fold_right (+) 0 (of_list l) = 6);
        assert (find p' (of_list l) = 3);
        assert (to_list (append (of_list l) (of_list l2)) = l @ l2);
        assert (to_list (concat (of_list [zl; zl])) = l @ l)
    end

let () =
    let f _ = failwith "This shouldn't be raised" in
    ignore $ from f

let () = print_endline "*** All tests passed ***"
