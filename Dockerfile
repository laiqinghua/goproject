# 阶段1：构建
FROM --platform=$BUILDPLATFORM golang:1.24 AS builder

# 安装多架构编译工具链
RUN apt-get update && apt-get install -y \
    gcc-aarch64-linux-gnu gcc-x86-64-linux-gnu

# 动态接收平台参数
ARG TARGETOS TARGETARCH
ENV GOOS=$TARGETOS \
    GOARCH=$TARGETARCH \
    CGO_ENABLED=1 \
    CC=$${TARGETARCH}-linux-gnu-gcc  # 动态设置交叉编译器

# 编译
WORKDIR /app
COPY . .
RUN go build -o /app main.go

# 阶段2：运行
FROM alpine
COPY --from=builder /app /app
ENTRYPOINT ["/app"]