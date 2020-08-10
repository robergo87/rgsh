#!/bin/bash

DIR="$(dirname $(readlink -f $0))"
curdir="$(pwd)"

cont="Yes"

if [ "$1" = "feed" ]; then
	ls --color=yes -a "$2" | tail -n +2
	exit
fi

if [ "$1" = "fzf" ]; then
	PDIR=`dirname $2`
	$DIR/fzf/bin/fzf --ansi --no-info --layout=reverse --header "$2" \
		--bind "enter:execute(echo 'edit')+accept,del:execute(echo 'rm')+accept,space:execute(echo 'menu')+accept"
	if [ $? -gt 1 ]; then
		exit 2
	else
		exit 0
	fi
fi

while [ $cont = "Yes" ];
do
	file_select=`$DIR/menu.sh feed "$curdir" | $DIR/menu.sh fzf "$curdir"`
	if [ $? -gt 1 ]; then
		cont="No"
    fi
	IFS=$'\n'
	answer=($file_select)
	action=${answer[0]}
	file_select=${answer[1]}

	if [ "$action" = "menu" ]; then
		echo "$curdir/$file_select"
		action=`printf "mv\nchmod\ntouch\nmkdir\nrm" | $DIR/fzf/bin/fzf --reverse`
		$DIR/fm.sh "$action" "$curdir/$file_select"
	elif [ "$action" = "rm" ]; then
		$DIR/fm.sh rm "$file_select"
	elif [ ! -z "$file_select" ]; then
		full_path="$curdir/$file_select"
    	full_path=`readlink -m "$full_path"`
    	if [ -d "$full_path" ]; then
			curdir="$full_path"
		else
			#tmux send-keys -t "$1" C-r "$full_path" Enter
			tmux send-keys -t "$1" C-e "tab $full_path" Enter \; select-pane -t "$1"
			#tmux send-keys -t "$1" Escape ":tab drop " "$full_path" Enter \; select-pane -t "$1"
    	fi
	fi
done
