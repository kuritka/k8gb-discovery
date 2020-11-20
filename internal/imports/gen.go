// Package imports is responsible for downloading and pre-compiling go modules, see: Dockerfile
package imports

//go:generate bash -c "cd $(mktemp -d) && GO111MODULE=on go get github.com/edwarnicke/imports-gen@v1.1.0"

//go:generate bash -c "GOOS=linux ${GOPATH}/bin/imports-gen"
