FROM quay.io/gattytto/rust:latest as builder
# Create appuser
USER root
RUN git clone https://github.com/solana-labs/solana.git; \
    git clone https://github.com/solana-labs/solana-program-library.git; 

RUN rustup toolchain add $RUST_VERSION; \
    export DEBIAN_FRONTEND=noninteractive; \
    rustup component add rustfmt; \
    apt-get install -y --no-install-recommends tzdata libudev-dev; \
    apt install -y --no-install-recommends libssl-dev libudev-dev pkg-config zlib1g-dev llvm clang make git; \
    cd solana; \
    cargo build --release; \
    cd .. ; \
    cd solana-program-library && export PATH=/solana/target/release:$PATH; \
    rm -rf ~/.cargo/registry/* && \
    cargo build-bpf --bpf-sdk /solana/sdk/bpf && ls target -alh
    
FROM scratch
WORKDIR /
# Import from builder.
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group
COPY --from=builder /solana/target/release ./solana
COPY --from=builder /solana-program-library/target/release ./solana/bpf
USER rust:rust

