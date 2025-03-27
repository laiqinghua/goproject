# 阶段1：构建
FROM --platform=$BUILDPLATFORM golang:1.24 AS builder

# 安装多架构编译工具链
RUN apt-get update && apt-get install -y \
    gcc-aarch64-linux-gnu gcc-x86-64-linux-gnu

# 动态接收平台参数
ARG TARGETOS TARGETARCH
# 移除错误的$$引用，改用直接变量传递
ENV GOOS=$TARGETOS \
    GOARCH=$TARGETARCH \
    CGO_ENABLED=1
# 动态设置编译器（使用条件判断替代$$）
RUN if [ "$TARGETARCH" = "arm64" ]; then \
      export CC=aarch64-linux-gnu-gcc; \
    else \
      export CC=x86_64-linux-gnu-gcc; \
    fi 

# 编译
WORKDIR /app
COPY . .
RUN go build -o /app main.go

# 阶段2：运行
FROM alpine
COPY --from=builder /app /app
ENTRYPOINT ["/app"]