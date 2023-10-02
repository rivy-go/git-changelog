//go:build !go1.12
// +build !go1.12

package main

func version_impl(_option FnVersionOptions) string {
	if VersionFromBuilder != "" {
		return VersionFromBuilder
	}
	return Version + "+"
}
