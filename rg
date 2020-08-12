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
	cd "$DIR"
	echo '#!/bin/bash' > ~/.local/bin/rg
	echo "$DIR/rg \"\$@\"" >> ~/.local/bin/rg
	chmod 755 ~/.local/bin/rg
	curl https://getmic.ro | bash
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
	toadd=`git status -s | $DIR/fzf/bin/fzf -m`
	IFS=$'\n'
	for file in $toadd
	do
		pathonly=`echo "$file" | cut -c 4-`
		echo "git add $pathonly"
		git add "$pathonly"
	done
fi

if [ "$1" = "gitclear" ]; then
	git reset HEAD -- .
fi

if [ "$1" = "filemenu" ]; then
	shift
	$DIR/menu.sh "$@"
fi

if [ "$1" = "treemenu" ]; then
	shift 2
	$DIR/treemenu.sh display "$@"
	exit 0
fi


if [ "$1" = "vim" ]; then
	shift
	vim -S "$DIR/vim.so" "$@"
fi

if [ "$1" = "micro" ]; then
	shift
	export TERM=xterm-256color
	$DIR/micro --config-dir "$DIR/.micro" "$@"
fi

if [ "$1" = "nano" ]; then
	shift
	nano --tabsize=4 -i -S -l -m -T 4 -F "$@"
fi

if [ "$1" = "editor" ]; then
	tmux split -h \; \
		resize-pane -t 1 -x 80 \; \
		select-pane -t 0 \; split -v \; \
		resize-pane -t 1 -y 8 \; \
		select-pane -t 0 \; \
		split -h \; \
		resize-pane -t 0 -x 30 \; \
		select-pane -t 3 \; \
		split -t 3 -v \; \
		send-keys -t 0 "rg treemenu display 1" Enter \; \
		send-keys -t 1 "rg micro" Enter \; \
		send-keys -t 2 "pwd" Enter \; \
		send-keys -t 4 "top" Enter \; \
		select-pane -t 1
fi

if [ "$1" = "history" ]; then
	line=`cat ~/.bash_history | rg fzf --layout reverse-list --exact`
	echo "$line"
	echo "$($line)"
fi

if [ "$1" = "filegoto" ]; then
	filepath=`echo "$3" | cut -d ":" -f 1`
	fileline=`echo "$3" | cut -d ":" -f 2`
	echo "filepath [$filepath] [$fileline]"
	tmux send-keys -t "$2" C-e "tab $filepath" Enter C-e "goto $fileline" Enter \; select-pane -t "$2"
fi

if [ "$1" = "search" ]; then	
	grep --color=always -rn . -e "$3" | rg fzf --ansi --layout=reverse-list \
		--bind="enter:execute($DIR/rg filegoto $2 {})"
fi
