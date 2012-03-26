open Backpack

let copy src dest =
    let in_fd  = Unix.openfile src [Unix.O_RDONLY] 0 in
    let out_fd = Unix.openfile dest [Unix.O_CREAT; Unix.O_WRONLY] 0o666 in
    let buf    = String.create 8192 in
    let rec copy' buf in_fd out_fd =
        match Unix.read in_fd buf 0 8192 with
        | 0 -> ()
        | n ->
                ignore (Unix.write out_fd buf 0 n);
                copy' buf in_fd out_fd
    in copy' buf in_fd out_fd

let copy_sendfile src dest =
    let in_fd  = Unix.openfile src [Unix.O_RDONLY] 0 in
    let out_fd = Unix.openfile dest [Unix.O_CREAT; Unix.O_WRONLY] 0o666 in
    let rec copy pos in_fd out_fd =
        match Unix.sendfile out_fd in_fd pos 8192 with
        | 0 -> ()
        | n -> copy (pos + n) in_fd out_fd
    in copy 0 in_fd out_fd

let usage () = Printf.fprintf stderr "Usage: %s [-n] <src> <dest>\n" Sys.argv.(0)

let () =
    match Sys.argv with
    | [|_; "-n"; src; dest|] -> copy src dest
    | [|_; src; dest|]       -> copy_sendfile src dest
    | _                      -> usage ()
