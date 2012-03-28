open Backpack
open Backpack.OptionMonad
open Backpack.Op
open Backpack.LazyList

(* Unix *)

let () =
    let epfd = Unix.Epoll.create1 [Unix.Epoll.EPOLL_CLOEXEC] in
    assert (Unix.Epoll.wait epfd 10 0 = []);
    let r_fd, w_fd = Unix.pipe () in
    Unix.Epoll.add epfd r_fd [Unix.Epoll.EPOLLIN];
    Unix.Epoll.add epfd w_fd [Unix.Epoll.EPOLLOUT];
    assert (Unix.Epoll.wait epfd 10 0 = [([Unix.Epoll.EPOLLOUT], w_fd)]);
    assert (Unix.Epoll.wait epfd 10 0 = [([Unix.Epoll.EPOLLOUT], w_fd)]);
    Unix.Epoll.del epfd w_fd;
    assert (Unix.Epoll.wait epfd 10 0 = []);
    assert (Unix.write w_fd "x" 0 1 = 1);
    assert (Unix.Epoll.wait epfd 10 0 = [([Unix.Epoll.EPOLLIN], r_fd)]);
    assert (Unix.Epoll.wait epfd 10 0 = [([Unix.Epoll.EPOLLIN], r_fd)]);
    let buf = String.create 1 in
    assert (Unix.read r_fd buf 0 1 = 1);
    assert (Unix.Epoll.wait epfd 10 0 = []);
    Unix.close r_fd;
    Unix.close w_fd;
    Unix.close epfd;
    Gc.full_major ()

let () =
    assert (Unix.Mqueue.msg_max () > 0);
    assert (Unix.Mqueue.msgsize_max () > 0);
    assert (Unix.Mqueue.queues_max () > 0);
    assert (Unix.Mqueue.prio_max () >= 32);
    Gc.full_major ()

let () =
    let open Unix.Mqueue in
    let mq   = Unix.Mqueue.create_mq "/foo" [O_CREAT; O_RDWR] 0o666 Mq_defs in
    let mq'  = Unix.Mqueue.open_mq "/foo" [Unix.Mqueue.O_RDONLY] in
    let attr = Unix.Mqueue.getattr mq in
    assert (attr.flags = []);
    assert (attr.maxmsg = Unix.Mqueue.msg_max ());
    assert (attr.msgsize = Unix.Mqueue.msgsize_max ());
    assert (attr.curmsgs = 0);
    Unix.Mqueue.close mq';
    Unix.Mqueue.close mq;
    Unix.Mqueue.unlink "/foo";
    Gc.full_major ()

let () =
    let open Unix.Mqueue in
    let attr = {maxmsg_attr = 10; msgsize_attr = 100} in
    let mq   = Unix.Mqueue.create_mq "/foo" [O_CREAT; O_RDWR] 0o666 (Mq_attrs attr) in
    let mq'  = Unix.Mqueue.open_mq "/foo" [Unix.Mqueue.O_RDONLY] in
    let attr = Unix.Mqueue.getattr mq in
    assert (attr.flags = []);
    assert (attr.maxmsg = 10);
    assert (attr.msgsize = 100);
    assert (attr.curmsgs = 0);
    Unix.Mqueue.close mq';
    Unix.Mqueue.close mq;
    Unix.Mqueue.unlink "/foo";
    Gc.full_major ()

let () =
    let date = Unix.asctime (Unix.localtime (Unix.time ())) in
    assert (date.[20] = '1' || date.[20] = '2');
    Gc.full_major ()

let () =
    Unix.sync ();
    Gc.full_major ()

let () =
    let fd = Unix.openfile "Makefile" [Unix.O_RDONLY] 0 in
    Unix.fsync fd;
    Unix.close fd;
    try
        Unix.fsync fd;
        assert false
    with Unix.Unix_error (Unix.EBADF, _, _) -> ();
    Gc.full_major ()

let () =
    let fd = Unix.openfile "Makefile" [Unix.O_RDONLY] 0 in
    Unix.fdatasync fd;
    Unix.close fd;
    try
        Unix.fdatasync fd;
        assert false
    with Unix.Unix_error (Unix.EBADF, _, _) -> ();
    Gc.full_major ()

