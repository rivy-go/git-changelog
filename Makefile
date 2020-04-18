# cross platform (*nix/windows) Makefile

## NOTE: requirements ...
## * windows ~ `awk`, `grep`, and `make`; use `scoop install gawk grep make`
## * all platforms ~ `goverage`; use `go get -u github.com/haya14busa/goverage`

NAME = ## optional (defaults to name of parent directory)

####

# spell-checker:ignore () busa chglog haya haya14busa
# spell-checker:ignore (targets) deps realclean veryclean
# spell-checker:ignore (make) abspath addprefix addsuffix endef findstring firstword ifeq ifneq lastword undefine notdir
#
# spell-checker:ignore (MSVC flags) defaultlib nologo
# spell-checker:ignore (abbrev/acronyms/names) MSVC
# spell-checker:ignore (clang flags) flto Xclang Wextra Werror
# spell-checker:ignore (flags) coverprofile
# spell-checker:ignore (go) GOBIN GOPATH dep goverage golint
# spell-checker:ignore (misc) brac cmdbuf forwback lessecho lesskey libcmt libpath linenum optfunc opttbl stdext ttyin
# spell-checker:ignore (shell/nix) printf uname
# spell-checker:ignore (shell/win) COMSPEC USERPROFILE delims findstr goawk mkdir
# spell-checker:ignore (vars) BQUOTE BSLASH CFLAGS CXXFLAGS DQUOTE LDFLAGS RMDIR SQUOTE devnull mkfile

####

# require at least `make` v4 (minimum needed for correct path functions)
MAKE_VERSION_major := $(word 1,$(subst ., ,$(MAKE_VERSION)))
MAKE_VERSION_fail := $(filter $(MAKE_VERSION_major),3 2 1 0)
ifneq ($(MAKE_VERSION_fail),)
$(error ERR!: `make` v4+ required)
endif

