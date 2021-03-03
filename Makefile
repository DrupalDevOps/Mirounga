# VSD Makefile.

install: vsd.go
	go build && go install
	~/go/bin/vsd version

build:
	cd docker && ./scripts/build.sh

# Tools needed for Go extension in Visual Studio Code.
setup-vsc:
	go version
	go get github.com/uudashr/gopkgs/v2/cmd/gopkgs
	go get github.com/ramya-rao-a/go-outline
	go get golang.org/x/lint/golint
