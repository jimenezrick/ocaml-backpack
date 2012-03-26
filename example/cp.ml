open Backpack

let copy src dest =
    let in_fd  = Unix.openfile src [Unix.O_RDONLY] 0 in
    let out_fd = Unix.openfile dest [Unix.O_CREAT; Unix.O_WRONLY] 0o666 in
    let buf    = String.create 8192 in
    let rec copy () =
        match Unix.read in_fd buf 0 8192 with
        | 0 -> ()
        | n ->
                ignore (Unix.write out_fd buf 0 n);
                copy ()
    in copy ()

let copy_sendfile src dest =
    let in_fd  = Unix.openfile src [Unix.O_RDONLY] 0 in
    let out_fd = Unix.openfile dest [Unix.O_CREAT; Unix.O_WRONLY] 0o666 in
    let rec copy () =
        match Unix.sendfile out_fd in_fd None 8192 with
        | 0 -> ()
        | n -> copy ()
    in copy ()

let copy_splice src dest =
    let in_fd        = Unix.openfile src [Unix.O_RDONLY] 0 in
    let out_fd       = Unix.openfile dest [Unix.O_CREAT; Unix.O_WRONLY] 0o666 in
    let pr_fd, pw_fd = Unix.pipe () in
    let flags        = [Unix.SPLICE_F_MOVE; Unix.SPLICE_F_MORE] in
    let rec copy () =
        match Unix.splice in_fd None pw_fd None 8192 flags with
        | 0 -> ()
        | n ->
                ignore (Unix.splice pr_fd None out_fd None n flags);
                copy ()
    in copy ()

let usage () = Printf.fprintf stderr "Usage: %s [-sendfile|-splice] <src> <dest>\n" Sys.argv.(0)

let () =
    match Sys.argv with
    | [|_; src; dest|]              -> copy src dest
    | [|_; "-sendfile"; src; dest|] -> copy_sendfile src dest
    | [|_; "-splice"; src; dest|]   -> copy_splice src dest
    | _                             -> usage ()
