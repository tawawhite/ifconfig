FROM alpine:edge as base
WORKDIR /src
RUN apk add --no-cache crystal shards libressl-dev libc-dev zlib-dev
COPY . .
RUN shards install --production
RUN crystal build --release --static src/ifconfig.cr

# Move built binary to minimal image to reduce size
FROM scratch
COPY --from=base /src/ifconfig /ifconfig
CMD ["/ifconfig"]