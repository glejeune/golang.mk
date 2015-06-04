.PHONY: bootstrap

help::
	@printf "%s\n" "" \
		"  bootstrap          Generate a skeleton of an application"

define tmpl_Makefile
PROJECT = $(PROJECT)
PROJECT_PATH = github.com/$(shell whoami)/$(PROJECT)
include golang.mk

clean::
	@rm $(PROJECT)/$(PROJECT)
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
  @$(call console_debug,"Generate $(2)")
	@echo "$${$(1)}" > $(2)
endef

$(foreach template,$(filter tmpl_%,$(.VARIABLES)),$(eval export $(template)))

bootstrap:
ifneq ($(wildcard $(PROJECT)/),)
	@$(call console_info,"$(PROJECT)/ directory already exists")
else
	@$(call console_info,"Generate bootstrap")
	@mkdir $(PROJECT)
	@$(call render_template,tmpl_Makefile,Makefile)
	@$(call render_template,tmpl_main,$(PROJECT)/$(PROJECT).go)
endif

