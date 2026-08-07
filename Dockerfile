FROM debian:bookworm-slim

COPY --from=base-img /root/server/ /bin

CMD ["memoir-3167.bin"]
