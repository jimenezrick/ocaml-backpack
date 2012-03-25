#include <fcntl.h>
#include <sys/stat.h>
#include <mqueue.h>
#include <limits.h>

#include "backpack.h"

static int mqueue_flags[] = {
	O_RDONLY,
	O_WRONLY,
	O_RDWR,
	O_NONBLOCK,
	O_CREAT,
	O_EXCL
};

CAMLprim value
caml_backpack_mq_prio_max(value val_unit)
{
	CAMLparam1(val_unit);
	CAMLlocal1(val_res);

	val_res = Val_int(MQ_PRIO_MAX);

	CAMLreturn(val_res);
}

CAMLprim value
caml_backpack_mq_open(value val_name, value val_flags, value val_mode)
{
	CAMLparam3(val_name, val_flags, val_mode);
	CAMLlocal1(val_res);
	int flags = caml_convert_flag_list(val_flags, mqueue_flags);
	mqd_t mq;

	if ((mq = mq_open(String_val(val_name), flags, Int_val(val_mode), NULL)) == -1)
		uerror("mq_open", val_name);

	val_res = Val_int(mq);

	CAMLreturn(val_res);
}

CAMLprim value
caml_backpack_mq_close(value val_mq)
{
	CAMLparam1(val_mq);

	if (mq_close(Int_val(val_mq)) == -1)
		uerror("mq_close", Nothing);

	CAMLreturn(Val_unit);
}

CAMLprim value
caml_backpack_mq_unlink(value val_name)
{
	CAMLparam1(val_name);

	if (mq_unlink(String_val(val_name)) == -1)
		uerror("mq_unlink", val_name);

	CAMLreturn(Val_unit);
}
