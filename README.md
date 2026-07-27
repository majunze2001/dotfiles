# Dotfiles

## TLDR
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/majunze2001/dotfiles/main/install.sh)"
```

## Installing dotfiles on a new system

Initialize the dotfile management environment.

```bash
git clone --bare git@github.com:majunze2001/dotfiles.git $HOME/.dotfiles
git --git-dir=$HOME/.dotfiles --work-tree=$HOME checkout main
source .dotmodules/init.sh
```

**Warning.** My machines have SSH authentication set up with Github, so cloning with `git@github.com:majunze2001/dotfiles.git` works. Others will have to clone with the URL `https://github.com/majunze2001/dotfiles.git`.

A unified set of dotfiles for MacOS and Linux machines is on the `unified` branch:

```bash
dotfiles checkout unified
```

You may run into errors when checking out a branch due to existing dotfiles in your home directory.
Do a quick backup to a separate directory, or just remove them.

Finally, run the installation script.
```bash
zsh ~/.dotmodules/install/all.sh
```


Restarting the shell will finish the installation.

**Warning.** Don't forget to change `.gitconfig` to reflect your identity (use the `git config` command).

## Modifying configurations

In your home directory, you can do things like:

```bash
dotfiles status
dotfiles add .new_dotfile
dotfiles commit -m "A new dotfile that's really damn.. new!"
dotfiles push
```
