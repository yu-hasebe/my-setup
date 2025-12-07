# my-setup

This repository contains the core setup for my development environment.

## Dependencies not managed in this repository

Before running anything, make sure you install:

- [Homebrew](https://brew.sh/)
- `.tty` file from [x14y24pxHeadUpDaisy](https://hicchicc.github.io/00ff/#:~:text=%E3%81%B2%E3%81%A3%E3%81%8F-,x14y24pxHeadUpDaisy,-%E3%83%98%E3%83%83%E3%83%89%E3%82%A2%E3%83%83%E3%83%97%E3%83%87%E3%82%A4) and execute it once

## Homebrew

To install everything from Brewfile:
```bash
brew bundle install --file=Brewfile
```

To update Brewfile:
```bash
brew bundle dump --describe --file=Brewfile --force
```

## Setting up dotfiles in your `$HOME` directory

> [!NOTE]
> FIXME: Add the following snipets to `setup.sh` or its help message.

Create symlinks in your `$HOME` directory without replacing any existing files, directories or symlinks:
```bash
./setup.sh install --target .*
```

Specify particular files or directories:
```bash
./setup.sh install --target .config .gitconfig
```

Forcefully replace existing files, directories, or symlinks:
```bash
./setup.sh install --target .* --force
```

