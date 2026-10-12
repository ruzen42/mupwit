FROM fedora:latest AS builder

RUN dnf install -y \
    clang \
    lld \
    make \
    git \
    pkgconfig \
    glibc-static \
    libmpdclient-devel \
    wayland-devel \
    cairo-devel \
    libxkbcommon-devel \
    freetype-devel \
    fontconfig-devel \
    libpng-devel \
    libjpeg-turbo-devel \
    libX11-devel \
    libXcursor-devel \
    libXrandr-devel \
    libXinerama-devel \
    libXi-devel \
    && dnf clean all

RUN ln -sf /usr/bin/clang /usr/local/bin/gcc && \
    ln -sf /usr/bin/clang++ /usr/local/bin/g++ && \
    ln -sf /usr/bin/clang /usr/local/bin/cc && \
    ln -sf /usr/bin/lld /usr/local/bin/ld

ARG ODIN_URL=https://github.com/odin-lang/Odin/releases/download/dev-2026-10/odin-linux-amd64-dev-2026-10.tar.gz

RUN curl -L -o odin.tar.gz ${ODIN_URL} && \
    mkdir -p /opt/odin && \
    tar -xzf odin.tar.gz -C /opt/odin --strip-components=1 && \
    rm odin.tar.gz

RUN /opt/odin/vendor/stb/src/build_stb.sh

ENV PATH="/opt/odin:${PATH}"

WORKDIR /build
COPY . .

RUN make release

FROM fedora-minimal:latest

RUN microdnf install -y \
	libmpdclient \
	libwayland-client \
	cairo \
	libxkbcommon \
	freetype \
	fontconfig \
	libpng \
	&& microdnf clean all

WORKDIR /app

COPY --from=builder /build/build/mupwit /app/mupwit

RUN chmod +x /app/mupwit

ENTRYPOINT ["/app/mupwit"]
