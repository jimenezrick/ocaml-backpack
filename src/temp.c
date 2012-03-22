#include <stdlib.h>
#include <string.h>
#include <limits.h>
#include <caml/mlvalues.h>
#include <caml/alloc.h>
#include <caml/memory.h>
#include <caml/fail.h>
#include <caml/threads.h>
#include <caml/unixsupport.h>

static void init_mktemp(const char *where, char *buf, value val_path)
{
	int i, len = caml_string_length(val_path);

	if (len > PATH_MAX - 7)
		caml_invalid_argument(where);

	memcpy(buf, String_val(val_path), len);
	for (i = len; i < len + 6; i++)
		buf[i] = 'X';
	buf[len + 6] = '\0';
}

CAMLprim value caml_backpack_mkstemp(value val_path)
{
	CAMLparam1(val_path);
	CAMLlocal2(val_res_path, val_res);
	char buf[PATH_MAX];
	int fd;

	init_mktemp("mkstemp", buf, val_path);
	caml_enter_blocking_section();
	fd = mkstemp(buf);
	caml_leave_blocking_section();

	if (fd == -1)
		uerror("mkstemp", val_path);

	val_res_path = caml_copy_string(buf);
	val_res      = caml_alloc_tuple(2);

	Field(val_res, 0) = val_res_path;
	Field(val_res, 1) = Val_int(fd);

	CAMLreturn(val_res);
}

CAMLprim value caml_backpack_mkdtemp(value val_path)
{
	CAMLparam1(val_path);
	char buf[PATH_MAX], *path;

	init_mktemp("mkdtemp", buf, val_path);
	caml_enter_blocking_section();
	path = mkdtemp(buf);
	caml_leave_blocking_section();

	if (path == NULL)
		uerror("mkdtemp", val_path);

	CAMLreturn(caml_copy_string(buf));
}
