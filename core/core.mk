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

GOLANG_MK_VERSION = 1
GO_VERSION = $(shell go version 2>/dev/null)

# Core configuration.

PROJECT_MAIN ?= $(notdir $(CURDIR))
PROJECT_MAIN := $(strip $(PROJECT_MAIN))

# Verbosity.

V ?= 0

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

