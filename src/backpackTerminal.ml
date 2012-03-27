type key =
    | Eot
    | Bs
    | Del
    | Esc
    | Enter
    | Up
    | Down
    | Forward
    | Backward
    | Pg_up
    | Pg_down
    | Home
    | End
    | Fn of int
    | Char of char
    | Unknown_seq

let sigwinch = 28

let esc = '\x1B'

let csi = String.make 1 esc ^ "["

let flush () = flush stdout; Unix.tcdrain Unix.stdout

let beep () = print_string "\x07"; flush ()

external term_size : unit -> int * int = "caml_backpack_term_size"

external canonical_mode : unit -> unit = "caml_backpack_canonical_mode"

external raw_mode : unit -> unit = "caml_backpack_raw_mode"

let enable_echo () =
    let term = Unix.tcgetattr Unix.stdin in
    Unix.tcsetattr Unix.stdin Unix.TCSADRAIN {term with Unix.c_echo = true}

let disable_echo () =
    let term = Unix.tcgetattr Unix.stdin in
    Unix.tcsetattr Unix.stdin Unix.TCSAFLUSH {term with Unix.c_echo = false}

let match_esc_seq3 buf =
    match buf.[1], buf.[2] with
    | '[', 'A' -> Up
    | '[', 'B' -> Down
    | '[', 'C' -> Forward
    | '[', 'D' -> Backward
    | _        -> Unknown_seq

let match_esc_seq4 buf =
    match buf.[1], buf.[2], buf.[3] with
    | '[', '3', '~' -> Del
    | '[', '5', '~' -> Pg_up
    | '[', '6', '~' -> Pg_down
    | '[', '7', '~' -> Home
    | '[', '8', '~' -> End
    | _             -> Unknown_seq

let match_esc_seq5 buf =
    match buf.[1], buf.[2], buf.[3], buf.[4] with
    | '[', '1', '1', '~' -> Fn  1
    | '[', '1', '2', '~' -> Fn  2
    | '[', '1', '3', '~' -> Fn  3
    | '[', '1', '4', '~' -> Fn  4
    | '[', '1', '5', '~' -> Fn  5
    | '[', '1', '7', '~' -> Fn  6
    | '[', '1', '8', '~' -> Fn  7
    | '[', '1', '9', '~' -> Fn  8
    | '[', '2', '0', '~' -> Fn  9
    | '[', '2', '1', '~' -> Fn 10
    | '[', '2', '3', '~' -> Fn 11
    | '[', '2', '4', '~' -> Fn 12
    | _                  -> Unknown_seq

let read_key () =
    let buf = String.create 5 in
    let len = Unix.read Unix.stdin buf 0 (String.length buf) in
    match buf.[0] with
    | '\x04'         -> Eot
    | '\x7F'         -> Bs
    | '\x0D'         -> Enter
    | c when c = esc ->
            begin
                match len with
                | 1 -> Esc
                | 3 -> match_esc_seq3 buf
                | 4 -> match_esc_seq4 buf
                | 5 -> match_esc_seq5 buf
                | _ -> Unknown_seq
            end
    | c -> Char c

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
