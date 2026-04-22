# Build stage
# 使用最新的 alpine 版本的 rust 镜像以支持最新的 edition 和依赖
FROM rust:alpine AS builder

# 安装构建依赖
RUN apk add --no-cache musl-dev pkgconfig openssl-dev git

WORKDIR /usr/src/douban-api-rs
COPY . .

# 编译应用
RUN cargo build --release

# Run stage
FROM alpine:latest

# 安装必要运行时依赖
RUN apk --no-cache add ca-certificates tini tzdata && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone

WORKDIR /data/
# 从构建阶段复制编译好的二进制文件
COPY --from=builder /usr/src/douban-api-rs/target/release/douban-api-rs /usr/bin/douban-api-rs

# 暴露端口
EXPOSE 8080

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/usr/bin/douban-api-rs", "--host", "0.0.0.0", "--port", "8080"]
