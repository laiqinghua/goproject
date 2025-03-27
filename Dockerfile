# 阶段1：构建 Go 二进制（自动匹配目标平台）
FROM --platform=$BUILDPLATFORM golang:1.21-alpine AS builder
WORKDIR /app
COPY . .
ARG TARGETOS TARGETARCH  # 由 Buildx 自动注入
RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build -o ./cmd/app main.go

# 阶段2：生成最小化镜像
FROM alpine:latest
COPY --from=builder ./cmd/app /usr/local/bin/app
ENTRYPOINT ["/usr/local/bin/app"]
