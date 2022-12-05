# precompile# {{{
if [ ! -f ~/.zshrc.zwc -o ~/.zshrc -nt ~/.zshrc.zwc ]; then
  zcompile ~/.zshrc
fi
#}}}
# prompt# {{{
autoload -Uz colors; colors
autoload -Uz vcs_info
autoload -Uz add-zsh-hook
autoload -Uz is-at-least

# 以下の3つのメッセージをエクスポートする
#   $vcs_info_msg_0_ : 通常メッセージ用 (緑)
#   $vcs_info_msg_1_ : 警告メッセージ用 (黄色)
#   $vcs_info_msg_2_ : エラーメッセージ用 (赤)
zstyle ':vcs_info:*' max-exports 3

zstyle ':vcs_info:*' enable git svn hg bzr
# 標準のフォーマット(git 以外で使用)
# misc(%m) は通常は空文字列に置き換えられる
zstyle ':vcs_info:*' formats '(%s)-[%b]'
zstyle ':vcs_info:*' actionformats '(%s)-[%b]' '%m' '<!%a>'
zstyle ':vcs_info:(svn|bzr):*' branchformat '%b:r%r'
zstyle ':vcs_info:bzr:*' use-simple true


if is-at-least 4.3.10; then
    # git 用のフォーマット
    # git のときはステージしているかどうかを表示
    zstyle ':vcs_info:git:*' formats '[%b]' '%c%u %m'
    zstyle ':vcs_info:git:*' actionformats '[%b]' '%c%u %m' '<!%a>'
    zstyle ':vcs_info:git:*' check-for-changes true
    zstyle ':vcs_info:git:*' stagedstr "+"    # %c で表示する文字列
    zstyle ':vcs_info:git:*' unstagedstr "-"  # %u で表示する文字列
fi

# hooks 設定
if is-at-least 4.3.11; then
    # git のときはフック関数を設定する

    # formats '(%s)-[%b]' '%c%u %m' , actionformats '(%s)-[%b]' '%c%u %m' '<!%a>'
    # のメッセージを設定する直前のフック関数
    # 今回の設定の場合はformat の時は2つ, actionformats の時は3つメッセージがあるので
    # 各関数が最大3回呼び出される。
    zstyle ':vcs_info:git+set-message:*' hooks \
        git-hook-begin \
        git-untracked \
        git-push-status \
        git-nomerge-branch \
        git-stash-count

    # フックの最初の関数
    # git の作業コピーのあるディレクトリのみフック関数を呼び出すようにする
    # (.git ディレクトリ内にいるときは呼び出さない)
    # .git ディレクトリ内では git status --porcelain などがエラーになるため
    function +vi-git-hook-begin() {
        if [[ $(command git rev-parse --is-inside-work-tree 2> /dev/null) != 'true' ]]; then
            # 0以外を返すとそれ以降のフック関数は呼び出されない
            return 1
        fi

        return 0
    }

    # untracked フィアル表示
    #
    # untracked ファイル(バージョン管理されていないファイル)がある場合は
    # unstaged (%u) に ? を表示
    function +vi-git-untracked() {
        # zstyle formats, actionformats の2番目のメッセージのみ対象にする
        if [[ "$1" != "1" ]]; then
            return 0
        fi

        if command git status --porcelain 2> /dev/null \
            | awk '{print $1}' \
            | command grep -F '??' > /dev/null 2>&1 ; then

        # unstaged (%u) に追加
        hook_com[unstaged]+='?'
        fi
    }

    # push していないコミットの件数表示
    #
    # リモートリポジトリに push していないコミットの件数を
    # pN という形式で misc (%m) に表示する
    function +vi-git-push-status() {
    # zstyle formats, actionformats の2番目のメッセージのみ対象にする
    if [[ "$1" != "1" ]]; then
        return 0
    fi

    if [[ "${hook_com[branch]}" != "master" ]]; then
        # master ブランチでない場合は何もしない
        return 0
    fi

    # push していないコミット数を取得する
    local ahead
    ahead=$(command git rev-list origin/master..master 2>/dev/null \
        | wc -l \
        | tr -d ' ')

    if [[ "$ahead" -gt 0 ]]; then
        # misc (%m) に追加
        hook_com[misc]+="(p${ahead})"
    fi
    }

    # マージしていない件数表示
    #
    # master 以外のブランチにいる場合に、
    # 現在のブランチ上でまだ master にマージしていないコミットの件数を
    # (mN) という形式で misc (%m) に表示
    function +vi-git-nomerge-branch() {
    # zstyle formats, actionformats の2番目のメッセージのみ対象にする
    if [[ "$1" != "1" ]]; then
        return 0
    fi

    if [[ "${hook_com[branch]}" == "master" ]]; then
        # master ブランチの場合は何もしない
        return 0
    fi

    local nomerged
    nomerged=$(command git rev-list master..${hook_com[branch]} 2>/dev/null | wc -l | tr -d ' ')

    if [[ "$nomerged" -gt 0 ]] ; then
        # misc (%m) に追加
        hook_com[misc]+="(m${nomerged})"
    fi
    }

    # stash 件数表示
    #
    # stash している場合は :SN という形式で misc (%m) に表示
    function +vi-git-stash-count() {
    # zstyle formats, actionformats の2番目のメッセージのみ対象にする
    if [[ "$1" != "1" ]]; then
        return 0
    fi

    local stash
    stash=$(command git stash list 2>/dev/null | wc -l | tr -d ' ')
    if [[ "${stash}" -gt 0 ]]; then
        # misc (%m) に追加
        hook_com[misc]+=":S${stash}"
    fi
    }

