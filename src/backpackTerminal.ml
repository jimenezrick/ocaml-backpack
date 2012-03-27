(* XXX XXX XXX XXX XXX XXX XXX XXX XXX *)
let rec read () =
    let buf = String.create 128 in
    let n   = Unix.read Unix.stdin buf 0 (String.length buf) in
    Printf.printf "read %d\n%!" n;
    read ()

let foooooooooooooo () =
    let tio  = Unix.tcgetattr Unix.stdin in
    Unix.tcsetattr Unix.stdin Unix.TCSANOW {tio with Unix.c_icanon = false; Unix.c_echo = false};
    read ()
(* XXX XXX XXX XXX XXX XXX XXX XXX XXX *)





(* XXX: read_key, leer varios caracteres *)
(* XXX: screen height and width *)
(* XXX: Abstraer y poder guardar secuencias sin hacer print_string *)
(* XXX: Disable canonical mode and echo, leer libro *)





let esc = "\x1B"

let csi = esc ^ "["

let flush () = flush stdout

let cursor_up n = print_string (csi ^ string_of_int n ^ "A")

let cursor_down n = print_string (csi ^ string_of_int n ^ "B")

let cursor_forward n = print_string (csi ^ string_of_int n ^ "C")

let cursor_backward n = print_string (csi ^ string_of_int n ^ "D")

let cursor_next_line n = print_string (csi ^ string_of_int n ^ "E")

let cursor_previous_line n = print_string (csi ^ string_of_int n ^ "F")

let cursor_line n = print_string (csi ^ string_of_int n ^ "H")

let cursor_column n = print_string (csi ^ string_of_int n ^ "G")

let cursor_position row col =
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

type text_attribute =
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

let set_text_attributes attrs =
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

let save_cursor_position () = print_string (csi ^ "s")

let restore_cursor_position () = print_string (csi ^ "u")

let hide_cursor () = print_string (csi ^ "?25l")

let show_cursor () = print_string (csi ^ "?25h")
