help:  ## display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n\nTargets:\n"} \
	/^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%17s\033[0m  %s\n", $$1, $$2 }' $(MAKEFILE_LIST)


check:  ## check the formatting
	terraform fmt -recursive -check -diff


fmt:  ## reformat the code
	terraform fmt -recursive -write=true


validate:  ## check validity of the code
	terraform validate 
