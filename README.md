# my-setup

This repository contains the core setup for my development environment.

## Dependencies not managed in this repository

Before running anything, make sure you install:

- [Homebrew](https://brew.sh/)
- `.tty` file from [x14y24pxHeadUpDaisy](https://hicchicc.github.io/00ff/#:~:text=%E3%81%B2%E3%81%A3%E3%81%8F-,x14y24pxHeadUpDaisy,-%E3%83%98%E3%83%83%E3%83%89%E3%82%A2%E3%83%83%E3%83%97%E3%83%87%E3%82%A4) and execute it once

## Homebrew

To install everything from Brewfile:
```bash
make install-from-brewfile
```

To update Brewfile:
```bash
make update-brewfile
```

## Setting up dotfiles in your `$HOME` directory

To install all dotfiles in this repository, run the following command from the repository root:
```bash
./setup.sh install -t .* --force
```

This command creates symbolic links in your `$HOME` directory for all files matching the pattern `.*` in this repository.
The --force flag overwrites existing files or symlinks in `$HOME`.

For additional commands and options, see:
```bash
./setup.sh --help
```
