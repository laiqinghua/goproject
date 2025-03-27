FROM --platform=$BUILDPLATFORM golang:1.24 AS builder

# 基础工具安装（所有架构都需要）
RUN apt-get update && apt-get install -y \
    make \
    git \
    qemu-user-static

# 动态安装交叉编译工具链
ARG TARGETARCH
RUN if [ "$TARGETARCH" = "arm64" ]; then \
        apt-get install -y gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu; \
    elif [ "$TARGETARCH" = "amd64" ]; then \
        apt-get install -y gcc-x86-64-linux-gnu binutils-x86-64-linux-gnu; \
    fi && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 设置编译环境
ENV GOOS=linux \
    GOARCH=$TARGETARCH \
    CGO_ENABLED=1

# 动态设置编译器
RUN if [ "$TARGETARCH" = "arm64" ]; then \
        export CC=aarch64-linux-gnu-gcc \
               CXX=aarch64-linux-gnu-g++ \
               AR=aarch64-linux-gnu-ar; \
    else \
        export CC=gcc \
               CXX=g++ \
               AR=ar; \
    fi

WORKDIR /app
COPY . .
RUN go build -o /app main.go

# 阶段2：运行
FROM alpine
COPY --from=builder /app /app
ENTRYPOINT ["/app"]