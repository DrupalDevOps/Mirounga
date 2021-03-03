# VSD Makefile.

install: vsd.go
	go build && go install
	~/go/bin/vsd version
