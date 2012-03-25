include Unix

module Epoll =
    struct
        type epoll_descr = file_descr

        type event =
            | EPOLLIN
            | EPOLLOUT
            | EPOLLRDHUP
            | EPOLLPRI
            | EPOLLERR
            | EPOLLHUP
            | EPOLLET
            | EPOLLONESHOT

        type operation =
            | EPOLL_CTL_ADD
            | EPOLL_CTL_MOD
            | EPOLL_CTL_DEL

        external create1 : bool -> epoll_descr = "caml_backpack_epoll_create1"

        let create () = create1 false

        external ctl : epoll_descr -> operation -> file_descr -> event list -> unit = "caml_backpack_epoll_ctl"

        let add epfd fd events = ctl epfd EPOLL_CTL_ADD fd events

        let modify epfd fd events = ctl epfd EPOLL_CTL_MOD fd events

        let del epfd fd = ctl epfd EPOLL_CTL_DEL fd []

        external wait : epoll_descr -> int -> int -> (event list * file_descr) list = "caml_backpack_epoll_wait"
    end

external asctime : tm -> string = "caml_backpack_asctime"

external sync : unit -> unit = "caml_backpack_sync"

external fsync : file_descr -> unit = "caml_backpack_fsync"

external fdatasync : file_descr -> unit = "caml_backpack_fdatasync"

external mkstemp : string -> string * file_descr = "caml_backpack_mkstemp"

external mkdtemp : string -> string = "caml_backpack_mkdtemp"

type flock_op =
    | LOCK_SH
    | LOCK_EX
    | LOCK_NB
    | LOCK_UN

external flock : file_descr -> flock_op list -> unit = "caml_backpack_flock"

let is_regular path = (stat path).st_kind = S_REG

let is_directory path = (stat path).st_kind = S_DIR

let rec restart_on_EINTR f x =
    try f x
    with Unix_error (EINTR, _, _) -> restart_on_EINTR f x
