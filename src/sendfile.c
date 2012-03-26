#include <sys/sendfile.h>

#include "backpack.h"

CAMLprim value
caml_backpack_sendfile(value val_out_fd, value val_in_fd,
		       value val_pos, value val_len)
{
	CAMLparam4(val_out_fd, val_in_fd, val_pos, val_len);
	CAMLlocal1(val_res);
	off_t pos, *ppos;
	ssize_t size;

	if (Is_long(val_pos))
		ppos = NULL;
	else {
		pos  = Long_val(Field(val_pos, 0));
		ppos = &pos;
	}

	caml_enter_blocking_section();
	size = sendfile(Int_val(val_out_fd), Int_val(val_in_fd),
			ppos, Long_val(val_len));
	caml_leave_blocking_section();

	if (size == -1)
		uerror("sendfile", Nothing);

	val_res = Val_long(size);

	CAMLreturn(val_res);
}
