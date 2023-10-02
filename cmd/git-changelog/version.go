package main

const Version = "1.1.0"

var VersionFromBuilder string // set by the build system, when needed (ie, for earlier golang versions)

// FnVersionOptions ~ optional arguments for `version()`
//  * `HashAbbrevLength` ~ target length of VCS revision hash abbreviation string (default: 8)
type FnVersionOptions struct {
	HashAbbrevLength int
}

// version()
// : RETURNS the version string (eg, '1.1.1', '1.1.1-abcdef01', or '1.1.1+') for the current build
//  * for `go install ...@VERSION`, the returned version string will be the published VERSION tag
//  * for local builds with VCS info, the returned version string will be [Version] with a VCS revision hash suffix
//  * for local builds w/o build info, the returned version string will be [Version] with a '+' suffix
//
// The returned version string will be as un-ambiguous as possible, exact/precise for remote builds and when VCS info is available.
func version(options ...FnVersionOptions) string {
	// risk of hash collision between commits:
	// 7-hex-character (28 bit) length: 1% at 3,000 commits, 17% at 10,000 commits
	// 8-hex-character (32 bit) length: 0.1% at 3,000 commits, 1% at 10,000 commits
	// 10-hex-character (40 bit) length: 0.1% at 47,000 commits, 1% at 150,000 commits
	// ref: <https://en.wikipedia.org/wiki/Birthday_problem> @@ <https://archive.is/sqPqu>
	var option = FnVersionOptions{ HashAbbrevLength: 8 }
	if len(options) > 0 {
		// option = options[0]
		option = options[len(options)-1]
	}
	return version_impl(option)
}
