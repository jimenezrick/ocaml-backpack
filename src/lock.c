#include <sys/file.h>
#include <caml/mlvalues.h>
#include <caml/alloc.h>
#include <caml/memory.h>
#include <caml/threads.h>
#include <caml/unixsupport.h>

static int flock_op_table[] = {
	LOCK_SH,
	LOCK_EX,
	LOCK_NB,
	LOCK_UN
};

CAMLprim value caml_backpack_flock(value val_fd, value val_op)
{
	CAMLparam2(val_fd, val_op);
	int r;
	int op = caml_convert_flag_list(val_op, flock_op_table);

	caml_enter_blocking_section();
	r = flock(Int_val(val_fd), op);
	caml_leave_blocking_section();

	if (r == -1)
		uerror("flock", Nothing);

	CAMLreturn(Val_unit);
}
