open Backpack

let print_term_size _ =
    let row, col = Unix.Terminal.term_size () in
    Unix.Terminal.erase_screen Unix.Terminal.Erase_entire_screen;
    Unix.Terminal.cur_pos 1 1;
    Printf.printf "Terminal size %dx%d%!" row col

let rec run () =
    Unix.pause ();
    run ()

let () =
    Sys.set_signal Unix.Terminal.sigwinch (Sys.Signal_handle print_term_size);
    print_term_size 0;
    run ()
