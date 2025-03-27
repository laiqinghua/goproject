# 使用多阶段构建确保工具链完整
FROM --platform=$BUILDPLATFORM golang:1.21 AS builder

# 阶段1：构建（强制使用Go 1.24+）
FROM golang:1.24 AS builder

# 安装CGO依赖（根据基础镜像选择）
RUN apt-get update && apt-get install -y gcc libc6-dev

# 显式传递平台参数
ARG TARGETOS=linux
ARG TARGETARCH=amd64
ENV GOOS=$TARGETOS \
    GOARCH=$TARGETARCH \
    CGO_ENABLED=1

# 编译
WORKDIR /app
COPY . .
RUN go build -o /out/app main.go

# 阶段2：运行
FROM alpine:latest
COPY --from=builder /out/app /app
ENTRYPOINT ["/app"]
