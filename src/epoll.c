#include <sys/epoll.h>
#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/unixsupport.h>

CAMLprim value caml_backpack_epoll_create(value val_cloexec)
{
	CAMLparam1(val_cloexec);
	int fd;

	fd = epoll_create1(Bool_val(val_cloexec) ? EPOLL_CLOEXEC : 0);
	if (fd == -1)
		uerror("epoll_create1", Nothing);

	CAMLreturn(Val_int(fd));
}
