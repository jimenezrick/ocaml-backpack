open Backpack

let () =
    let f a b = a * b in
    let g c   = c + 1 in
    assert (f 2 $ g 3 = 8)

let () = print_endline "*** All tests passed ***"
