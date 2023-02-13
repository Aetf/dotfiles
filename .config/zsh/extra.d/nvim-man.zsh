# Use nvim as manpagger `:h Man`
function nvim_man() {
    nvim "+Man $* | only"
}
alias man=nvim_man

# TODO: add new nvimd target to customize beheavior
# * disable most plugins
# * remap q to :q

# Using MANPAGER and MANWIDTH as in the vim doc chokes on lines with middle &
# right justification -- it expands them out according to the value of MANWIDTH
# and they softwrap to a couple dozen mostly space-filled lines.
#export MANPAGER='nvim +Man!'
#export MANWIDTH=999
