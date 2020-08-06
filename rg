#!/bin/bash

DIR="$(dirname $(readlink -f $0))"

if [ "$1" = "echo" ]; then
	shift
	echo "echo"
	echo $@
fi

if [ "$1" = "bind" ]; then
	echo '#!/bin/bash' > ~/.local/bin/rg
	echo "$DIR/rg \"\$@\"" >> ~/.local/bin/rg
	chmod 755 ~/.local/bin/rg
fi

if [ "$1" = "install" ]; then
	echo '#!/bin/bash' > ~/.local/bin/rg
	echo "$DIR/rg \"\$@\"" >> ~/.local/bin/rg
	chmod 755 ~/.local/bin/rg
	sudo apt install tmux git
	git clone --depth 1 https://github.com/junegunn/fzf.git "$DIR/fzf"
	$DIR/fzf/install --no-key-bindings --no-update-rc --no-completion --no-bash
fi

if [ "$1" = "fzf" ]; then
	shift
	$DIR/fzf/bin/fzf "$@"
fi

if [ "$1" = "fzf-tmux" ]; then
	shift
	$DIR/fzf/bin/fzf-tmux "$@"
fi

if [ "$1" = "tmux" ]; then
	shift
	tmux -f "$DIR/tmux.conf" "$@"
fi

if [ "$1" = "gitadd" ]; then
	toadd=`git status -s | $DIR/fzf/bin/fzf -m | cut -d' ' -f2-`
	for file in $toadd
	do
		echo "git add $file"
		git add "$file"
	done
fi

if [ "$1" = "gitclear" ]; then
	git reset HEAD -- .
fi

if [ "$1" = "filemenu" ]; then
	shift
	$DIR/menu.sh "$@"
fi

if [ "$1" = "fm" ]; then
	shift 
	$DIR/fm.sh "$@"
fi

if [ "$1" = "vim" ]; then
	shift
	vim -S "$DIR/vim.so" "$@"
fi

if [ "$1" = "editor" ]; then
	tmux split -h
	tmux resize-pane -t 1 -x 80
	tmux select-pane -t 0
	tmux split -v
	tmux resize-pane -t 1 -y 8
	tmux select-pane -t 0
	tmux split -h
	tmux resize-pane -t 0 -x 30
	tmux select-pane -t 3
	tmux split -v
	tmux send-keys -t 0 "rg filemenu 1" Enter
	tmux send-keys -t 1 "rg vim" Enter
	tmux send-keys -t 2 "pwd" Enter
	tmux send-keys -t 4 "top" Enter
	tmux select-pane -t 1
fi

if [ "$1" = "history" ]; then
	line=`cat ~/.bash_history | rg fzf --layout reverse-list --exact`
	echo "$line"
	echo "$($line)"
fi
	
