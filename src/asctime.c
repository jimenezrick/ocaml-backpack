#include <time.h>
#include <caml/mlvalues.h>
#include <caml/alloc.h>
#include <caml/memory.h>
#include <caml/fail.h>

CAMLprim value backpack_asctime(value val_tm)
{
	CAMLparam1(val_tm);
	char buf[26];
	struct tm tm = {
		.tm_sec   = Int_val(Field(val_tm, 0)),
		.tm_min   = Int_val(Field(val_tm, 1)),
		.tm_hour  = Int_val(Field(val_tm, 2)),
		.tm_mday  = Int_val(Field(val_tm, 3)),
		.tm_mon   = Int_val(Field(val_tm, 4)),
		.tm_year  = Int_val(Field(val_tm, 5)),
		.tm_wday  = Int_val(Field(val_tm, 6)),
		.tm_yday  = Int_val(Field(val_tm, 7)),
		.tm_isdst = Bool_val(Field(val_tm, 8))
	};

	if (asctime_r(&tm, buf) == NULL)
		caml_failwith("asctime_r");

	CAMLreturn(caml_copy_string(buf));
}
