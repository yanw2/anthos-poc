# Use some sensible default shell settings
SHELL := /bin/bash -o pipefail
.SILENT:
.DEFAULT_GOAL := help

# Terraform 
include ./terraform/Makefile

##@ Miscellaneous
.PHONY: help
help: ## Display help
	awk \
	  'BEGIN { \
	    FS = ":.*##"; printf "\nUsage:\n  make \033[36m[TARGET] [CLUSTER]\033[0m\n" \
	  } /^[a-zA-Z0-9_.-]+:.*?##/ { \
	    printf "  \033[36m%-15s\033[0m	%s\n", $$1, $$2 \
	  } /^##@/ { \
	    printf "\n\033[1m%s\033[0m\n", substr($$0, 5) \
	  }' $(MAKEFILE_LIST)
