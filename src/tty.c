#include <unistd.h>
#include <limits.h>
#include <errno.h>

#include "backpack.h"

CAMLprim value
caml_backpack_ttyname(value val_fd)
{
	CAMLparam1(val_fd);
	CAMLlocal1(val_res);
	char buf[TTY_NAME_MAX];

	if ((errno = ttyname_r(Int_val(val_fd), buf, TTY_NAME_MAX)) != 0)
		uerror("ttyname_r", Nothing);

	val_res = caml_copy_string(buf);

	CAMLreturn(val_res);
}
