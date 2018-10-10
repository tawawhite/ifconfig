FROM alpine:edge as base
WORKDIR /src
RUN apk add --no-cache crystal shards libressl-dev libc-dev zlib-dev
COPY . .
RUN shards install --production
RUN crystal build --release --static src/public-ip-api.cr

# Move built binary to minimal image to reduce size
FROM scratch
COPY --from=base /src/public-ip-api /public-ip-api
CMD ["/public-ip-api"]