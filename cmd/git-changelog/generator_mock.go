package main

import (
	"io"

	changelog "github.com/rivy-go/git-changelog/internal/changelog"
)

type mockGeneratorImpl struct {
	ReturnGenerate func(io.Writer, string, *changelog.Config) error
}

func (m *mockGeneratorImpl) Generate(w io.Writer, query string, config *changelog.Config) error {
	return m.ReturnGenerate(w, query, config)
}
