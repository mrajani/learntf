.PHONY: up down start stop cleanContainers clean

up:
	echo "hello world  up"

down:
	echo "hello world down"

start:
	echo "Starting Clean Up"

purge:
	find . -type f -name \*.tfstate.backup -exec rm {} \;
	find . -type f -name \*.tfstate -exec rm {} \;
	find . -type f -name \*.tfplan -exec rm {} \;
	find . -type d -name .terraform | xargs rm -rf {} \;
clean: start purge
