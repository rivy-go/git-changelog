//go:build go1.12 && !go1.18
// +build go1.12,!go1.18

package main

import (
	"runtime/debug"
)

// ref: [Go 1.18 debug/buildinfo features](https://shibumi.dev/posts/go-18-feature) @@ <https://archive.is/4LeZV>
// ref: [How to include Git version information in Go](https://blog.carlmjohnson.net/post/2023/golang-git-hash-how-to) @@ <https://archive.is/SmRbl>
// ref: <https://stackoverflow.com/questions/71642366/how-do-you-read-debug-vcs-version-info-from-a-go-1-18-binary> @@ <https://archive.is/CF6yk>

// `debug.BuildInfo` is available from Go 1.12

func version_impl(_options FnVersionOptions) string {
	if info, ok := debug.ReadBuildInfo(); ok {
		if info.Main.Version != "" && (info.Main.Version != "(devel)" /* a local build */) {
			return info.Main.Version
		}
	}
	if VersionFromBuilder != "" {
		return VersionFromBuilder
	}
	return Version + "+"
}
