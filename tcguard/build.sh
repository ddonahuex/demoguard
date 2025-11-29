#!/bin/sh
set -eux

mkdir -p out
go build -o out/hello-melange-apko ./hello-melange/apko/go
