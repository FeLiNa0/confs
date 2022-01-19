export PATH="$HOME/bin:$PATH:$HOME/.local/bin"
setxkbmap -option terminate:ctrl_alt_bks

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

export PATH="$HOME/.cargo/bin:$PATH"

export PATH="$HOME/.poetry/bin:$PATH"

# Source file if it exists
load_file() {
    [ -f "$1" ] && . "$1"
}

# Load extra .bashrc
load_file "$HOME/.bashrc_extra"
