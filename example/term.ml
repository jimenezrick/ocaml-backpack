open Backpack

let print_term_size _ =
    let row, col = Unix.Terminal.term_size () in
    Unix.Terminal.cur_pos 1 1;
    Unix.Terminal.erase_screen Unix.Terminal.Erase_entire_screen;
    Printf.printf "Terminal size: %dx%d%!" row col

let string_of_key = function
    | Unix.Terminal.Eot            -> "Eot"
    | Unix.Terminal.Bs             -> "Bs"
    | Unix.Terminal.Del     -> "Del"
    | Unix.Terminal.Esc            -> "Esc"
    | Unix.Terminal.Enter          -> "Enter"
    | Unix.Terminal.Up       -> "Up"
    | Unix.Terminal.Down     -> "Down"
    | Unix.Terminal.Forward  -> "Forward"
    | Unix.Terminal.Backward -> "Backward"
    | Unix.Terminal.Pg_up    -> "Pg_up"
    | Unix.Terminal.Pg_down  -> "Pg_down"

    | Unix.Terminal.Home           -> "Home"
    | Unix.Terminal.End            -> "End"

    | Unix.Terminal.Fn 6     -> "Fun 6"
    | Unix.Terminal.Fn 7     -> "Fun 7"
    | Unix.Terminal.Fn _     -> "Fn X"

    | Unix.Terminal.Char 'q'       -> exit 0
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
    at_exit Unix.Terminal.canonical_mode;
    Unix.Terminal.raw_mode ();
    Sys.set_signal Unix.Terminal.sigwinch (Sys.Signal_handle print_term_size);
    print_term_size 0;
    run ()
