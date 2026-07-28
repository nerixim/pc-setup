# Package lists
APTFILE := Aptfile

.PHONY: apt zsh git mise docker cli all help

help:
	@echo "Targets: apt zsh git mise docker cli all"
	@echo "Typical first run: make apt zsh git mise docker cli"

all: apt zsh git mise docker cli

apt:
	./scripts/apt.sh
	touch apt

zsh: apt
	./scripts/zsh.sh
	touch zsh

git: apt
	./scripts/git.sh
	touch git

mise: apt
	./scripts/mise.sh
	touch mise

docker: apt
	./scripts/docker.sh
	touch docker

cli: apt
	./scripts/cli.sh
	touch cli
