open Backpack

let print_term_size _ =
    let row, col = Unix.Terminal.term_size () in
    Unix.Terminal.cur_pos 1 1;
    Unix.Terminal.erase_screen Unix.Terminal.Erase_entire_screen;
    Printf.printf "Terminal size %dx%d%!" row col

let rec run () =
    let key = Unix.restart_on_EINTR Unix.Terminal.read_key () in
    Unix.Terminal.cur_pos 2 1;
    Unix.Terminal.erase_line Unix.Terminal.Erase_entire_line;
    Printf.printf "Read: %s (%d)%!" key (String.length key);
    Unix.Terminal.beep ();
    run ()

let () =
    Sys.set_signal Unix.Terminal.sigwinch (Sys.Signal_handle print_term_size);
    Unix.Terminal.noncanonical_mode ();
    print_term_size 0;
    run ()
