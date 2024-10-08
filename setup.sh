#!/usr/bin/env bash
set -x
SRC=.
DST=~

function link () {
    if [ -f "$1" ]; then
        if ! [ -f "$2" ]; then
            ln -s $1 $2
        else
            echo $2 already exists
        fi
    else
        echo $1 does not exist
    fi
}

echo ------- making ~/bin -------
mkdir $DST/bin

echo ------- making ~/tmp -------
mkdir $DST/tmp

echo ------- making ~/src -------
mkdir $DST/src

echo ------- mkshrc is bashrc -------
link $DST/.bashrc $DST/.mkshrc

echo ------- linking .vimrc to .config/nvim. creating vim backup dirs -------
mkdir -p $DST/.config/nvim
mkdir -p $DST/{.vim,.config/nvim,tmp}/{backup,swap,undo}

echo ------- downloading plug.vim -------
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

echo ------- downloading minecraft-server -------
git clone https://github.com/Fellowship-The/minecraft-server $HOME/src/minecraft-server

echo ------- downloading kitty-themes -------
git clone --depth 1 git@github.com:dexpota/kitty-themes.git ~/.config/kitty/kitty-themes

echo ------- downloading and installing external confs -------
git submodule update --init --recursive

EXT_DIR=$SRC/external
set -x
cp "$EXT_DIR/commacd/commacd.sh" "$DST/.commacd.sh"
cp "$EXT_DIR/gp/gp" "$DST/bin/"
cp "$EXT_DIR/makeanywhere/makeanywhere" "$DST/bin/"