/ := /
NULL :=
SPACE := $() $()
BSLASH := $(strip \)
BQUOTE := $(firstword \` \`)
DQUOTE := \"
SQUOTE := \'
ifeq ($(OS),Windows_NT)
/ := $(strip \)
BQUOTE := $(subst \,,$(BQUOTE))
DQUOTE := $(subst \,,$(DQUOTE))
SQUOTE := $(subst \,,$(SQUOTE))
endif

mkfile_path := $(subst /,$(/),$(lastword $(MAKEFILE_LIST)))
mkfile_abs_path := $(subst /,$(/),$(abspath $(mkfile_path)))
mkfile_dir := $(subst /,$(/),$(abspath $(dir $(mkfile_abs_path))))
ifeq (${OS},Windows_NT)
SHELL := cmd
COMSPEC := $(shell echo %COMSPEC%)## avoid any env variable case variance issue
current_dir := $(subst /,$(/),$(abspath $(shell "$(COMSPEC)" /x/d/c echo %CD%)))## %CD% requires CMD extensions
else
SHELL := bash
current_dir := $(subst /,$(/),$(abspath $(shell echo $$PWD)))
endif

ifeq (${NAME},)
override NAME = $(notdir $(mkfile_dir))
endif

# $(info mkfile_path='$(mkfile_path)')
# $(info mkfile_abs_path='$(mkfile_abs_path)')
# $(info mkfile_dir='$(mkfile_dir)')
# $(info current_dir='$(current_dir)')

ifeq (${SPACE},$(findstring ${SPACE},${mkfile_abs_path}))
$(error ERR!: <space>'s within project directory may cause issues)
endif

####

OS_PREFIX=
ifeq (${OS},Windows_NT)
OS_ID      = win
OS_PREFIX  = $(OS_ID).
EXT        = .exe
HOME       ?= $(shell echo %USERPROFILE%)## avoid any env variable case variance issue
SystemRoot := $(shell echo %SystemRoot%)## avoid any env variable case variance issue
AWK        = gawk
CP         = copy /y
ECHO       = echo
GREP       = grep
MKDIR      = mkdir
RM         = del
RM_r       = $(RM) /s
RM_rf      = $(RM) /s
RMDIR      = rmdir /s/q
RMDIR_f    = rmdir /s/q
FIND       = "$(SystemRoot)\System32\find"
FINDSTR    = "$(SystemRoot)\System32\findstr"
MORE       = "$(SystemRoot)\System32\more"
SORT       = "$(SystemRoot)\System32\sort"
devnull    = NUL
shell_true = cd .
else
/ := /
OS := $(shell uname | tr '[:upper:]' '[:lower:]')
OS_ID      = $(OS)
OS_PREFIX  = $(OS_ID).
EXT        =
AWK        = awk
CP         = cp
ECHO       = echo
GREP       = grep
MKDIR      = mkdir
PRINTF     = printf
RM         = rm
RM_r       = $(RM) -r
RM_rf      = $(RM) -rf
RMDIR      = $(RM) -r
RMDIR_f    = $(RM) -rf
SORT       = sort
devnull    = /dev/null
shell_true = true
endif

## xMKDIR_p == cross-platform MKDIR
ifeq ($(OS),Windows_NT)
define xMKDIR_p =
	if NOT EXIST "$(subst /,\,$(1:"%"=%))" $(MKDIR) "$(subst /,\,$(1:"%"=%))" >$(devnull)
endef
else
define xMKDIR_p =
	$(MKDIR) -p "$(1:"%"=%)" >$(devnull)
endef
endif

## xRM == cross-platform RM
ifeq ($(OS),Windows_NT)
define xRM =
	if EXIST "$(subst /,\,$(1:"%"=%))" $(RM) "$(subst /,\,$(1:"%"=%))" >$(devnull) 2>&1 && echo "$(subst /,\,$(1:"%"=%))" removed
endef
else
define xRM =
	ls -d "$(1:"%"=%)" >$(devnull) 2>&1 && $(RM) "$(1:"%"=%)" && echo \""$(1:"%"=%)"\" removed || ${shell_true}
endef
endif

## xRMDIR == cross-platform RMDIR
ifeq ($(OS),Windows_NT)
define xRMDIR =
	if EXIST "$(subst /,\,$(1:"%"=%))" $(RMDIR_f) "$(subst /,\,$(1:"%"=%))" >$(devnull) 2>&1 && echo "$(subst /,\,$(1:"%"=%))" directory removed
endef
else
define xRMDIR =
	ls -d "$(1:"%"=%)" >$(devnull) 2>&1 && $(RMDIR_f) "$(1:"%"=%)" && echo \""$(1:"%"=%)"\" directory removed || ${shell_true}
endef
endif

lc = $(subst A,a,$(subst B,b,$(subst C,c,$(subst D,d,$(subst E,e,$(subst F,f,$(subst G,g,$(subst H,h,$(subst I,i,$(subst J,j,$(subst K,k,$(subst L,l,$(subst M,m,$(subst N,n,$(subst O,o,$(subst P,p,$(subst Q,q,$(subst R,r,$(subst S,s,$(subst T,t,$(subst U,u,$(subst V,v,$(subst W,w,$(subst X,x,$(subst Y,y,$(subst Z,z,$(1)))))))))))))))))))))))))))

####

BUILD_DIR ?= \#builds

## `go` packages are generally compiled to targets which include debug and symbol information
CONFIG ?= debug
override CONFIG := $(call lc,$(CONFIG))

OUT_DIR = $(BUILD_DIR)$(/)$(OS_PREFIX)$(CONFIG)
# OUT_DIR = $(BUILD_DIR)$(/)$(OS_ID)

GOPATH    ?= $(HOME)$(/)go
GOBIN     ?= $(GOPATH)$(/)bin

# $(info BUILD_DIR='$(BUILD_DIR)')
# $(info CONFIG='$(CONFIG)')
# $(info GOPATH='$(GOPATH)')
# $(info NAME='$(NAME)')
# $(info OUT_DIR='$(OUT_DIR)')

####

GO_BUILD_FLAGS =
ifeq ($(call lc,$(CONFIG)),release)
## -ldflags="-s -w" == remove symbol and debug info from target
GO_BUILD_FLAGS = -ldflags="-s -w"
endif

####

# since we rely on paths relative to the makefile location, abort if current directory != makefile directory
ifneq ($(current_dir),$(mkfile_dir))
$(error ERR!: Invalid current directory; this makefile must be invoked from the directory it resides in ('$(mkfile_dir)'))
endif

####

ifeq (${mkfile_path},Makefile)
BUILD_HELP_ALIAS ?= make
else
BUILD_HELP_ALIAS ?= make -f "$(mkfile_path)"
endif

####

.PHONY: default
default: clean test ## [*DEFAULT*] Build and test project

####

.PHONY: clean
clean: ## Remove build artifacts (including intermediate files)
	@$(call xRMDIR,"dist")
	@$(call xRM,"$(BUILD_DIR)$(/)cover.out")

.PHONY: help
help: ## Display help
	@echo usage: $(BQUOTE)$(BUILD_HELP_ALIAS) [TARGET [TARGET]...]$(BQUOTE)
	@echo TARGETs:
ifeq ($(OS),Windows_NT)
	@$(FINDSTR) "^[a-zA-Z-]*:" "$(mkfile_path)" | $(SORT) | for /f "tokens=1-2,* delims=:#" %%g in ('$(MORE)') do @(@call set "t=%%g                " & @call echo %%t:~0,15%% %%i )
else
	@$(GREP) -P "(?i)^[[:alpha:]-]+:" "$(mkfile_path)" | $(SORT) | $(AWK) 'match($$0,"^([[:alpha:]]+):.*?##\\s*(.*)$$",m){ $(PRINTF) "%-10s\t%s\n", m[1], m[2] }'
endif

realclean: clean ## Remove *all* build artifacts (including all configurations and the build directory)
	@$(call xRMDIR,"$(BUILD_DIR)")

veryclean: realclean ## Remove *all* build artifacts and GOPATH installed binary
	@$(call xRM,"$(GOBIN)$(/)$(NAME)$(EXT)")

####

.PHONY: all build compile rebuild veryclean
# build: $(PROJECT_TARGET) ## Build project
# compile: $(OBJ_files) ## Build intermediate files
rebuild: clean build ## Clean and rebuild project

####

.PHONY: build
build: ## Build project
	@go build -i $(GO_BUILD_FLAGS) -o "$(OUT_DIR)$(/)$(NAME)$(EXT)" ./cmd/$(NAME)
	@echo $(SQUOTE)$(OUT_DIR)$(/)$(NAME)$(EXT)$(SQUOTE) created

.PHONY: coverage
coverage: ## Display test coverage for project files
	@$(call xMKDIR_p,"$(BUILD_DIR)")
	goverage -coverprofile="$(BUILD_DIR)$(/)cover.out" $(shell go list ./... | $(GREP) -v /vendor/)
	go tool cover -func="$(BUILD_DIR)$(/)cover.out"
	@$(call xRM,"$(BUILD_DIR)$(/)cover.out")

.PHONY: format
format: ## `go fmt ...` ~ reformat source files
	go fmt $(shell go list ./... | ${GREP} -v /vendor/)

.PHONY: install
install: ## Install project binary
	@go install $(GO_BUILD_FLAGS) "./cmd/$(NAME)"
	@echo $(SQUOTE)$(GOBIN)$(/)$(NAME)$(EXT)$(SQUOTE) created/installed

.PHONY: lint
lint: ## `golint ...` ~ display lint warnings for source files
	golint $(shell go list ./... | ${GREP} -v /vendor/)

.PHONY: test
test: ## Test project
	go test -v $(shell go list ./... | ${GREP} -v /vendor/)

####

.PHONY: changelog
changelog: ## `git-chglog --next-tag $TAG $TAG` ~ create CHANGELOG for planned next tag (requires $TAG)
	@git-chglog --next-tag $(TAG) $(TAG)
