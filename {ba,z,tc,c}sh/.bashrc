# Set path to binaries
export PATH="$HOME/bin:$PATH:$HOME/.local/bin"
export PATH="$HOME/.pyenv/bin:$PATH"

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Source file if it exists
load_file() {
    [ -f "$1" ] && . "$1"
}

# asdf
load_file $HOME/.asdf/asdf.sh
load_file $HOME/.asdf/completions/asdf.bash

# Load extra .bashrc
load_file "$HOME/.bashrc_extra"

if command -v go > /dev/null ; then
    export GOPATH=$(go env GOPATH)
    export PATH=$PATH:$GOPATH/bin
fi

# Set editor
export VISUAL=vim

# Save lots of history
export HISTSIZE=999999
export HISTCONTROL=ignoredups:ignorespace
# export HISTTIMEFORMAT="$(echo -e\ '\r\e[K\')"

##### Set PS1
# load_file "$HOME/.bashrc_ps1"

# Set pager command
if command -v vimpager > /dev/null ; then
    export PAGER=vimpager
elif command -v most > /dev/null ; then
    export PAGER=most
else
    export PAGER=less
fi
export MANPAGER="$PAGER"
export SYSTEMD_PAGER="$PAGER"

export PYTHONSTARTUP="$HOME/.ipython/profile_default/startup/10-imports.py"

# Load aliases
load_file "$HOME/.tryalias.sh"
load_file "$HOME/.aliases"

##### Set commands in interactive mode
if [[ $- == *i* ]]; then
    # Keep aliases when running sudo
    alias sudo='sudo '

    # pyenv
    if command -v pyenv > /dev/null ; then
        eval "$(pyenv init -)"
        # eval "$(pyenv virtualenv-init -)"
    fi

    # Use , as an improved cd command
    load_file "$HOME/.commacd.bash"

    # Sensible defaults
    load_file "$HOME/.sensible.bash"

    tty -s

    ##### Set PS1
    if command -v starship > /dev/null; then
      eval "$(starship init bash)"
    fi

    export BASHRC_INTERACTIVE_LOADED=true
fi

export BASHRC_LOADED=true
