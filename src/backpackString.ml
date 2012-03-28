include String

let lstrip chars s =
    match chars with
    | "" -> s
    | _ ->
            let regexp = Str.regexp ("^[" ^ Str.quote chars ^ "]*") in
            ignore (Str.search_forward regexp s 0);
            Str.string_after s (Str.match_end ())

let rstrip chars s =
    match chars with
    | "" -> s
    | _ ->
            let regexp = Str.regexp ("[" ^ Str.quote chars ^ "]*$") in
            ignore (Str.search_forward regexp s 0);
            Str.string_before s (Str.match_beginning ())

let strip chars s = lstrip chars (rstrip chars s)

let split seps s =
    let regexp = String.concat "\\|" (List.map (Str.quote) seps) in
    Str.split (Str.regexp regexp) s

let explode s =
    let rec explode' i l =
        if i < 0 then l else explode' (i - 1) (s.[i] :: l)
    in explode' (String.length s - 1) []

let implode l =
    let res = String.create (List.length l) in
    let rec implode' i = function
        | [] -> res
        | c :: l -> res.[i] <- c; implode' (i + 1) l
    in implode' 0 l

let map f s =
    let s' = String.copy s in
    for i = 0 to (String.length s' - 1)
    do
        s'.[i] <- f s.[i]
    done;
    s'
