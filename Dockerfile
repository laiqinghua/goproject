FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY . .
RUN go build -o main.go ./cmd/main.go 

FROM alpine:latest
COPY --from=builder /app/bin/main /main
ENTRYPOINT ["/main"]
