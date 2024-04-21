# Makefile (GoLang; OOS-build support; gmake-form/style; v2024.04.21)
# Cross-platform (*nix/windows)
# GNU make (gmake) compatible; ref: <https://www.gnu.org/software/make/manual>
# Copyright (C) 2020-2024 ~ Roy Ivy III <rivy.dev@gmail.com>; MIT+Apache-2.0 license

## NOTE: requirements ...
## * windows ~ `awk`, `grep`, and `make`; use `scoop install gawk grep make`
## * all platforms ~ `goverage`; use `go install github.com/haya14busa/goverage@latest` (or `go get -u github.com/haya14busa/goverage` for earlier `go` versions)

# NOTE: * requires `make` version 4.0+ (minimum needed for correct path functions); for windows, install using `scoop install make`
# NOTE: `make` doesn't handle spaces within file names without gyrations (see <https://stackoverflow.com/questions/9838384/can-gnu-make-handle-filenames-with-spaces>@@<https://archive.is/PYKKq>)
# NOTE: `make -d` will display full debug output (`make` and makefile messages) during the build/make process
# NOTE: `make MAKEFLAGS_debug=1` will display just the makefile debug messages during the build/make process
# NOTE: use `make ... run -- <OPTIONS>` to pass options to the run TARGET; otherwise, `make` will interpret the options as targeted for itself

# `make [CONFIG=debug|release] [DEBUG=<truthy>] [STATIC=<truthy>] [SUBSYSTEM=console|windows|..] [TARGET=..] [COLOR=<truthy>] [MAKEFLAGS_debug=<truthy>] [VERBOSE=<truthy>] [MAKE_TARGET...]`

####

# spell-checker:ignore (project) busa changelog haya haya14busa

# spell-checker:ignore (targets) realclean veryclean
# spell-checker:ignore (make) BASEPATH CURDIR MAKECMDGOALS MAKEFLAGS SHELLSTATUS TERMERR TERMOUT abspath addprefix addsuffix endef eval findstring firstword gmake ifeq ifneq lastword notdir patsubst prepend undefine wordlist
#
# spell-checker:ignore (MSVC flags) defaultlib nologo
# spell-checker:ignore (abbrev/acronyms/names) Deno MSDOS MSVC
# spell-checker:ignore (clang flags) flto Xclang Wextra Werror
# spell-checker:ignore (flags) coverprofile extldflags
# spell-checker:ignore (go) GOBIN GOPATH goverage golint asmflags gccgoflags gcflags ldflags
# spell-checker:ignore (jargon) autoset delims executables maint multilib
# spell-checker:ignore (misc) brac cmdbuf forwback lessecho lesskey libcmt libpath linenum optfunc opttbl stdext ttyin
# spell-checker:ignore (people) benhoyt rivy
# spell-checker:ignore (shell/nix) mkdir printf rmdir uname
# spell-checker:ignore (shell/win) COMSPEC SystemDrive SystemRoot findstr findstring mkdir windir
# spell-checker:ignore (utils) goawk
# spell-checker:ignore (vars) CFLAGS CLICOLOR CPPFLAGS CXXFLAGS DEFINETYPE EXEEXT LDFLAGS LDXFLAGS LIBPATH LIBs MAKEDIR OBJ_deps OBJs OSID PAREN RCFLAGS REZ REZs devnull dotslash falsey fileset filesets globset globsets punct truthy

####

NAME := $()## $()/empty/null => autoset to name of containing folder

# SRC_PATH := $()## path to source relative to makefile (defaults to first of ['cmd','src','source']); used to create ${SRC_DIR} which is then used as the source base directory path
BUILD_PATH := $()## path to build storage relative to makefile (defaults to '#build'); used to create ${BUILD_DIR} which is then used as the base path for build outputs

####

# `make ...` command line flag/option defaults
# ARCH := $()## default ARCH for compilation ([$(),...]); $()/empty/null => use CC default ARCH
# CC_DEFINES := false## provide compiler info (as `CC_...` defines) to compiling targets ('truthy'-type)
CONFIG := debug## default build configuration (debug/release); `go` packages are generally compiled to targets with debug and symbol information
COLOR := auto## defaults to "auto" mode ("on/true" if STDOUT is tty, "off/false" if STDOUT is redirected); will be modified later, in-process, to respect CLICOLOR/CLICOLOR_FORCE and NO_COLOR (but overridden by `COLOR=..` on command line); refs: <https://bixense.com/clicolors>@@<https://archive.is/mF4IA> , <https://no-color.org>@@<https://archive.ph/c32Wn>
DEBUG := false## enable compiler debug flags/options ('truthy'-type)
STATIC := true## compile to statically linked executable ('truthy'-type)
VERBOSE := false## verbose `make` output ('truthy'-type)
MAKEFLAGS_debug := $(if $(findstring d,${MAKEFLAGS}),true,false)## Makefile debug output ('truthy'-type; default == false) ## NOTE: use `-d` or `MAKEFLAGS_debug=1`, `--debug[=FLAGS]` does not set MAKEFLAGS correctly (see <https://savannah.gnu.org/bugs/?func=detailitem&item_id=58341>)

####

MAKE_VERSION_major := $(word 1,$(subst ., ,${MAKE_VERSION}))
MAKE_VERSION_minor := $(word 2,$(subst ., ,${MAKE_VERSION}))

# require at least `make` v4.0 (minimum needed for correct path functions)
MAKE_VERSION_fail := $(filter ${MAKE_VERSION_major},3 2 1 0)
ifeq (${MAKE_VERSION_major},4)
MAKE_VERSION_fail := $(filter ${MAKE_VERSION_minor},)
endif
ifneq (${MAKE_VERSION_fail},)
# $(call %error,`make` v4.0+ required (currently using v${MAKE_VERSION}))
$(error ERR!: `make` v4.0+ required (currently using v${MAKE_VERSION}))
endif

makefile_path := $(lastword ${MAKEFILE_LIST})## note: *must* precede any makefile imports (ie, `include ...`)

makefile_abs_path := $(abspath ${makefile_path})
makefile_dir := $(abspath $(dir ${makefile_abs_path}))
make_invoke_alias ?= $(if $(filter-out Makefile,${makefile_path}),${MAKE} -f "${makefile_path}",${MAKE})
current_dir := ${CURDIR}
makefile_set := $(wildcard ${makefile_path} ${makefile_path}.config ${makefile_path}.target)
makefile_set_abs := $(abspath ${makefile_set})

#### * determine OS ID

