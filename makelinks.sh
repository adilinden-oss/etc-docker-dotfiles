#!/bin/bash
#
# Set up soft links from files their destination. Files are nested
# per their final destination. Everything top-level is assumed to
# be a dotfile.
#
# Examples:
#
#   git             ~
#   bash_profile    .bash_profile
#   ssh/config      .ssh/config
#
# Requires /bin/bash 
#

# Adjust to other location for debug
DESTROOT="$HOME"

# Exclude these files and directories
# Backslash escape and special chars
# We do exclude dotted files here...
EXCLUDE=".* makelinks.sh"

# Define some vars
FINDOPTS=""

# Get the real path to our dotfile repository
case $0 in
    /*|~*)
        SCRIPT_INDIRECT="`dirname $0`"
        ;;
    *)
        PWD="`pwd`"
        SCRIPT_INDIRECT="`dirname $PWD/$0`"
        ;;
esac
REPOROOT="`(cd \"$SCRIPT_INDIRECT\"; pwd -P)`"

# Build options string for excluded files
for i in $EXCLUDE; do
    FINDOPTS="$FINDOPTS -path $REPOROOT/$i -prune -or"
done

# Travers repo and find our dotfiles
FOUND=$(find "$REPOROOT" $FINDOPTS -type f -name '*' -print)

for REPOFILE in $FOUND; do

    # Path to file from the dot onwards
    DOTPATH=${REPOFILE#$REPOROOT/}

    # Build the full path for dotfile
    DESTFILE="${DESTROOT}/.${DOTPATH}"

    # Build the directory to dotfile
    DESTDIR=$(dirname "$DESTFILE")

    # Create destination directory if it does not exist
    if [ ! -e "$DESTDIR" ]; then
        echo "Creating directory: $DESTDIR"
        mkdir -p "$DESTDIR"
    fi

    # Remove links or files, if we have permission
    if [ -d "$DESTFILE" ]; then
        echo "Dotfile is a dir: $DESTFILE"
        echo "This is a serious issue, abort!"
        exit
    fi

    if [ -L "$DESTFILE" ]; then
        echo "Removing link: $DESTFILE"
        rm "$DESTFILE"
    elif [ -f "$DESTFILE" ]; then
        if [ "$1" = "-f" ]; then
            echo "Removing file: $DESTFILE"
            rm "$DESTFILE"
        else
            echo "Real file found: $DESTFILE"
            echo -e '\033[0;31m'"Run with -f to allow deletion of file"'\033[0m'
            continue
        fi
    fi

    # Create link
    echo "Creating link: $DESTFILE"
    ln -s "$REPOFILE" "$DESTFILE"
            
done

echo "+=================================================================+"
echo "|                                                                 |"
#echo "|  Append this to the .bashrc file to make use of the git prompt  |"
#echo "|                                                                 |"
#echo -e "|      "'\033[0;32m'"if [ -f ~/.bashrc_add ]; then . ~/.bashrc_add; fi"'\033[0m'"          |"
echo "|   Check on .bashrc and .bash_profile depending on the system.   |"
echo "|   Install \`keychain\` using brew or apt to manage passphrases.   |"
echo "|                                                                 |"
echo "+=================================================================+"

# End
