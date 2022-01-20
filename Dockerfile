FROM quay.io/gattytto/rust:latest as builder
# Create appuser
ENV USER=rust
ENV UID=10001

RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    "${USER}"

RUN export DEBIAN_FRONTEND=noninteractive && rustup component add rustfmt && apt-get install -y --no-install-recommends tzdata && apt update && apt install -y libssl-dev libudev-dev pkg-config zlib1g-dev llvm clang make git && \
    git clone https://github.com/solana-labs/solana.git && cd solana && \
    cargo build --release && \
    ls -alh target
FROM scratch
WORKDIR /
# Import from builder.
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group
COPY --from=builder /solana/target/release ./
USER rust:rust

