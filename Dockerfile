ARG ARCH="amd64"
ARG OS="linux"

FROM golang:1.20 AS build
ENV CGO_ENABLED=0
RUN apt-get update && apt-get install -y patch
WORKDIR /go/src/github.com/allanhung/coredns-crd-plugin
COPY . /go/src/github.com/allanhung/coredns-crd-plugin
RUN make build

FROM alpine:3.14.2
COPY --from=build /go/src/github.com/allanhung/coredns-crd-plugin/coredns /
EXPOSE 53 53/udp
ENTRYPOINT ["/coredns"]
