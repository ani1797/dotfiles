# Ani's Dotfiles

This project aims to streamline and simplify my machine setup. I primarily use MacOS, Ubuntu and Windows (wsl) as the OS of choice. Please see compatibility section for choices being made.

## Getting Started

Get started by running commands below:

```sh
# Here is a suggestion for dotfiles locations:
# 1. $HOME/.dotfiles
# 2. $HOME/dotfiles
# 3. /workspaces/.dotfiles
# 4. /workspaces/dotfiles
# 5. /workspaces/.codespaces/.persistedshare/dotfiles

# Assuming you will be cloning and using $HOME folder for you dotfiles.
git clone https://github.com/ani1797/dot.git $HOME/.dotfiles
$HOME/dotfiles/install.sh
```

> Note the 5rd option is where Github Codespaces clones and installs the dotfiles from.
> You can enable these settings [here](https://github.com/settings/codespaces)
> Learn more about personalizing github codespaces [here](https://docs.github.com/en/codespaces/troubleshooting/troubleshooting-personalization-for-codespaces)

## What's in this repo?

This repo installs and configures homebrew as my package manager of choice on all platform. I had also considered nix and would love to switch however the steep learning curve is just too much to take at this time.

- Custom Quick Commands

I have written a bunch and sourced a bunch of cool little scripts that make using terminal a little more pleasant. See [here](shell/bin) for all scripts.

- Brew Bundles

Brew bundles are a collection of tools for either different systems or different purpose. Along with these collection which can be found [here](brew), I have included a quick command that will allow you update/install these collections in one go.

```sh
# not providing name will default to the "common" package.
ibrew [name]
```

Common package consist of various tools I consider good to have on all systems. These packages work on all OS. These common tools are:

1. starship
2. fzf
3. eza
4. direnv
5. mise
6. fd

You can also explore other mini collections and add more if you'd like and ibrew will install any bundle folders right name.

## OS Compatibility

1. MacOS
2. Ubuntu
3. Arch Linux
4. Window (WSL Only)

### Shell

1. ZSH
2. Bash
