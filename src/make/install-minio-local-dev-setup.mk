# src/make/clean-install-dockers.func.mk
# only the clean install dockers calls here ...
# TODO: figure a more elegant and generic way to avoid this copy paste ...
#

SHELL = bash
PRODUCT := $(shell basename $$PWD)
ORG := $(shell export ORG=$${ORG:-csi}; echo $${ORG})


APP_PORT=""


.PHONY: clean-install-minio-local-dev-setup  ## @-> setup the whole local devops environment no cache
clean-install-minio-local-dev-setup:
	$(call install-img,minio-local-dev-setup,--no-cache,${APP_PORT})


.PHONY: install-minio-local-dev-setup  ## @-> setup the whole local devops environment
install-minio-local-dev-setup:
	$(call install-img,minio-local-dev-setup,,${APP_PORT})