fi

function _update_vcs_info_msg() {
    local -a messages
    local prompt

    LANG=en_US.UTF-8 vcs_info

    if [[ -z ${vcs_info_msg_0_} ]]; then
        # vcs_info で何も取得していない場合はプロンプトを表示しない
        prompt=""
    else
        # vcs_info で情報を取得した場合
        # $vcs_info_msg_0_ , $vcs_info_msg_1_ , $vcs_info_msg_2_ を
        # それぞれ緑、黄色、赤で表示する
        [[ -n "$vcs_info_msg_0_" ]] && messages+=( "%F{green}${vcs_info_msg_0_}%f" )
        [[ -n "$vcs_info_msg_1_" ]] && messages+=( "%F{yellow}${vcs_info_msg_1_}%f" )
        [[ -n "$vcs_info_msg_2_" ]] && messages+=( "%F{red}${vcs_info_msg_2_}%f" )

        # 間にスペースを入れて連結する
        prompt="${(j: :)messages}"
    fi

    RPROMPT="$prompt"
}
add-zsh-hook precmd _update_vcs_info_msg

setopt prompt_subst
function zle-line-init zle-keymap-select {
PROMPT="
%{${fg[yellow]}%}%h %n@%m:%~%{${reset_color}%}
%(?.%{$fg[green]%}.%{$fg[cyan]%})(%(!.#.)%(?!-__-) !;__;%) )${${KEYMAP/vicmd/|}/(main|viins)/<}%{${reset_color}%} "
zle reset-prompt
}
zle -N zle-line-init
zle -N zle-keymap-select
SPROMPT="%{$fg[cyan]%}%{$suggest%}(-__-)?< %B%r%b %{$fg[cyan]%}でしょうか? [(y)es,(n)o,(a)bort,(e)dit]:${reset_color} "

function command_not_found_handler() {
    echo "$fg[cyan](;-__-)< $0 というコマンドは見当たりませんが${reset_color}"
}

REPORTTIME=3
setopt PRINT_EXIT_VALUE
# }}}
# title bar# {{{
echo -ne "\033]0;${USER}@${HOST%%.*}\007"
# }}}
# packages# {{{
if [ ! -e ~/.zplug ]; then
  curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh| zsh
fi
source ~/.zplug/init.zsh

zplug "zsh-users/zaw"
zplug "zsh-users/zsh-syntax-highlighting"
zplug "zplug/zplug"

if type "terminal-notifier" > /dev/null 2>&1; then
    zplug "marzocchi/zsh-notify"
    export SYS_NOTIFIER=$(which terminal-notifier)
    export NOTIFY_COMMAND_COMPLETE_TIMEOUT=10
    source ~/.zplug/repos/marzocchi/zsh-notify/notify.plugin.zsh
fi

autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs
zstyle ':chpwd:*' recent-dirs-max 5000
zstyle ':chpwd:*' recent-dirs-default yes
zstyle ':completion:*' recent-dirs-insert both
zstyle ':filter-select' case-insensitive yes 

if ! zplug check --verbose; then
  printf "Install? [y/N]: "
  if read -q; then
    echo; zplug install
  fi
fi

zplug load # --verbose
# }}}
# keybind# {{{
bindkey -r '^X'
export KEYTIMEOUT=1
autoload -Uz select-word-style
select-word-style default
zstyle ':zle:*' word-chars " /=;@:{},|"
zstyle ':zle:*' word-style
bindkey "^P" up-line-or-history
bindkey "^N" down-line-or-history
bindkey '^R' history-incremental-pattern-search-backward
bindkey '^S' history-incremental-pattern-search-forward
bindkey "^Xg" list-expand
bindkey "^F" forward-word
bindkey "^B" backward-word
bindkey -s "^Z" "fg\n"
# C-cをC-yで回復
trapint() {
  if zle; then
    zle kill-whole-line
    zle reset-prompt
  fi
}
trap trapint INT
show_buffer_stack() {
  POSTDISPLAY="
  stack: $LBUFFER"
  zle push-line-or-edit
}
zle -N show_buffer_stack
setopt noflowcontrol
bindkey '^Q' show_buffer_stack
function chpwd() {
    ls_abbrev
}
function ls_abbrev() {
    if [[ ! -r $PWD ]]; then
        return
    fi
    local cmd_ls='ls'
    local -a opt_ls
    opt_ls=('-ACF' '--color=always')
    case "${OSTYPE}" in
        freebsd*|darwin*)
            if type gls > /dev/null 2>&1; then
                cmd_ls='gls'
            else
                # -G : Enable colorized output.
                opt_ls=('-ACFG')
            fi
            ;;
    esac

    local ls_result
    ls_result=$(CLICOLOR_FORCE=1 COLUMNS=$COLUMNS command $cmd_ls ${opt_ls[@]} | sed $'/^\e\[[0-9;]*m$/d')

    local ls_lines=$(echo "$ls_result" | wc -l | tr -d ' ')

    if [ $ls_lines -gt 10 ]; then
        echo "$ls_result" | head -n 5
        echo '         ...'
        echo "$ls_result" | tail -n 5
        echo "$(command ls -1 -A | wc -l | tr -d ' ') files exist"
    else
        echo "$ls_result"
    fi
}
function do_enter() {
    if [ -n "$BUFFER" ]; then
        zle accept-line
        return 0
    fi
    echo
    ls_abbrev
    if [ "$(git rev-parse --is-inside-work-tree 2> /dev/null)" = 'true' ]; then
        echo
        echo -e "\e[0;33m--- git status ---\e[0m"
        git status -sb
    fi
    echo
    echo
    zle reset-prompt
    return 0
}
zle -N do_enter
bindkey '^m' do_enter
function separate(){
    echo -n $fg_bold[yellow]
    for i in $(seq 1 $COLUMNS); do
        echo -n '~'
    done
    echo -n $reset_color
}

zstyle ':chpwd:*' recent-dirs-max 500 # cdrの履歴を保存する個数
zstyle ':chpwd:*' recent-dirs-default yes
zstyle ':completion:*' recent-dirs-insert both

zstyle ':filter-select:highlight' selected fg=black,bg=white,standout
zstyle ':filter-select' case-insensitive yes

bindkey '^R' zaw-history
bindkey '^O' zaw-cdr
bindkey -r '^l'

# }}}
# action option# {{{
setopt auto_cd # ディレクトリ名だけでcd
setopt auto_pushd # cdの時にpushd
setopt pushd_ignore_dups # 同じディレクトリをpushしない
setopt share_history # コマンド履歴を共有
setopt hist_ignore_all_dups # 履歴重複削除
setopt hist_reduce_blanks # 空白履歴削除
setopt extended_glob # 拡張ワイルドカード表現
setopt ignore_eof # Ctrl-Dで終了しない
setopt correct # もしかして
setopt list_packed # 補完表示を詰める
setopt auto_param_keys # カッコ補完
setopt auto_param_slash # ディレクトリ名の後ろのスラッシュを補完
setopt numeric_glob_sort # 数値順
setopt nolistbeep # beepを鳴らさない
setopt long_list_jobs # jobsの時にプロセスidも知る
setopt noflowcontrol # 画面更新停止(ctrl-S)させない
setopt interactive_comments # コメントを書けるように
setopt magic_equal_subst # =後ろの補完
setopt noclobber # >! >>! を使おう

### ウィンドウの名前をカレントディレクトリに
#show-current-dir-as-window-name() {
#    tmux set-window-option window-status-format " #I ${PWD:t} " > /dev/null
#}
#
##show-current-dir-as-window-name
#add-zsh-hook chpwd show-current-dir-as-window-name
## }}}

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

PERL5LIB="$HOME/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="$HOME/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"$HOME/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=$HOME/perl5"; export PERL_MM_OPT;

if [ -d ${HOME}/.opam/opam-init/init.zsh ] ; then
  . ${HOME}/.opam/opam-init/init.zsh > /dev/null 2> /dev/null || true
fi

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/admin/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/admin/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/admin/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/admin/Downloads/google-cloud-sdk/completion.zsh.inc'; fi
export PATH="/usr/local/opt/gettext/bin:$PATH"

export WORDCHARS="*?_-.[]~=&;!#$%^(){}<>"

# Created by `userpath` on 2021-09-26 08:58:34
export PATH="$PATH:/Users/admin/.local/bin"

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh" || true

