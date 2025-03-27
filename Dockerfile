# 阶段1：构建
FROM --platform=$BUILDPLATFORM golang:1.24 AS builder

# 动态接收参数（移除硬编码）
ARG TARGETOS TARGETARCH
ENV GOOS=$TARGETOS \
    GOARCH=$TARGETARCH \
    CGO_ENABLED=1

# 安装对应架构的编译工具链
RUN apt-get update && \
    if [ "$TARGETARCH" = "arm64" ]; then \
      apt-get install -y gcc-aarch64-linux-gnu; \
    else \
      apt-get install -y gcc; \
    fi

# 编译
RUN GOARCH=$TARGETARCH go build -o /app main.go