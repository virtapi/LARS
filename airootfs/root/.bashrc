#
# ~/.bashrc
#

#
# created by Tim 'bastelfreak' Meusel
# place this under /etc/skel if you want this as the default bashrc for all new users
# source: https://github.com/bastelfreak/scripts/blob/master/bashrc
# Licensed under GNU GPL3 http://www.gnu.org/licenses/gpl-3.0.en.html
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return
alias ls='ls $LS_OPTIONS'
alias ll='ls -l'
alias l='ls $LS_OPTIONS -lA'
alias ..='cd ..'
alias ...='cd ../..'
alias s='ssh -l root'
alias grep='grep --color'
alias nossh='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
alias megacli_list='megacli -PDList -aAll | egrep "Enclosure Device ID:|Slot Number:|Inquiry Data:|Error Count:|Failure Count:|state"'
alias dmesg='dmesg -T --color'
alias r10k='r10k --color'
# workaround for broken systemd sync
alias reboot='sync; reboot'
alias poweroff='sync; poweroff'
alias pacman='pacman --color=auto'
alias installimage='/root/.installimage/installimage'

eval "$(dircolors)"

umask 022

export LS_OPTIONS='--color=auto -h'
export EDITOR='vim'


# hetzner style PS1
export PS1='\[\033[01;31m\]\u\[\033[01;33m\]@\[\033[01;36m\]\h \[\033[01;33m\]\w \[\033[01;35m\]\$ \[\033[00m\]'

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
export HISTCONTROL='ignoreboth'

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
export HISTFILESIZE='99999999'
export HISTSIZE='99999999'

# Less Colors for Man Pages
export LESS_TERMCAP_mb=$'\E[01;31m'       # begin blinking
export LESS_TERMCAP_md=$'\E[01;38;5;74m'  # begin bold
export LESS_TERMCAP_me=$'\E[0m'           # end mode
export LESS_TERMCAP_se=$'\E[0m'           # end standout-mode
export LESS_TERMCAP_so=$'\E[38;5;11m'    # begin standout-mode - info box
export LESS_TERMCAP_ue=$'\E[0m'           # end underline
export LESS_TERMCAP_us=$'\E[04;38;5;146m' # begin underline

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# enable gems if we have some
if which ruby >/dev/null && which gem >/dev/null; then
    PATH="$(ruby -rubygems -e 'puts Gem.user_dir')/bin:$PATH"
fi

# colorized tail
ctail() {
  tail "$@" | ccze -A -o nolookups
}
# colorized journalctl
cj() {
  journalctl -f "$@" | ccze -A -o nolookups
}
