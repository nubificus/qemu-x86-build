FROM nubificus/jetson-inference

# Install common build utilities
RUN mkdir /guest && apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install -yy eatmydata && \
	DEBIAN_FRONTEND=noninteractive eatmydata \
	apt-get install -y --no-install-recommends \
		bison \
		flex \
		build-essential \
		libglib2.0-dev \
		libfdt-dev \
		libpixman-1-dev \
		zlib1g-dev \
		pkg-config \
		iproute2 \
		libcap-ng-dev \
		libattr1-dev \
		genisoimage \
		$(apt-get -s build-dep qemu | egrep ^Inst | fgrep '[all]' | cut -d\  -f2) \
	&& rm -rf /var/lib/apt/lists/*

ARG TOKEN
# Build & install vaccel-runtime
RUN git clone https://${TOKEN}:x-oauth-basic@github.com/cloudkernels/vaccel-runtime.git \
	-b timers-wip && cd vaccel-runtime && \
	make DISABLE_OPENCL=1 CUDAML_DIR="/usr/local" && \
	cp libvaccel_runtime.so /usr/local/lib/ && \
	cp vaccel_runtime.h /usr/local/include && \
	cp test-class_op /usr/local/bin/classify && \
	cd .. && rm -rf vaccel-runtime
	
# Build & install QEMU w/ vAccel backend
RUN git clone https://${TOKEN}:x-oauth-basic@github.com/cloudkernels/qemu-vaccel.git \
	-b legacy_virtio && cd qemu-vaccel && \
	git submodule update --init && \
	./configure --target-list=x86_64-softmmu --enable-virtfs && \
	make -j$(nproc) && make install && \
	cd .. && rm -rf qemu-vaccel

COPY qemu-ifup /etc/qemu-ifup
COPY guest/ /guest/

##ENTRYPOINT ["/run.sh"]
