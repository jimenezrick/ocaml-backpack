#ifndef BACKPACK_H
#define BACKPACK_H

#include <stdint.h>

#include <caml/mlvalues.h>
#include <caml/alloc.h>
#include <caml/memory.h>
#include <caml/fail.h>
#include <caml/threads.h>
#include <caml/unixsupport.h>
#include <caml/custom.h>

#define BACKPACK_FLAGS_LEN(flags) sizeof(flags) / sizeof(flags[0])

value caml_backpack_cons(value list, value val);
value caml_backpack_unpack_flags(int pack, int *flags, int flags_len);

uint32_t crc32(uint32_t crc, const void *buf, size_t size);

#endif
