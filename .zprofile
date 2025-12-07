alias ll='ls -alF'
alias vim='nvim'
alias vi='nvim'
alias v='nvim'

# homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# volta
export PATH="$PATH:$HOME/.volta/bin"

# cloud-pratica
alias cpstg='export ENV=stg && export AWS_ACCOUNT_ID=786193448834 && export AWS_PROFILE=cp-terraform-stg'
alias cpprd='export ENV=prd && export AWS_ACCOUNT_ID=277905775607 && export AWS_PROFILE=cp-terraform-prd'

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.zsh 2>/dev/null || :
