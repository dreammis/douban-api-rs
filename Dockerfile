FROM rust:alpine AS builder
RUN apk add --no-cache musl-dev pkgconfig openssl-dev

WORKDIR /app

# 先只复制依赖文件，单独构建依赖层（只要 Cargo.toml/lock 不变就命中缓存）
COPY Cargo.toml Cargo.lock ./
RUN mkdir src && echo "fn main() {}" > src/main.rs && \
    cargo build --release && \
    rm -rf src

# 再复制源码，只重新编译业务代码
COPY src ./src
RUN touch src/main.rs && cargo build --release

# 运行镜像
FROM alpine:latest
RUN apk add --no-cache ca-certificates tini tzdata && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone

COPY --from=builder /app/target/release/douban-api-rs /usr/bin/
EXPOSE 8080
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/usr/bin/douban-api-rs", "--host", "0.0.0.0", "--port", "8080"]
