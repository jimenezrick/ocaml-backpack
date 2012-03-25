#include "backpack.h"

value
caml_backpack_cons(value list, value val)
{
	CAMLparam2(list, val);
	CAMLlocal1(list2);

	list2 = caml_alloc(2, 0);
	Store_field(list2, 0, val);
	Store_field(list2, 1, list);

	CAMLreturn(list2);
}

value
caml_backpack_unpack_flags(int pack, int *flags, int flags_len)
{
	CAMLparam0();
	CAMLlocal1(flags_list);
	int i;

	flags_list = Val_emptylist;
	for (i = 0; i < flags_len; i++) {
		if (pack & flags[i])
			flags_list = caml_backpack_cons(flags_list, Val_int(i));
	}

	CAMLreturn(flags_list);
}
