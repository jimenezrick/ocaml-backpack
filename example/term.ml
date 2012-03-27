open Backpack

let print_term_size _ =
    let row, col = Unix.Terminal.term_size () in
    Unix.Terminal.cur_pos 1 1;
    Unix.Terminal.erase_screen Unix.Terminal.Erase_entire_screen;
    Printf.printf "Terminal size: %dx%d%!" row col

let string_of_key = function
    | Unix.Terminal.Eot            -> "Eot"
    | Unix.Terminal.Bs             -> "Bs"
    | Unix.Terminal.Esc            -> "Esc"
    | Unix.Terminal.Enter          -> "Enter"
    | Unix.Terminal.Arrow_up       -> "Arrow_up"
    | Unix.Terminal.Arrow_down     -> "Arrow_down"
    | Unix.Terminal.Arrow_forward  -> "Arrow_forward"
    | Unix.Terminal.Arrow_backward -> "Arrow_backward"
    | Unix.Terminal.Home           -> "Home"
    | Unix.Terminal.End            -> "End"
    | Unix.Terminal.Char c         -> String.make 1 c

let rec run () =
    let key = Unix.restart_on_EINTR Unix.Terminal.read_key () in
    Unix.Terminal.cur_pos 2 1;
    Unix.Terminal.erase_line Unix.Terminal.Erase_entire_line;
    begin
        match string_of_key key with
        | c when String.length c = 1 ->
                let n = int_of_char c.[0] in
                Printf.printf "Key: %s (%d)%!" c n
        | c ->
                Printf.printf "Key: %s%!" c
    end;
    Unix.Terminal.beep ();
    run ()

let () =
    Sys.set_signal Unix.Terminal.sigwinch (Sys.Signal_handle print_term_size);
    Unix.Terminal.raw_mode ();
    print_term_size 0;
    run ()
