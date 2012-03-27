#include <stdlib.h>
#include <termios.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <limits.h>
#include <errno.h>

#include "backpack.h"

static struct termios *normal_term;

CAMLprim value
caml_backpack_ttyname(value val_fd)
{
	CAMLparam1(val_fd);
	CAMLlocal1(val_res);
	char buf[TTY_NAME_MAX];

	if ((errno = ttyname_r(Int_val(val_fd), buf, TTY_NAME_MAX)) != 0)
		uerror("ttyname_r", Nothing);

	val_res = caml_copy_string(buf);

	CAMLreturn(val_res);
}

CAMLprim value
caml_backpack_term_size(value val_unit)
{
	CAMLparam1(val_unit);
	CAMLlocal1(val_res);
	struct winsize size;

	if (ioctl(STDIN_FILENO, TIOCGWINSZ, &size) == -1)
		uerror("ioctl", Nothing);

	val_res = caml_alloc_tuple(2);
	Store_field(val_res, 0, Val_int(size.ws_row));
	Store_field(val_res, 1, Val_int(size.ws_col));

	CAMLreturn(val_res);
}

CAMLprim value
caml_backpack_canonical_mode(value val_unit)
{
	CAMLparam1(val_unit);

	if (normal_term != NULL) {
		if (tcsetattr(STDIN_FILENO, TCSAFLUSH, normal_term) == -1)
			uerror("tcsetattr", Nothing);
	}

	CAMLreturn(Val_unit);
}

CAMLprim value
caml_backpack_raw_mode(value val_unit)
{
	CAMLparam1(val_unit);
	struct termios term;

	if (normal_term == NULL) {
		normal_term = malloc(sizeof(struct termios));
		if (tcgetattr(STDIN_FILENO, normal_term) == -1)
			uerror("tcgetattr", Nothing);
	}

	/* Noncanonical mode, disable signals, extended
	 * input processing and echoing. */
	term.c_lflag &= ~(ICANON | ISIG | IEXTEN | ECHO);

	/* Disable special handling of CR, NL, and BREAK.
	 * No 8th-bit stripping or parity error handling.
	 * Disable START/STOP output flow control. */
	term.c_iflag &= ~(BRKINT | ICRNL | IGNBRK | IGNCR | INLCR |
			  INPCK | ISTRIP | IXON | PARMRK);

	term.c_oflag &= ~OPOST; /* Disable all output processing */

	term.c_cc[VMIN]  = 1; /* Character-at-a-time input */
	term.c_cc[VTIME] = 0; /* with blocking */

	if (tcsetattr(STDIN_FILENO, TCSAFLUSH, &term) == -1)
		uerror("tcsetattr", Nothing);

	CAMLreturn(Val_unit);
}
