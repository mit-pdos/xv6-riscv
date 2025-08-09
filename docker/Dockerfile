FROM ubuntu:25.04

RUN apt update
RUN apt install -y --no-install-recommends \
        git libglib2.0-dev libfdt-dev libpixman-1-dev zlib1g-dev \
        ninja-build python3 python3-pip python3-setuptools \
        libslirp-dev libssh-dev libspice-server-dev libusb-1.0-0-dev \
        build-essential gcc-riscv64-linux-gnu binutils-riscv64-linux-gnu
# Test utils
RUN apt install -y --no-install-recommends gawk expect 
RUN apt-get clean

RUN git clone https://gitlab.com/qemu-project/qemu.git /opt/qemu && \
    cd /opt/qemu && \
    # Configure only RISC-V target
    ./configure --target-list=riscv64-softmmu,riscv64-linux-user && \
    # Build (takes ~5–10 min depending on your machine)
    make -j$(nproc) && \
    make install