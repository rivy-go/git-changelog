package changelog

import (
	"sort"
	"strings"
)

type commitExtractor struct {
	opts *Options
}

func newCommitExtractor(opts *Options) *commitExtractor {
	return &commitExtractor{
		opts: opts,
	}
}

func (e *commitExtractor) Extract(commits []*Commit) ([]*CommitGroup, []*Commit, []*Commit, []*NoteGroup) {
	commitGroups := []*CommitGroup{}
	noteGroups := []*NoteGroup{}
	mergeCommits := []*Commit{}
	revertCommits := []*Commit{}

	filteredCommits := commitFilter(commits, e.opts.CommitFilters, e.opts.NoCaseSensitive)

	for _, commit := range commits {
		if commit.Merge != nil {
			mergeCommits = append(mergeCommits, commit)
			continue
		}

		if commit.Revert != nil {
			revertCommits = append(revertCommits, commit)
			continue
		}
	}

	for _, commit := range filteredCommits {
		if commit.Merge == nil && commit.Revert == nil {
			e.processCommitGroups(&commitGroups, commit, e.opts.NoCaseSensitive)
		}

		e.processNoteGroups(&noteGroups, commit)
	}

	e.sortCommitGroups(commitGroups)
	e.sortNoteGroups(noteGroups)

	return commitGroups, mergeCommits, revertCommits, noteGroups
}

func (e *commitExtractor) processCommitGroups(groups *[]*CommitGroup, commit *Commit, noCaseSensitive bool) {
	var group *CommitGroup

	// commit group
	raw, ttl := e.commitGroupTitle(commit)

	for _, g := range *groups {
		rawTitleTmp := g.RawTitle
		if noCaseSensitive {
			rawTitleTmp = strings.ToLower(g.RawTitle)
		}

		rawTmp := raw
		if noCaseSensitive {
			rawTmp = strings.ToLower(raw)
		}
		if rawTitleTmp == rawTmp {
			group = g
		}
	}

	if group != nil {
		group.Commits = append(group.Commits, commit)
	} else if raw != "" {
		*groups = append(*groups, &CommitGroup{
			RawTitle: raw,
			Title:    ttl,
			Commits:  []*Commit{commit},
		})
	}
}

func (e *commitExtractor) processNoteGroups(groups *[]*NoteGroup, commit *Commit) {
	if len(commit.Notes) != 0 {
		for _, note := range commit.Notes {
			e.appendNoteToNoteGroups(groups, note)
		}
	}
}

func (e *commitExtractor) appendNoteToNoteGroups(groups *[]*NoteGroup, note *Note) {
	exist := false

	for _, g := range *groups {
		if g.Title == note.Title {
			exist = true
			g.Notes = append(g.Notes, note)
		}
	}

	if !exist {
		*groups = append(*groups, &NoteGroup{
			Title: note.Title,
			Notes: []*Note{note},
		})
	}
}

func (e *commitExtractor) commitGroupTitle(commit *Commit) (string, string) {
	var (
		raw string
		ttl string
	)

	if title, ok := dotGet(commit, e.opts.CommitGroupBy); ok {
		if v, ok := title.(string); ok {
			raw = v
			if t, ok := e.opts.CommitGroupTitleMaps[v]; ok {
				ttl = t
			} else {
				ttl = strings.Title(raw)
			}
		}
	}

	return raw, ttl
}

func (e *commitExtractor) sortCommitGroups(groups []*CommitGroup) {
	// groups
	sort.SliceStable(groups, func(i, j int) bool {
		var (
			a, b interface{}
			ok   bool
		)

		a, ok = dotGet(groups[i], e.opts.CommitGroupSortBy)
		if !ok {
			return false
		}

		b, ok = dotGet(groups[j], e.opts.CommitGroupSortBy)
		if !ok {
			return false
		}

		res, err := compare(a, "<", b)
		if err != nil {
			return false
		}
		return res
	})

	// commits
	for _, group := range groups {
		// initial sorting is `git log ...` dependant; generally in a topologic child-parent order
		// ... ref: <https://stackoverflow.com/questions/8576503/how-can-i-make-git-log-order-based-on-authors-timestamp> @@ <>
		// ... ref: <http://thesimplesynthesis.com/post/how-to-sort-git-commits-by-author-date>@@<https://archive.is/DPPpw>
		// ...maybe... // presort for consistency/stability
		// // * sort by `Hash.Long` (unique) and then `Subject` (semi-unique, more visible, better for UI/UX) traits
		// // ToDO: [2024-04-21; rivy] explore using a `sort_by` array of fields in config (w/o breaking the current behavior)
		// // ToDO: [2024-04-21; rivy] explore adding more Author/Committer info for sorting (eg, AuthorDate, CommitterData)
		// sort.SliceStable(group.Commits, func(i, j int) bool {
		// 	return strings.ToLower(group.Commits[i].Hash.Long) < strings.ToLower(group.Commits[j].Hash.Long)
		// })
		// sort.SliceStable(group.Commits, func(i, j int) bool {
		// 	return strings.ToLower(group.Commits[i].Subject) < strings.ToLower(group.Commits[j].Subject)
		// })
		sort.SliceStable(group.Commits, func(i, j int) bool {
			var (
				a, b interface{}
				ok   bool
			)

			a, ok = dotGet(group.Commits[i], e.opts.CommitSortBy)
			if !ok {
				return false
			}

			b, ok = dotGet(group.Commits[j], e.opts.CommitSortBy)
			if !ok {
				return false
			}

			res, err := compare(a, "<", b)
			if err != nil {
				return false
			}
			return res
		})
	}
}

func (e *commitExtractor) sortNoteGroups(groups []*NoteGroup) {
	// groups
	sort.SliceStable(groups, func(i, j int) bool {
		return strings.ToLower(groups[i].Title) < strings.ToLower(groups[j].Title)
	})

	// notes
	for _, group := range groups {
		sort.SliceStable(group.Notes, func(i, j int) bool {
			return strings.ToLower(group.Notes[i].Title) < strings.ToLower(group.Notes[j].Title)
		})
	}
}
