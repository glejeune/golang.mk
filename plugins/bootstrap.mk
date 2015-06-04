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
	@$(call render_template,tmpl_gitignore,.gitignore)
endif

