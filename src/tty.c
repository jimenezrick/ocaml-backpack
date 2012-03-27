#include <unistd.h>
#include <sys/ioctl.h>
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

CAMLprim value
caml_backpack_term_size(value val_unit)
{
	CAMLparam1(val_unit);
	CAMLlocal1(val_res);
	struct winsize size;

	if (ioctl(STDOUT_FILENO, TIOCGWINSZ, &size) == -1)
		uerror("ioctl", Nothing);

	val_res = caml_alloc_tuple(2);
	Store_field(val_res, 0, size.ws_row);
	Store_field(val_res, 1, size.ws_col);

	CAMLreturn(val_res);
}
