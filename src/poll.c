#include <sys/epoll.h>

#include "backpack.h"

static int epoll_events[] = {
	EPOLLIN,
	EPOLLOUT,
	EPOLLRDHUP,
	EPOLLPRI,
	EPOLLERR,
	EPOLLHUP,
	EPOLLET,
	EPOLLONESHOT
};

CAMLprim value
caml_backpack_epoll_create1(value val_cloexec)
{
	CAMLparam1(val_cloexec);
	CAMLlocal1(val_res);
	int fd;

	if ((fd = epoll_create1(Bool_val(val_cloexec) ? EPOLL_CLOEXEC : 0)) == -1)
		uerror("epoll_create1", Nothing);

	val_res = Val_int(fd);

	CAMLreturn(val_res);
}

CAMLprim value
caml_backpack_epoll_wait(value val_epfd, value val_maxevents, value val_timeout)
{
	CAMLparam3(val_epfd, val_maxevents, val_timeout);
	CAMLlocal2(events_list, elem);
	struct epoll_event events[Int_val(val_maxevents)];
	int num_events, i;

	caml_enter_blocking_section();
	num_events = epoll_wait(Int_val(val_epfd), events, Int_val(val_maxevents),
				Int_val(val_timeout));
	caml_leave_blocking_section();

	if (num_events == -1)
		uerror("epoll_wait", Nothing);

	events_list = Val_emptylist;
	for (i = 0; i < num_events; i++) {
		elem = caml_alloc_tuple(2);
		Store_field(elem, 0,
			    caml_backpack_unpack_flags(events[i].events, epoll_events,
						       BACKPACK_FLAGS_LEN(epoll_events)));
		Store_field(elem, 1, Val_int(events[i].data.fd));
		events_list = caml_backpack_cons(events_list, elem);
	}

	CAMLreturn(events_list);
}
