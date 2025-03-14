#
# Git prompt
#
# We use $_git because our git alias will require us to always
# load our ssh keys.
#
# Most everything copied from:
#   https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh
#
function __my_git_ps1 ()
{
    local _git
    local _ps1_pre=''
    local _ps1_post=''
    local _repo_info
    local _repo_info_exit
    local _repo_is_gitdir
    local _repo_is_bare
    local _repo_is_workdir
    local _repo_is_detached
    local _repo_sha
    local _repo_branch

    # We must have git
    _git=$(which git)
    if [ -z "$_git" ]; then
        return 1
    fi

    # Get repo info
    _repo_info="$($_git rev-parse --is-inside-git-dir --is-bare-repository --is-inside-work-tree --short HEAD 2> /dev/null)"
    _repo_info_exit=$?

    # We must be inside a repo
    if [ -z "$_repo_info" ]; then
        return 1
    fi

    # Get command line args
    if [ -n "$1" ]; then
        _ps1_pre="$1"
    fi
    if [ -n "$2" ]; then
        _ps1_post="$2"
    fi

    # Parse $_git_info into variables
    if [ "$_repo_info_exit" = "0" ]; then
        _repo_sha="${_repo_info##*$'\n'}"
        _repo_info="${_repo_info%$'\n'*}"
    fi
    _repo_is_workdir="${_repo_info##*$'\n'}"
    _repo_info="${_repo_info%$'\n'*}"
    _repo_is_bare="${_repo_info##*$'\n'}"
    _repo_info="${_repo_info%$'\n'*}"
    _repo_is_gitdir="${_repo_info##*$'\n'}"

    # String variables
    #
    # branch        $_b
    # changed       $_c
    # staged        $_s
    # untracked     $_u
    # clear (color) $_z
    # flags         $_f
    # result        $_r

    local _b=""
    local _c=""
    local _s=""
    local _u=""
    local _z=""
    local _f=""
    local _r=""

    if [ "$_repo_is_gitdir" = "true" ]; then
        if [ "$_repo_is_bare" = "true" ]; then
            _b="BARE!"
        else 
            _b="GIT_DIR!"
        fi
    elif [ "$_repo_is_workdir" = "true" ]; then
        # Get repo branch
        _repo_branch="$($_git rev-parse --abbrev-ref HEAD 2> /dev/null)"

        # Detached?
        if [ "$_repo_branch" = "HEAD" ]; then
            _repo_is_detached="yes"
            _b="$_repo_sha"
        else
            _b="$_repo_branch"
        fi

        # Repo dirty?
        #
        # Unstaged changed files
        #   0-true 1-false  
        #   git diff --no-ext-diff --quiet ; echo $?
        #
        # Uncommitted but staged files
        #   1-true 0-false
        #   git diff --no-ext-diff --cached --quiet ; echo $?
        #
        # Untracked files
        #   0-true 1-false  
        #   git ls-files --others --exclude-standard --directory --no-empty-directory \
        #           --error-unmatch -- ':/*' >/dev/null 2>/dev/null
        #
        "$_git" diff --no-ext-diff --quiet || _c='*'
        "$_git" diff --no-ext-diff --cached --quiet || _s='+'
        "$_git" ls-files --others --exclude-standard --directory --no-empty-directory \
                --error-unmatch -- ':/*' >/dev/null 2>/dev/null && _u='?'
    fi

    # Path components
    #
    # relative work dir    $_w
    # git repo name        $_n

    local _w=""
    local _n=""

    __my_git_ps1_dir

    # Apply color
    __my_git_ps1_col

    # Escape branch name
    #
    # Read https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh
    #
    # Prevents arbitrary code execution via specially crafted ref names.
    # I.e. try a branch named '$(IFS=_;cmd=ls_-al;$cmd)' without it.  I
    # tried, it's fun.  It's worrysome...
    #
    local _ps1_expand="yes"
    [ -z "${BASH_VERSION-}" ] || shopt -q promptvars || _ps1_expand="no"
    if [ "$_ps1_expand" = "yes" ]; then
        __my_git_ps1_branch_repo_name="$_b"
        _b="${__my_git_ps1_branch_repo_name}"
    fi

    # Build string
    _f="$_c$_s$_u"
    _r="$_b${_f:+ $_f}$_z"
    _r="$_n$_w($_r)"

    # Echo output
    printf -- '%s%s%s' "$_ps1_pre" "$_r" "$_ps1_post"
}

function __my_git_ps1_dir ()
{
    # Pluck apart the path components
    #
    # /Users/adi/Working/docker-golang/buster     <- _cwd
    # /Users/adi/Working/docker-golang            <- _repo_top
    # 
    # /Users/adi/Working                          <- _repo_pre  (path prefix)
    #                    docker-golang            <- _repo_name (repo name)
    #                                  buster     <- _repo_post (path suffix)
    local _cwd
    local _repo_top

    # Break down path
    _cwd=$(pwd -P)
    _repo_top="$($_git rev-parse --show-toplevel)"

    _repo_pre="${_repo_top%/*}"
    _repo_name="${_repo_top##*/}"
    _repo_post="${_cwd#$_repo_top}"

    if [ "$_repo_is_workdir" = "true" ]; then
        _w="$_repo_post"
        _n="$_repo_name"
    else
        _w='\w'
    fi
}

function __my_git_ps1_col ()
{
    local _col_red='\[\e[31m\]'
    local _col_green='\[\e[32m\]'
    local _col_blue='\[\e[1;34m\]'
    local _col_yellow='\[\e[33m\]'
    local _col_cyan='\[\e[36m\]'
    local _col_clear='\[\e[0m\]'

    if [ "$_c" = '*' ]; then
        _c="$_col_red$_c"
    fi
    if [ -n "$_s" ]; then
        _s="$_col_green$_s"
    fi
    if [ -n "$_u" ]; then
        _u="$_col_red$_u"
    fi

    if [ "$_repo_is_detached" = "yes" ]; then
        _b="$_col_red$_b"
    else
        _b="$_col_green$_b"
    fi
    _n="$_col_cyan$_n$_col_clear"
    _z="$_col_clear"
}

# End
