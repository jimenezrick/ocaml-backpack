let hex_of_string s =
    let buf = Buffer.create 128 in
    for i = 0 to (String.length s - 1)
    do
        Buffer.add_string buf (Printf.sprintf "%02x" (int_of_char s.[i]))
    done;
    Buffer.contents buf

let string_of_tuple2 f g (x, y) =
    Printf.sprintf "(%s, %s)" (f x) (g y)

let string_of_tuple3 f g h (x, y, z) =
    Printf.sprintf "(%s, %s, %s)" (f x) (g y) (h z)

let string_of_list f l =
    Printf.sprintf "[%s]" (String.concat "; " (List.map f l))

let string_of_array f a =
    let buf = Buffer.create 128 in
    let len = Array.length a in
    Buffer.add_string buf "[|";
    Array.iteri (fun i e ->
        Buffer.add_string buf (f e);
        if i < len - 1 then
            Buffer.add_string buf "; "
    ) a;
    Buffer.add_string buf "|]";
    Buffer.contents buf
