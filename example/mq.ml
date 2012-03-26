open Backpack

type msg = Msg of int

let send mq n =
    let s = Marshal.to_string (Msg n) [] in
    Unix.Mqueue.send mq s 0 (String.length s) 6

let recv mq =
    let s     = String.create (Unix.Mqueue.msgsize_max ()) in
    ignore (Unix.Mqueue.receive mq s 0 (String.length s));
    let Msg n = Marshal.from_string s 0 in
    n

let create name =
    let open Unix.Mqueue in
    create_mq name [O_CREAT; O_RDWR] 0o666 Mq_defs

let send_loop () =
    let mq = create "/foo" in
    let rec f mq n =
        send mq n;
        Printf.printf "Msg sent %d\n%!" n;
        f mq (n + 1)
    in f mq 0

let recv_loop () =
    let mq = create "/foo" in
    let rec f mq =
        let n = recv mq in
        Printf.printf "Msg received %d\n%!" n;
        Unix.sleep 1;
        f mq
    in f mq

let usage () = Printf.fprintf stderr "Usage: %s -send|-recv\n" Sys.argv.(0)

let () =
    match Sys.argv with
    | [|_; "-send"|] -> send_loop ()
    | [|_; "-recv"|] -> recv_loop ()
    | _              -> usage ()
