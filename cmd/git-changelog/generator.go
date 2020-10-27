package main

import (
	"io"

	changelog "github.com/rivy-go/git-changelog/internal/changelog"
)

// Generator ...
type Generator interface {
	Generate(io.Writer, string, *changelog.Config) error
}

type generatorImpl struct{}

// NewGenerator ...
func NewGenerator() Generator {
	return &generatorImpl{}
}

// Generate ...
func (*generatorImpl) Generate(w io.Writer, query string, config *changelog.Config) error {
	return changelog.NewGenerator(config).Generate(w, query)
}
