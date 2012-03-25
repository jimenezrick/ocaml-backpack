include Unix

let input_proc_int path =
    let chan = open_in path in
    let line = input_line chan in
    close_in chan;
    int_of_string line

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

        type flag = EPOLL_CLOEXEC

        external create1 : flag list -> epoll_descr = "caml_backpack_epoll_create1"

        let create () = create1 []

        external ctl : epoll_descr -> operation -> file_descr -> event list -> unit = "caml_backpack_epoll_ctl"

        let add epfd fd events = ctl epfd EPOLL_CTL_ADD fd events

        let modify epfd fd events = ctl epfd EPOLL_CTL_MOD fd events

        let del epfd fd = ctl epfd EPOLL_CTL_DEL fd []

        external wait : epoll_descr -> int -> int -> (event list * file_descr) list = "caml_backpack_epoll_wait"
    end

module Mqueue =
    struct
        type mqueue_descr = file_descr

        type flag =
            | O_RDONLY
            | O_WRONLY
            | O_RDWR
            | O_NONBLOCK
            | O_CREAT
            | O_EXCL

        type attributes = flag list * int * int * int

        type open_attrs =
            | Defs
            | Attrs of int * int

        let msg_max () = input_proc_int "/proc/sys/fs/mqueue/msg_max"

        let msgsize_max () = input_proc_int "/proc/sys/fs/mqueue/msgsize_max"

        let queues_max () = input_proc_int "/proc/sys/fs/mqueue/queues_max"

        external prio_max : unit -> int = "caml_backpack_mq_prio_max"

        external create_mq : string -> flag list -> file_perm -> open_attrs -> mqueue_descr = "caml_backpack_mq_open"

        let open_mq name flags = create_mq name flags 0 Defs

        external close : mqueue_descr -> unit = "caml_backpack_mq_close"

        external unlink : string -> unit = "caml_backpack_mq_unlink"

        external getattr : mqueue_descr -> attributes = "caml_backpack_mq_getattr"




        (*external set_nonblock : mqueue_descr -> unit*)






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
