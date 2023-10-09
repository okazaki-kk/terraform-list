FROM golang:alpine AS builder
ADD ./src /work
WORKDIR /work
RUN go build -o happy main.go

FROM golang:alpine
COPY --from=builder /work/happy /usr/local/bin/happy
ENTRYPOINT ["/usr/local/bin/happy"]
