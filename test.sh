#!/bin/bash
set -e

export PATH="/usr/bin:/bin"

GO=$(command -v go)

export CGO_ENABLED=0
FLAGS=('-tags' 'netgo,osusergo,static_build' '-buildmode=pie' '-trimpath' '-ldflags' '-extldflags -static-pie -extld gcc -linkmode external')

$GO version
$GO env

rm -f */foo */go-static-pie-bug

echo -e '\x1b[94m# mod\x1b[m'
$GO clean -cache -modcache
(
  cd mod
  echo -e " \x1b[94m# build\x1b[m"
  env -i GOOS=linux GOARCH=amd64 PATH=$PATH HOME=$HOME $GO build -mod=vendor "${FLAGS[@]}"
  echo -e " \x1b[94m# build -o foo.go main.go\x1b[m"
  env -i GOOS=linux GOARCH=amd64 PATH=$PATH HOME=$HOME $GO build -mod=vendor "${FLAGS[@]}" -o foo main.go
)

echo -e '\x1b[94m# path\x1b[m'
$GO clean -cache -modcache
(
  cd path
  echo -e " \x1b[94m# build\x1b[m"
  env -i PATH=$PATH HOME=$HOME GO111MODULE=off GOPATH=$PWD $GO build "${FLAGS[@]}" github.com/bluec0re/go-static-pie-bug
  echo -e " \x1b[94m# build -o foo.go main.go\x1b[m"
  env -i PATH=$PATH HOME=$HOME GO111MODULE=off GOPATH=$PWD $GO build "${FLAGS[@]}" -o foo src/github.com/bluec0re/go-static-pie-bug/main.go
)

echo -e '\x1b[94m# file\x1b[m'
file */go-static-pie-bug */foo
echo -e '\x1b[94m# ldd\x1b[m'
ldd */go-static-pie-bug */foo
echo -e '\x1b[94m# deadcode\x1b[m'
grep --color -r 'This is not used' mod path

echo -e '\x1b[94m# exec\x1b[m'
set +e
for b in ./*/go-static-pie-bug ./*/foo; do
  echo -e "\x1b[95m$b\x1b[m"
  $b
done
