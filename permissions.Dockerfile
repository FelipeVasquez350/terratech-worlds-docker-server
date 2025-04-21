FROM debian:bookworm-slim AS fix-perms

RUN apt-get update && \
    apt-get install -y --no-install-recommends coreutils && \
    rm -rf /var/lib/apt/lists/*

COPY fix-perms.sh /fix-perms.sh

RUN chmod +x /fix-perms.sh

ENTRYPOINT ["/fix-perms.sh"]
