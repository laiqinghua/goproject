# 使用多阶段构建确保工具链完整
FROM --platform=$BUILDPLATFORM golang:1.21 AS builder

# 安装交叉编译依赖
RUN apt-get update && apt-get install -y gcc-aarch64-linux-gnu gcc-x86-64-linux-gnu

# 显式传递构建参数
ARG TARGETOS=linux
ARG TARGETARCH=amd64
ENV GOOS=$TARGETOS \
    GOARCH=$TARGETARCH \
    CGO_ENABLED=1
WORKDIR /app
COPY . .
ARG TARGETOS TARGETARCH  # 由 Buildx 自动注入
RUN CGO_ENABLED=1 GOOS=$TARGETOS GOARCH=$TARGETARCH go build -o ./cmd/app main.go

# 阶段2：生成最小化镜像
FROM alpine:latest
COPY --from=builder ./cmd/app /usr/local/bin/app
ENTRYPOINT ["/usr/local/bin/app"]
