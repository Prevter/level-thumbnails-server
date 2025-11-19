# syntax=docker/dockerfile:1.7

FROM rust:1.91.1 as builder
WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends pkg-config libssl-dev \
    && rm -rf /var/lib/apt/lists/*

COPY Cargo.toml Cargo.lock ./
COPY src ./src
COPY migrations ./migrations
COPY dist ./dist

RUN cargo install --locked --path .
RUN cargo install --locked sqlx-cli --no-default-features --features rustls,postgres

FROM debian:bookworm-slim as runner
WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/cargo/bin/level-thumbnails-server /usr/local/bin/level-thumbnails-server
COPY --from=builder /usr/local/cargo/bin/sqlx /usr/local/bin/sqlx
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/migrations ./migrations

RUN mkdir -p /app/logs /app/uploads /app/thumbnails

ENV RUST_LOG=info
EXPOSE 3000
VOLUME ["/app/logs", "/app/uploads", "/app/thumbnails"]

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=5 \
    CMD wget -qO- http://127.0.0.1:3000/stats || exit 1

CMD ["level-thumbnails-server"]

