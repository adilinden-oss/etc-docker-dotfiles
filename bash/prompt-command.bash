#
# Bash prompt
#
# This ties together the various location aware prompts into a single
# comprehensive bash prompt.
#
# General bash PS1 and PROMPT_COMMAND info
#   https://wiki.archlinux.org/index.php/Bash/Prompt_customization#Embedding_commands
#
# The desired outcome should be something like:
#
# Inside $PWD short path        PS1='\u@\h:\W\$ '
# Outside $PWD long path        PS1='\u@\h:\w\$ '
# Inside git repo               PS1='\u@\h:\w(repo:branch flags)\$ '
# Remote docker active          PS1='\u@\h:\W[docker-machine-name]\$ '
#

function __my_prompt_command ()
{
    local _ps1_pre='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:'
    local _ps1_path='\[\033[01;34m\]\w\[\033[00m\]'
    local _ps1_post='\$ '
    local _ps1_git
    local _ps1_docker
    local _ps1

    _ps1="$_ps1_pre"

    # Get git prompt
    [ -n "$(declare -F __my_git_ps1)" ] && _ps1="$_ps1$(__my_git_ps1)" || _ps1="$_ps1$_ps1_path"

    # Finished off
    _ps1="$_ps1$_ps1_post"

    # Set PS1
    PS1="$_ps1"
}

# End