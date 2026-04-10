# ----------------------------
# Powerlevel10k instant prompt (MUST stay first)
# ----------------------------
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-$USER.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-$USER.zsh"
fi


# ----------------------------
# Environment
# ----------------------------
export GBM_BACKEND=nvidia-drm
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export LANG=en_GB.UTF-8
export ZSHDIR=/usr/local/share/zsh_conf
export ZSH=$ZSHDIR/ohmyzsh
export HISTFILE=~/.cache/.histfile
export HISTSIZE=1000
export SAVEHIST=2000
export EDITOR='vim'
export PAGER='bat'
source /home/son/.config/restic/resticenv

setopt hist_expire_dups_first hist_ignore_dups hist_ignore_space hist_verify
HIST_STAMPS="yyyy-mm-dd"


# ----------------------------
# Key bindings
# ----------------------------
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


# ----------------------------
# Plugins (NO GRC HERE)
# ----------------------------
plugins=(git zoxide)
eval "$(zoxide init zsh)"

source $ZSH/oh-my-zsh.sh
source $ZSHDIR/zsh-autosuggestions/zsh-autosuggestions.zsh
source $ZSHDIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source <(fzf --zsh)

# ----------------------------
# Shell behaviour
# ----------------------------
WORDCHARS=${WORDCHARS/\/}
PROMPT_EOL_MARK=""
COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
typeset -g ZSH_DISABLE_COMPFIX=true


# ----------------------------
# Aliases (ALL aliases together)
# ----------------------------
#alias ls='ls -lah --color=auto'
alias ls='eza -la'
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
alias jcat='journalctl --output=cat'
alias ssrestart='sudo systemctl restart'
alias ssstart='sudo systemctl start'
alias ssstop='sudo systemctl stop'
alias ssenable='sudo systemctl enable'
alias ssdisable='sudo systemctl disable'
alias ssstat='sudo systemctl status'
alias ssreload='sudo systemctl reload'
alias sslj='systemctl list-jobs'
alias sslsr='systemctl list-units --type=service --state=running'
alias inv='vim $(fzf -m --preview="bat --color=always {}")'

# Dynamic cat alias based on distro
if [[ -f /etc/debian_version ]]; then
    alias cat='batcat'
elif [[ -f /etc/arch-release ]]; then
    alias cat='bat'
fi


# ----------------------------
# Functions
# ----------------------------
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
    curl -H "Authorization: Bearer tk_ukmfwmse2ui8tiezn0xh46q55tgxu" -d "$*" http://10.4.0.2:47346/home
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

yt-dlpLoop() {
    while true;
    do
        printf "Enter URL or Q to quit\n";
        read input; [ "$input" = Q ] && break;
         yt-dlp "$input";
     done
}

resticreport() {
    # Color codes
    GREEN='\033[0;32m'
    CYAN='\033[0;36m'
    NC='\033[0m' # No Color
    # Print overall repository stats
    echo -e "\n${GREEN}=== Repository Stats ===${NC}"
    restic stats --mode raw-data
    echo
    # Get all snapshots
    SNAPSHOTS=$(restic snapshots --json)
    # Loop through each snapshot
    echo "$SNAPSHOTS" | jq -c '.[]' | while read -r SNAP; do
        ID=$(echo "$SNAP" | jq -r '.short_id')
        TAGS=$(echo "$SNAP" | jq -r '.tags | join(", ")')
        TIME=$(echo "$SNAP" | jq -r '.time')
        echo -e "${GREEN}=== ${TAGS} Snapshot ${ID} (${TIME}) ===${NC}"
        # Per-snapshot stats
        restic stats "$ID" --mode raw-data
        echo
    done
}

# ----------------------------
# GRC (AFTER aliases + functions)
# ----------------------------
if [[ -f /usr/share/grc/grc.zsh ]]; then
    source /usr/share/grc/grc.zsh
fi

# Optional: wrap modern replacements
#alias eza='grc eza'
#alias batcat='grc batcat'

# ----------------------------
# Powerlevel10k theme (ALWAYS LAST)
# ----------------------------
[[ -f /usr/local/share/zsh_conf/powerlevel10k/powerlevel10k.zsh-theme ]] && \
source /usr/local/share/zsh_conf/powerlevel10k/powerlevel10k.zsh-theme

[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
