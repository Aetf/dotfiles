# dotfiles

Managed by [yadm](https://github.com/TheLocehiliosan/yadm).

To bootstrap on a new machine, first download a temporary yadm and use it to clone this repository.
Later on yadm will be managed by zinit.

```sh
curl -fLo /tmp/yadm https://github.com/TheLocehiliosan/yadm/raw/master/yadm && chmod a+x /tmp/yadm
export PATH=/tmp:$PATH
yadm clone https://github.com/Aetf/dotfiles
```

## Sparse checkout
Some files are hidden by default to not clutter `$HOME`.
To modify those files, use a worktree, which will by default have sparse checkout disabled.

```sh
y worktree add /tmp/dotfiles
cd /tmp/dotfiles
# work on files and commit
y worktree remove /tmp/dotfiles
y merge --ff-only dotfiles
y branch -d dotfiles
```
