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
		tmux send-keys -t "$4" C-e "tab $filepath" Enter
	fi
	exit 0
fi 

if [ "$1" = "home" ]; then
	filepath=`echo "$2" | cut -d ";" -f 1`
	filename=`echo "$2" | cut -d ";" -f 2`
	if [ -d "$filepath" ]; then
		tmux send-keys -t "$4" C-e "cd $filepath" Enter 
		$DIR/filetree.py init "$3" $filepath
	fi
	exit 0
fi

if [ "$1" = "display" ]; then
	$DIR/filetree.py init "$pid" "$(pwd)"
	$DIR/filetree.py "print" "$pid" | $DIR/fzf/bin/fzf --layout reverse-list --delimiter ";" --with-nth -1 --ansi \
		--bind "home:execute-silent($DIR/treemenu.sh home {} $pid $2)+reload($DIR/filetree.py 'print' $pid),left-click:execute-silent($DIR/treemenu.sh select {} $pid $2)+reload($DIR/filetree.py 'print' $pid),double-click:execute-silent($DIR/treemenu.sh select {} $pid $2)+reload($DIR/filetree.py 'print' $pid),enter:execute-silent($DIR/treemenu.sh select {} $pid $2)+reload($DIR/filetree.py 'print' $pid),space:execute($DIR/fm.sh menu {} < /dev/tty)+reload($DIR/filetree.py 'print' $pid)"
	$DIR/filetree.py destroy "$pid"
	exit 0
fi
