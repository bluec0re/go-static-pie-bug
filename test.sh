#!/bin/sh
set -e

export PATH="$HOME/sdk/go1.17/bin:/usr/bin:/bin"

GO=$(command -v go)

export CGO_ENABLED=0
FLAGS=('-tags' 'netgo,osusergo,static_build' '-buildmode=pie' '-trimpath' '-ldflags' '-extldflags -static-pie -extld gcc -linkmode external')

echo mod
$GO clean -cache -modcache
(
  cd mod
  env -i GOOS=linux GOARCH=amd64 PATH=$PATH HOME=$HOME $GO build -mod=vendor "${FLAGS[@]}"
  env -i GOOS=linux GOARCH=amd64 PATH=$PATH HOME=$HOME $GO build -mod=vendor "${FLAGS[@]}" -o foo main.go
)

echo mod1.13
$GO clean -cache -modcache
(
  cd mod1.13
  env -i GOOS=linux GOARCH=amd64 PATH=$PATH HOME=$HOME $GO build -mod=vendor "${FLAGS[@]}"
  env -i GOOS=linux GOARCH=amd64 PATH=$PATH HOME=$HOME $GO build -mod=vendor "${FLAGS[@]}" -o foo main.go
)

echo path
$GO clean -cache -modcache
(
  cd path
  env -i PATH=$PATH HOME=$HOME GO111MODULE=off GOPATH=$PWD $GO build "${FLAGS[@]}" github.com/bluec0re/go-static-pie-bug
  env -i PATH=$PATH HOME=$HOME GO111MODULE=off GOPATH=$PWD $GO build "${FLAGS[@]}" -o foo src/github.com/bluec0re/go-static-pie-bug/main.go
)

file */go-static-pie-bug */foo
ldd */go-static-pie-bug */foo
grep --color -r 'This is not used' mod path

set +e
for b in ./*/go-static-pie-bug ./*/foo; do
  echo $b
  $b
done
