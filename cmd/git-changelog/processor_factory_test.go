package main

import (
	"testing"

	changelog "github.com/rivy-go/git-changelog/internal/changelog"
	"github.com/stretchr/testify/assert"
)

func TestProcessorFactory(t *testing.T) {
	assert := assert.New(t)
	factory := NewProcessorFactory()

	processor, err := factory.Create(&Config{
		Info: Info{
			RepositoryURL: "https://example.com/owner/repo",
		},
	})

	assert.Nil(err)
	assert.Nil(processor)
}

func TestProcessorFactoryForGitHub(t *testing.T) {
	assert := assert.New(t)
	factory := NewProcessorFactory()

	// github.com
	processor, err := factory.Create(&Config{
		Info: Info{
			RepositoryURL: "https://github.com/owner/repo",
		},
	})

	assert.Nil(err)
	assert.Equal(
		&changelog.GitHubProcessor{
			Host: "https://github.com",
		},
		processor,
	)

	// ghe
	processor, err = factory.Create(&Config{
		Style: "github",
		Info: Info{
			RepositoryURL: "https://ghe-example.com/owner/repo",
		},
	})

	assert.Nil(err)
	assert.Equal(
		&changelog.GitHubProcessor{
			Host: "https://ghe-example.com",
		},
		processor,
	)
}

func TestProcessorFactoryForGitLab(t *testing.T) {
	assert := assert.New(t)
	factory := NewProcessorFactory()

	// gitlab.com
	processor, err := factory.Create(&Config{
		Info: Info{
			RepositoryURL: "https://gitlab.com/owner/repo",
		},
	})

	assert.Nil(err)
	assert.Equal(
		&changelog.GitLabProcessor{
			Host: "https://gitlab.com",
		},
		processor,
	)

	// self-hosted
	processor, err = factory.Create(&Config{
		Style: "gitlab",
		Info: Info{
			RepositoryURL: "https://original-gitserver.com/owner/repo",
		},
	})

	assert.Nil(err)
	assert.Equal(
		&changelog.GitLabProcessor{
			Host: "https://original-gitserver.com",
		},
		processor,
	)
}

func TestProcessorFactoryForBitbucket(t *testing.T) {
	assert := assert.New(t)
	factory := NewProcessorFactory()

	// bitbucket.org
	processor, err := factory.Create(&Config{
		Info: Info{
			RepositoryURL: "https://bitbucket.org/owner/repo",
		},
	})

	assert.Nil(err)
	assert.Equal(
		&changelog.BitbucketProcessor{
			Host: "https://bitbucket.org",
		},
		processor,
	)

	// self-hosted
	processor, err = factory.Create(&Config{
		Style: "bitbucket",
		Info: Info{
			RepositoryURL: "https://original-gitserver.com/owner/repo",
		},
	})

	assert.Nil(err)
	assert.Equal(
		&changelog.BitbucketProcessor{
			Host: "https://original-gitserver.com",
		},
		processor,
	)
}
