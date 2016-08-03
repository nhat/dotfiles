# grc overides for ls
#   Made possible through contributions from generous benefactors like
#   `brew install coreutils`
if $(gls &>/dev/null)
then
  alias ls="gls -F --color"
  alias l="gls -lAh --color"
  alias ll="gls -lh --color"
  alias la="gls -A --color"
fi

alias cp='cp -iv'                           # Preferred 'cp' implementation
alias mv='mv -iv'                           # Preferred 'mv' implementation
alias mkdir='mkdir -pv'                     # Preferred 'mkdir' implementation
alias finder='open .'                       # Open current directory in finder
alias grep='grep --color=auto'               # Always highlight grep search term

alias vi=nvim

alias i223='sudo killall -HUP mDNSResponder; sshuttle -H --dns -r nnguyen2@10.44.223.191 10.44.0.0/16'
alias prod='sudo killall -HUP mDNSResponder; sshuttle -H --dns -r nnguyen2@login.corp.mobile.de 10.38.0.0/16 10.46.0.0/16 10.47.0.0/16'
