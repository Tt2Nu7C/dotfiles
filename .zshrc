# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path configuration
export PATH=$HOME/bin:/usr/local/bin:$HOME/.surrealdb:$HOME/Documents/IDEs:$PATH
export GBM_BACKEND=nvidia-drm
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export LANG=en_GB.UTF-8

# ZSH configuration
export ZSHDIR=/usr/local/share/zsh_conf
export ZSH=$ZSHDIR/ohmyzsh
export HISTFILE=~/.cache/.histfile
export HISTSIZE=1000
export SAVEHIST=2000
export EDITOR='vim'

setopt hist_expire_dups_first hist_ignore_dups hist_ignore_space hist_verify
HIST_STAMPS="yyyy-mm-dd"

# Key bindings
bindkey -e
bindkey ' ' magic-space
bindkey '^[[3;5~' kill-word
bindkey '^[[3~' delete-char
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[[5~' beginning-of-buffer-or-history
bindkey '^[[6~' end-of-buffer-or-history
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[Z' undo

# Oh My Zsh theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Plugins
plugins=(git)
#ENABLE_CORRECTION="true"

# Other settings
WORDCHARS=${WORDCHARS/\/}
PROMPT_EOL_MARK=""
COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"

# Functions
paste_rs_post() {
    local file=${1:-/dev/stdin}
    curl --data-binary @${file} https://paste.rs
}

function build_server_release() {
        dirname=$PWD
        #shopt -s extglob           # enable +(...) glob syntax
        result=${dirname%%+(/)}    # trim however many trailing slashes exist
        result=${result##*/}       # remove everything before the last / that still remains
        result=${result:-/}        # correct for dirname=/ case
        cargo update
        cargo b --package $result --bin $result --release --target x86_64-unknown-linux-musl

}

unzip_d() {
    for i in "$@"; do
        unzip -d "${i%.zip}" "$i"
    done
}

ntfy_post() {
    curl -H "Authorization: Bearer tk_rxrmfp4j3u3928vw9lmorbw6bjrml" -d "$*" http://91.98.71.85:47346/home
}

wgreload() {
    wg-quick down $1
    echo -e "Bringing back up $1"
    wg-quick up $1
}

lbr_ffmpeg() {
    mkdir -p LBR || return 1
    for file in "$@"; do
        [ -f "$file" ] || continue
        base=$(basename "$file" | sed 's/\.[^.]*$//')  # Remove the last extension
        ffmpeg -i "$file" -c:v libx264 -b:v 2200k -pass 1 -f null /dev/null &&
        ffmpeg -i "$file" -c:v libx264 -b:v 2200k -pass 2 -c:a eac3 -b:a 320k -c:s copy -f matroska "LBR/${base}_LBR.mkv" &&
        rm -f ffmpeg2pass-0.log*
    done
}

typeset -g ZSH_DISABLE_COMPFIX=true

# Sources
source $ZSHDIR/zsh-autosuggestions/zsh-autosuggestions.zsh
source $ZSH/oh-my-zsh.sh
source $ZSHDIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
eval "$(zoxide init zsh)"
source /usr/local/share/zsh_conf/powerlevel10k/powerlevel10k.zsh-theme

# Aliases
alias ls='ls -lah --color=auto'
alias ps='ps aux'
alias reboot='shutdown -r now'
alias htop='htop -d 8'
alias tt='tmux attach-session -t $1'
alias ttn='tmux new-session -s $1'
alias ttl='tmux list-session'
alias htp='htop -p $1'
alias wgup='sudo wg-quick up $1'
alias wgdown='sudo wg-quick down $1'
alias history='history 0'
alias cd='z'
alias duf='duf --only local,network,fuse'

# Dynamic cat alias based on distro
if [[ -f /etc/debian_version ]]; then
    alias cat='batcat'
elif [[ -f /etc/arch-release ]]; then
    alias cat='bat'
fi

