if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

function git_prompt {
    local GITOUTPUT; GITOUTPUT=$(git rev-parse --show-toplevel --symbolic-full-name --abbrev-ref HEAD 2> /dev/null)
    if [ $? -eq 0 ] # i.e. we are in a git repo
    then
        IFS=$'\n'; DATA=($GITOUTPUT); unset IFS;
        local GITPATH="${DATA[0]}"
        local GITNAME="${GITPATH##*/}"
        local GITBRANCH="${DATA[1]}"
        if [ "$GITBRANCH" == HEAD ]
        then
            local NM=$(git name-rev --name-only HEAD 2> /dev/null)
            if [ "$NM" != undefined ]
            then echo -n "($GITNAME/@$NM):"
            else echo -n "($GITNAME/$(git rev-parse --short HEAD 2> /dev/null)):"
            fi
        else
            echo -n "($GITNAME/$GITBRANCH):"
        fi
    fi
}

# hab-run [plan-dir]
function hab-run {
    local PLAN_DIR=${1:-.}
    local RESULTS_DIR=$PLAN_DIR/results
    local RESULTS_ENV=$RESULTS_DIR/last_build.env
    (export $(cat $RESULTS_ENV | xargs) && sudo -E hab svc unload $pkg_ident)
    hab pkg build $PLAN_DIR
    (export $(cat $RESULTS_ENV | xargs) && sudo -E hab svc start $RESULTS_DIR/$pkg_artifact)
}

# moz-ec2 [env] [asg]
function moz-ec2 {
    local ALL=$(aws ec2 describe-instances)
    local SELECTED=$(jq -r '.Reservations | map(.Instances) | flatten | map(select(any(.State; .Name=="running")))' <<< "$ALL")
    if [ ! -z "$1" ]
    then
        SELECTED=$(jq -r "map(select(any(.Tags//[]|from_entries; .[\"env\"]==\"${1}\")))" <<< "$SELECTED")
    fi
    if [ ! -z "$2" ]
    then
        SELECTED=$(jq -r "map(select(any(.Tags//[]|from_entries; .[\"aws:autoscaling:groupName\"]==\"${1}-${2}\")))" <<< "$SELECTED")
    fi
    OUTPUT=$(jq -r '.[] | [((.Tags//[])[]|select(.Key=="aws:autoscaling:groupName")|.Value) // "null", ((.Tags//[])[]|select(.Key=="Name")|.Value) // "null", .PrivateIpAddress // "null", .PublicIpAddress // "null"] | @tsv' <<< "$SELECTED")
    echo "${OUTPUT}" | sort -k 1,2 | column -t
}

# moz-host env asg
function moz-host {
    moz-ec2 $1 $2 | shuf | head -n 1 | awk '{print $2}'
}

# moz-tunnel env asg local-port remote-port
function moz-tunnel {
    ssh -L "$3:$(moz-host $1 $2)-local.reticulum.io:$4" "$(moz-host $1 bastion).reticulum.io"
}

# moz-proxy cmd env ...cmd-args
function moz-proxy {
    $1 -o ProxyJump="$(moz-host $2 bastion).reticulum.io" "${@:3}"
}

alias moz-ci='moz-tunnel dev ci 8088 8080'
alias moz-ssh='moz-proxy ssh'
alias moz-scp='moz-proxy scp'

# export for subshells
export -f git_prompt hab-run moz-ec2 moz-host moz-proxy moz-tunnel
export PS1='\[\033]0;\u@\H: \w\007\]\[\033[01;36m\]\H\[\033[00m\]:\[\033[01;34m\]$(git_prompt)\[\033[01;31m\]\W\[\033[00m\]\$ '
export EDITOR=emacsclient VISUAL=emacsclient ALTERNATE_EDITOR=emacs
export HISTCONTROL=ignoredups
export HISTSIZE=1000
export HISTFILESIZE=2000
export PATH=$PATH:$HOME/bin:$HOME/.cargo/bin:$HOME/.local/bin
export GRADLE_OPTS="-Dorg.gradle.daemon=true -Dorg.gradle.parallel=true"
export JAVA_OPTS="-Xms128m -Xmx16384m"
export BOTO_CONFIG="~/.aws/config"

# address problems with Gnome apps
# http://debbugs.gnu.org/cgi/bugreport.cgi?bug=15154#11
export NO_AT_BRIDGE=1

shopt -s checkwinsize
shopt -s histappend

if [ -x /usr/local/bin/virtualenvwrapper.sh ]; then
    source /usr/local/bin/virtualenvwrapper.sh
fi

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi
