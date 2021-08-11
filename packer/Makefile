AWS_DEFAULT_REGION?=eu-central-1
export AWS_DEFAULT_REGION


default: help

help:
	@echo "avaliable make commands:"
	@cat $(MAKEFILE_LIST) |grep -E "^[a-z-]*:" |grep -v default |sed 's/^/\ \ /g'

build:
	packer validate . ; \
	packer fmt . ; \
	packer init . ; \
	packer build .

install-ansible:
	sudo apt update; \ 
	sudo apt install software-properties-common; \
	sudo add-apt-repository --yes --update ppa:ansible/ansible; \
	sudo apt install ansible

install-packer:
	curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
	sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
	sudo apt-get update && sudo apt-get install packer

install-packer-goss:
	mkdir ~/.packer.d/plugins
	curl -L https://github.com/YaleUniversity/packer-provisioner-goss/releases/download/v3.0.3/packer-provisioner-goss-v3.0.3-linux-amd64.tar.gz -o packer-goss.tar.gz | tar -zxvf packer-goss.tar.gz -C ~/.packer.d/plugins

install:
	install-ansible
	install-packer
	install-packer-goss