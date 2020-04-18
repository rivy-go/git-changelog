#!/bin/bash

REPO_ROOT=$(git rev-parse --show-toplevel)

echo "Start release ..."

gox -os="darwin linux windows" -arch="amd64 386" -output="$REPO_ROOT/dist/{{.Dir}}_{{.OS}}_{{.Arch}}" ./cmd/git-changelog
ghr --username git-changelog --token $GITHUB_TOKEN --replace `grep 'Version =' ./cmd/git-changelog/version.go | sed -E 's/.*"(.+)"$$/\1/'` dist/

echo "Released!"
