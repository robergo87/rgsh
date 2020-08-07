#!/bin/bash

DIR="$(dirname $(readlink -f $0))"
curdir="$(pwd)"
pid="$$"

if [ "$1" = "select" ]; then
	filepath=`echo "$2" | cut -d ";" -f 1`
	filename=`echo "$2" | cut -d ";" -f 2`
	if [ -d "$filepath" ]; then
		$DIR/filetree.py toggle "$3" $filepath
	else
		tmux send-keys -t "$4" Escape ":tab drop $filepath" Enter
	fi
	exit 0
fi 

if [ "$1" = "display" ]; then
	$DIR/filetree.py init "$pid" "$(pwd)"
	$DIR/filetree.py "print" "$pid" | $DIR/fzf/bin/fzf --layout reverse-list --delimiter ";" --with-nth -1 \
		--bind "enter:execute-silent($DIR/treemenu.sh select {} $pid $2)+reload($DIR/filetree.py 'print' $pid)"
	exit 0
fi
