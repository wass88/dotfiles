# path {{{
setopt no_global_rcs
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin":$PATH

# anyenv
if [ -d $HOME/.anyenv ] ; then
    export PATH="$HOME/.anyenv/bin:$PATH"
    eval "$(anyenv init -)"
    for D in `ls $HOME/.anyenv/envs`
    do
      export PATH="$HOME/.anyenv/envs/$D/shims:$PATH"
    done
fi

## opam
if [ -d ${HOME}/.opam ] ; then
  eval `opam config env`
fi
export OCAMLPARAM="_,bin-annot=1"
export OPAMKEEPBUILDDIR=1

## rsense
if [ -d ${HOME}/.rsense-0.3  ] ; then
    export RSENSE_HOME=$HOME/.rsense-0.3
fi

## cabal
if [ -d ${HOME}/.cabal  ] ; then
  export PATH=$HOME/.cabal/bin:$PATH
fi

## luajit
export PATH="/usr/local/luajit/bin/:$PATH"

## vim
export PATH="/usr/local/vim/bin/:$PATH"

## texlive
export PATH="/Library/TeX/texbin/:$PATH"

## go
export PATH="$HOME/go/bin:$PATH"

## general
export PATH="$HOME/.bin/:$PATH"

## neovim
export XDG_CONFIG_HOME=$HOME/.config
if type nvim >/dev/null 2>&1; then
  alias vim='nvim'
fi 

## rust
export PATH="$HOME/.cargo/bin:$PATH"

if type -a rustc >/dev/null 2>&1; then
  export RUST_SRC_PATH="$(rustc --print sysroot)/lib/rustlib/src/rust/src"
fi

export PATH="$HOME/bin/flutter/bin:$PATH"
export PATH="$PATH":"$HOME/.pub-cache/bin"

# }}}
# local {{{
if [ -f $HOME/dotfiles/.zshlocal ] ; then
  source $HOME/dotfiles/.zshlocal
fi
#}}}

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/admin/Documents/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/admin/Documents/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/admin/Documents/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/admin/Documents/google-cloud-sdk/completion.zsh.inc'; fi



# Single characters
alias a='git add'
alias ac='git add . && git commit -v'
      alias a.='git add -A'
alias b='bundle'
         alias bi='bundle install --path vendor/bundle'
         alias be='bundle exec'
         c-func(){git commit -m "$*"}
alias c='noglob c-func'
      alias ca='git commit --amend --no-edit'
      cf(){git commit --fixup ${1-HEAD}}
      alias cx='chmod +x'
alias d='docker'
         alias dc='docker-compose'
alias e='docker run --rm -it'
alias f='git fetch'
      fb(){git fetch origin $1:$1}
      fm(){fb $(gdefault)}
alias g='git'
         alias ga='git add'
         alias gap='git add -p'
         alias gan='git add -NA'
         alias gc='git commit -v'
         alias crr="cargo run --relase"
         alias gcm='git commit -m'
         alias gcp='git commit -p -v'
         alias gcpm='git commit -p -m'
         alias gb='git branch'
         alias gb-rename='git branch -m'
         alias gb-delete='git branch -D'
         alias gop='git checkout -p'
         alias gl='git lg'
         alias gd='git d'
         alias gp='git push --force-with-lease'
         alias gds='git diff --staged'
         alias gg='git grep'
         alias gs='git stash'
         alias gdefault="git remote show origin | head -n 5 | sed -n '/HEAD branch/s/.*: //p'"
         gi(){git rebase --autosquash -i --keep-base ${1-$(gdefault)}}
         alias gr='git rebase'
         alias gri='git rebase -i'
         grm(){git rebase $(gdefault)}
alias h='ssh'
alias i='git add -p'
alias j='git checkout master'
alias k='git diff --staged'
alias l='ls'
        alias ll='ls -lA'
        alias la='ls -A'
alias m='make'
alias n='npm'
        alias ni='npm install'
        alias nr='npm run'
alias o='git checkout'
    alias ob='git checkout -b'
    om(){git checkout $(gdefault) -b $@}
    alias o-='git checkout -'
alias p='pgrep -fl'
alias q='tldr'
# alias r=
alias s='less'
if builtin command -v bat > /dev/null; then
	alias s='bat -p'
	export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi
alias t='tmux'
alias u='unar'
alias v='vim'
        alias vi='vim'
# alias w=
alias x='./a.out'
alias y='tee | pbcopy'
         z-func(){git commit --amend -m "$*"}
alias z='noglob z-func'

alias doc='cd ~/Documents'
alias dow='cd ~/Downloads'

alias -- -="cd -"

# Two letters
alias py=python
alias rb=ruby
alias wg=wget
alias cr="cargo run"
alias crr="cargo run --relase"
alias ct="cargo test"

