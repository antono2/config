# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

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
if [ $TILIX_ID ] || [ $VTE_VERSION ] ; then source /etc/profile.d/vte.sh; fi # Ubuntu Budgie END

## CUSTOM STUFF
#disable terminal freeze in VIM on CTRL+S
stty -ixon
#enable holding down key to repeat
xset r on
#vab bash completion
#source <(vab complete setup bash)
#v bash completion
#source <(v complete setup bash)
#set rust environment vars to custom paths for
#export RUSTUP_HOME=/home/anton/workspace/rust/rustup
#export CARGO_HOME=/home/anton/workspace/rust/cargo
#export PATH="/home/anton/workspace/rust/cargo/bin:$PATH"
. "$HOME/.cargo/env"
source <( rustup completions bash )          # for rustup
source <( rustup completions bash cargo )    # for cargo
source /home/anton/workspace/alacritty/extra/completions/alacritty.bash
export PATH="/home/anton/workspace/alacritty/target/release:$PATH"
export PATH="/home/anton/.local/bin:$PATH"
export PATH="/home/anton/workspace/glslang/bin/bin:$PATH"
#set vulkan env var for VK_LAYER_KHRONOS_validation
#export VK_LOADER_LAYERS_ENABLE=*validation,*gfxreconstruct,*api_dump
#export VK_LOADER_LAYERS_ENABLE=*validation,*api_dump
export VK_LOADER_LAYERS_ENABLE=*api_dump
#export VULKAN_SDK=/home/anton/.local/share/vulkan
export VULKAN_SDK=$HOME/workspace/vulkansdk-linux-x86_64-1.3.296.0/x86_64
export VK_LAYER_PATH=$VULKAN_SDK/share/vulkan/explicit_layer.d
export LD_LIBRARY_PATH=$VULKAN_SDK/lib:$LD_LIBRARY_PATH
export PATH="/home/anton/workspace/ccls/Release:$PATH"
#export CPLUS_INCLUDE_PATH=/usr/include/c++/11:/usr/lib/gcc/x86_64-linux-gnu/11:/usr/include/x86_64-linux-gnu/c++/11:/usr/lib/x86_64-linux-gnu
#export PATH="/home/anton/workspace/v-analyzer/bin:$PATH"
export PATH="/home/anton/.config/v-analyzer/bin:$PATH"
export ABCL_ROOT="/home/anton/workspace/abcl-src-1.9.2"
export LD_LIBRARY_PATH="/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH"
# Erlang
export KERL_BUILD_BACKEND="git"
export KERL_CONFIGURE_OPTIONS="--without-javac \
                               --with-dynamic-trace=systemtap"
export PATH="/home/anton/workspace/kerl:$PATH"
export PATH="/home/anton/workspace/rebar3:$PATH"
export PATH="/home/anton/workspace/gf:$PATH"
export PATH="/home/anton/workspace/binutils-gdb/install/bin:$PATH"
#export KAKOUNE_CONFIG_DIR="/home/anton/Configs"
export PATH=$PATH:$HOME/workspace/kak-lsp
export PATH=$PATH:/usr/local/go/bin
export GCM_CREDENTIAL_STORE="gpg"
export PATH="$HOME/workspace/llvm-project/install/bin:$PATH"
export GLFW_LIB="/usr/lib/x86_64-linux-gnu"
export GLFW_INCLUDE=""



