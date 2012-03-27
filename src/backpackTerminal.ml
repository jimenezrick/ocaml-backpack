type key =
    | Eot
    | Bs
    | Esc
    | Enter
    | Arrow_up
    | Arrow_down
    | Arrow_forward
    | Arrow_backward
    | Home
    | End
    | Char of char

let sigwinch = 28

let esc = '\x1B'

let csi = String.make 1 esc ^ "["

let flush () = flush stdout; Unix.tcdrain Unix.stdout

let beep () = print_string "\x07"; flush ()

let normal_term =
    try Some (Unix.tcgetattr Unix.stdin) with
    | Unix.Unix_error (Unix.ENOTTY, _, _) -> None
    | Unix.Unix_error (Unix.EBADF, _, _)  -> None

let canonical_mode () =
    match normal_term with
    | None      -> failwith "Not in a tty"
    | Some term -> Unix.tcsetattr Unix.stdin Unix.TCSADRAIN term

let raw_mode () =
    let open Unix in
    match normal_term with
    | None      -> failwith "Not in a tty"
    | Some term ->
            Unix.tcsetattr Unix.stdin Unix.TCSAFLUSH
            {term with
                c_icanon = false; c_isig = false; c_echo = false;
                c_brkint = false; c_icrnl = false; c_ignbrk = true; c_igncr = true;
                c_inlcr = false; c_inpck = true; c_istrip = true; c_ixon = false;
                c_parmrk = true; c_opost = false;
                c_vmin = 1; c_vtime = 0}

let enable_echo () =
    let term = Unix.tcgetattr Unix.stdin in
    Unix.tcsetattr Unix.stdin Unix.TCSADRAIN {term with Unix.c_echo = true}

let disable_echo () =
    let term = Unix.tcgetattr Unix.stdin in
    Unix.tcsetattr Unix.stdin Unix.TCSAFLUSH {term with Unix.c_echo = false}

let read_key () =
    let buf = String.create 1 in
    ignore (Unix.read Unix.stdin buf 0 1);
    match buf.[0] with
    | '\x04'         -> Eot
    | '\x7F'         -> Bs
    | '\x1B'         -> Esc
    | '\x0D'         -> Enter
    | c when c = esc ->
            let buf = String.create 2 in
            let n   = Unix.read Unix.stdin buf 0 2 in
            if n = 1 then failwith "Fuck!" (* XXX *)
            else
                begin
                    match buf.[0], buf.[1] with
                    | '[', 'A' -> Arrow_up
                    | '[', 'B' -> Arrow_down
                    | '[', 'C' -> Arrow_forward
                    | '[', 'D' -> Arrow_backward
                    | '[', 'H' -> Home
                    | '[', 'F' -> End
                    | _        -> failwith "Fuckme too!" (* XXX *)
                end
    | c -> Char c

external term_size : unit -> int * int = "caml_backpack_term_size"

let cur_up n = print_string (csi ^ string_of_int n ^ "A")

let cur_down n = print_string (csi ^ string_of_int n ^ "B")

let cur_forward n = print_string (csi ^ string_of_int n ^ "C")

let cur_backward n = print_string (csi ^ string_of_int n ^ "D")

let cur_next_line n = print_string (csi ^ string_of_int n ^ "E")

let cur_prev_line n = print_string (csi ^ string_of_int n ^ "F")

let cur_line n = print_string (csi ^ string_of_int n ^ "H")

let cur_col n = print_string (csi ^ string_of_int n ^ "G")

let cur_pos row col =
    print_string (csi ^ string_of_int row ^ ";" ^ string_of_int col ^ "H")

type screen_erase =
    | Erase_to_screen_end
    | Erase_from_screen_begin
    | Erase_entire_screen

let erase_screen how =
    let n =
        match how with
        | Erase_to_screen_end     -> 0
        | Erase_from_screen_begin -> 1
        | Erase_entire_screen     -> 2
    in print_string (csi ^ string_of_int n ^ "J")

type line_erase =
        | Erase_to_line_end
        | Erase_from_line_begin
        | Erase_entire_line

let erase_line how =
    let n =
        match how with
        | Erase_to_line_end     -> 0
        | Erase_from_line_begin -> 1
        | Erase_entire_line     -> 2
    in print_string (csi ^ string_of_int n ^ "K")

let scroll_up n = print_string (csi ^ string_of_int n ^ "S")

let scroll_down n = print_string (csi ^ string_of_int n ^ "T")

type color =
    | Black
    | Red
    | Green
    | Yellow
    | Blue
    | Magenta
    | Cyan
    | White

type text_attr =
    | Normal
    | Bold
    | Italic
    | Underline
    | Blink
    | Reverse
    | Bold_off
    | Italic_off
    | Underline_off
    | Blink_off
    | Reversed_off
    | Default_color
    | Default_background_color
    | Color of color
    | Color_background of color

let color_num = function
    | Black   -> (30, 40)
    | Red     -> (31, 41)
    | Green   -> (32, 42)
    | Yellow  -> (33, 43)
    | Blue    -> (34, 44)
    | Magenta -> (35, 45)
    | Cyan    -> (36, 46)
    | White   -> (37, 47)

let set_text_attrs attrs =
    let conv =
        function
            | Normal                   -> 0
            | Bold                     -> 1
            | Italic                   -> 3
            | Underline                -> 4
            | Blink                    -> 5
            | Reverse                  -> 7
            | Bold_off                 -> 22
            | Italic_off               -> 23
            | Underline_off            -> 24
            | Blink_off                -> 25
            | Reversed_off             -> 27
            | Default_color            -> 39
            | Default_background_color -> 49
            | Color c                  -> fst (color_num c)
            | Color_background c       -> snd (color_num c)
    in let map = List.map (fun x -> string_of_int (conv x)) in
    print_string (csi ^ String.concat ";" (map attrs) ^ "m")

let save_cur_pos () = print_string (csi ^ "s")

let restore_cur_pos () = print_string (csi ^ "u")

let hide_cur () = print_string (csi ^ "?25l")

let show_cur () = print_string (csi ^ "?25h")
