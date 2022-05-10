FROM nubificus/jetson-inference:x86_64

# Install common build utilities
RUN apt-get --allow-releaseinfo-change update && \
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
		$(apt-get -s build-dep qemu | egrep ^Inst | fgrep '[all]' | cut -d\  -f2) \
		cargo \
		libclang-dev \
		clang \
		vim \
		ca-certificates \
		freeglut3-dev \
	&& rm -rf /var/lib/apt/lists/*

ARG TOKEN
# Build & install vaccelrt
RUN git clone \
	https://${TOKEN}:x-oauth-basic@github.com/cloudkernels/vaccelrt && \
	cd vaccelrt && git submodule update --init && \
	mkdir build && cd build && \
	cmake -DCMAKE_INSTALL_PREFIX=/usr/local -DBUILD_EXAMPLES=ON \
		-DBUILD_PLUGIN_EXEC=ON -DBUILD_PLUGIN_NOOP=ON .. && \
	make install && \
	echo "/usr/local/lib" >> /etc/ld.so.conf.d/vaccel.conf && \
	echo "/sbin/ldconfig" >> /root/.bashrc && \
	mkdir /run/user && \
	cd ../.. && rm -rf vaccelrt

# Build & install vaccelrt jetson inference plugin
RUN git clone \
	https://${TOKEN}:x-oauth-basic@github.com/nubificus/vaccelrt-plugin-jetson && \
	cd vaccelrt-plugin-jetson && git submodule update --init && \
	cd vaccelrt && git submodule update --init && \
	cd .. && mkdir build && cd build && \
	cmake -DCMAKE_INSTALL_PREFIX=/usr/local .. && make install && \
	cd ../.. && rm -rf vaccelrt-plugin-jetson

# Build & install QEMU w/ vAccel backend
COPY vq-size.patch /
RUN git clone -b vaccelrt --depth 1 \
	https://${TOKEN}:x-oauth-basic@github.com/cloudkernels/qemu-vaccel.git && \
	mv /vq-size.patch qemu-vaccel/ && cd qemu-vaccel && \
	git apply vq-size.patch && git submodule update --init && \
	./configure --target-list=x86_64-softmmu --enable-virtfs && \
	make -j$(nproc) && make install && \
	cd .. && rm -rf qemu-vaccel

# Build & install vaccelrt agent
RUN git clone \
	https://${TOKEN}:x-oauth-basic@github.com/cloudkernels/vaccelrt-agent && \
	cd vaccelrt-agent && \
	cargo build && \
	cp $(find -name "vaccelrt-agent") /usr/local/bin/ && \
	cd .. && rm -rf vaccelrt-agent

COPY qemu-ifup /etc/qemu-ifup
COPY qemu-script.sh /run.sh

VOLUME /data
WORKDIR /data
ENTRYPOINT ["/run.sh"]
