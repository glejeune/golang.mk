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


