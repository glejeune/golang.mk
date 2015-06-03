# Copyright (c) 2015, Gregoire Lejeune
#
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
# * The name of the author may not be used to endorse or promote products derived
#   from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

.PHONY: all deps app docs tests clean distclean help golang-mk

GOLANG_MK_VERSION = master
GO_VERSION = $(shell go version 2>/dev/null)

# Core configuration.

PROJECT ?= $(notdir $(CURDIR))
PROJECT := $(strip $(PROJECT))

# Verbosity.

V ?= 0

gen_verbose_0 = @echo " GEN   " $@;
gen_verbose = $(gen_verbose_$(V))

# Temporary files directory.

GOLANG_MK_TMP ?= $(CURDIR)/.golang.mk
export GOLANG_MK_TMP

all:: deps
	@$(MAKE) --no-print-directory app

clean::
	@echo -n

distclean:: clean

help::
	@printf "%s\n" \
		"golang.mk (version $(GOLANG_MK_VERSION)) is distributed under the terms of the BSD-3 License." \
		"Copyright (c) 2015 Grégoire Lejeune <gregoire.lejeune@free.fr>" \
		"" \
		"$(GO_VERSION)" \
		"" \
		"Usage: [V=1] $(MAKE) [target]" \
		"" \
		"Core targets:" \
		"  all           Run deps, app and rel targets in that order" \
		"  deps          Fetch dependencies (if needed) and compile them" \
		"  app           Compile the project" \
		"  tests         Run the tests for this project" \
		"  clean         Delete temporary and output files from most targets" \
		"  distclean     Delete all temporary and output files" \
		"  help          Display this help and exit" \
		"" \
		"The target clean only removes files that are commonly removed." \
		"Dependencies are left untouched." \
		"" \
		"Setting V=1 when calling $(MAKE) enables verbose mode."

# Core functions.

define newline


endef

ifeq ($(shell which wget 2>/dev/null | wc -l), 1)
define core_http_get
	wget --no-check-certificate -O $(1) $(2)|| rm $(1)
endef
else
	@echo "ERROR: Missing wget..."
endif

define mk_tmp
  @mkdir -p $(GOLANG_MK_TMP)
endef

# Automated update.

GOLANG_MK_BUILD_CONFIG ?= build.config
GOLANG_MK_BUILD_DIR ?= .golang.mk.build
GO_SOURCES ?= $(wildcard **/*.go)

golang-mk:
	git clone https://github.com/glejeune/golang.mk $(GOLANG_MK_BUILD_DIR)
	if [ -f $(GOLANG_MK_BUILD_CONFIG) ]; then cp $(GOLANG_MK_BUILD_CONFIG) $(GOLANG_MK_BUILD_DIR); fi
	cd $(GOLANG_MK_BUILD_DIR) && $(MAKE)
	cp $(GOLANG_MK_BUILD_DIR)/golang.mk ./golang.mk
	rm -rf $(GOLANG_MK_BUILD_DIR)


# Copyright (c) 2015, Gregoire Lejeune
#
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
# * The name of the author may not be used to endorse or promote products derived
#   from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.



deps:: get-deps

define build_get_deps
  @$(call mk_tmp); \
  if [ ! -f $(GOLANG_MK_TMP)/checkdeps ] ; then \
    printf "package main\n \
import (\n \
	\"fmt\"\n \
	\"go/parser\"\n \
	\"go/token\"\n \
	\"os\"\n \
	\"os/exec\"\n \
	\"strings\"\n \
)\n \
func stripchars(str, chr string) string {\n \
  return strings.Map(func(r rune) rune {\n \
    if strings.IndexRune(chr, r) < 0 {\n \
      return r\n \
    }\n \
    return -1\n \
  }, str)\n \
}\n \
func main() {\n \
	pkgs := make(map[string]bool)\n \
	for _, goSrc := range os.Args[1:] {\n \
		fset := token.NewFileSet()\n \
		f, err := parser.ParseFile(fset, goSrc, nil, parser.ImportsOnly)\n \
		if err != nil {\n \
			fmt.Println(err)\n \
			return\n \
		}\n \
		for _, s := range f.Imports {\n \
			if !pkgs[s.Path.Value] {\n \
				pkgs[s.Path.Value] = true\n \
			}\n \
		}\n \
	}\n \
	for p, _ := range pkgs {\n \
	  fmt.Printf(\"CHECK %%s\\\\n\", p)\n \
	  out, _ := exec.Command(\"go\", \"get\", stripchars(p, \"\\\\\"\")).Output()\n \
		if len(out) > 0 {\n \
		  fmt.Printf(\"  !! %%s\\\\n\", out)\n \
	  }\n \
	}\n \
}" > $(GOLANG_MK_TMP)/checkdeps.go; \
    cd $(GOLANG_MK_TMP) && go build checkdeps.go; \
  fi
endef

define get_deps
	$(GOLANG_MK_TMP)/checkdeps $(1)
endef

get-deps::
	@$(call build_get_deps)
	@$(call get_deps, $(GO_SOURCES))



# Copyright (c) 2015, Gregoire Lejeune
#
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
# * The name of the author may not be used to endorse or promote products derived
#   from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

app:: install
	@echo "Build app..."
	@cd $(PROJECT) && go build $(PROJECT).go

