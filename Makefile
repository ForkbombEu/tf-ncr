# Makefile for running a series of commands for tofu initialization and deployment
ContractsURL ?= https://github.com/ForkbombEu/tf-pqcrypto-scripts

.PHONY: start help destroy

#all: start

help:
	@echo "Some examples for usage: \n\
	make start SSH=y NewPKey=y \n\
	make start SSH=n NewPKey=n \n\
	make start SSH=y NewPKey=n ContractsURL=someGithubUrlWithAZenroomContratsFolder \n\
	make start SSH=n NewPKey=n ContractsURL=https://github.com/ForkbombEu/tf-pqcrypto-scripts"

deploy:
# Check parameters
ifndef SSH
	$(error SSH is required. Usage: make start SSH=y/n NewPKey=y/n ContractsURL=githubUrl)
endif
ifndef NewPKey
	$(error NewPKey is required. Usage: make start SSH=y/n NewPKey=y/n ContractsURL=githubUrl)
endif

	@if [ "$(SSH)" != "y" ] && [ "$(SSH)" != "Y" ] && [ "$(SSH)" != "n" ]; then \
		echo "Aborted. SSH can only be y or n"; \
		exit 1; \
	fi
	@if [ "$(NewPKey)" != "y" ] && [ "$(NewPKey)" != "Y" ] && [ "$(NewPKey)" != "n" ]; then \
		echo "Aborted. NewPKey can only be y or n"; \
		exit 1; \
	fi

	# Creating a new public key
	@if [ "$(NewPKey)" = "y" ] || [ "$(NewPKey)" = "Y" ]; then \
		echo "Creating a new public key..."; \
		ssh-keygen -t ed25519 -C "noOwnerName" -f ./myED25519Key && \
		chmod 700 ./myED25519Key; \
	fi

	# Replacing 'PLACEHOLDER_FOR_GITHUB_REPO_WITH_ZENROOM_CONTRACTS_FOLDER' with '$(ContractsURL)' in user-data.sh
	sed -i 's|PLACEHOLDER_FOR_GITHUB_REPO_WITH_ZENROOM_CONTRACTS_FOLDER|$(ContractsURL)|g' user-data.sh

	# Check if public key is necessary and exists
	@if [ "$(SSH)" = "y" ] || [ "$(SSH)" = "Y" ]; then \
		if [ ! -f myED25519Key ]; then \
			echo "Error: Public key is missing. Aborting start."; \
			exit 1; \
		fi; \
	fi

	# Deployment
	@echo "Deploying the EC2 machine..."
	@if [ "$(SSH)" = "y" ] || [ "$(SSH)" = "Y" ]; then \
		cd openTofuCode && tofu init && tofu apply -auto-approve; \
	else \
		cd openTofuCode && tofu init && tofu apply -auto-approve -var="create_key_pair=false"; \
	fi

destroy:
	cd openTofuCode && tofu destroy