let () =
    let name, fd = Unix.mkstemp "foo" in
    Unix.close fd;
    Unix.unlink name;
    Gc.full_major ()

let () =
    let name = Unix.mkdtemp "bar" in
    Unix.rmdir name;
    Gc.full_major ()

let () =
    let fd  = Unix.openfile "Makefile" [Unix.O_RDONLY] 0 in
    let fd' = Unix.openfile "Makefile" [Unix.O_RDONLY] 0 in
    Unix.flock fd [Unix.LOCK_EX; Unix.LOCK_NB];
    try
        Unix.flock fd' [Unix.LOCK_EX; Unix.LOCK_NB];
        assert false
    with
    | Unix.Unix_error (Unix.EAGAIN, _, _)      -> Unix.close fd';
    | Unix.Unix_error (Unix.EWOULDBLOCK, _, _) -> Unix.close fd';
    Unix.flock fd [Unix.LOCK_UN];
    Unix.close fd;
    try
        Unix.flock fd [Unix.LOCK_EX];
        assert false
    with Unix.Unix_error (Unix.EBADF, _, _) -> ();
    Gc.full_major ()

let () =
    let info = Unix.sysinfo () in
    assert (info.Unix.mem_unit = 1);
    Gc.full_major ()

let () =
    assert (Unix.sysconf Unix.PAGESIZE >= Int64.of_int 4096);
    Gc.full_major ()

let () =
    match String.split ["/"] (Unix.ttyname Unix.stdin) with
    | "dev" :: _ -> Gc.full_major ()
    | _          -> assert false

let () =
    assert (Unix.is_regular "Makefile");
    assert (Unix.is_directory "src");
    Gc.full_major ()

(* Unix.Terminal *)

let () =
    let row, col = Unix.Terminal.term_size () in
    assert (row >= 1 && col >= 1);
    Gc.full_major ()

let () =
    Unix.Terminal.canonical_mode ();
    Unix.Terminal.raw_mode ();
    Unix.Terminal.canonical_mode ();
    Gc.full_major ()

(* StringMap *)

