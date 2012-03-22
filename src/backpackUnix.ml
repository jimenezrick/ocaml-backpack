include Unix

external asctime : Unix.tm -> string = "caml_backpack_asctime"

external fsync : Unix.file_descr -> unit = "caml_backpack_fsync"

external fdatasync : Unix.file_descr -> unit = "caml_backpack_fdatasync"
