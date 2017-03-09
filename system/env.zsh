# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
    export EDITOR='vim'
elif [[ -n ${NVIM_LISTEN_ADDRESS+x} ]]; then
    export EDITOR='nvr'
else
    export EDITOR='nvim'
fi

export LANG=en_US.UTF-8

# Set location for cask to install apps
export HOMEBREW_CASK_OPTS="--appdir=/Applications"
# Set location for Java JDK
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_92.jdk/Contents/Home
# Set source-highlight for less
export LESSOPEN="| src-hilite-lesspipe.sh %s"
export LESS=" -iR"

