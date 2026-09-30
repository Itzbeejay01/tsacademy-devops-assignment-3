FROM alpine:3.20

RUN apk add --no-cache \
    bash \
    bind-tools \
    coreutils \
    iputils \
    netcat-openbsd \
    procps

WORKDIR /app

COPY app/ /app/

RUN chmod +x /app/app.sh

ENTRYPOINT ["/app/app.sh"]
CMD ["help"]
