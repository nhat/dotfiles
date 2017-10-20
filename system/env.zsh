# preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
    export EDITOR='vim'
elif [[ -n ${NVIM_LISTEN_ADDRESS+x} ]]; then
    export EDITOR='nvr'
else
    export EDITOR='nvim'
fi

export LANG=en_US.UTF-8

# set location for cask to install apps
export HOMEBREW_CASK_OPTS="--appdir=/Applications"

# set location for Java JDK
export JAVA_HOME=/Library/Java/Home

