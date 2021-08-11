AWS_DEFAULT_REGION?=eu-central-1
export AWS_DEFAULT_REGION


default: help

help:
	@echo "avaliable make commands:"
	@cat $(MAKEFILE_LIST) |grep -E "^[a-z-]*:" |grep -v default |sed 's/^/\ \ /g'

plan:
	terraform fmt .
	terraform plan

apply:
	terraform fmt .
	terraform apply

destroy:
	terraform fmt .
	terraform destroy