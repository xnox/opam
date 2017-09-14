#!/bin/bash -uex

# This script is expected to run on Linux with docker available, and to have two
# remotes "some-osx" and "some-openbsd", with the corresponding OSes, ocaml deps
# and glpk installed

cd $(dirname $0)
if [[ $# -eq 0 || "x$1" =~ "x-" ]]; then
    echo "Usage: $0 TAG [archive|builds]"
    exit 1
fi

TAG="$1"; shift

if [[ $# -eq 0 || " $* " =~ " archive " ]]; then
  make TAG="$TAG" GIT_URL="https://github.com/ocaml/opam.git" "out/opam-full-$TAG.tar.gz"
  git-upload-release ocaml opam "$TAG" out/opam-full-2.0.0-beta4.tar.gz
fi

if [[ $# -eq 0 || " $* " =~ " builds " ]]; then
  make TAG="$TAG" all &
  make TAG="$TAG" remote REMOTE=some-osx REMOTE_DIR=opam-release &
  make TAG="$TAG" remote REMOTE=some-openbsd REMOTE_MAKE=gmake REMOTE_DIR=opam-release &
  wait
  for f in out/opam-$TAG-*; do
      git-upload-release ocaml opam "$TAG" $f
  done
fi