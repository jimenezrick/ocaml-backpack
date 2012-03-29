#include "backpack.h"

#define SHA2_TYPES
#include "sha2.h"

struct custom_operations backpack_sha256_ctx_ops = {
	.identifier  = "Backpack.Digest.sha256_ctx",
	.finalize    = custom_finalize_default,
	.compare     = custom_compare_default,
	.hash        = custom_hash_default,
	.serialize   = custom_serialize_default,
	.deserialize = custom_deserialize_default
};

CAMLprim value
caml_backpack_sha256(value val_buf)
{
	CAMLparam1(val_buf);
	CAMLlocal1(val_res);

	val_res = caml_alloc_string(32);
	sha256((unsigned char *) String_val(val_buf), caml_string_length(val_buf),
	       (unsigned char *) String_val(val_res));

	CAMLreturn(val_res);
}

CAMLprim value
caml_backpack_sha256_init(value val_unit)
{
	CAMLparam1(val_unit);
	CAMLlocal1(val_res);
	sha256_ctx *ctx;

	val_res = caml_alloc_custom(&backpack_sha256_ctx_ops,
				    sizeof(sha256_ctx), 0, 1);
	ctx = (sha256_ctx *) Data_custom_val(val_res);
	sha256_init(ctx);

	CAMLreturn(val_res);
}

CAMLprim value
caml_backpack_sha256_update(value val_ctx, value val_buf)
{
	CAMLparam2(val_ctx, val_buf);
	sha256_ctx *ctx;

	ctx = (sha256_ctx *) Data_custom_val(val_ctx);
	sha256_update(ctx, (unsigned char *) String_val(val_buf),
		      caml_string_length(val_buf));

	CAMLreturn(Val_unit);
}

CAMLprim value
caml_backpack_sha256_final(value val_ctx)
{
	CAMLparam1(val_ctx);
	CAMLlocal1(val_res);
	sha256_ctx *ctx;

	ctx     = (sha256_ctx *) Data_custom_val(val_ctx);
	val_res = caml_alloc_string(32);
	sha256_final(ctx, (unsigned char *) String_val(val_res));

	CAMLreturn(val_res);
}
