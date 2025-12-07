# my-dotfiles

This repository has my dotfiles and their setup script.

## Usage

You can create symlinks at your `$HOME` but does not replace existing files, directories or symlinks:
```bash
./setup.sh install --target .*

# Or you can specify some symlinks:
./setup.sh install --target .config .gitconfig

# Or you can replace existing file, directories or symlinks with --force flag:
./setup.sh install --target .* --force
```

