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
  if [ -d $(GOPATH)/src/$(PROJECT_PATH) ] ; then \
    rm -rf $(GOPATH)/src/$(PROJECT_PATH); \
  fi
endef

define install_path
  mkdir -p $(GOPATH)/src/$(PROJECT_PATH); \
  cp -r . $(GOPATH)/src/$(PROJECT_PATH)
endef

install::
ifdef PROJECT_PATH
ifneq (${GOPATH}/src/${PROJECT_PATH},$(shell pwd))
	@$(call console_info,"Install app.")
	@$(call console_debug,"Install PATH: ${GOPATH}/src/${PROJECT_PATH}")
	@$(call clean_install_path)
	@$(call install_path)
else
	@$(call console_debug,"skip install: all done")
endif
else
	@$(call console_debug,"PROJECT_PATH undefined, skip install")
endif

distclean::
ifdef PROJECT_PATH
ifneq (${GOPATH}/src/${PROJECT_PATH},$(shell pwd))
	@$(call clean_install_path)
endif
endif