# note: environment/${OS}=="Windows_NT" for XP, 2000, Vista, 7, 10, 11, ...
OSID := $(or $(and $(filter .exe,$(patsubst %.exe,.exe,$(subst $() $(),_,${SHELL}))),$(filter win,${OS:Windows_NT=win})),nix)## OSID == [nix,win]
ifeq (${OSID},win)
# WinOS-specific settings
# * set SHELL (from COMSPEC or SystemRoot, if possible)
# ... `make` may otherwise use an incorrect shell (eg, `sh` or `bash`, if found in PATH); "syntax error: unexpected end of file" or "CreateProcess(NULL,...)" error output is indicative
SHELL := cmd$()## start with a known default shell (`cmd` for WinOS XP+)
# * set internal variables from environment variables (if available)
# ... avoid env var case variance issues and use fallbacks
# ... note: assumes *no spaces* within the path values specified by ${ComSpec}, ${SystemRoot}, or ${windir}
HOME := $(or $(strip $(shell echo %HOME%)),$(strip $(shell echo %UserProfile%)))
COMSPEC := $(strip $(shell echo %ComSpec%))
SystemRoot := $(or $(strip $(shell echo %SystemRoot%)),$(strip $(shell echo %windir%)))
SHELL := $(firstword $(wildcard ${COMSPEC} ${SystemRoot}/System32/cmd.exe) cmd)
endif

#### * determine BASEPATH

# use ${BASEPATH} as an anchor to allow otherwise relative path specification of files
ifneq (${makefile_dir},${current_dir})
BASEPATH := ${makefile_dir:${current_dir}/%=%}
# BASEPATH := $(patsubst ./%,%,${makefile_dir:${current_dir}/%=%}/)
endif
ifeq (${BASEPATH},)
BASEPATH := .
endif

#### * constants and methods

falsey_list := false 0 f n never no none off
falsey := $(firstword ${falsey_list})
false := $()
true := true
truthy := ${true}

devnull := $(if $(filter win,${OSID}),NUL,/dev/null)
int_max := 2147483647## largest signed 32-bit integer; used as arbitrary max expected list length

NULL := $()
BACKSLASH := $()\$()
COMMA := ,
DOLLAR := $$
DOT := .
ESC := $()$()## literal ANSI escape character (required for ANSI color display output; also used for some string matching)
HASH := \#
PAREN_OPEN := $()($()
PAREN_CLOSE := $())$()
SLASH := /
SPACE := $() $()

