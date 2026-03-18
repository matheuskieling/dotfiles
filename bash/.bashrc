# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# Omarchy defaults (sourced individually to skip inputrc which breaks vi mode)
source ~/.local/share/omarchy/default/bash/envs
source ~/.local/share/omarchy/default/bash/shell
source ~/.local/share/omarchy/default/bash/aliases
source ~/.local/share/omarchy/default/bash/functions
source ~/.local/share/omarchy/default/bash/init

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'

set -o vi
