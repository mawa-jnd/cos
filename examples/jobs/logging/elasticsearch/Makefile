category    	:= support/logging
name        	:= lbe

docker_dir := .

# FIXME: DO NOT COMMIT THIS if true!!!
registry_local     := false
registry_local_url := "<host_ip_address>:5000"
latest_tag         := false

# Registry: AWS - default configuration, if unset environment variables
AWS_REGION    ?= eu-central-1
AWS_PROFILE		?= integration

################################################################################################################
# NOTE: The following lines can keep untouched. There is nothing more to configure the category and the name.  #
#################################################################################################################

# Registry: LOCAL
ifeq ($(registry_local), true)
	registry_url := $(registry_local_url)
	creds := $(echo "Using local docker registry: " $(registry_url))
# Registry: AWS
else
	# obtain aws account id
	aws_aid  := $(shell aws sts get-caller-identity --output text --query 'Account' --profile $(AWS_PROFILE))
	registry_url  := $(aws_aid).dkr.ecr.$(AWS_REGION).amazonaws.com

	# Create credentials for Docker for AWS ecr login
	creds := $(shell aws ecr get-login --no-include-email --region $(AWS_REGION) --profile $(AWS_PROFILE))
endif

# Create version tag from git commit message. Indicate if there are uncommited local changes.
ifeq ($(latest_tag), true)
	tag  := "latest"
else
	date := $(shell date '+%Y-%m-%d_%H-%M-%S')
	rev  := $(shell git rev-parse --short HEAD)
	flag := $(shell git diff-index --quiet HEAD -- || echo "_dirty";)
	tag  := $(date)_$(rev)$(flag)
endif

all: clean build push finish

build: version delim
	@echo "[INFO] Building and tagging image"
	docker build -t $(category)/$(name) --build-arg VERSION=$(tag) .
	@docker tag $(category)/$(name):latest $(registry_url)/$(category)/$(name):$(tag)

push: credentials delim
	@echo "[INFO] Pushing image to Registry"
	@docker push $(registry_url)/$(category)/$(name):$(tag)

clean:
	@rm -f version


version: delim chgwork
	@echo "[INFO] Building version:"
	@echo $(tag) | tee version

credentials: delim
	@echo "[INFO] Login to Registry"
	@$(creds)

chgwork: delim
	@echo "[INFO] Changing to work directory: $(docker_dir)"
	@cd $(docker_dir)

chgroot: delim
	@echo "[INFO] Changing to root directory"
	cd -

delim:
	@echo "------------------------------------------------------------------------------------------------"

finish:
	@echo "================================================================================================"
