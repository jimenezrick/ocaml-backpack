#define _GNU_SOURCE
#include <fcntl.h>

#include "backpack.h"

static int splice_flags[] = {
	SPLICE_F_MOVE,
	SPLICE_F_NONBLOCK,
	SPLICE_F_MORE,
	SPLICE_F_GIFT
};

CAMLprim value
caml_backpack_splice_native(value val_fd_in, value val_pos_in, value val_fd_out,
			    value val_pos_out, value val_len, value val_flags)
{
	CAMLparam5(val_fd_in, val_pos_in, val_fd_out, val_pos_out, val_len);
	CAMLxparam1(val_flags);
	CAMLlocal1(val_res);
	unsigned int flags = caml_convert_flag_list(val_flags, splice_flags);
	off_t pos_in, pos_out, *ppos_in, *ppos_out;
	ssize_t size;

	if (Is_long(val_pos_in))
		ppos_in = NULL;
	else {
		pos_in  = Long_val(Field(val_pos_in, 0));
		ppos_in = &pos_in;
	}

	if (Is_long(val_pos_out))
		ppos_out = NULL;
	else {
		pos_out  = Long_val(Field(val_pos_out, 0));
		ppos_out = &pos_out;
	}

	caml_enter_blocking_section();
	size = splice(Int_val(val_fd_in), ppos_in, Int_val(val_fd_out),
		      ppos_out, Long_val(val_len), flags);
	caml_leave_blocking_section();

	if (size == -1)
		uerror("splice", Nothing);

	val_res = Val_long(size);

	CAMLreturn(val_res);
}

CAMLprim value
caml_backpack_splice_bytecode(value *argv, int argn)
{
	return caml_backpack_splice_native(argv[0], argv[1], argv[2],
					   argv[3], argv[4], argv[5]);
}