let () =
    let map  = StringMap.empty in
    let map' = StringMap.add "foo" "bar" map in
    assert (StringMap.find "foo" map' = "bar")

(* Pretty *)

let () =
    let s = String.create 3 in
    s.[0] <- char_of_int   1;
    s.[1] <- char_of_int  10;
    s.[2] <- char_of_int 255;
    assert (Pretty.hex_of_string s = "010aff")

let () =
    assert (Pretty.string_of_tuple2 string_of_int string_of_int (1, 2) = "(1, 2)");
    assert (Pretty.string_of_list string_of_int [1; 2; 3] = "[1; 2; 3]");
    assert (Pretty.string_of_array string_of_int [|1; 2; 3|] = "[|1; 2; 3|]")

(* Digest *)

let () =
    let s1 = "123" in
    let s2 = "456" in
    let s3 = s1 ^ s2 in
    assert (Digest.crc32 s1 = Int64.to_int32 2286445522L);
    assert (Digest.crc32 s2 = Int64.to_int32 2980627313L);
    assert (Digest.crc32 s3 = Int64.to_int32 158520161L);
    assert (Digest.crc32_update (Digest.crc32 s1) s2 = Digest.crc32 s3);
    Gc.full_major ()

let () =
    let h  = Digest.sha256 "123" in
    let h' = "a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3" in
    assert (Pretty.hex_of_string h = h');
    Gc.full_major ()

(* IntMap *)

let () =
    let map  = IntMap.empty in
    let map' = IntMap.add 123 666 map in
    assert (IntMap.find 123 map' = 666)

(* OptionMonad *)

let () =
    let good x = Some x in
    let bad _  = None in
    begin
        assert (good 6 >>= good >>= good = Some 6);
        assert (good 6 >>= bad >>= good = None);
        assert (good 6 >>= good >> return 3 = Some 3);
        assert (good 6 >>= bad >> return 3 = None)
    end

(* Op *)

let () =
    let f x    = x + 1 in
    let g y    = y + 2 in
    let f' a b = a * b in
    let g' c   = c + 1 in
    begin
        assert ((f |. g) 8 = 11);
        assert (f' 2 @@ g' 3 = 8);
        assert (1 |> f = 2)
    end

(* String *)

let () =
    begin
        assert (String.lstrip "" ",.foo+bar" = ",.foo+bar");
        assert (String.lstrip "2" ",.foo2bar" = ",.foo2bar");
        assert (String.lstrip ".,+" ",.foo+bar" = "foo+bar");
        assert (String.lstrip ".,+" ",." = "");
        assert (String.lstrip ".,+" "" = "")
    end

let () =
    begin
        assert (String.rstrip "" "foo+bar,." = "foo+bar,.");
        assert (String.rstrip "2" ",.foo2bar" = ",.foo2bar");
        assert (String.rstrip ".,+" ",.foo+bar,." = ",.foo+bar");
        assert (String.rstrip ".,+" ",." = "");
        assert (String.rstrip ".,+" "" = "")
    end

let () =
    begin
        assert (String.strip "" "" = "");
        assert (String.strip "" "foo" = "foo");
        assert (String.strip ".," ",foo.bar.," = "foo.bar")
    end

let () =
    begin
        assert (String.split [] "foo" = ["f"; "o"; "o"]);
        assert (String.split ["x"] ",foo,bar," = [",foo,bar,"]);
        assert (String.split [","] ",foo,bar," = ["foo"; "bar"]);
        assert (String.split ["::"] "::foo::bar::" = ["foo"; "bar"]);
        assert (String.split ["::"; ","] "::foo::bar,fu" = ["foo"; "bar"; "fu"])
    end

let () =
    begin
        assert (String.explode "abc" = ['a'; 'b'; 'c']);
        assert (String.implode ['a'; 'b'; 'c'] = "abc")
    end

let () =
    let ( + ) a b = char_of_int (int_of_char a + int_of_char b) in
    let s         = "123" in
    let s'        = String.map ((+) (char_of_int 1)) s in
    assert (s  = "123");
    assert (s' = "234");
    assert (s != s')

(* List *)

let () =
    let l = [1; 2; 3; 4; 3; 5] in
    assert (List.remove 6 [] = []);
    assert (List.remove 3 l = [1; 2; 4; 3; 5]);
    assert (List.remove 6 l = l)

(* LazyList *)

let () =
    let l  = [1; 2; 3] in
    let l2 = ['1'; '2'; '3'] in
    begin
        assert (to_list (of_list l) = l);
        assert (to_list (of_string "123") = l2);
        assert (to_list (of_stream (Stream.of_list l)) = l)
    end

let () =
    let l   = [0; 1; 2] in
    let f n = if n < 3 then Some n else None
    in assert (to_list (from f) = l)

let () =
    let zl = lazy (Cons (1, lazy (Cons (2, nil)))) in
    let l  = [1; 2] in
    begin
        assert (to_list zl = l);
        assert (to_list (cons (hd zl) (tl zl)) = l)
    end

let () =
    let l      = [1; 2; 3] in
    let incr x = x + 1 in
    assert (to_list (map incr (of_list l)) = List.map incr l)

let () =
    let l    = [1; 2; 3] in
    let l2   = [2; 3] in
    let l3   = [1] in
    let zl   = of_list l in
    let p x  = x > 1 in
    let p' x = x = 3 in
    begin
        assert (to_list (filter p (of_list l)) = l2);
        assert (to_list (take 1 (of_list l)) = l3);
        assert (to_list (drop 1 (of_list l)) = l2);
        assert (iter ignore (of_list l) = ());
        assert (fold_left (+) 0 (of_list l) = 6);
        assert (fold_right (+) 0 (of_list l) = 6);
        assert (find p' (of_list l) = 3);
        assert (to_list (append (of_list l) (of_list l2)) = l @ l2);
        assert (to_list (concat (of_list [zl; zl])) = l @ l)
    end

let () =
    let f _ = failwith "This shouldn't be raised" in
    ignore @@ from f

let () = print_endline "*** All tests passed ***"
