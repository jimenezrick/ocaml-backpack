#include <sys/sysinfo.h>

#include "backpack.h"

CAMLprim value
caml_backpack_sysinfo(value val_unit)
{
	CAMLparam1(val_unit);
	CAMLlocal1(val_res);
	struct sysinfo info;

	if (sysinfo(&info) == -1)
		uerror("sysinfo", Nothing);

	val_res = caml_alloc(14, 0);
	Store_field(val_res,  0, Val_long(info.uptime));
	Store_field(val_res,  1, Val_long(info.loads[0]));
	Store_field(val_res,  2, Val_long(info.loads[1]));
	Store_field(val_res,  3, Val_long(info.loads[2]));
	Store_field(val_res,  4, Val_long(info.totalram));
	Store_field(val_res,  5, Val_long(info.freeram));
	Store_field(val_res,  6, Val_long(info.sharedram));
	Store_field(val_res,  7, Val_long(info.bufferram));
	Store_field(val_res,  8, Val_long(info.totalswap));
	Store_field(val_res,  9, Val_long(info.freeswap));
	Store_field(val_res, 10, Val_int(info.procs));
	Store_field(val_res, 11, Val_long(info.totalhigh));
	Store_field(val_res, 12, Val_long(info.freehigh));
	Store_field(val_res, 13, Val_int(info.mem_unit));

	CAMLreturn(val_res);
}
