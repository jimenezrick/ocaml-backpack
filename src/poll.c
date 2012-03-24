#include <sys/epoll.h>
#include <caml/mlvalues.h>
#include <caml/alloc.h>
#include <caml/memory.h>
#include <caml/unixsupport.h>

CAMLprim value caml_backpack_epoll_create1(value val_cloexec)
{
	CAMLparam1(val_cloexec);
	int fd;

	fd = epoll_create1(Bool_val(val_cloexec) ? EPOLL_CLOEXEC : 0);
	if (fd == -1)
		uerror("epoll_create1", Nothing);

	CAMLreturn(Val_int(fd));
}

CAMLprim value caml_backpack_epoll_wait(void)
{
	CAMLparam0();
	CAMLlocal3(head, cons, list);
	int i;

	head = caml_alloc_tuple(2);
	Store_field(head, 0, Val_int(123));
	Store_field(head, 1, Val_int(666));

	list = Val_emptylist;

	for (i = 0; i < 3; i++) {
		cons = caml_alloc(2, 0);
		Store_field(cons, 0, head);
		Store_field(cons, 1, list);

		list = cons;
	}

	CAMLreturn(list);
}
