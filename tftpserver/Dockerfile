FROM golang:alpine AS build 
RUN mkdir /tftpboot
RUN apk update; apk add --no-cache git make build-base
ADD moby.txt /tftpboot
WORKDIR /build
COPY . .
# COPY go-tftp /go
# RUN go get github.com/mattn/go-sqlite3

# RUN go mod download
#"With no arguments, download applies to all dependencies of the main module."
#i.e."pack.ag/tftp" "log" "os" "io" 
RUN CGO_ENABLED=1 GOOS=linux GOARCH=amd64 go build -o tftp

RUN mv /build/tftp /tftp
# FROM scratch
# COPY --from=build /build/tftp tftp
# ENTRYPOINT ["/tftp"]
# EXPOSE 69
ENTRYPOINT ["/tftp"]