# 阶段1：构建
FROM --platform=$BUILDPLATFORM golang:1.24 AS builder

# 安装跨平台工具链
RUN apt-get update && apt-get install -y \
    gcc-aarch64-linux-gnu \
    binutils-aarch64-linux-gnu \
    gcc-x86-64-linux-gnu

# 动态设置编译环境
ARG TARGETARCH
ENV GOOS=linux \
    GOARCH=$TARGETARCH \
    CGO_ENABLED=1

# 条件设置编译器
RUN if [ "$TARGETARCH" = "arm64" ]; then \
      export CC=aarch64-linux-gnu-gcc \
        CXX=aarch64-linux-gnu-g++ \
        AR=aarch64-linux-gnu-ar; \
    else \
      export CC=x86_64-linux-gnu-gcc \
        CXX=x86_64-linux-gnu-g++ \
        AR=x86_64-linux-gnu-ar; \
    fi

# 编译
WORKDIR /app
COPY . .
RUN go build -o /app main.go

# 阶段2：运行
FROM alpine
COPY --from=builder /app /app
ENTRYPOINT ["/app"]