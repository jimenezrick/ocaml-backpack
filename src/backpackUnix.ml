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

        external create1 : flag list -> epoll_descr =
            "caml_backpack_epoll_create1"

        let create () = create1 []

        external ctl : epoll_descr -> operation -> file_descr -> event list ->
            unit = "caml_backpack_epoll_ctl"

        let add epfd fd events = ctl epfd EPOLL_CTL_ADD fd events

        let modify epfd fd events = ctl epfd EPOLL_CTL_MOD fd events

        let del epfd fd = ctl epfd EPOLL_CTL_DEL fd []

        external wait : epoll_descr -> int -> int ->
            (event list * file_descr) list = "caml_backpack_epoll_wait"
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

        type attributes = {
            flags   : flag list;
            maxmsg  : int;
            msgsize : int;
            curmsgs : int
        }

        type mq_attrs = {
            maxmsg_attr  : int;
            msgsize_attr : int
        }

        type open_attrs =
            | Mq_defs
            | Mq_attrs of mq_attrs

        type priority = int

        let msg_max () = input_proc_int "/proc/sys/fs/mqueue/msg_max"

        let msgsize_max () = input_proc_int "/proc/sys/fs/mqueue/msgsize_max"

        let queues_max () = input_proc_int "/proc/sys/fs/mqueue/queues_max"

        external prio_max : unit -> priority = "caml_backpack_mq_prio_max"

        external create_mq : string -> flag list -> file_perm -> open_attrs ->
            mqueue_descr = "caml_backpack_mq_open"

        let open_mq name flags = create_mq name flags 0 Mq_defs

        external close : mqueue_descr -> unit = "caml_backpack_mq_close"

        external unlink : string -> unit = "caml_backpack_mq_unlink"

        external getattr : mqueue_descr -> attributes =
            "caml_backpack_mq_getattr"

        external setattr : mqueue_descr -> flag list -> unit =
            "caml_backpack_mq_setattr"

        let set_nonblock mqfd = setattr mqfd [O_NONBLOCK]

        let clear_nonblock mqfd = setattr mqfd []

        external send : mqueue_descr -> string -> int -> int -> priority ->
            unit = "caml_backpack_mq_send"

        external receive : mqueue_descr -> string -> int -> int ->
            int * priority = "caml_backpack_mq_receive"
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

external sendfile : file_descr -> file_descr -> int option -> int -> int =
    "caml_backpack_sendfile"

type splice_flag =
    | SPLICE_F_MOVE
    | SPLICE_F_NONBLOCK
    | SPLICE_F_MORE
    | SPLICE_F_GIFT

external splice : file_descr -> int option -> file_descr -> int option ->
    int -> splice_flag list -> int =
        "caml_backpack_splice_bytecode" "caml_backpack_splice_native"

type sysinfo = {
    uptime    : int;
    load1     : int;
    load5     : int;
    load15    : int;
    totalram  : int;
    freeram   : int;
    sharedram : int;
    bufferram : int;
    totalswap : int;
    freeswap  : int;
    procs     : int;
    totalhigh : int;
    freehigh  : int;
    mem_unit  : int;
}

external sysinfo : unit -> sysinfo = "caml_backpack_sysinfo"

type sysconf =
    | ARG_MAX
    | CHILD_MAX
    | HOST_NAME_MAX
    | LOGIN_NAME_MAX
    | CLK_TCK
    | OPEN_MAX
    | PAGESIZE
    | RE_DUP_MAX
    | STREAM_MAX
    | SYMLOOP_MAX
    | TTY_NAME_MAX
    | TZNAME_MAX
    | VERSION
    | LINE_MAX
    | PHYS_PAGES
    | AVPHYS_PAGES
    | NPROCESSORS_CONF
    | NPROCESSORS_ONLN

external sysconf : sysconf -> int64 = "caml_backpack_sysconf"

external ttyname : file_descr -> string = "caml_backpack_ttyname"

let is_regular path = (stat path).st_kind = S_REG

let is_directory path = (stat path).st_kind = S_DIR

let rec restart_on_EINTR f x =
    try f x
    with Unix_error (EINTR, _, _) -> restart_on_EINTR f x
