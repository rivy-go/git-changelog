package main

import (
	"fmt"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestConfigBuilder(t *testing.T) {
	assert := assert.New(t)
	builder := NewConfigBuilder()

	out, err := builder.Build(&Answer{
		RepositoryURL:       "https://github.com/rivy-go/git-changelog/git-changelog/",
		Style:               styleNone,
		CommitMessageFormat: fmtGitBasic.display,
		Template:            tplStandard.display,
	})

	assert.Nil(err)
	assert.Contains(out, "style: none")
	assert.Contains(out, "template: CHANGELOG.tpl.md")
	assert.Contains(out, "  repository_url: https://github.com/rivy-go/git-changelog/git-changelog")
	assert.Contains(out, fmt.Sprintf("    pattern: \"%s\"", fmtGitBasic.pattern))
	assert.Contains(out, fmt.Sprintf(
		`    pattern_maps:
      - %s
      - %s`,
		fmtGitBasic.patternMaps[0],
		fmtGitBasic.patternMaps[1],
	))
}

func TestConfigBuilderEmptyRepoURL(t *testing.T) {
	assert := assert.New(t)
	builder := NewConfigBuilder()

	out, err := builder.Build(&Answer{
		RepositoryURL:       "",
		Style:               styleNone,
		CommitMessageFormat: fmtGitBasic.display,
		Template:            tplStandard.display,
	})

	assert.Nil(err)
	assert.Contains(out, "  repository_url: \"\"")
}

func TestConfigBuilderInvalidFormat(t *testing.T) {
	assert := assert.New(t)
	builder := NewConfigBuilder()

	_, err := builder.Build(&Answer{
		RepositoryURL:       "",
		Style:               styleNone,
		CommitMessageFormat: "",
		Template:            tplStandard.display,
	})

	assert.Contains(err.Error(), "invalid commit message format")
}
