ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=240"
ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_USE_ASYNC=1
ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(bracketed-paste accept-line)
# Bind the widgets once, on the first prompt after the plugin loads, instead
# of rewrapping every widget in precmd (~30 ms per prompt). Everything that
# defines widgets (zsh-vi-mode, fzf-tab, fast-syntax-highlighting) is loaded
# by then; call _zsh_autosuggest_bind_widgets after defining new ones later.
ZSH_AUTOSUGGEST_MANUAL_REBIND=1
