default:
	go mod download
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o tftp
	# go build [-o output] [build flags] [packages]
	# The -o flag forces build to write the resulting executable or object to the named output file or directory,