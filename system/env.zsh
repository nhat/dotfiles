# Only set this if we haven't set $EDITOR up somewhere else previously.
if [[ "$EDITOR" == "" ]] ; then
	# Preferred editor for local and remote sessions
	if [[ -n $SSH_CONNECTION ]]; then
	  export EDITOR='vim'
	else
	  export EDITOR='subl'
	fi
fi

export LANG=en_US.UTF-8

# Set location for cask to install apps
export HOMEBREW_CASK_OPTS="--appdir=/Applications"
# Set location for Java JDK
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_92.jdk/Contents/Home
# Set source-highlight for less
export LESSOPEN="| src-hilite-lesspipe.sh %s"
export LESS=" -R "

