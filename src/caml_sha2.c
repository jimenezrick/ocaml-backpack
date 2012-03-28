#include "backpack.h"

#define SHA2_TYPES
#include "sha2.h"

CAMLprim value
caml_backpack_sha256(value val_buf)
{
	CAMLparam1(val_buf);
	CAMLlocal1(val_res);

	val_res = caml_alloc_string(32);
	sha256((unsigned char *) String_val(val_buf), caml_string_length(val_buf),
	       (unsigned char *) String_val(val_res));

	CAMLreturn(val_res);
}
