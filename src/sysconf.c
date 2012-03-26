#include <unistd.h>
#include <errno.h>

#include "backpack.h"

static int sysconf_names[] = {
	_SC_ARG_MAX,
	_SC_CHILD_MAX,
	_SC_HOST_NAME_MAX,
	_SC_LOGIN_NAME_MAX,
	_SC_CLK_TCK,
	_SC_OPEN_MAX,
	_SC_PAGESIZE,
	_SC_RE_DUP_MAX,
	_SC_STREAM_MAX,
	_SC_SYMLOOP_MAX,
	_SC_TTY_NAME_MAX,
	_SC_TZNAME_MAX,
	_SC_VERSION,
	_SC_LINE_MAX,
	_SC_PHYS_PAGES,
	_SC_AVPHYS_PAGES,
	_SC_NPROCESSORS_CONF,
	_SC_NPROCESSORS_ONLN
};

CAMLprim value
caml_backpack_sysconf(value val_name)
{
	CAMLparam1(val_name);
	CAMLlocal1(val_res);
	long r;

	if ((r = sysconf(sysconf_names[Int_val(val_name)])) == -1 &&
	    errno == EINVAL)
		uerror("sysconf", Nothing);

	val_res = copy_int64(r);

	CAMLreturn(val_res);
}
