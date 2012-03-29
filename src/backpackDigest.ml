include Digest

external crc32_update : int32 -> string -> int32 = "caml_backpack_crc32"

let crc32 buf = crc32_update Int32.zero buf

type sha256_ctx

external sha256 : string -> string = "caml_backpack_sha256"

external sha256_init : unit -> sha256_ctx = "caml_backpack_sha256_init"

external sha256_update : sha256_ctx -> string -> unit = "caml_backpack_sha256_update"

external sha256_final : sha256_ctx -> string = "caml_backpack_sha256_final"
