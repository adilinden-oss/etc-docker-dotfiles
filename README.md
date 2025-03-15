# K-Net Dotfiles For Servers

... and Desktop too

To have a `bash` prompt that is responsive to git, install `etc-dotfiles` into the home directory.

    git clone https://github.com/knetca/etc-dotfiles.git .etc-dotfiles

Add this to `~/.gitconfig`:

```
[include]
    path = ~/.gitconfig_add
```

Initialize dotfiles

    cd .etc-dotfiles
    ./makelinks.sh

Log out and log back in to see the changes applied to the new bash session.
