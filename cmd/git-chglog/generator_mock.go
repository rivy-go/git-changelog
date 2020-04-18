package main

import (
	"io"

	chglog "github.com/rivy-go/git-chglog/internal/chglog"
)

type mockGeneratorImpl struct {
	ReturnGenerate func(io.Writer, string, *chglog.Config) error
}

func (m *mockGeneratorImpl) Generate(w io.Writer, query string, config *chglog.Config) error {
	return m.ReturnGenerate(w, query, config)
}
