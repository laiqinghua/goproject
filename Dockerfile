# 阶段1：构建
FROM --platform=$BUILDPLATFORM golang:1.24 AS builder

# 安装完整交叉编译工具链[3](@ref)
RUN apt-get update && apt-get install -y \
    gcc-aarch64-linux-gnu \
    binutils-aarch64-linux-gnu \
    libc6-dev-arm64-cross

# 动态接收参数（移除硬编码）
ARG TARGETOS TARGETARCH
ENV GOOS=$TARGETOS \
    GOARCH=$TARGETARCH \
    CGO_ENABLED=1 \
    CC=aarch64-linux-gnu-gcc \
    CXX=aarch64-linux-gnu-g++

# 编译
WORKDIR /app
COPY . .
RUN go build -o /app main.go

# 阶段2：运行
FROM alpine
COPY --from=builder /app /app
ENTRYPOINT ["/app"]