# This file is read by bash

# if running bash
if [ -n "$BASH_VERSION" ]; then

    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi

    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc_add" ]; then
	. "$HOME/.bashrc_add"
    fi

fi

