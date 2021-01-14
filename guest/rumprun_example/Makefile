BIN = classify.bin
OBJ = test_class.o
SRC = test-class_op.c
DATA ?= ../data

all: ${BIN} data.iso

data.iso: ${DATA}
	genisoimage -o $@ $^

${BIN}: ${OBJ}
	rumprun-bake hw_virtio_accel $@ $^

${OBJ}: ${SRC}
	x86_64-rumprun-netbsd-gcc -o $@ $^

clean:
	rm -f ${OBJ} ${BIN}

distclean:
	rm -f ${OBJ} ${BIN} data.iso
