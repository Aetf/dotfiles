# My dotfiles

After checkout, run `scripts/crypt.sh init` to setup filters. Then run the following to recheckout with filter applied.
```
git stash save
rm .git/index
git checkout HEAD -- "$(git rev-parse --show-toplevel)"
git stash pop
```