# Remove
alias rm='rm -i'
if builtin command -v trash.sh > /dev/null; then
	alias rm='trash.sh -i'
	export TRASHLIST=~/.trashlist # Where trash list is written
	export TRASHBOX=~/.Trash # Where trash will be moved in
	export MAXTRASHBOXSIZE=1024
	export MAXTRASHSIZE=`echo $MAXTRASHBOXSIZE "*" 0.1|bc -l|cut -d. -f1`
fi


# Fuck
if builtin command -v fuck > /dev/null; then
  eval "$(thefuck --alias f)"
fi

# Travis gem
[ -f /home/vagrant/.travis/travis.sh ] && source /home/vagrant/.travis/travis.sh

# Misc
alias gpp='g++ -std=c++11 -Winit-self -Wfloat-equal -Wno-sign-compare -Wshadow -Wall -Wextra -D_GLIBCXX_DEBUG'
alias tmux='tmux -2'
alias time='/usr/bin/time'
function take () { mkdir -p "$@" && eval cd "\"\$$#\"";}

autoload -Uz zmv
alias mmv='noglob zmv -W'

alias youdl="~/cw/python/youtube-dl/youtube_dl/__main__.py"
function addnicolist() {
    /bin/ruby ~/cw/ruby/getmylistids.rb $1 | tee -a ~/cw/db/Temp/nicofab.txt
}

function sendstatus() {

  time --output=~/.output_time $@ 2>&1 | tee >(tail -n 20 > ~/.last_output)
  if [[ $pipestatus[1] == 0 ]]
  then
    (echo "OK: $*"; cat ~/.output_time;
    echo "---"; cat ~/.last_output) | tee >(mail)
    true
  else
    (echo "Fail: $*"; cat ~/.output_time;
    echo "---"; cat  ~/.last_output) | tee >(mail)
    false
  fi
}

export LESS='-j10 --no-init --quit-if-one-screen -i -M -R -W -z-4 -x4'

alias po='popd'
alias cp='cp -i'
alias mv='mv -i'
alias df='df -h'
alias du='du -h'
alias grep='grep --color'                     # show differences in colour
alias dir='ls --color=auto --format=vertical'
alias vdir='ls --color=auto --format=long'
case "${OSTYPE}" in
  darwin*)
    alias ls="ls -G"
    ;;
  linux*)
    alias ls='ls --color'
    ;;
esac
alias tree='tree -CF'
alias htree='tree -hDF'
alias filelist='/usr/bin/tree --charset unicode -nF'


alias lns='ln -s'


alias mail='sed -e '"'"'1!b;s/^/To: wasss80@gmail.com\nSubject: FromOhtan\n\n/'"'"'| sendmail -t'

alias rl='rlwrap -pYellow -ic'

alias dt='date +%Y%m%dT%H%M%S'

if builtin command -v exa > /dev/null; then
  alias l='exa -lahF'
  alias ls='exa'
  alias la='exa -a'
fi


### global alias
alias -g H='date %T%H%M%S'
alias -g G='| grep'
alias -g L='| less -N'
alias -g H='| head'
alias -g T='| tail'
alias -g S='| sort'
alias -g W='| wc'
alias -g X='| xargs'
alias -g B='| ruby -e'
alias -g U='--help 2>&1 | less'
alias -g V='| vim -R -'

alias -g ND='*(/om[1])' # newest directory
alias -g NF='*(.om[1])' # newest file

alias dstat-full='dstat -Tclmdrn'
alias dstat-mem='dstat -Tclm'
alias dstat-cpu='dstat -Tclr'
alias dstat-net='dstat -Tclnd'
alias dstat-disk='dstat -Tcldr'

alias C='> >(while read line; do echo -e "\e[01;32m$line\e[0m"; done) 2> >(while read line; do echo -e "\e[01;31m$line\e[0m" >&2; done)'

function watch() {
  cmd=$1
  files=${@[@]:1}
  zsh <<SHELL
    set -v
    while true; do
      echo - - - - - - - - - - - - - - - - - - - - - - - - - -
      sh -c "{ $cmd ;} ; echo ; echo Exited; while true; do sleep 60; done; echo Unfortunatelly END" &
      pid=$!
      echo PID $pid
      prog=$(cat <<PROG
      echo !!!
      kill $pid
PROG
)
      echo PROG ": $prog :"
      trap "$prog" HUP
      jobs
      fg
    done
SHELL
  pid=$!
  fswatch -o $files | xargs -n1 -I % sh -c "kill -HUP $pid"
}

# colored man
man() {
  env \
    LESS_TERMCAP_mb=$(printf "\e[1;33m") \
    LESS_TERMCAP_md=$(printf "\e[1;33m") \
    LESS_TERMCAP_me=$(printf "\e[0m") \
    LESS_TERMCAP_se=$(printf "\e[0m") \
    LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
    LESS_TERMCAP_ue=$(printf "\e[0m") \
    LESS_TERMCAP_us=$(printf "\e[1;32m") \
    man "$@"
}

# history option
HISTSIZE=1000000
SAVEHIST=1000000
HISTFILE=~/.zsh_history # 保存先

eval $(/opt/homebrew/bin/brew shellenv)
