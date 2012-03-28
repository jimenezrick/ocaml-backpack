include Digest

external crc32_update : int32 -> string -> int32 = "caml_backpack_crc32"

let crc32 buf = crc32_update Int32.zero buf

external sha256 : string -> string = "caml_backpack_sha256"
