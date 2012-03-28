#include "backpack.h"

CAMLprim value
caml_backpack_crc32(value val_crc, value val_buf)
{
	CAMLparam2(val_crc, val_buf);
	CAMLlocal1(val_res);

	val_res = caml_copy_int32(crc32(Int32_val(val_crc), String_val(val_buf),
					caml_string_length(val_buf)));

	CAMLreturn(val_res);
}
