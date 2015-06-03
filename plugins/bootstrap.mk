.PHONY: bootstrap

help::
	@printf "%s\n" "" \
		"  bootstrap          Generate a skeleton of an application"

define tmpl_Makefile
PROJECT = $(PROJECT)
PROJECT_PATH = github.com/$(shell whoami)/$(PROJECT)
include golang.mk
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

define render_template
	@echo "$${$(1)}" > $(2)
endef

$(foreach template,$(filter tmpl_%,$(.VARIABLES)),$(eval export $(template)))

bootstrap:
ifneq ($(wildcard $(PROJECT)/),)
	$(error Error: $(PROJECT)/ directory already exists)
endif
	@mkdir $(PROJECT)
	$(call render_template,tmpl_Makefile,Makefile)
	$(call render_template,tmpl_main,$(PROJECT)/$(PROJECT).go)

