<!-- markdownlint-disable --><!-- spellchecker:ignore markdownlint --><!-- spellchecker:disable -->

# CHANGELOG <br/> [rivy-go/git-changelog](https://github.com/rivy-go/git-changelog)

<div style="font-size: 0.8em">

> This project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).
> <br/>
> The changelog format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) using [conventional/semantic commits](https://nitayneeman.com/posts/understanding-semantic-commit-messages-using-git-and-angular).

</div>
<div class="prefix"></div>

---

## [1.1.0](https://github.com/rivy-go/git-changelog/compare/1.0.0...1.1.0) <small>(2021-02-13)</small>

<details open><summary><small><em>[1.1.0; details]</em></small></summary>

#### Changes

* add '--next-tag-now' CLI option &ac; [`e3a58a0`](https://github.com/rivy-go/git-changelog/commit/e3a58a0f1076a628c0311805f03b0abaedd3cf9e)
* add 'Separator' field to Commit structure &ac; [`8d80c49`](https://github.com/rivy-go/git-changelog/commit/8d80c49186e56973c789bff812631196bc7d6b65)
* add 'smartLowerFirstWord' template function &ac; [`09fd4e5`](https://github.com/rivy-go/git-changelog/commit/09fd4e53dbcd741977d64f2a645686c9c6418adc)
* change ~ improve 'upperFirst' to effect first non-space character &ac; [`c47dac0`](https://github.com/rivy-go/git-changelog/commit/c47dac02b913b4ac2ce1cfe3f736a4b03ef15c4e)

#### Maintenance

* maint *(build)*: VSCode configuration update &ac; [`1e47489`](https://github.com/rivy-go/git-changelog/commit/1e474895cdbe52d39fe2798c459bb1bbfa2a5c78)
* maint *(deps)*: `go mod tidy` &ac; [`530970c`](https://github.com/rivy-go/git-changelog/commit/530970c7043b7277d8ae065345aa61498952df45)
* maint *(dev)*: (gitignore) ignore file history storage &ac; [`340ac99`](https://github.com/rivy-go/git-changelog/commit/340ac9988594dad20517b5f001d27ccc0a6fd857)
* maint *(dev)*: update .editorconfig &ac; [`39e1f48`](https://github.com/rivy-go/git-changelog/commit/39e1f4867fef71d03d73fef3bbaf56fe174361f8)
* maint *(dev)*: update VSCode settings &ac; [`1316480`](https://github.com/rivy-go/git-changelog/commit/1316480e1a68242c9f032f7904f7ae9a82547a02)
* maint *(polish)*: `make format` (ie, `go fmt`) whitespace standardization &ac; [`e8e9894`](https://github.com/rivy-go/git-changelog/commit/e8e989454c58edae4ee06865fa15f04314b8178e)
* maint *(polish)*: whitespace fixup &ac; [`dde4272`](https://github.com/rivy-go/git-changelog/commit/dde4272f1c153aea847505ddc168e1c208f37f59)

#### Refactoring

* refactor *(polish)*: fix CMD lint warnings (function exports and comments) &ac; [`1ce091a`](https://github.com/rivy-go/git-changelog/commit/1ce091a8d8a99820ef6f3127c6bf565aaf5b828f)

</details>

---

## [1.0.0](https://github.com/rivy-go/git-changelog/compare/0.9.1...1.0.0) <small>(2020-04-18)</small>

FORK! ~ project hard forked from `git-chglog/git-chglog`

* `git-changelog`

- added features
  - allows multiple possible header pattern matches
  - Commit.Type mapping/aggregation
  - add 'commitURL' template function
  - add 'unreleased' CLI flag (and now default to skipping unreleased commits)
  - allow zero tag/version matches without error
  - add Tag.Pattern as config-file option for `--tag-filter-pattern`
- modernize build methods and improve platform portability of builds
- improve code structure for better separation of concerns

.# [why]

This feature expansion was offered to the [original project](https://github.com/git-chglog/git-chglog/issues/53)
without response. So, in order to add the needed new features, as well as modernize build
methods and code structure, a hard fork was created and the utility renamed to
`git-changelog`.

To expound on the newly added features:

1. Multiple header pattern regex are allowed as an alternation with first matching.
    - this is useful to allow for mixed-commit message type repositories (especially those repositories which have multiple styles or are "in-transition" to a new style)
2. Adds Commit.Type mapping/aggregation (eg, 'add' => 'change', 'added' => 'change', etc).
    - useful for repositories with mixed-commit message formats
    - can aggregate different commit-types into a single category
    - uses "smart-case" matching which can be used to ignore case of commit-type (eg, `change: change` will match any case-variant of "change" [eg, "CHANGE', "Change", etc)
3. Adds a `commitURL()` template function which can map hashes to a repository-style URL.
    - useful for sub-templating individual commit formats
4. Adds a command-line option to control display of "unreleased" commits.
    - useful for generating the changelog automatically for automated builds
    - change the default to *not* show "unreleased" commits as that would be the most used case
        - also, adds `-u` to the command line options to easily process and display unreleased commits
5. Allows empty tags/versions without error if no query string is used.
    - useful for initial repositories without any tags and for unmatched tag/version patterns
    - still an error if a query is passed and no match is found
6. Adds a corresponding config file entry for the `--tag-filter-pattern` CLI option.
    - configuration file entries, as usual, will be overridden by the CLI option, if used

<details><summary><small><em>[1.0.0; details]</em></small></summary>

#### Features

* feat: add option to filter commits in a case insensitive way &ac; [`72fb3ea`](https://github.com/rivy-go/git-changelog/commit/72fb3eac14ad73a2a9ac82a679075bc9bfc72ea9)
* feat: add upperFirst template function &ac; [`495fa2d`](https://github.com/rivy-go/git-changelog/commit/495fa2de574c1d330aaebf7b48934f3b270ef6ea)
* feat: Add emoji format and some formatters in variables &ac; [`15ce9db`](https://github.com/rivy-go/git-changelog/commit/15ce9db03e27cca63a26e5f3d82920c2313fa8a9)
* feat: allow zero tags/versions without error &ac; [`d634b33`](https://github.com/rivy-go/git-changelog/commit/d634b33730339553afa80a2e8379f42d76bca3e6)
* feat: add `commitURL()` template function &ac; [`c2302b5`](https://github.com/rivy-go/git-changelog/commit/c2302b5a3079194f7d2779a9112c8fb6d51dd984)
* feat: add commit type mapping &ac; [`12b2197`](https://github.com/rivy-go/git-changelog/commit/12b2197f675c3b2f2c2b613f804edea124d71e3d)
* feat: add support for multiple alternate header regexs &ac; [`acd99ef`](https://github.com/rivy-go/git-changelog/commit/acd99ef3472b48d628b7c6d34765dabed72c4d25)
* feat: add Tag.Pattern as config-file option &ac; [`019a134`](https://github.com/rivy-go/git-changelog/commit/019a1341bfc10da4b0eb8b7a77fe2bc3a01557bb)
* feat *(API!)*: add 'unreleased' CLI flag (and now default to skipping unreleased commits) &ac; [`fcb25bf`](https://github.com/rivy-go/git-changelog/commit/fcb25bf230db40a4a432366951f44ed9ef64d3ce)

#### Changes

* change *(FORK!)*: FORK project (from 'git-chglog/git-chglog' to 'rivy-go/git-changelog'); now `git-changelog` &ac; [`abbd1b6`](https://github.com/rivy-go/git-changelog/commit/abbd1b62bd5959340e6acf6480c068be9645dd35)

#### Documentation

* docs ~ de-lint and polish README &ac; [`27367a9`](https://github.com/rivy-go/git-changelog/commit/27367a97a21bdb9bd822750abc917976a376da6b)
* docs ~ update project CHANGELOG auto-generator configuration (via `git-chglog`) &ac; [`1f89ae0`](https://github.com/rivy-go/git-changelog/commit/1f89ae0c1c55154a6f3b8792137f320ac0d34ad4)
* docs: Markdown tweaks in README.md &ac; [`ec5cdfe`](https://github.com/rivy-go/git-changelog/commit/ec5cdfeea22263682a81c3dead988d141c4f64e6)
* docs: Update CHANGELOG &ac; [`6050f20`](https://github.com/rivy-go/git-changelog/commit/6050f20bcdb0cb4915ffd5a36efdefa29989861d)
* docs *(polish)*: README whitespace cleanup &ac; [`26b5bf7`](https://github.com/rivy-go/git-changelog/commit/26b5bf75276bba99a5288041e22bd6d705314a78)

#### Maintenance

* build ~ configure VSCode debugging of CLI &ac; [`5e5e4ba`](https://github.com/rivy-go/git-changelog/commit/5e5e4ba31a93e17cb1e858b54c5e84ba28448388)
* maint ~ update `git-chglog` configuration &ac; [`7b926be`](https://github.com/rivy-go/git-changelog/commit/7b926be3a13b1a36d093d47b1f145d019ca57aaa)
* maint ~ FIXME/broken test &ac; [`735e907`](https://github.com/rivy-go/git-changelog/commit/735e907c54c8b9649e74e18d2d180dd1c542ebc6)
* maint *(build)*: convert project from using `dep` to Go Modules for dependencies &ac; [`41ffd9a`](https://github.com/rivy-go/git-changelog/commit/41ffd9a628a5fcd7ee86df238e982a00eeb840c7)
* maint *(build)*: add 'format' and 'lint' Makefile targets (code hygiene helpers) &ac; [`f7968be`](https://github.com/rivy-go/git-changelog/commit/f7968bee408572928150fe507868ef72642e6a3a)
* maint *(build)*: convert to a cross-platform 'Makefile' &ac; [`966b077`](https://github.com/rivy-go/git-changelog/commit/966b07731570e5228b0b234f25d34cd7d0cb9e51)
* maint *(build)*: re-vendor dependencies (via `go mod vendor`) &ac; [`3036c56`](https://github.com/rivy-go/git-changelog/commit/3036c5654426ae2f31af01aa3b550a440201cfac)
* maint *(dev)*: update .editorconfig &ac; [`4eb3d10`](https://github.com/rivy-go/git-changelog/commit/4eb3d10a7138560a9c7ef0b4902330354e6d7393)
* maint *(polish)*: whitespace cleanup &ac; [`3331b52`](https://github.com/rivy-go/git-changelog/commit/3331b52d8f489e9879855f42a2c27b71253d26c4)

#### Refactoring

* refactor ~ improve grouping/organization of package source code files &ac; [`db06c29`](https://github.com/rivy-go/git-changelog/commit/db06c295f056b3f41be86f897afc79d46bb732a3)

#### Pull Requests

* Merge pull request [#65](https://github.com/rivy-go/git-changelog/issues/65) from barryib/case-sensitive-option
* Merge pull request [#59](https://github.com/rivy-go/git-changelog/issues/59) from momotaro98/feature/add-emoji-template-in-init
* Merge pull request [#66](https://github.com/rivy-go/git-changelog/issues/66) from barryib/add-upper-first-func
* Merge pull request [#68](https://github.com/rivy-go/git-changelog/issues/68) from unixorn/tweak-readme

</details>

---

## [0.9.1](https://github.com/rivy-go/git-changelog/compare/0.9.0...0.9.1) <small>(2019-09-23)</small>

<details><summary><small><em>[0.9.1; details]</em></small></summary>

<br/>

*No changelog for this release.*

</details>

---

## [0.9.0](https://github.com/rivy-go/git-changelog/compare/0.8.0...0.9.0) <small>(2019-09-23)</small>

feat: Add --tag-filter-pattern flag.

<details><summary><small><em>[0.9.0; details]</em></small></summary>

#### Features

* feat: Add --tag-filter-pattern flag. &ac; [`1198e28`](https://github.com/rivy-go/git-changelog/commit/1198e283de00a32746be4dca6ac9ce688d7bfb9e)

#### Fixes

* fix: Fixing tests on windows &ac; [`f5df8fa`](https://github.com/rivy-go/git-changelog/commit/f5df8faf8b6a328107fc5142a7ef36dae28fdeb5)

#### Documentation

* docs: Add windows installation &ac; [`af1f714`](https://github.com/rivy-go/git-changelog/commit/af1f71410a8e27d529bf880dcab2d2e37a0d29f0)

#### Pull Requests

* Merge pull request [#44](https://github.com/rivy-go/git-changelog/issues/44) from evanchaoli/tag-filter
* Merge pull request [#41](https://github.com/rivy-go/git-changelog/issues/41) from StanleyGoldman/fixing-tests-windows
* Merge pull request [#37](https://github.com/rivy-go/git-changelog/issues/37) from ForkingSyndrome/master

</details>

---

## [0.8.0](https://github.com/rivy-go/git-changelog/compare/0.7.1...0.8.0) <small>(2019-02-23)</small>

<details><summary><small><em>[0.8.0; details]</em></small></summary>

#### Features

* feat: add the contains, hasPrefix, hasSuffix, replace, lower and upper functions to the template functions map &ac; [`dc12802`](https://github.com/rivy-go/git-changelog/commit/dc128028e64f6413fa3b191b97c9f76471c21a63)

#### Pull Requests

* Merge pull request [#34](https://github.com/rivy-go/git-changelog/issues/34) from atosatto/template-functions

</details>

---

## [0.7.1](https://github.com/rivy-go/git-changelog/compare/0.7.0...0.7.1) <small>(2018-11-10)</small>

<details><summary><small><em>[0.7.1; details]</em></small></summary>

#### Fixes

* fix: Panic occured when exec --next-tag with HEAD with tag &ac; [`e407b9a`](https://github.com/rivy-go/git-changelog/commit/e407b9a96ee3ce2a685e89cdb536404ec8ca1cb9)

#### Documentation

* docs: Fix typo &ac; [`f53bfcc`](https://github.com/rivy-go/git-changelog/commit/f53bfccee07433c440884ecc8853dc9981f0a9d5)

#### Pull Requests

* Merge pull request [#31](https://github.com/rivy-go/git-changelog/issues/31) from drubin/patch-1
* Merge pull request [#30](https://github.com/rivy-go/git-changelog/issues/30) from vvakame/fix-panic

</details>

---

## [0.7.0](https://github.com/rivy-go/git-changelog/compare/0.6.0...0.7.0) <small>(2018-05-06)</small>

<details><summary><small><em>[0.7.0; details]</em></small></summary>

#### Features

* feat: Add URL of output example for template style &ac; [`87df4b4`](https://github.com/rivy-go/git-changelog/commit/87df4b477c0f1b860f09d1e752d451ed042c2399)
* feat: Add `--next-tag` flag (experimental) &ac; [`f8f4ccb`](https://github.com/rivy-go/git-changelog/commit/f8f4ccb8b764ed22270ec86d43f4406e6fb57bc8)

#### Fixes

* fix: Remove accidentally added `Unreleased.Tag` &ac; [`7a71844`](https://github.com/rivy-go/git-changelog/commit/7a71844c6f73e65e271af187ee14f8dbe610adea)

#### Documentation

* docs: Fix typo &ac; [`4046d94`](https://github.com/rivy-go/git-changelog/commit/4046d94b7c58f3d9e813ebfc6911882d3e30a1a9)
* docs: Add document related on `--next-tag` &ac; [`83ccab2`](https://github.com/rivy-go/git-changelog/commit/83ccab2905e0296f343fec8e15555f8d5fc45097)

#### Maintenance

* chore: Update `changelog` task in Makefile &ac; [`5ad4cab`](https://github.com/rivy-go/git-changelog/commit/5ad4cab29873be97762eb9d4b2a29e0be51a68f1)

#### Test Improvements

* test: Change output test of chglog to keep-a-changelog &ac; [`d008bef`](https://github.com/rivy-go/git-changelog/commit/d008bef7fb1a50bb02dbf06deb5b539c6c996b9a)
* test: Refactor for chglog test code &ac; [`36cf6bc`](https://github.com/rivy-go/git-changelog/commit/36cf6bce12154394db9e67419af522af192d3b6b)

#### Pull Requests

* Merge pull request [#22](https://github.com/rivy-go/git-changelog/issues/22) from git-chglog/feat/add-preview-style-link
* Merge pull request [#21](https://github.com/rivy-go/git-changelog/issues/21) from git-chglog/feat/next-tag

</details>

---

## [0.6.0](https://github.com/rivy-go/git-changelog/compare/0.5.0...0.6.0) <small>(2018-05-04)</small>

<details><summary><small><em>[0.6.0; details]</em></small></summary>

#### Features

* feat: Add tag name header id for keep-a-changelog template &ac; [`481f6c0`](https://github.com/rivy-go/git-changelog/commit/481f6c0770b61577e91ba0a1a0101ce77fc3c422)

#### Documentation

* docs: docs: Update template example for README &ac; [`bcfe4d2`](https://github.com/rivy-go/git-changelog/commit/bcfe4d23cf34d0a7209be4766499eb77b9b1cee2)

#### Maintenance

* chore: Update CHANGELOG template format &ac; [`f97c6a0`](https://github.com/rivy-go/git-changelog/commit/f97c6a022e7c106fb2e796838d76c0de8e535882)

#### Pull Requests

* Merge pull request [#20](https://github.com/rivy-go/git-changelog/issues/20) from git-chglog/feat/kac-template-title-id

</details>

---

## [0.5.0](https://github.com/rivy-go/git-changelog/compare/0.4.0...0.5.0) <small>(2018-05-04)</small>

<details><summary><small><em>[0.5.0; details]</em></small></summary>

#### Features

* feat: Update template format to human readable &ac; [`25c4182`](https://github.com/rivy-go/git-changelog/commit/25c41823a330239b3b2f835a8b4fcd3974328e2c)
* feat: Add `Unreleased` field to `RenderData` &ac; [`5ce1760`](https://github.com/rivy-go/git-changelog/commit/5ce1760d0f0638731a5b12a09b3d6fa8b10a24e2)

#### Fixes

* fix: Add unreleased commits section to keep-a-changelog template [#15](https://github.com/rivy-go/git-changelog/issues/15) &ac; [`d3e1f56`](https://github.com/rivy-go/git-changelog/commit/d3e1f56e9164974d99de4d6f7ce4b101fe234d84)

#### Documentation

* docs: Update template example for README &ac; [`3f49f93`](https://github.com/rivy-go/git-changelog/commit/3f49f9338fcee6a1ca3e4d65de7575bd31e73269)
* docs: Fix markdown table format &ac; [`f65b08d`](https://github.com/rivy-go/git-changelog/commit/f65b08d1f6a3a99a59bf0301377f6a72b5aa446c)
* docs: Fix "style" markdown format &ac; [`d44e8cc`](https://github.com/rivy-go/git-changelog/commit/d44e8ccdcb6558b9621e14752211bb8872418e53)

#### Maintenance

* chore: Update CHANGELOG template format &ac; [`5564081`](https://github.com/rivy-go/git-changelog/commit/55640815838e09ffd15fbcae7ce59f71e155d6f8)

#### Pull Requests

* Merge pull request [#19](https://github.com/rivy-go/git-changelog/issues/19) from git-chglog/fix/unreleased-commits
* Merge pull request [#18](https://github.com/rivy-go/git-changelog/issues/18) from ringohub/master

</details>

---

## [0.4.0](https://github.com/rivy-go/git-changelog/compare/0.3.3...0.4.0) <small>(2018-04-14)</small>

<details><summary><small><em>[0.4.0; details]</em></small></summary>

#### Features

* feat: Add support for Bitbucket &ac; [`21ae9e8`](https://github.com/rivy-go/git-changelog/commit/21ae9e83883133fabdf828863864e2ad9dabd0df)

#### Documentation

* docs: Update `--init` gif animation &ac; [`ab4e0f6`](https://github.com/rivy-go/git-changelog/commit/ab4e0f6039ba65a2c58758ff88971e8001bd9ab5)
* docs: Add Bitbucket section &ac; [`a00a2f2`](https://github.com/rivy-go/git-changelog/commit/a00a2f206fbc71f4b71a54d98c8867976138c288)

#### Pull Requests

* Merge pull request [#17](https://github.com/rivy-go/git-changelog/issues/17) from git-chglog/feat/bitbucket

</details>

---

## [0.3.3](https://github.com/rivy-go/git-changelog/compare/0.3.2...0.3.3) <small>(2018-04-07)</small>

<details><summary><small><em>[0.3.3; details]</em></small></summary>

#### Features

* feat: Change to kindly error message when git-tag does not exist &ac; [`82d0df1`](https://github.com/rivy-go/git-changelog/commit/82d0df16a8178e1fac607eb76c24d4784e90b34f)

#### Documentation

* docs: Update TODO List &ac; [`588c3d0`](https://github.com/rivy-go/git-changelog/commit/588c3d0a41053b0e92ec436bb7c488d18f291cb0)

#### Pull Requests

* Merge pull request [#16](https://github.com/rivy-go/git-changelog/issues/16) from git-chglog/fix/empty-tag-handling

</details>

---

## [0.3.2](https://github.com/rivy-go/git-changelog/compare/0.3.1...0.3.2) <small>(2018-04-02)</small>

<details><summary><small><em>[0.3.2; details]</em></small></summary>

#### Fixes

* fix: Fix color output bug in windows help command &ac; [`e304986`](https://github.com/rivy-go/git-changelog/commit/e30498689cafb07a1fa09c640e45cbd3a005fef4)

#### Pull Requests

* Merge pull request [#14](https://github.com/rivy-go/git-changelog/issues/14) from git-chglog/fix/windows-help-color

</details>

---

## [0.3.1](https://github.com/rivy-go/git-changelog/compare/0.3.0...0.3.1) <small>(2018-03-15)</small>

<details><summary><small><em>[0.3.1; details]</em></small></summary>

#### Fixes

* fix: fix preview string of commit subject &ac; [`b217d78`](https://github.com/rivy-go/git-changelog/commit/b217d782ebc4c2facc5047836a9aa26f5701e083)

#### Pull Requests

* Merge pull request [#13](https://github.com/rivy-go/git-changelog/issues/13) from kt3k/feature/fix-preview

</details>

---

## [0.3.0](https://github.com/rivy-go/git-changelog/compare/0.2.0...0.3.0) <small>(2018-03-12)</small>

<details><summary><small><em>[0.3.0; details]</em></small></summary>

#### Features

* feat: Add support for GitLab &ac; [`45ed6e3`](https://github.com/rivy-go/git-changelog/commit/45ed6e3ee29ace0acb516ad1fb168aad11cce404)

#### Documentation

* docs: Add document related to GitLab &ac; [`0a623f3`](https://github.com/rivy-go/git-changelog/commit/0a623f3f618396f9a297ff60dc5cb19d91116ad4)
* docs: Fix old template section in document &ac; [`d446571`](https://github.com/rivy-go/git-changelog/commit/d446571b8c5dc54e790ea8b054d2c7b4be22c231)

#### Maintenance

* chore: Add helper task for generate CHANGELOG &ac; [`081aa8d`](https://github.com/rivy-go/git-changelog/commit/081aa8df602943282e0f1c7b68ba07118477eeb3)

#### Pull Requests

* Merge pull request [#12](https://github.com/rivy-go/git-changelog/issues/12) from git-chglog/feat/gitlab

</details>

---

## [0.2.0](https://github.com/rivy-go/git-changelog/compare/0.1.0...0.2.0) <small>(2018-03-02)</small>

<details><summary><small><em>[0.2.0; details]</em></small></summary>

#### Features

* feat: Add template for `Keep a changelog` to the `--init` option &ac; [`ed6fb27`](https://github.com/rivy-go/git-changelog/commit/ed6fb2722ea84db8b9349d1bff61285cf5c0878d)
* feat: Supports vim like `j/k` keybind with item selection of `--init` &ac; [`790a2e6`](https://github.com/rivy-go/git-changelog/commit/790a2e6574e5f1d7af5fe2883ae3e7ee3da13093)

#### Documentation

* docs: Change CHANGELOG format to Keep a changelog &ac; [`7a004f8`](https://github.com/rivy-go/git-changelog/commit/7a004f88eb2be8ca88899e7e9332ddd42bb08ac0)
* docs: Add AppVeyor status badge &ac; [`dd838e8`](https://github.com/rivy-go/git-changelog/commit/dd838e86752a9fe046127074a32bc92f1101ab04)

#### Maintenance

* chore: Fix release flow (retry) &ac; [`4059813`](https://github.com/rivy-go/git-changelog/commit/40598132fcaecca49b0e38a8c904630ffc0de1ec)
* chore: Add AppVeyor config &ac; [`f9ab379`](https://github.com/rivy-go/git-changelog/commit/f9ab3795194698ad54cf24bf192b901487657dd8)

#### Test Improvements

* test: Pass all the test cases with windows &ac; [`98543fb`](https://github.com/rivy-go/git-changelog/commit/98543fb897a4837cf228e0b490861df27f43261a)

#### Pull Requests

* Merge pull request [#11](https://github.com/rivy-go/git-changelog/issues/11) from git-chglog/develop
* Merge pull request [#10](https://github.com/rivy-go/git-changelog/issues/10) from mattn/fix-test
* Merge pull request [#9](https://github.com/rivy-go/git-changelog/issues/9) from mattn/windows-color

</details>

---

## [0.1.0](https://github.com/rivy-go/git-changelog/compare/0.0.2...0.1.0) <small>(2018-02-25)</small>

<details><summary><small><em>[0.1.0; details]</em></small></summary>

#### Features

* feat: Supports annotated git-tag and adds `Tag.Subject` field [#3](https://github.com/rivy-go/git-changelog/issues/3) &ac; [`114b7d6`](https://github.com/rivy-go/git-changelog/commit/114b7d6fc8c5f6fda328e326bb961ed7f1609a62)
* feat: Remove commit message preview on select format &ac; [`7a6d2a0`](https://github.com/rivy-go/git-changelog/commit/7a6d2a015d2af3a94586757c67295209c60c979c)
* feat: Add Git Basic to commit message format &ac; [`25bb6e1`](https://github.com/rivy-go/git-changelog/commit/25bb6e17a18f2bb9d3d787b0abcecf7149c8babe)
* feat: Add preview to the commit message format of `--init` option &ac; [`a7d8646`](https://github.com/rivy-go/git-changelog/commit/a7d86469b9d399f1bf4e86059e6c55c03f14ef4c)

#### Fixes

* fix: Fix a bug that `Commit.Revert.Header` is not converted by `GitHubProcessor` &ac; [`d165ea8`](https://github.com/rivy-go/git-changelog/commit/d165ea884a56229be12eb81b2689210b64362b6e)
* fix: Fix error message when `Tag` can not be acquired &ac; [`b01be88`](https://github.com/rivy-go/git-changelog/commit/b01be882302ad42915ea4462ebc895cd76b4a1f8)
* fix a small typo, no content changes &ac; [`6566949`](https://github.com/rivy-go/git-changelog/commit/65669492a0516c9921ff9e905b142ebb987ae354)
* fix: Fix `Revert` of template created by Initializer &ac; [`aa5cf09`](https://github.com/rivy-go/git-changelog/commit/aa5cf0913d31d9f59fa71c08c4003fd115856421)

#### Documentation

* docs: Update `--init` gif animation &ac; [`8fb0c7f`](https://github.com/rivy-go/git-changelog/commit/8fb0c7f482a1aa2fdb99f13aee5c01c91dfeac31)
* docs: Add coveralls status badge &ac; [`7fe88a3`](https://github.com/rivy-go/git-changelog/commit/7fe88a3f613cbf4908bb4fa67098f9ecfd01d3b5)
* docs: Add contributing guide and Issues/PR templates &ac; [`ccd7250`](https://github.com/rivy-go/git-changelog/commit/ccd72509c673dee1963a8260ee9aff2c319d96cd)
* docs: Update `--init` option demo gif animation &ac; [`4910289`](https://github.com/rivy-go/git-changelog/commit/491028989e863701308fedeb25c68ba196a7309d)

#### Maintenance

* chore: Fix release scripts &ac; [`f8160a2`](https://github.com/rivy-go/git-changelog/commit/f8160a2b76ad0806434c2588f0c91b75e31d6477)
* chore: Remove unnecessary task &ac; [`1b2210d`](https://github.com/rivy-go/git-changelog/commit/1b2210dbca5deb3a9ab3e93b8765b51aca115955)
* chore: Add coverage measurement task for local confirmation &ac; [`b738561`](https://github.com/rivy-go/git-changelog/commit/b7385619d12a4201f276ff1ad179fa0c3b6fc1b0)
* chore: Change release method of git tag on TravisCI &ac; [`c7ca5ce`](https://github.com/rivy-go/git-changelog/commit/c7ca5ce738623c77d244a971ffadce8477760c9a)

#### Refactoring

* refactor: Refactor `Initializer` to testable &ac; [`8780cd1`](https://github.com/rivy-go/git-changelog/commit/8780cd12442b65b6931231933f77f5fd3e20a468)

#### Test Improvements

* test: Add coverage measurement using coveralls &ac; [`2b81993`](https://github.com/rivy-go/git-changelog/commit/2b81993531e2fbec2e502435120157efa12f2b36)
* test: Fix test which failed due to timezone difference &ac; [`96562bc`](https://github.com/rivy-go/git-changelog/commit/96562bcc9af4bebc55159acddf9768212198d13a)

#### Pull Requests

* Merge pull request [#8](https://github.com/rivy-go/git-changelog/issues/8) from git-chglog/feat/0.0.3
* Merge pull request [#6](https://github.com/rivy-go/git-changelog/issues/6) from git-chglog/chore/coverage
* Merge pull request [#4](https://github.com/rivy-go/git-changelog/issues/4) from paralax/patch-1
* Merge pull request [#5](https://github.com/rivy-go/git-changelog/issues/5) from git-chglog/develop
* Merge pull request [#1](https://github.com/rivy-go/git-changelog/issues/1) from git-chglog/develop

</details>

---

## [0.0.2](https://github.com/rivy-go/git-changelog/compare/0.0.1...0.0.2) <small>(2018-02-18)</small>

<details><summary><small><em>[0.0.2; details]</em></small></summary>

#### Documentation

* docs: Add CHANGELOG &ac; [`34815ca`](https://github.com/rivy-go/git-changelog/commit/34815cafe8a533bc148beec2a7e3acd8d69c362f)

#### Maintenance

* chore: Fix release script &ac; [`fc2b625`](https://github.com/rivy-go/git-changelog/commit/fc2b625debd4d9c3a3cdab95fc710120486cf2ed)
* chore: Add release process &ac; [`8292ab7`](https://github.com/rivy-go/git-changelog/commit/8292ab7d2c191e27da5759d128415a8b1362b896)

</details>

---

## 0.0.1 <small>(2018-02-18)</small>

<details><summary><small><em>[0.0.1; details]</em></small></summary>

#### Features

* feat: Add cli client &ac; [`066fa21`](https://github.com/rivy-go/git-changelog/commit/066fa21430aafeba97ec08bfef1e239a9a4650ec)
* feat: Add commits in commit version struct &ac; [`153727e`](https://github.com/rivy-go/git-changelog/commit/153727ed1a4d0d1712eeabcc9ee36f4f294e0928)
* feat: Add config normalize process &ac; [`633c7f0`](https://github.com/rivy-go/git-changelog/commit/633c7f0e89d26b5248663782ba005b118b9d961b)
* feat: Add Next and Previous in Tag &ac; [`d4d2a7e`](https://github.com/rivy-go/git-changelog/commit/d4d2a7ed805300a14ce419daa13dd7a4823cff50)
* feat: Add MergeCommits and RevertCommits &ac; [`fd369d4`](https://github.com/rivy-go/git-changelog/commit/fd369d4c5320582a2946173b87de42f53d96af96)
* feat: First implement &ac; [`6caf676`](https://github.com/rivy-go/git-changelog/commit/6caf676beb56bd053eb2008ed133ca8582b50c45)

#### Fixes

* fix: Fix parsing of revert and body &ac; [`8869631`](https://github.com/rivy-go/git-changelog/commit/8869631aad9059c30a7271c7ce2dc37d0e6493ac)

#### Documentation

* docs: Fix links &ac; [`ff400cd`](https://github.com/rivy-go/git-changelog/commit/ff400cdfd36a363f82b0de698877d9cd9aa6a34a)
* docs: Add documentation &ac; [`9e216d5`](https://github.com/rivy-go/git-changelog/commit/9e216d56276c32427baf6e368fcd4b8e8716339d)
* docs: Add godoc &ac; [`d55318c`](https://github.com/rivy-go/git-changelog/commit/d55318c7a09aaab32c6c010cdb8e5d2823818d13)
* docs: Add license &ac; [`2d5764a`](https://github.com/rivy-go/git-changelog/commit/2d5764a30d26be5a4cfe15bf70db09a1b84e8ba5)

#### Maintenance

* chore: Fix timezone in TravisCI &ac; [`ec1d4de`](https://github.com/rivy-go/git-changelog/commit/ec1d4dec3c8caa6bd0c2bf587d149e527ea80f39)
* chore: Add travis configuration &ac; [`1d37984`](https://github.com/rivy-go/git-changelog/commit/1d37984592cb01db55d72e1ccd131ee2d9d979c4)
* chore: Add Makefile for task management &ac; [`4dd9b35`](https://github.com/rivy-go/git-changelog/commit/4dd9b350e607a8b8189474a2dc2c49e8ebd53cda)
* chore: Fix testcase depending on datetime &ac; [`cd96846`](https://github.com/rivy-go/git-changelog/commit/cd9684604bb8750b1984779689437c37fa7d5cfb)
* chore: Update vendor packages &ac; [`2179ede`](https://github.com/rivy-go/git-changelog/commit/2179edebb604b0309b7dc3b9b023a9566afaa8a6)
* chore: Add e2e tests &ac; [`8b6430e`](https://github.com/rivy-go/git-changelog/commit/8b6430ea17207f370c7cfeaef0bf9f5a187a5979)
* chore: Setup gitignore &ac; [`8c7c870`](https://github.com/rivy-go/git-changelog/commit/8c7c8707ababe1a6d27a48900f9c0dfc779f3c23)
* chore: Initial commit &ac; [`a44743e`](https://github.com/rivy-go/git-changelog/commit/a44743ef3fe09fd622e22372f8f3e4a3c65f0439)
* maint *(editor)*: Add Editorconfig &ac; [`78c2f1e`](https://github.com/rivy-go/git-changelog/commit/78c2f1e90939cc8d3ba2b0d6455a2369e22089bc)

#### Refactoring

* refactor: Fix typo &ac; [`5599878`](https://github.com/rivy-go/git-changelog/commit/5599878683f353b1d4f2606d0217034995bf3a86)
* refactor: Change to return an error if corresponding commit is empty &ac; [`22cfb51`](https://github.com/rivy-go/git-changelog/commit/22cfb5112444e4aa38d2ab53af3c62e5a2ac5f78)
* refactor: Refactor the main logic &ac; [`8f31716`](https://github.com/rivy-go/git-changelog/commit/8f3171633c984a8ef9c714ea8a33438865aa2d8e)

</details><br/>
