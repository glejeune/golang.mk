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

PROJECT_MAIN ?= $(notdir $(CURDIR))
PROJECT_MAIN := $(strip $(PROJECT_MAIN))

# Verbosity.

V ?= 0
Q ?= 0

# Other options

DISABLE_FMT ?= 0

# Temporary files directory.

GOLANG_MK_TMP ?= $(CURDIR)/.golang.mk
export GOLANG_MK_TMP

all::
	@$(MAKE) --no-print-directory app

clean::
	@echo -n

distclean:: clean
	@rm -rf $(GOLANG_MK_TMP)

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
		"  run           Run the project (like go run...). Use ARGS for arguments." \
		"  help          Display this help and exit" \
		"  golank-mk     Update golang.mk" \
		"" \
		"The target clean only removes files that are commonly removed." \
		"Dependencies are left untouched." \
		"" \
		"Setting V=1 when calling $(MAKE) enables verbose mode." \
		"Setting Q=1 when calling $(MAKE) in quiet mode."

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

ifeq ($Q,0)
define console_info
  @echo "INFO: "$(1)
endef
ifeq ($V,1)
define console_debug
  @echo "DEBUG: "$(1)
endef
else
define console_debug
endef
endif
else
define console_info
endef
define console_debug
endef
endif

# Automated update.