[lower] := a b c d e f g h i j k l m n o p q r s t u v w x y z
[upper] := A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
[alpha] := ${[lower]} ${[upper]}
[digit] := 1 2 3 4 5 6 7 8 9 0
[punct] := ~ ` ! @ ${HASH} ${DOLLAR} % ^ & * ${PAREN_OPEN} ${PAREN_CLOSE} _ - + = { } [ ] | ${BACKSLASH} : ; " ' < > ${COMMA} ? ${SLASH} ${DOT}

%not = $(if ${1},${false},$(or ${1},${true}))
%eq = $(or $(and $(findstring ${1},${2}),$(findstring ${2},${1})),$(if ${1}${2},${false},${true}))# note: `call %eq,$(),$()` => ${true}
%neq = $(if $(call %eq,${1},${2}),${false},$(or ${1},${2},${true}))# note: ${1} != ${2} => ${false}; ${1} == ${2} => first non-empty value (or ${true})

# %falsey := $(firstword ${falsey})
# %truthy := $(firstword ${truthy})

%as_truthy = $(if $(call %is_truthy,${1}),${truthy},${falsey})# note: returns 'truthy'-type text value (eg, true => 'true' and false => 'false')
%is_truthy = $(if $(filter-out ${falsey_list},$(call %lc,${1})),${1},${false})# note: returns `make`-type boolean value (eg, true => non-empty and false => $()/empty/null)
%is_falsey = $(call %not,$(call %is_truthy,${1}))# note: returns `make`-type boolean value (eg, true => non-empty and false => $()/empty/null)

%range = $(if $(word ${1},${2}),$(wordlist 1,${1},${2}),$(call %range,${1},${2} $(words _ ${2})))
%repeat = $(if $(word ${2},${1}),$(wordlist 1,${2},${1}),$(call %repeat,${1} ${1},${2}))

%head = $(firstword ${1})
%tail = $(wordlist 2,${int_max},${1})
%chop = $(wordlist 2,$(words ${1}),_ ${1})
%append = ${2} ${1}
%prepend = ${1} ${2}
%length = $(words ${1})

%_position_ = $(if $(findstring ${1},${2}),$(call %_position_,${1},$(wordlist 2,$(words ${2}),${2}),_ ${3}),${3})
%position = $(words $(call %_position_,${1},${2}))

%map = $(foreach elem,${2},$(call ${1},${elem}))# %map(fn,list) == [ fn(list[N]),... ]
%filter_by = $(strip $(foreach elem,${3},$(and $(filter $(call ${1},${2}),$(call ${1},${elem})),${elem})))# %filter_by(fn,item,list) == [ list[N] iff fn(item)==fn(list[N]), ... ]
%uniq = $(if ${1},$(firstword ${1}) $(call %uniq,$(filter-out $(firstword ${1}),${1})))

%none = $(if $(call %map,${1},${2}),${false},${true})## %none(fn,list) => all of fn(list_N) == ""
%some = $(if $(call %map,${1},${2}),${true},${false})## %some(fn,list) => any of fn(list_N) != ""
%any = %some## %any(), aka %some(); %any(fn,list) => any of fn(list_N) != ""
%all = $(if $(call %map,%not,$(call %map,${1},${2})),${false},${true})## %all(fn,list) => all of fn(list_N) != ""

%cross = $(foreach a,${2},$(foreach b,${3},$(call ${1},${a},${b})))# %cross(fn,listA,listB) == [ fn(listA[N],listB[M]), ... {for all combinations of listA and listB }]
%join = $(subst ${SPACE},${1},$(strip ${2}))# %join(text,list) == join all list elements with text
%replace = $(foreach elem,${3},$(foreach pat,${1},${elem:${pat}=${2}}))# %replace(pattern(s),replacement,list) == [ ${list[N]:pattern[M]=replacement}, ... ]

%tr = $(strip $(if ${1},$(call %tr,$(wordlist 2,$(words ${1}),${1}),$(wordlist 2,$(words ${2}),${2}),$(subst $(firstword ${1}),$(firstword ${2}),${3})),${3}))
%lc = $(call %tr,${[upper]},${[lower]},${1})
%uc = $(call %tr,${[lower]},${[upper]},${1})

%as_nix_path = $(subst \,/,${1})
%as_win_path = $(subst /,\,${1})
%as_os_path = $(call %as_${OSID}_path,${1})

%strip_leading_cwd = $(patsubst ./%,%,${1})# %strip_leading_cwd(list) == normalize paths; stripping any leading './'
%strip_leading_dotslash = $(patsubst ./%,%,${1})# %strip_leading_dotslash(list) == normalize paths; stripping any leading './'

%dirs_in = $(dir $(wildcard ${1:=/*/.}))
%filename = $(notdir ${1})
%filename_base = $(basename $(notdir ${1}))
%filename_ext = $(suffix ${1})
%filename_stem = $(firstword $(subst ., ,$(basename $(notdir ${1}))))
%recursive_wildcard = $(strip $(foreach entry,$(wildcard ${1:=/*}),$(strip $(call %recursive_wildcard,${entry},${2}) $(filter $(subst *,%,${2}),${entry}))))

%filter_by_stem = $(call %filter_by,%filename_stem,${1},${2})

# * `%is_gui()` tests filenames for a match to '*[-.]gui{${EXEEXT},.${O}}'
%is_gui = $(if $(or $(call %is_gui_exe,${1}),$(call %is_gui_obj,${1})),${1},${false})
%is_gui_exe = $(if $(and $(patsubst %-gui${EXEEXT},,${1}),$(patsubst %.gui${EXEEXT},,${1})),${false},${1})
%is_gui_obj = $(if $(and $(patsubst %-gui.${O},,${1}),$(patsubst %.gui.${O},,${1})),${false},${1})

# %any_gui = $(if $(foreach file,${1},$(call %is_gui,${file})),${true},${false})
# %all_gui = $(if $(foreach file,${1},$(call %not,$(call %is_gui,${file}))),${false},${true})
# %any_gui = $(call %any,%is_gui,${1})
# %all_gui = $(call %all,%is_gui,${1})

ifeq (${OSID},win)
%mkdir_shell_s = (if NOT EXIST $(call %shell_escape,$(call %as_win_path,${1})) ${MKDIR} $(call %shell_escape,$(call %as_win_path,${1})) >${devnull} 2>&1 && ${ECHO} ${true})
else
%mkdir_shell_s = (${MKDIR} $(call %shell_escape,${1}) >${devnull} 2>&1 && ${ECHO} ${true})
endif
%mkdir = $(shell $(call %mkdir_shell_s,${1}))

# * `rm` shell commands; note: return `${true}` result when argument (`${1}`) is successfully removed (to support verbose feedback display)
ifeq (${OSID},win)
%rm_dir_shell_s = (if EXIST $(call %shell_quote,$(call %as_win_path,${1})) (${RMDIR} $(call %shell_quote,$(call %as_win_path,${1})) >${devnull} 2>&1 && ${ECHO} ${true}))
%rm_file_shell_s = (if EXIST $(call %shell_quote,$(call %as_win_path,${1})) (${RM} $(call %shell_quote,$(call %as_win_path,${1})) >${devnull} 2>&1 && ${ECHO} ${true}))
%rm_file_globset_shell_s = (for %%G in $(call %shell_quote,($(call %as_win_path,${1}))) do (${RM} "%%G" >${devnull} 2>&1 && ${ECHO} ${true}))
else
%rm_dir_shell_s = (ls -d $(call %shell_escape,${1}) >${devnull} 2>&1 && { ${RMDIR} $(call %shell_escape,${1}) >${devnull} 2>&1 && ${ECHO} ${true}; } || true)
%rm_file_shell_s = (ls -d $(call %shell_escape,${1}) >${devnull} 2>&1 && { ${RM} $(call %shell_escape,${1}) >${devnull} 2>&1 && ${ECHO} ${true}; } || true)
%rm_file_globset_shell_s = (for file in $(call %shell_escape,${1}); do ls -d "$${file}" >${devnull} 2>&1 && ${RM} "$${file}"; done && ${ECHO} "${true}"; done)
endif

# NOTE: `_ := $(call %rm_dir,...)` or `$(if $(call %rm_dir,...))` can be used to avoid interpreting in-line output as a makefile command/rule (avoids `*** missing separator` errors)
%rm_dir = $(shell $(call %rm_dir_shell_s,${1}))
%rm_file = $(shell $(call %rm_file_shell_s,${1}))
%rm_file_globset = $(shell $(call %rm_file_globset_shell_s,${1}))
%rm_dirs = $(strip $(call %map,%rm_dir,${1}))
%rm_dirs_verbose = $(strip $(call %map,$(eval %f=$$(if $$(call %rm_dir,$${1}),$$(call %info,'$${1}' removed.),))%f,${1}))
%rm_files = $(strip $(call %map,%rm_file,${1}))
%rm_files_verbose = $(strip $(call %map,$(eval %f=$$(if $$(call %rm_file,$${1}),$$(call %info,'$${1}' removed.),))%f,${1}))
%rm_file_globsets = $(strip $(call %map,%rm_file_globset,${1}))
%rm_file_globsets_verbose = $(strip $(call %map,$(eval %f=$$(if $$(call %rm_file_globset,$${1}),$$(call %info,'$${1}' removed.),))%f,${1}))

# %rm_dirs_verbose_cli = $(call !shell_noop,$(call %rm_dirs_verbose,${1}))

ifeq (${OSID},win)
%shell_escape = $(call %tr,^ | < > %,^^ ^| ^< ^> ^%,${1})
else
%shell_escape = '$(call %tr,','"'"',${1})'
endif

ifeq (${OSID},win)
%shell_quote = "$(call %shell_escape,${1})"
else
%shell_quote = $(call %shell_escape,${1})
endif

# ref: <https://superuser.com/questions/10426/windows-equivalent-of-the-linux-command-touch/764716> @@ <https://archive.is/ZjFSm>
ifeq (${OSID},win)
%touch_shell_s = type NUL >> $(call %shell_quote,$(call %as_win_path,${1})) & copy >NUL /B $(call %shell_quote,$(call %as_win_path,${1})) +,, $(call %shell_quote,$(call %as_win_path,${1}))
else
%touch_shell_s = touch $(call %shell_quote,${1})
endif
%touch = $(shell $(call %touch_shell_s,${1}))

@mkdir_rule = ${1} : ${2} ; @${MKDIR} $(call %shell_quote,$$@) >${devnull} 2>&1 && ${ECHO} $(call %shell_escape,$(call %info_text,created '$$@'.))

!shell_noop = ${ECHO} >${devnull}

####

## determine COLOR based on NO_COLOR and CLICOLOR_FORCE/CLICOLOR; refs: <https://bixense.com/clicolors>@@<https://archive.is/mF4IA> , <https://no-color.org>@@<https://archive.ph/c32Wn>
COLOR := $(if $(call %is_truthy,${NO_COLOR}),false,${COLOR})## unconditionally NO_COLOR => COLOR=false
COLOR := $(if $(filter auto,${COLOR}),$(if $(call %is_truthy,${CLICOLOR_FORCE}),true,${COLOR}),${COLOR})## if autoset default ('auto') && CLICOLOR_FORCE => COLOR=true
COLOR := $(if $(filter auto,${COLOR}),$(if $(and ${CLICOLOR},$(call %is_falsey,${CLICOLOR})),false,${COLOR}),${COLOR})## if autoset default ('auto') && defined CLICOLOR && !CLICOLOR => COLOR=false

####

override COLOR := $(call %as_truthy,$(or $(filter-out auto,$(call %lc,${COLOR})),${MAKE_TERMOUT}))
override DEBUG := $(call %as_truthy,${DEBUG})
override STATIC := $(call %as_truthy,${STATIC})
override VERBOSE := $(call %as_truthy,${VERBOSE})

override MAKEFLAGS_debug := $(call %as_truthy,$(or $(call %is_truthy,${MAKEFLAGS_debug}),$(call %is_truthy,${MAKEFILE_debug})))

####

color_black := $(if $(call %is_truthy,${COLOR}),${ESC}[0;30m,)
color_blue := $(if $(call %is_truthy,${COLOR}),${ESC}[0;34m,)
color_cyan := $(if $(call %is_truthy,${COLOR}),${ESC}[0;36m,)
color_green := $(if $(call %is_truthy,${COLOR}),${ESC}[0;32m,)
color_magenta := $(if $(call %is_truthy,${COLOR}),${ESC}[0;35m,)
color_red := $(if $(call %is_truthy,${COLOR}),${ESC}[0;31m,)
color_yellow := $(if $(call %is_truthy,${COLOR}),${ESC}[0;33m,)
color_white := $(if $(call %is_truthy,${COLOR}),${ESC}[0;37m,)
color_bold := $(if $(call %is_truthy,${COLOR}),${ESC}[1m,)
color_dim := $(if $(call %is_truthy,${COLOR}),${ESC}[2m,)
color_hide := $(if $(call %is_truthy,${COLOR}),${ESC}[8;30m,)
color_reset := $(if $(call %is_truthy,${COLOR}),${ESC}[0m,)
#
color_command := ${color_dim}
color_path := $()
color_target := ${color_green}
color_success := ${color_green}
color_failure := ${color_red}
color_debug := ${color_cyan}
color_info := ${color_blue}
color_warning := ${color_yellow}
color_error := ${color_red}

%error_text = ${color_error}ERR!:${color_reset} ${1}
%debug_text = ${color_debug}debug:${color_reset} ${1}
%info_text = ${color_info}info:${color_reset} ${1}
%success_text = ${color_success}SUCCESS:${color_reset} ${1}
%failure_text = ${color_failure}FAILURE:${color_reset} ${1}
%warning_text = ${color_warning}WARN:${color_reset} ${1}
%error = $(error $(call %error_text,${1}))
%debug = $(if $(call %is_truthy,${MAKEFLAGS_debug}),$(info $(call %debug_text,${1})),)
%info = $(info $(call %info_text,${1}))
%success = $(info $(call %success_text,${1}))
%failure = $(info $(call %failure_text,${1}))
%warn = $(info $(call %warning_text,${1}))
%warning = $(info $(call %warning_text,${1}))

%debug_var = $(call %debug,${1}="${${1}}")
%info_var = $(call %info,${1}="${${1}}")

#### * OS-specific tools and vars

EXEEXT_nix := $()
EXEEXT_win := .exe

ifeq (${OSID},win)
OSID_name  := windows
OS_PREFIX  := win.
EXEEXT     := ${EXEEXT_win}
#
AWK        := gawk## from `scoop install gawk`; or "goawk" from `go get github.com/benhoyt/goawk`
CAT        := "${SystemRoot}\System32\findstr" /r .*## note: (unlike `type`) will read from STDIN; BUT with multiple file arguments, this will prefix each line with the file name
CP         := copy /y
ECHO       := echo
GREP       := grep## from `scoop install grep`
MKDIR      := mkdir
RM         := del
RM_r       := ${RM} /s
RMDIR      := rmdir /s/q
RMDIR_f    := rmdir /s/q
FIND       := "${SystemRoot}\System32\find"
FINDSTR    := "${SystemRoot}\System32\findstr"
MORE       := "${SystemRoot}\System32\more"
SORT       := "${SystemRoot}\System32\sort"
TYPE       := type## note: will not read from STDIN unless invoked as `${TYPE} CON`
WHICH      := where
#
ECHO_newline := echo.
shell_true := cd .
else
OSID_name  ?= $(shell uname | tr '[:upper:]' '[:lower:]')
OS_PREFIX  := ${OSID_name}.
EXEEXT     := $(if $(call %is_truthy,${CC_is_MinGW_w64}),${EXEEXT_win},${EXEEXT_nix})
#
AWK        := awk
CAT        := cat
CP         := cp
ECHO       := echo
GREP       := grep
MKDIR      := mkdir -p
RM         := rm
RM_r       := ${RM} -r
RMDIR      := ${RM} -r
RMDIR_f    := ${RM} -rf
SORT       := sort
WHICH      := which
#
ECHO_newline := echo
shell_true := true
endif

####

make_ARGS := ${MAKECMDGOALS}
has_runner_target := $(strip $(call %map,$(eval %f=$$(findstring $${1},${MAKECMDGOALS}))%f,run test))
has_runner_first := $(strip $(call %map,$(eval %f=$$(findstring $${1},$$(firstword ${MAKECMDGOALS})))%f,run test))
runner_positions := $(call %map,$(eval %f=$$(call %position,$${1},${MAKECMDGOALS}))%f,${has_runner_target})
runner_position := $(firstword ${runner_positions})

make_runner_ARGS := $(if ${has_runner_target},$(call %tail,$(wordlist ${runner_position},$(call %length,${make_ARGS}),${make_ARGS})),)

$(call %debug_var,has_runner_first)
$(call %debug_var,has_runner_target)
$(call %debug_var,runner_position)
$(call %debug_var,MAKECMDGOALS)
$(call %debug_var,make_ARGS)
$(call %debug_var,make_runner_ARGS)
$(call %debug_var,ARGS_default_${has_runner_target})
$(call %debug_var,ARGS)

has_debug_target := $(strip $(call %map,$(eval %f=$$(findstring $${1},${MAKECMDGOALS}))%f,debug))
ifneq (${has_debug_target},)
override DEBUG := $(call %as_truthy,${true})
endif
$(call %debug_var,has_debug_target)
$(call %debug_var,DEBUG)

$(call %debug_var,COLOR)
$(call %debug_var,DEBUG)
$(call %debug_var,STATIC)
$(call %debug_var,VERBOSE)
$(call %debug_var,MAKEFILE_debug)

####

# include sibling configuration file, if exists (easier project config with a stable base Makefile)
-include ${makefile_path}.config

####

override ARGS := $(or $(and ${ARGS},${ARGS}${SPACE})${make_runner_ARGS},${ARGS_default_${has_runner_target}})

$(call %debug_var,has_runner_first)
$(call %debug_var,has_runner_target)
$(call %debug_var,runner_position)
$(call %debug_var,MAKECMDGOALS)
$(call %debug_var,make_ARGS)
$(call %debug_var,make_runner_ARGS)
$(call %debug_var,ARGS_default_${has_runner_target})
$(call %debug_var,ARGS)

#### * optional target-specific flags

override TAG := $(if ${TAG},${TAG},v-next)

$(call %debug_var,TAG)

#### End of basic configuration section ####

# ref: [Understanding and Using Makefile Flags](https://earthly.dev/blog/make-flags) @@ <https://archive.is/vEpEU>

#### * GoLang compiler configuration

override GOPATH := $(call %as_nix_path,$(or ${GOPATH},${HOME}/go))
override GOBIN  := $(call %as_nix_path,$(or ${GOBIN},${GOPATH}/bin))

$(call %debug_var,GOPATH)
$(call %debug_var,GOBIN)

GO_BUILD_FLAGS := $()
# note: (from `go help build`): '-asmflags', '-gccgoflags', '-gcflags', and '-ldflags' are not additive; the last option specified will be used for each matching "package pattern"
GO_BUILD_LDFLAGS := $()

GO_BUILD_FLAGS_go116+_false := -i

## -ldflags="-s -w" == remove symbol and debug info from target
GO_BUILD_LDFLAGS_CONFIG_release := -s -w

## ref: [](https://www.arp242.net/static-go.html) @@ <https://archive.ph/YP82Y>
## * enforce static linking (an error will be raised if any dynamic linking is attempted)
GO_BUILD_LDFLAGS_STATIC_true := -extldflags=-static

#### End of compiler configuration section. ####

#### * ensure `make` environment requirements

# # detect `go`
# ifeq (,$(shell go version >${devnull} 2>&1 <${devnull} && echo `go` present))
# $(call %error,Missing required compiler (`go`))
# endif

ifeq (${SPACE},$(findstring ${SPACE},${makefile_abs_path}))
$(call %error,<SPACE>'s within project directory path are not allowed)## `make` has very limited ability to quote <SPACE> characters
endif

# use of BASEPATH allows `make -f ../Makefile ...`; no need for this error
## # since we rely on paths relative to the makefile location, abort if current directory != makefile directory
## ifneq ($(current_dir),$(makefile_dir))
## $(call %error,Invalid current directory; this makefile must be invoked from the directory it resides in ('$(makefile_dir)'))
## endif

####

$(call %debug_var,MAKE_VERSION)
$(call %debug_var,MAKE_VERSION_major)
$(call %debug_var,MAKE_VERSION_minor)

$(call %debug_var,MAKE_VERSION_fail)

$(call %debug_var,makefile_path)
$(call %debug_var,makefile_abs_path)
$(call %debug_var,makefile_dir)
$(call %debug_var,current_dir)
$(call %debug_var,make_invoke_alias)
$(call %debug_var,makefile_set)
$(call %debug_var,makefile_set_abs)

$(call %debug_var,BASEPATH)

# discover NAME
NAME := $(strip ${NAME})
ifeq (${NAME},)
# * generate a default NAME from Makefile project path
working_NAME := $(notdir ${makefile_dir})
## remove any generic repo and/or category tag prefix
tags_repo := repo.GH repo.GL repo.github repo.gitlab repo
tags_category := cxx deno djs js-cli js-user js rs rust ts sh
tags_combined := $(call %cross,$(eval %f=$${1}${DOT}$${2})%f,${tags_repo},${tags_category}) ${tags_repo} ${tags_category}
tag_patterns := $(call %map,$(eval %f=$${1}${DOT}% $${1})%f,${tags_combined})
# $(call %debug_var,tags_combined)
# $(call %debug_var,tag_patterns)
clipped_NAMEs := $(strip $(filter-out ${working_NAME},$(call %replace,${tag_patterns},%,$(filter-out ${tags_repo},${working_NAME}))))
# $(call %debug_var,clipped_NAMEs)
working_NAME := $(firstword $(filter-out ${tags_repo},${clipped_NAMEs} ${working_NAME}))
ifeq (${working_NAME},)
working_NAME := $(notdir $(abspath $(dir ${makefile_dir})))
endif
override NAME := ${working_NAME}
endif
$(call %debug_var,working_NAME)
$(call %debug_var,NAME)

####

# `go` version determination
s := $(shell go version)
# remove all non-version-compatible punctuation characters (leaving common version characters [${BACKSLASH} ${SLASH} ${DOT} _ - +])
s := $(call %tr,$(filter-out ${SLASH} ${BACKSLASH} ${DOT} _ - +,${[punct]}),$(),${s})
# $(call %debug_var,s)
# filter_map ${DOT}-containing words
%f = $(and $(findstring ${DOT},${1}),${1})
s := $(strip $(call %map,%f,${s}))
# remove go version prefix
s := $(call %tr,go,$(),${s})
# $(call %debug_var,s)

# take first word as full version
GO_version := $(firstword ${s})
GO_version_parts := $(strip $(subst ${DOT},${SPACE},${GO_version}))
GO_version_M := $(strip $(word 1,${GO_version_parts}))
GO_version_m := $(strip $(word 2,${GO_version_parts}))
GO_version_r := $(strip $(word 3,${GO_version_parts}))
GO_version_Mm := $(strip ${GO_version_M}.${GO_version_m})

is_go116+ := $(call %as_truthy,$(and $(or $(filter ${GO_version_M},0 1)),$(call %not,$(filter ${GO_version_m},0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15))))
# is_go118+ := $(call %as_truthy,$(and $(or $(filter ${GO_version_M},0 1)),$(call %not,$(filter ${GO_version_m},0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17))))

$(call %debug_var,GO_version)
$(call %debug_var,GO_version_parts)
$(call %debug_var,is_go116+)
# $(call %debug_var,is_go118+)

####

OUT_DIR_EXT := $(if $(call %is_truthy,${STATIC}),,.dynamic)

$(call %debug_var,OUT_DIR_EXT)

####

# note: (from `go help build`): '-asmflags', '-gccgoflags', '-gcflags', and '-ldflags' are not additive; the last option specified will be used for each matching "package pattern"

GO_BUILD_FLAGS += ${GO_BUILD_FLAGS_GO116+_${is_go116+}}

GO_BUILD_LDFLAGS += ${GO_BUILD_LDFLAGS_CONFIG_${CONFIG}}
GO_BUILD_LDFLAGS += ${GO_BUILD_LDFLAGS_STATIC_${STATIC}}

GO_BUILD_LD_FLAGS := $(strip ${GO_BUILD_LDFLAGS})
GO_BUILD_FLAGS := $(strip ${GO_BUILD_FLAGS}$(if ${GO_BUILD_LDFLAGS}, -ldflags="${GO_BUILD_LDFLAGS}",))

$(call %debug_var,GO_BUILD_FLAGS)

####

RUNNER := $()## place-holder for more specific executable runner (eg, `DOSBox-run`, `MSDOS-run`, `wine`, etc for 'special' executables)

####

BUILD_DIR := ${BASEPATH}/$(or ${BUILD_PATH},${HASH}build)## note: `${HASH}build` causes issues with OpenWatcom-v2.0 [2020-09-01], but `${DOLLAR}build` causes variable expansion issues for VSCode debugging; note: 'target' is a common alternative

$(call %debug_var,BUILD_DIR)

## `go` packages are generally compiled to targets which include debug and symbol information
# $(call %debug_var,CONFIG)
override CONFIG := $(call %lc,$(if $(findstring install,${make_ARGS}),release,${CONFIG}))

$(call %debug_var,CONFIG)

# SOURCE_dirs := cmd src source
SOURCE_dirs := $(call %replace,${makefile_dir}/%,${BASEPATH}/%,$(call %as_nix_path,$(shell go list -f {{.Dir}} ./... 2>${devnull})))
SOURCE_exts = *.go **/*.go

SRC_files := $(strip $(foreach p,$(foreach segment,${SOURCE_dirs},$(foreach elem,${SOURCE_exts},${segment}/${elem})),$(wildcard ${p})))

$(call %debug_var,SOURCE_dirs)
$(call %debug_var,SRC_files)

BIN_DIR := ${BASEPATH}/cmd$()## by `go` convention, executables are placed in the `cmd` directory

$(call %debug_var,BIN_DIR)

OUT_DIR := ${BUILD_DIR}/${OS_PREFIX}${CONFIG}${OUT_DIR_EXT}
OUT_DIR_bin := ${OUT_DIR}

$(call %debug_var,OUT_DIR)
$(call %debug_var,OUT_DIR_bin)

####

PROJECT_TARGET := ${OUT_DIR_bin}/${NAME}${EXEEXT}

.DEFAULT_GOAL := $(if ${SRC_files},${PROJECT_TARGET},$(if ${BIN_SRC_files},bins,$(if ${EG_SRC_files},examples,)))# *default* target

$(call %debug_var,PROJECT_TARGET)
$(call %debug_var,.DEFAULT_GOAL)

####

out_dirs += $(strip $(call %uniq,$(if ${has_debug_target},${DEBUG_DIR},) ${OUT_DIR} $(if $(filter-out bins examples,${.DEFAULT_GOAL}),${OUT_DIR_bin},) $(if ${BIN_SRC_files},${BIN_OUT_DIR_bin},) $(if ${EG_SRC_files},${EG_OUT_DIR_bin},) $(if ${TEST_SRC_files},${TEST_OUT_DIR_bin},) $(if $(filter-out bins examples,${.DEFAULT_GOAL}),${OUT_DIR_obj},) $(patsubst %/,%,$(dir ${OBJ_files} ${OBJ_sup_files} $(if ${BIN_SRC_files},${BIN_OBJ_files} ${BIN_OBJ_sup_files} ${BIN_REZ_files} ,) $(if ${EG_SRC_files},${EG_OBJ_files} ${EG_OBJ_sup_files} ${EG_REZ_files},) $(if ${TEST_SRC_files},${TEST_OBJ_files} ${TEST_OBJ_sup_files} ${TEST_REZ_files},) ${REZ_files})) ${OUT_DIR_targets}))

out_dirs_for_rules = $(strip $(call %tr,${DOLLAR} ${HASH},${DOLLAR}${DOLLAR} ${BACKSLASH}${HASH},${out_dirs}))

$(call %debug_var,out_dirs)
$(call %debug_var,out_dirs_for_rules)

####

all_phony_targets += $()

####

# include sibling target(s) file (if/when sibling file exists; provides easy project customization upon a stable base Makefile)
# * note: `-include ${makefile_path}.target` is placed as late as possible, just prior to any goal/target declarations
-include ${makefile_path}.target.config

####

ifneq (${NULL},$(filter-out all bins,${.DEFAULT_GOAL}))## define 'run' target only for real executable targets (ignore 'all' or 'bins')
all_phony_targets += run
run: ${.DEFAULT_GOAL} ## Build and execute project executable (for ARGS, use `-- [ARGS]` or `ARGS="..."`)
	$(strip ${RUNNER} $(call %shell_quote,$^)) ${ARGS}
endif

####
ifeq (${false},${has_run_first})## define standard phony targets only when 'run' is not the first target (all text following 'run' is assumed to be arguments for the run; minimizes recipe duplication/overwrite warnings)
####

# have_git := $(shell git --version 2>${devnull})
# have_git_repo := $(if $(shell git status 2>${devnull}),${true},)
have_git_changelog := $(shell git changelog --version 2>${devnull})

# $(call %debug_var,have_git)
# $(call %debug_var,have_git_repo)
$(call %debug_var,have_git_changelog)

have_tests := $(wildcard ${SRC_files}/*_test.go)## .or. (slower) `$(if $(shell go test -v ./... -list . 2>${devnull}),${true},)`

$(call %debug_var,have_tests)

ifeq (${OSID},win)
shell_filter_targets := ${FINDSTR} -rc:"^[a-zA-Z][^: ]*:[^=].*${HASH}${HASH}"
shell_filter_targets := $(strip ${shell_filter_targets} $(if $(or $(call %not,${.DEFAULT_GOAL}),$(filter all bins examples,${.DEFAULT_GOAL})), | ${FINDSTR} -v "^run:"))
shell_filter_targets := $(strip ${shell_filter_targets} $(if $(or $(call %not,${.DEFAULT_GOAL}),$(filter all bins examples,${.DEFAULT_GOAL})), | ${FINDSTR} -v "^install:"))
shell_filter_targets := $(strip ${shell_filter_targets} $(if $(or $(call %not,${.DEFAULT_GOAL}),$(filter all bins examples,${.DEFAULT_GOAL})), | ${FINDSTR} -v "^uninstall:"))
shell_filter_targets := $(strip ${shell_filter_targets} $(and $(call %not,${SRC_files}), | ${FINDSTR} -v "^build:"))
shell_filter_targets := $(strip ${shell_filter_targets} $(and $(call %not,${SRC_files}), | ${FINDSTR} -v "^compile:"))
shell_filter_targets := $(strip ${shell_filter_targets} $(and $(call %not,${SRC_files}), | ${FINDSTR} -v "^rebuild:"))
# shell_filter_targets := $(strip ${shell_filter_targets} $(if ${SRC_files}${BIN_SRC_files}${EG_SRC_files}${TEST_SRC_files},, | ${FINDSTR} -v "^all:"))
# shell_filter_targets := $(strip ${shell_filter_targets} $(if ${SRC_files}${BIN_SRC_files}${EG_SRC_files}${TEST_SRC_files},, | ${FINDSTR} -v "^debug:"))
shell_filter_targets := $(strip ${shell_filter_targets} $(and $(call %not,${BIN_SRC_files}), | ${FINDSTR} -v "^bins:"))
shell_filter_targets := $(strip ${shell_filter_targets} $(and $(call %not,${EG_SRC_files}), | ${FINDSTR} -v "^examples:"))
shell_filter_targets := $(strip ${shell_filter_targets} $(and $(call %not,${SRC_files}), | ${FINDSTR} -v "^coverage:"))
shell_filter_targets := $(strip ${shell_filter_targets} $(and $(call %not,${SRC_files}), | ${FINDSTR} -v "^lint:"))
shell_filter_targets := $(strip ${shell_filter_targets} $(and $(call %not,${SRC_files}), | ${FINDSTR} -v "^reformat:"))
shell_filter_targets := $(strip ${shell_filter_targets} $(and $(call %not,${have_tests}), | ${FINDSTR} -v "^test:"))
shell_filter_targets := $(strip ${shell_filter_targets} $(and $(call %not,${have_tests}), | ${FINDSTR} -v "^tests:"))
#
shell_filter_targets := $(strip ${shell_filter_targets} $(and $(call %not,${have_git_changelog}), | ${FINDSTR} -v "^changelog:"))
else
shell_filter_targets := ${GREP} -P '(?i)^[[:alpha:]][^:\s]*:[^=].*${HASH}${HASH}'
shell_filter_targets := $(strip ${shell_filter_targets} $(if $(or $(call %not,${.DEFAULT_GOAL}),$(filter all bins examples,${.DEFAULT_GOAL})), | ${FINDSTR} -v "^run:"))
shell_filter_targets := $(strip ${shell_filter_targets} $(if $(or $(call %not,${.DEFAULT_GOAL}),$(filter all bins examples,${.DEFAULT_GOAL})), | ${FINDSTR} -v "^install:"))
shell_filter_targets := $(strip ${shell_filter_targets} $(if $(or $(call %not,${.DEFAULT_GOAL}),$(filter all bins examples,${.DEFAULT_GOAL})), | ${FINDSTR} -v "^uninstall:"))
shell_filter_targets := $(strip ${shell_filter_targets} $(and $(call %not,${SRC_files}), | ${GREP} -Pv "^build:"))
shell_filter_targets := $(strip ${shell_filter_targets} $(and $(call %not,${SRC_files}), | ${GREP} -Pv "^compile:"))
shell_filter_targets := $(strip ${shell_filter_targets} $(and $(call %not,${SRC_files}), | ${GREP} -Pv "^rebuild:"))
# shell_filter_targets := $(strip ${shell_filter_targets} $(if ${SRC_files}${BIN_SRC_files}${EG_SRC_files}${TEST_SRC_files},, | ${GREP} -Pv "^all:"))
# shell_filter_targets := $(strip ${shell_filter_targets} $(if ${SRC_files}${BIN_SRC_files}${EG_SRC_files}${TEST_SRC_files},, | ${GREP} -Pv "^debug:"))
shell_filter_targets := $(strip ${shell_filter_targets} $(and $(call %not,${BIN_SRC_files}), | ${GREP} -Pv "^bins:"))
shell_filter_targets := $(strip ${shell_filter_targets} $(and $(call %not,${EG_SRC_files}), | ${GREP} -Pv "^examples:"))
shell_filter_targets := $(strip ${shell_filter_targets} $(and $(call %not,${SRC_files}), | ${GREP} -Pv "^coverage:"))
shell_filter_targets := $(strip ${shell_filter_targets} $(and $(call %not,${SRC_files}), | ${GREP} -Pv "^lint:"))
shell_filter_targets := $(strip ${shell_filter_targets} $(and $(call %not,${SRC_files}), | ${GREP} -Pv "^reformat:"))
shell_filter_targets := $(strip ${shell_filter_targets} $(and $(call %not,${have_tests}), | ${GREP} -Pv "^test:"))
shell_filter_targets := $(strip ${shell_filter_targets} $(and $(call %not,${have_tests}), | ${GREP} -Pv "^tests:"))
#
shell_filter_targets := $(strip ${shell_filter_targets} $(and $(call %not,${have_git_changelog}), | ${GREP} -Pv "^changelog:"))
endif
$(call %debug_var,shell_filter_targets)

all_phony_targets += help
help: ## Display help
	@${ECHO_newline}
	@${ECHO} $(call %shell_escape,Usage: `${color_command}${make_invoke_alias} [MAKE_TARGET...] [CONFIG=debug|release] [COLOR=<truthy>] [MAKEFLAGS_debug=<truthy>] [VERBOSE=<truthy>]${color_reset}`)
ifneq (,$(or ${SRC_files},${BIN_SRC_files},${EG_SRC_files}))
	@${ECHO} $(call %shell_escape,Builds $(if $(filter all bins examples,${.DEFAULT_GOAL}),'${color_target}${.DEFAULT_GOAL}${color_reset}' targets,'${color_target}$(call %strip_leading_dotslash,${.DEFAULT_GOAL})${color_reset}') within '${color_path}$(call %strip_leading_dotslash,${current_dir})${color_reset}')
endif
	@${ECHO_newline}
	@${ECHO} $(call %shell_escape,MAKE_TARGETs:)
	@${ECHO_newline}
ifeq (${OSID},win)
	@${TYPE} $(call %map,%shell_quote,${makefile_set}) 2>${devnull} | ${shell_filter_targets} | ${SORT} | for /f "tokens=1-2,* delims=:${HASH}" %%g in ('${MORE}') do @(@call set "t=%%g                " & @call echo ${color_success}%%t:~0,15%%${color_reset} ${color_info}%%i${color_reset})
else
	@${CAT} $(call %map,%shell_quote,${makefile_set}) | ${shell_filter_targets} | ${SORT} | ${AWK} 'match($$0,"^([^:]+):.*?${HASH}${HASH}\\s*(.*)$$",m){ printf "${color_success}%-10s${color_reset}\t${color_info}%s${color_reset}\n", m[1], m[2] }END{}'
endif
	@${ECHO} ${color_hide}${DOT}${color_reset}

####

all_phony_targets += clean realclean

clean: ## Remove build artifacts (for the active configuration; includes intermediate files)
# * notes: avoid removing the main directory and filter-out directories which are obviously invalid
	@$(call !shell_noop,::note ~ pre-executed call::$(call %rm_dirs_verbose,$(filter-out filter-out ${DOT} ${DOT}${DOT} ${SLASH} ${BACKSLASH},${out_dirs})))

realclean: clean ## Remove *all* build artifacts (including all configurations and the build directory)
ifeq ($(filter-out ${DOT} ${DOT}${DOT} ${SLASH} ${BACKSLASH},${BUILD_DIR}),)
	@${ECHO} $(call %failure,'realclean' is unavailable for the current build directory ('${BUILD_DIR}').)
else
	@$(call !shell_noop,::note ~ pre-executed call::$(call %rm_dirs_verbose,${BUILD_DIR}))
endif

####

all_phony_targets += build rebuild

build: ${.DEFAULT_GOAL} ## Build project
rebuild: clean build ## Clean and re-build project

####

all_phony_targets += fmt format reformat
fmt: reformat
format: reformat
reformat: ## Reformat source files (using `go fmt ...`) [alias: 'fmt','format']
	go fmt ${SOURCE_dirs}

####

all_phony_targets += cov cover coverage
cov: coverage
cover: coverage
coverage: build | ${BUILD_DIR} ## Display test coverage for project files [alias: 'cov','cover']
	goverage -coverprofile="${BUILD_DIR}/cover.out" ${SOURCE_dirs}
	go tool cover -func="${BUILD_DIR}/cover.out"
	@$(call %rm_file_shell_s,${BUILD_DIR}/cover.out) >${devnull} 2>&1

####

all_phony_targets += lint
lint: ## Display lint warnings for source files (using `golint ...`)
	golint ${SOURCE_dirs}

all_phony_targets += test
test: build ## Test project
	go test -v ${SOURCE_dirs}

####

all_phony_targets += install uninstall
install: ## Install project executable (to host GOBIN)
	go install ${GO_BUILD_FLAGS} "${BIN_DIR}/${NAME}"
	@${ECHO} $(call %shell_escape,$(call %success_text,installed as '${GOBIN}/${NAME}${EXEEXT}'.))

uninstall: ## Remove *installed executable* (from host GOBIN)
	@$(call %rm_file_shell_s,${GOBIN}/${NAME}${EXEEXT}) >${devnull}
	@${ECHO} $(call %shell_escape,$(call %success_text,un-installed '${GOBIN}/${NAME}${EXEEXT}'.))

####

all_phony_targets += changelog
changelog: ## Display changelog for planned next TAG (using `git-changelog ...`; optionally use TAG="M.m.r")
	git-changelog --next-tag ${TAG} ${TAG}

####
endif ## not ${has_run_first}
####

# ref: [`make` default rules]<https://www.gnu.org/software/make/manual/html_node/Catalogue-of-Rules.html> @@ <https://archive.is/KDNbA>
# ref: [make ~ `eval()`](http://make.mad-scientist.net/the-eval-function) @ <https://archive.is/rpUfG>
# * note: for pattern-based rules/targets, `%` has some special matching mechanics; ref: <https://stackoverflow.com/a/21193953> , <https://www.gnu.org/software/make/manual/html_node/Pattern-Match.html#Pattern-Match> @@ <https://archive.is/GjJ3P>

####

%*[makefile.run]*: %
	@${ECHO} $(call %shell_escape,$(call %info_text,running '$<'))
	@$(strip ${RUNNER_${CC}} $(call %shell_quote,$<)) ${ARGS}

####

# ${NAME}: ${PROJECT_TARGET}
${PROJECT_TARGET}: ${SRC_files} ${makefile_set} | ${OUT_DIR}
	@go build $(GO_BUILD_FLAGS) -o "$(OUT_DIR)" ${SOURCE_dirs}
	@${ECHO} $(call %shell_escape,$(call %success_text,made '$@'.))

#### * auxiliary/configuration rules

# * directory rules
# $(foreach dir,$(filter-out ${DOT} ${DOT}${DOT},${out_dirs_for_rules}),$(call %info,eval $(call @mkdir_rule,${dir})))
$(foreach dir,$(filter-out ${DOT} ${DOT}${DOT},${out_dirs_for_rules}),$(eval $(call @mkdir_rule,${dir})))

# * all known phony targets
.PHONY: ${all_phony_targets}

# suppress auto-deletion of intermediate files
# ref: [`gmake` ~ removing intermediate files](https://stackoverflow.com/questions/47447369/gnu-make-removing-intermediate-files) @@ <https://archive.is/UXrIv>
.SECONDARY:

# suppress recipe output if not verbose (note: '@' prefix is suppressed no matter the VERBOSE setting)
$(call %is_truthy,${VERBOSE}).SILENT:

#### * final checks and hints

ifeq (${NULL},$(or ${SRC_files},${BIN_SRC_files},${EG_SRC_files}))
msg := no source files found; unrecognized project format and `go list -f {{.Dir}} ./...` finds no files
$(call %warning,${msg})
endif

# $(call %debug_var,NULL)
$(call %debug_var,has_runner_target)
$(call %debug_var,all_phony_targets)
$(call %debug_var,make_runner_ARGS)

ifeq (${true},$(call %as_truthy,${has_runner_target}))
ifneq (${NULL},$(if ${has_runner_target},$(filter ${all_phony_targets},${make_runner_ARGS}),${NULL}))
$(call %warning,runner arguments duplicate (and overwrite) standard targets; try using `${make_invoke_alias} run ARGS=...`)
endif
# $(info make_runner_ARGS=:${make_runner_ARGS}:)
$(eval ${make_runner_ARGS}:;@:)
endif
