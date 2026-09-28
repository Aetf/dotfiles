# Starship prompt integration. The indexer loads plugin directories after the
# top-level config.d files, in path order; the number puts this one before
# 90-work, which extends it.
#
#   config.zsh                 the config starship reads, from base.toml and
#                              the fragments other configs register
#   prompt.zsh                 the zsh prompt drawn around starship
#   async-prompt-segments.zsh  prompt segments computed in the background
source ${0:A:h}/config.zsh
source ${0:A:h}/prompt.zsh
source ${0:A:h}/async-prompt-segments.zsh
