.PHONY: up down start stop cleanContainers clean

repo := $(shell git rev-parse --show-toplevel)
cur_dir := $(shell pwd)

start:
	echo "Starting Clean Up"
show:
	echo ${repo}; 
	echo ${cur_dir};
purge:
	find ${repo} -type f -name \*.tfstate* -exec rm {} \;
	find ${repo} -type f -name \*.tfplan -exec rm {} \;
	find ${repo} -type d -name .terraform | xargs rm -rf {} \;
	find ${repo} -type f -name .DS_Store -exec rm {} \;
	find ${repo} -type f -name s3backend.tf -exec rm {} \;
	find ${repo} -type f -name dataremotestate.tf -exec rm {} \;
prep:
	find ${repo} -name \*.tf -exec chmod 644 {} \;
	find ${repo} -name \*.tfvars -exec chmod 644 {} \;
	find ${repo} -name \*.txt -exec chmod 644 {} \;
mvtf:
	for f in *.tf; do \
	  mv -- "$${f}"  "$${f}.ignore"; \
	done;
cptf:
	cd ${cur_dir}; \
	for f in *.ignore; do \
	  mv -- "$$f" "$${f%.ignore}"; \
	done;

clean: start show purge
