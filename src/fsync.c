#include <unistd.h>
#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/threads.h>
#include <caml/unixsupport.h>

CAMLprim value backpack_fsync(value val_fd)
{
	CAMLparam1(val_fd);
	int r;

	caml_enter_blocking_section();
	r = fsync(Int_val(val_fd));
	caml_leave_blocking_section();

	if (r != 0)
		uerror("fsync", Nothing);

	CAMLreturn(Val_unit);
}
