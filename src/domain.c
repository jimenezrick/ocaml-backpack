#include <unistd.h>

#include "backpack.h"

CAMLprim value
caml_backpack_getdomainname(value val_unit)
{
	CAMLparam1(val_unit);
	CAMLlocal1(val_res);
	char buf[64];

	if (getdomainname(buf, 64) == -1)
		uerror("getdomainname", Nothing);

	val_res = caml_copy_string(buf);

	CAMLreturn(val_res);
}