GOLANG_MK_BUILD_CONFIG ?= build.config
GOLANG_MK_BUILD_DIR ?= .golang.mk.build
GO_SOURCES ?= $(wildcard **/*.go) $(wildcard *.go)

golang-mk:
	@echo -n "Update golang.mk."
	@git clone https://github.com/glejeune/golang.mk $(GOLANG_MK_BUILD_DIR) --quiet
	@if [ -f $(GOLANG_MK_BUILD_CONFIG) ]; then cp $(GOLANG_MK_BUILD_CONFIG) $(GOLANG_MK_BUILD_DIR); fi
	@cd $(GOLANG_MK_BUILD_DIR) && $(MAKE) --no-print-directory
	@cp $(GOLANG_MK_BUILD_DIR)/golang.mk ./golang.mk
	@rm -rf $(GOLANG_MK_BUILD_DIR)
	@echo "ok"


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
	  pk := stripchars(p, \"\\\\\"\")\n \
	  fmt.Printf(\"INFO: check %%s\\\\n\", pk)\n \
	  out, _ := exec.Command(\"go\", \"get\", pk).Output()\n \
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

.PHONY: pre-app do-app post-app pre-fmt fmt post-fmt pre-install install post-install pre-deps deps post-deps

app:: pre-app do-app post-app

do-app: pre-fmt fmt post-fmt pre-install install post-install pre-deps deps post-deps
ifeq ($(wildcard $(PROJECT_MAIN)/$(PROJECT_MAIN).go),$(PROJECT_MAIN)/$(PROJECT_MAIN).go)
	@$(call console_info,"Build app (main: $(PROJECT_MAIN)/$(PROJECT_MAIN).go).")
	@cd $(PROJECT_MAIN) && go build $(PROJECT_MAIN).go
else ifeq ($(wildcard $(PROJECT_MAIN).go),$(PROJECT_MAIN).go)
	@$(call console_info,"Build app (main: $(PROJECT_MAIN).go).")
	@go build $(PROJECT_MAIN).go
else
	@$(call console_debug,"$(PROJECT_MAIN).go not found")
endif

run:: install deps
ifeq ($(wildcard $(PROJECT_MAIN)/$(PROJECT_MAIN).go),$(PROJECT_MAIN)/$(PROJECT_MAIN).go)
	@$(call console_info,"Build app (main: $(PROJECT_MAIN)/$(PROJECT_MAIN).go).")
	@cd $(PROJECT_MAIN) && go run $(PROJECT_MAIN).go $(ARGS)
else ifeq ($(wildcard $(PROJECT_MAIN).go),$(PROJECT_MAIN).go)
	@$(call console_info,"Build app (main: $(PROJECT_MAIN).go).")
	@go run $(PROJECT_MAIN).go $(ARGS)
else
	@$(call console_debug,"$(PROJECT_MAIN).go not found")
endif

fmt:
ifeq ($(DISABLE_FMT),0)
	@$(call console_debug,"Run fmt")
	@if [ -n "$$(go fmt ./...)" ]; then echo 'Please run go fmt on your code.' && exit 1; fi
else
	@$(call console_debug,"WARNING, fmt disabled")
endif

pre-fmt::

post-fmt::

pre-install::

post-install::

pre-deps::

post-deps::

pre-app::

post-app::



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

.PHONY: install

define clean_install_path
  if [ -d $(GOPATH)/src/$(PROJECT_MODULE) ] ; then \
    rm -rf $(GOPATH)/src/$(PROJECT_MODULE); \
  fi
endef

define install_path
  mkdir -p $(GOPATH)/src/$(PROJECT_MODULE); \
  cp -r . $(GOPATH)/src/$(PROJECT_MODULE)
endef

install::
ifdef PROJECT_MODULE
ifneq (${GOPATH}/src/${PROJECT_MODULE},$(shell pwd))
	@$(call console_info,"Install app.")
	@$(call console_debug,"Install PATH: ${GOPATH}/src/${PROJECT_MODULE}")
	@$(call clean_install_path)
	@$(call install_path)
else
	@$(call console_debug,"skip install: all done")
endif
else
	@$(call console_debug,"PROJECT_MODULE undefined, skip install")
endif

distclean::
ifdef PROJECT_MODULE
ifneq (${GOPATH}/src/${PROJECT_MODULE},$(shell pwd))
	@$(call clean_install_path)
endif
endif


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

.PHONY: tests cover

tests:: install-cover
	@go test -v -cover -race ./...

install-cover:
	@go get golang.org/x/tools/cmd/cover


.PHONY: bootstrap

help::
	@printf "%s\n" "" \
		"  bootstrap          Generate a skeleton of an application"

define tmpl_Makefile
PROJECT_MAIN = $(PROJECT_MAIN)
PROJECT_MODULE = github.com/$(shell whoami)/$(PROJECT_MAIN)
include golang.mk

clean::
	@rm $(PROJECT_MAIN)/$(PROJECT_MAIN)
endef

define tmpl_main
package main

import (
  "fmt"
)

func main() {
  fmt.Println("Hello World!")
}
endef

define tmpl_main_test
package main

import (
	"github.com/stretchr/testify/assert"
	"testing"
)

func TestMain(t *testing.T) {
	assert.True(t, false, "You *must* add more tests ;)")
}
endef

define tmpl_gitignore
$(PROJECT_MAIN)/$(PROJECT_MAIN)
*.swp
.golang.mk/
endef

define tmpl_README
# $(PROJECT_MAIN)

A golang project generated with [golang.mk](https://github.com/glejeune/golang.mk)

## Contributing

1. Fork it ( https://github.com/$(shell whoami)/$(PROJECT_MAIN)/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

endef

define render_template
  @$(call console_debug,"Generate $(2)")
	@echo "$${$(1)}" > $(2)
endef

$(foreach template,$(filter tmpl_%,$(.VARIABLES)),$(eval export $(template)))

bootstrap:
ifneq ($(findstring $(PROJECT_MAIN), $(GO_SOURCES)),)
	@$(call console_info,"$(PROJECT_MAIN).go already exists")
else
	@$(call console_info,"Generate bootstrap")
	@mkdir $(PROJECT_MAIN)
	@$(call render_template,tmpl_Makefile,Makefile)
	@$(call render_template,tmpl_main,$(PROJECT_MAIN)/$(PROJECT_MAIN).go)
	@$(call render_template,tmpl_main_test,$(PROJECT_MAIN)/$(PROJECT_MAIN)_test.go)
	@$(call render_template,tmpl_README,README.md)
	@$(call render_template,tmpl_gitignore,.gitignore)
endif


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

.PHONY: vet

help::
	@printf "%s\n" "" \
		"  vet                run go tool vet on packages"

vet: install_go_vet
	@go vet ./...

install_go_vet:
	@go get golang.org/x/tools/cmd/vet


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

.PHONY: errcheck

help::
	@printf "%s\n" "" \
		"  errcheck           run go tool errcheck on packages"

errcheck: install_go_errcheck
	@errcheck ./...

install_go_errcheck:
	@go get github.com/kisielk/errcheck

