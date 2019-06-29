# ailas
alias rm='rm -i'
if builtin command -v trash.sh > /dev/null; then
	alias rm='trash.sh -i'
	export TRASHLIST=~/.trashlist # Where trash list is written
	export TRASHBOX=~/.Trash # Where trash will be moved in
	export MAXTRASHBOXSIZE=1024
	export MAXTRASHSIZE=`echo $MAXTRASHBOXSIZE "*" 0.1|bc -l|cut -d. -f1`
fi


if builtin command -v hub > /dev/null; then
  function git(){hub "$@"}
fi
#sudo pip install thefuck
if builtin command -v fuck > /dev/null; then
  eval "$(thefuck --alias f)"
fi

# added by travis gem
[ -f /home/vagrant/.travis/travis.sh ] && source /home/vagrant/.travis/travis.sh

alias gpp='g++ -std=c++11 -Winit-self -Wfloat-equal -Wno-sign-compare -Wshadow -Wall -Wextra -D_GLIBCXX_DEBUG'
alias tmux='tmux -2'
alias t='tmux -2'
alias time='/usr/bin/time'
function take () { mkdir -p "$@" && eval cd "\"\$$#\"";}
autoload -Uz zmv

alias mmv='noglob zmv -W'

alias b='bundle'
alias bi='bundle install --path vendor/bundle'
alias be='bundle exec'

alias n='npm'
alias ni='npm install'
alias nr='npm run'


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
alias ls-full='ls -ld $(pwd)/*'
alias vdir='ls --color=auto --format=long'
case "${OSTYPE}" in
  darwin*)
    alias ls="ls -G"
    ;;
  linux*)
    alias ls='ls --color'
    ;;
esac
alias ll='ls -lA'                              # long list
alias la='ls -A'                              # all but . and ..
alias l='ls -CF'                              #
alias tree='tree -CF'
alias htree='tree -hDF'
alias filelist='/usr/bin/tree --charset unicode -nF'

alias vi='vim'
alias v='vim'

alias s='less'

alias lns='ln -s'

alias g='git'
alias ga='git add'
alias a='git add'
alias gap='git add -p'
alias gc='git commit -v'
alias gcm='git commit -m'
c-func(){git commit -m "$*"}
alias c='noglob c-func'
alias gcp='git commit -p -v'
alias gcpm='git commit -p -m'
alias gb='git checkout -b'
alias o='git checkout'
alias f='git fetch'
alias gl='git lg'
alias gd='git d'
alias gds='git ds'
alias gg='git grep'
alias gs='git stash'

alias j='cd `git rev-parse --show-toplevel`'
alias ac='git add . && git commit '

alias rb="ruby"
alias be="bundle exec"

alias mail='sed -e '"'"'1!b;s/^/To: wasss80@gmail.com\nSubject: FromOhtan\n\n/'"'"'| sendmail -t'

alias rl='rlwrap -pYellow -ic'

alias d='date +%Y%m%d'
alias dt='date +%Y%m%dT%H%M%S'

alias m='make'
alias mb='make -B'

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

# path {{{
setopt no_global_rcs
OLD_PATH=$PATH
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

if builtin command -v direnv > /dev/null; then
  eval "$(direnv hook zsh)"
fi

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

# go
export GOPATH=$HOME/.go
export PATH="$GOPATH/bin/:$PATH"

## general
export PATH="$HOME/.bin/:$PATH"
export PATH="$HOME/bin/:$PATH"

## neovim
export XDG_CONFIG_HOME=$HOME/.config

## rust
if [ -f $HOME/.cargo/bin ] ; then
  export PATH="$HOME/.cargo/bin:$PATH"
fi
if type -a rustc >/dev/null 2>&1; then
  export RUST_SRC_PATH="$(rustc --print sysroot)/lib/rustlib/src/rust/src"
fi

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
