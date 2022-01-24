FROM quay.io/gattytto/rust:latest as builder
# Create appuser

RUN rustup toolchain add $RUST_VERSION; \
    export DEBIAN_FRONTEND=noninteractive; \
    rustup component add rustfmt; \
    apt-get install -y --no-install-recommends tzdata libudev-dev; \
    apt update && apt install -y libssl-dev libudev-dev pkg-config zlib1g-dev llvm clang make git; \
    git clone https://github.com/solana-labs/solana.git && cd solana; \
    cargo build --release; \
    git clone https://github.com/solana-labs/solana-program-library.git; \
    cd solana-program-library && export PATH=/solana/target/release:$PATH; \
    cargo build-bpf --bpf-sdk /solana/sdk/bpf 
    
FROM scratch
WORKDIR /
# Import from builder.
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group
COPY --from=builder /solana/target/release ./solana
COPY --from=builder /solana-program-library/target/release ./solana/bpf
USER rust:rust

