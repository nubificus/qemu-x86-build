FROM nubificus/jetson-inference

# Install common build utilities
RUN apt-get update && \
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
		$(apt-get -s build-dep qemu | egrep ^Inst | fgrep '[all]' | cut -d\  -f2) \
	&& rm -rf /var/lib/apt/lists/*

ARG TOKEN
# Build & install vaccel-runtime
RUN git clone https://papazof:${TOKEN}@github.com/cloudkernels/vaccel-runtime.git && \
	cd vaccel-runtime && git checkout timers-wip && \
	make DISABLE_OPENCL=1 CUDAML_DIR="/usr/local" && \
	cp libvaccel_runtime.so /usr/local/lib/ && \
	cp vaccel_runtime.h /usr/local/include && \
	cd .. && rm -rf vaccel-runtime
	
# Build & install QEMU w/ vAccel backend
RUN git clone https://papazof:${TOKEN}@github.com/cloudkernels/qemu-vaccel.git && \
	cd qemu-vaccel && git checkout update-to-v5 && \
	git submodule update --init && \
	./configure --target-list=x86_64-softmmu && \
	make -j$(nproc) && make install && \
	cd .. && rm -rf qemu-vaccel

COPY qemu-ifup /etc/qemu-ifup
COPY qemu-script.sh /run.sh

VOLUME /data
ENTRYPOINT ["/run.sh"]
