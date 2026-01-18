.PHONY: update-brewfile
update-brewfile:
	brew bundle dump --describe --file=Brewfile --force

.PHONY: install-from-brewfile
install-from-brewfile:
	brew bundle install --file=Brewfile

