# 阶段1：构建
FROM --platform=$BUILDPLATFORM golang:1.24 AS builder

# 安装基础工具和跨平台依赖
RUN apt-get update && apt-get install -y \
    qemu-user-static \
    gcc-aarch64-linux-gnu \
    binutils-aarch64-linux-gnu \
    gcc-x86-64-linux-gnu \
    binutils-x86-64-linux-gnu \
    libc6-dev-arm64-cross && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 动态设置编译环境
ARG TARGETARCH
ENV GOOS=linux \
    GOARCH=$TARGETARCH \
    CGO_ENABLED=1 \
    CC_aarch64=aarch64-linux-gnu-gcc \
    CXX_aarch64=aarch64-linux-gnu-g++

# 条件配置编译器
RUN if [ "$TARGETARCH" = "arm64" ]; then \
        export CC=aarch64-linux-gnu-gcc \
               CXX=aarch64-linux-gnu-g++ \
               AR=aarch64-linux-gnu-ar; \
    else \
        export CC=gcc \
               CXX=g++ \
               AR=ar; \
    fi

# 编译
WORKDIR /app
COPY . .
RUN go build -tags netgo -ldflags '-extldflags "-static"' -o /app/main main.go

# 阶段2：运行
FROM alpine:3.19
RUN addgroup -S app && adduser -S app -G app
WORKDIR /app
COPY --from=builder --chmod=755 --chown=app:app /app/main .
ENTRYPOINT ["/app/main"]