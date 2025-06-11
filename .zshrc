# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# exports
export ZSHDIR=/usr/local/share/zsh_conf
export ZSH=$ZSHDIR/ohmyzsh

export PATH=$PATH:$HOME/Documents/IDEs/
export PATH=$HOME/.surrealdb:$PATH
export GBM_BACKEND=nvidia-drm
export __GLX_VENDOR_LIBRARY_NAME=nvidia

# export MANPATH="/usr/local/man:$MANPATH"

# configure key keybindings
bindkey -e                                        # emacs key bindings
bindkey ' ' magic-space                           # do history expansion on space
bindkey '^[[3;5~' kill-word                       # ctrl + Supr
bindkey '^[[3~' delete-char                       # delete
bindkey '^[[1;5C' forward-word                    # ctrl + ->
bindkey '^[[1;5D' backward-word                   # ctrl + <-
bindkey '^[[5~' beginning-of-buffer-or-history    # page up
bindkey '^[[6~' end-of-buffer-or-history          # page down
bindkey '^[[H' beginning-of-line                  # home
bindkey '^[[F' end-of-line                        # end
bindkey '^[[Z' undo                               # shift + tab undo last action

# prompt
NEWLINE=$'\n'
NEWLINE=$'\n'
if [[ $USER == "root" ]]; then
    COLOR=197  # Hot/red for root
elif [[ $USER == "son" ]]; then
    COLOR=87   # Cyan for son
else
    COLOR=040  # Green for others
fi
PS1="%F{$COLOR}┌──[%n%f@%F{$COLOR}%M:%f%d%F{$COLOR}]${NEWLINE}└─% $%f "

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/

#ENABLE_CORRECTION="true"
plugins=(git)

# User configuration

# You may need to manually set your language environment
export LANG=en_GB.UTF-8

WORDCHARS=${WORDCHARS/\/} # Don't consider certain characters part of the word
PROMPT_EOL_MARK="" # hide EOL sign ('%')

# aliases
alias ls='ls -lah --color=auto'
alias ps='ps aux'
alias reboot="shutdown -r now"
alias htop='htop -d 8'
alias cd='z'
alias paclean='sudo pacman -Rns $(pacman -Qtdq)'
alias cat='bat'
alias tt='tmux attach-session -t $1'
alias ttn='tmux new-session -s $1'
alias ttl='tmux list-session'
alias htp='htop -p $1'
alias wgup='sudo wg-quick up $1'
alias wgdown='sudo wg-quick down $1'

# history
HISTFILE=~/.cache/.histfile
HISTSIZE=1000
SAVEHIST=2000
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
alias history="history 0" # force zsh to show the complete history

# sources
source $ZSHDIR/zsh-autosuggestions/zsh-autosuggestions.zsh
#source $ZSH/oh-my-zsh.sh
source $ZSHDIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh # THIS MUST BE THE LAST SOURCE IN THE FILE
eval "$(zoxide init zsh)"


# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="dd/mm/yyyy"

function paste_rs_post() {
        local file=${1:-/dev/stdin}
        curl --data-binary @${file} https://paste.rs
}

function build_server_release() {
        dirname=$PWD
        #shopt -s extglob           # enable +(...) glob syntax
        result=${dirname%%+(/)}    # trim however many trailing slashes exist
        result=${result##*/}       # remove everything before the last / that still remains
        result=${result:-/}        # correct for dirname=/ case
        docker run -v cargo-cache:/root/.cargo/registry -v "$PWD:/volume" --rm -it clux/muslrust:stable cargo update
        docker run -v cargo-cache:/root/.cargo/registry -v "$PWD:/volume" --rm -it clux/muslrust:stable cargo b --package $result --bin $result --release
}

unzip_d () {
    for i in "$@";
    do
            #echo "${i%.zip}"
            unzip -d "${i%.zip}" "$i";
    done
}

ntfy_post() {
        curl -H "Authorization: Bearer tk_rxrmfp4j3u3928vw9lmorbw6bjrml" -d "$*" http://192.168.0.9:47346/home
}

function wgreload () {
    wg-quick down $1
    wg-quick up $1
}
