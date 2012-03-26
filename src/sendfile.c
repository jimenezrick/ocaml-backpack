#include <sys/sendfile.h>

#include "backpack.h"

CAMLprim value
caml_backpack_sendfile(value val_out_fd, value val_in_fd,
		       value val_pos, value val_len)
{
	CAMLparam4(val_out_fd, val_in_fd, val_pos, val_len);
	CAMLlocal1(val_res);
	ssize_t size;
	off_t pos = Long_val(val_pos);

	caml_enter_blocking_section();
	size = sendfile(Int_val(val_out_fd), Int_val(val_in_fd),
			&pos, Long_val(val_len));
	caml_leave_blocking_section();

	if (size == -1)
		uerror("sendfile", Nothing);

	val_res = Val_long(size);

	CAMLreturn(val_res);
}
