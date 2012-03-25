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
caml_backpack_mq_open(value val_name, value val_flags, value val_mode, value val_attr)
{
	CAMLparam4(val_name, val_flags, val_mode, val_attr);
	CAMLlocal1(val_res);
	int flags = caml_convert_flag_list(val_flags, mqueue_flags);
	struct mq_attr attr, *pattr;
	mqd_t mq;

	if (Is_long(val_attr))
		pattr = NULL;
	else {
		attr.mq_maxmsg  = Int_val(Field(val_attr, 0));
		attr.mq_msgsize = Int_val(Field(val_attr, 1));
		pattr           = &attr;
	}

	if ((mq = mq_open(String_val(val_name), flags, Int_val(val_mode), pattr)) == -1)
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

CAMLprim value
caml_backpack_mq_getattr(value val_mq)
{
	CAMLparam1(val_mq);
	CAMLlocal1(val_res);
	struct mq_attr attr;

	if (mq_getattr(Int_val(val_mq), &attr) == -1)
		uerror("mq_getattr", Nothing);

	val_res = caml_alloc_tuple(4);
	Store_field(val_res, 0,
		    caml_backpack_unpack_flags(attr.mq_flags, mqueue_flags,
					       BACKPACK_FLAGS_LEN(mqueue_flags)));
	Store_field(val_res, 1, Val_int(attr.mq_maxmsg));
	Store_field(val_res, 2, Val_int(attr.mq_msgsize));
	Store_field(val_res, 3, Val_int(attr.mq_curmsgs));

	CAMLreturn(val_res);
}

CAMLprim value
caml_backpack_mq_setattr(value val_mq, value val_flags)
{
	CAMLparam2(val_mq, val_flags);
	struct mq_attr attr = {
		.mq_flags = caml_convert_flag_list(val_flags, mqueue_flags)
	};

	if (mq_setattr(Int_val(val_mq), &attr, NULL) == -1)
		uerror("mq_setattr", Nothing);

	CAMLreturn(Val_unit);
}
