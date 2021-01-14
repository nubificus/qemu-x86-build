#ifndef _VACCELRT_RUNTIME_H
#define _VACCELRT_RUNTIME_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdbool.h>
#include <stdint.h>

#ifdef DEBUG
#define VRDPRINTF(fmt, ...) \
	fprintf(stderr, "vaccel-runtime: " fmt, ##__VA_ARGS__);
#else
#define VRDPRINTF(fmt, ...)
#endif

#define VACCELRT_OK 0
#define VACCELRT_ERR -1
#define VACCELRT_BAD_MSG -2

struct vaccelrt_arg {
	size_t len;
	void *buf;
};

/* session type */
#define VACCELRT_SESS_NONE      100
#define VACCELRT_SESS_GEMM      101
#define VACCELRT_SESS_AES_ECB   102
#define VACCELRT_SESS_SW        103
#define VACCELRT_SESS_KMEANS    104
#define VACCELRT_SESS_CLASSIFY  105
#define VACCELRT_SESS_DETECT    106
#define VACCELRT_SESS_SEGMENT   107

struct vaccelrt_mul {
	uint32_t k;
	uint32_t m;
	uint32_t n;
	size_t len_a;
	size_t len_b;
	size_t len_c;
	float *a;
	float *b;
	float *c;
};

struct vaccelrt_aes {
#define VACCELRT_AES_SET_KEY 0
#define VACCELRT_AES_ENCRYPT 1
#define VACCELRT_AES_DECRYPT 2
	unsigned int op;
	unsigned char *in;
	unsigned char *out;
	size_t len_in;
	size_t len_out;
	int rounds;
	void *rkeys;
};

struct vaccelrt_sw {
	unsigned int *in;
	unsigned int *out;
	size_t len_in;
	size_t len_out;
	uint32_t blk_size;
	uint32_t nblocks;
	uint32_t sz_input;
	uint32_t sz_output;
};

struct vaccelrt_km {
#if !defined(USE_DATA_TYPE) || USE_DATA_TYPE == INT_DT
	#define DATA_TYPE unsigned int
#else
	#define DATA_TYPE float
#endif
	float *feature;
	float *cluster;
	int *membership_ocl;
	int *membership;
	float *centers;
	int *centers_points;
	size_t len_feature;
	size_t len_cluster;
	size_t len_membership_ocl;
	size_t len_membership;
	size_t len_centers;
	size_t len_centers_points;
	uint32_t n_points;
	uint32_t n_features;
	uint32_t n_clusters;
	uint32_t vector_sz;
	uint32_t global_wg_sz;
	uint32_t threshold;
};

struct vaccelrt_class {
	void *img;
	unsigned char *out_text;
	unsigned char *out_imgname;
	size_t len_img;
	size_t len_out_text;
	size_t len_out_imgname;
};

struct vaccelrt_det {
	void *img;
	unsigned char *out_imgname;
	size_t len_img;
	size_t len_out_imgname;
};

struct vaccelrt_seg {
	void *img;
	unsigned char *out_imgname;
	size_t len_img;
	size_t len_out_imgname;
};

#define VACCELRT_OP_NONE 10
#define VACCELRT_OP_CREATE_SESS 11
#define VACCELRT_OP_DESTROY_SESS 12
#define VACCELRT_OP_DO_OP 13
struct vaccelrt_hdr {
	unsigned int op;
	unsigned int type;
	union {
		struct vaccelrt_mul mul;
		struct vaccelrt_aes aes;
		struct vaccelrt_sw sw;
		struct vaccelrt_km km;
		struct vaccelrt_class cl;
		struct vaccelrt_det det;
		struct vaccelrt_seg seg;
	} u;
};

struct vaccelrt_tmr {
	char name[20];
	double time;
};

struct vaccelrt_ctx {
	void *device;
	void *kernel;
	size_t max_wg;
	bool ready;
	struct vaccelrt_tmr *timer;
	int n_timer;
	void *priv;
};

struct vaccelrt_session {
	unsigned int type;
	struct vaccelrt_ctx ctx;
};

int vaccelrt_sess_init(struct vaccelrt_session *sess,
			struct vaccelrt_arg *out_args, struct vaccelrt_arg *in_args,
			unsigned int out_nargs, unsigned int in_nargs,
			unsigned int *type);

void vaccelrt_sess_free(struct vaccelrt_session *sess);

int vaccelrt_do_op(struct vaccelrt_session *sess,
			struct vaccelrt_arg *out_args, struct vaccelrt_arg *in_args,
			unsigned int out_nargs, unsigned int in_nargs);

#ifndef NO_OPENCL

void vaccelrt_opencl_set_key(struct vaccelrt_ctx *ctx,
			unsigned char *key, size_t nkey);

void vaccelrt_opencl_free_key(struct vaccelrt_ctx *ctx);

int vaccelrt_opencl_ecb(struct vaccelrt_ctx *ctx, char *in, char *out,
			size_t size, bool bEncrypt);

#define vaccelrt_opencl_ecb_encrypt(a,b,c,d) \
	vaccelrt_opencl_ecb(a,b,c,d,true)

#define vaccelrt_opencl_ecb_decrypt(a,b,c,d) \
	vaccelrt_opencl_ecb(a,b,c,d,false)

#endif

#ifdef __cplusplus
}
#endif

#endif /* _VACCELRT_RUNTIME_H */
