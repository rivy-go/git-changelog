{{- /* <!-- markdownlint-disable --><!-- spellchecker:ignore markdownlint --> */ -}}

{{- define "format-commit" -}}
* {{ if .Scope }}{{ .Type | smartLowerFirstWord }} *({{ .Scope }})*: {{ .Subject | smartLowerFirstWord }}{{ else }}{{ .Header | smartLowerFirstWord }}{{ end }} &ac; [`{{ .Hash.Short }}`]({{ commitURL .Hash.Long }})
{{ end -}}

{{- define "format-commit-group" }}
#### {{ .Title }}

{{ range .Commits }}{{ template "format-commit" . -}}{{ end -}}
{{ end -}}

<!-- markdownlint-disable --><!-- spellchecker:ignore markdownlint --><!-- spellchecker:disable -->

# CHANGELOG <br/> [{{ $.Info.Title }}]({{ $.Info.RepositoryURL }})

<div style="font-size: 0.8em">

> This project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).
> <br/>
> The changelog format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) using [conventional/semantic commits](https://nitayneeman.com/posts/understanding-semantic-commit-messages-using-git-and-angular).

</div>

{{- if .Unreleased.CommitGroups }}

---

{{/* <a name="unreleased"></a> */ -}}
## [Unreleased]
{{ range .Unreleased.CommitGroups }}{{ template "format-commit-group" . }}{{ end -}}
{{ end }}
<div id='last-line-of-prefix'></div>
{{- $first := true }}{{ range .Versions }}

---
{{ $output := false -}}
{{/* <a name="{{ .Tag.Name }}"></a> */}}
## {{ if .Tag.Previous }}[{{ .Tag.Name }}]({{ $.Info.RepositoryURL }}/compare/{{ .Tag.Previous.Name }}...{{ .Tag.Name }}){{ else }}{{ .Tag.Name }}{{ end }} <small>({{ datetime "2006-01-02" .Tag.Date }})</small>
{{ if and .Commits (index .Commits 0).Body }}
{{ (index .Commits 0).Body }}
{{ end }}
<details{{ if $first }} open{{ $first = false }}{{ end }}><summary><small><em>[{{ .Tag.Name }}; details]</em></small></summary>
{{ if .CommitGroups -}}
{{ range .CommitGroups }}{{ if eq .Title "Features" }}{{ $output = true }}{{ template "format-commit-group" . }}{{- end -}}{{- end -}}
{{ range .CommitGroups }}{{ if eq .Title "Enhancements" }}{{ $output = true }}{{ template "format-commit-group" . }}{{- end -}}{{- end -}}
{{ range .CommitGroups }}{{ if eq .Title "Changes" }}{{ $output = true }}{{ template "format-commit-group" . }}{{- end -}}{{- end -}}
{{ range .CommitGroups }}{{ if eq .Title "Fixes" }}{{ $output = true }}{{ template "format-commit-group" . }}{{- end -}}{{- end -}}
{{ range .CommitGroups }}{{ if not (eq .Title "Features" "Enhancements" "Changes" "Fixes") }}{{ $output = true }}{{ template "format-commit-group" . }}{{- end -}}{{- end -}}
{{- end -}}

{{ if .RevertCommits }}{{ $output = true }}
#### Reverts

{{ range .RevertCommits -}}
* {{ .Revert.Header }}
{{ end -}}
{{ end -}}

{{ if .MergeCommits }}{{ $output = true }}
#### Pull Requests

{{ range .MergeCommits -}}
* {{ .Header }}
{{ end -}}
{{ end -}}

{{ if .NoteGroups -}}{{ $output = true }}
{{ range .NoteGroups -}}
#### {{ .Title }}

{{ range .Notes }}
{{ .Body }}
{{ end -}}
{{ end -}}
{{ end -}}

{{- if not $output }}
<br/>

*No changelog for this release.*
{{ end }}
</details>
{{- end -}}
<br/>
