FROM --platform=linux/amd64 debian:bookworm-slim

COPY --from=game/base-img /root/server/ /bin

CMD ["memoir-3167.bin", "--verbose"]
