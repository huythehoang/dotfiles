# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"


# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
	git
    zsh-autosuggestions
	zsh-syntax-highlighting
	zsh-history-substring-search
	zsh-autocomplete
	svcat
)

source $ZSH/oh-my-zsh.sh

# User configuration

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export PATH="/home/discord/discord/.local/bin:/home/discord/.local/bin:$PATH"
export PATH="/home/discord/nexus_visual_fingerprinter_cli_ubuntu22_v0.9.0:$PATH"
export PATH="/usr/loca/bin:$PATH"
export PATH="/usr/bin:$PATH"

export REPO_ROOT="/home/discord/discord"

### ALIASES
alias gcauth="gcloud auth login --update-adc"
alias gst="git status"
alias gpull="git pull origin main"
alias gadd="git add"
alias gcm="git commit -m"
alias gpush="git push"
alias gck="git checkout"
alias disc="cd ~/discord"

alias clyde='/home/discord/discord/clyde'

# Replace kubectl with kubecolor
# export KUBECOLOR_CONFIG="$HOME/.config/kubecolor.yaml"
# alias kubectl=kubecolor

## VISUAL DETECTION ALIASES
alias hashmatchprd='kubectl --context teleport.discord.tools-discord-anti-abuse-prd-cluster-1 --namespace hasher-matcher '
alias hashmatchstg='kubectl --context teleport.discord.tools-discord-anti-abuse-stg-anti-abuse-stg --namespace hasher-matcher '
alias sdstg='kubectl --context teleport.discord.tools-discord-safety-dispatch-stg-safety-dispatch-stg-us-east1 --namespace safety-dispatch'
alias sdprd='kubectl --context teleport.discord.tools-discord-safety-dispatch-prd-safety-dispatch-prd-us-east1 --namespace safety-dispatch'
alias sgstg='kubectl --context teleport.discord.tools-discord-anti-abuse-stg-anti-abuse-stg --namespace safety-platform'
alias sgprd='kubectl --context teleport.discord.tools-discord-anti-abuse-prd-cluster-1 --namespace safety-platform'
alias srprd='kubectl --context teleport.discord.tools-discord-anti-abuse-prd-cluster-1 --namespace discord-safety-record'
alias srstg='kubectl --context teleport.discord.tools-discord-anti-abuse-stg-anti-abuse-stg --namespace discord-safety-record'
alias smiteprd='kubectl --context teleport.discord.tools-discord-anti-abuse-prd-cluster-1 --namespace smite'
alias smitestg='kubectl --context teleport.discord.tools-discord-anti-abuse-stg-anti-abuse-stg --namespace smite'
alias policystg='kubectl --context teleport.discord.tools-discord-staging-gke-discord-staging-1 --namespace discord-policy-service'
alias policyprd='kubectl --context teleport.discord.tools-discord-anti-abuse-prd-cluster-1 --namespace discord-policy-service'
alias druidprd='kubectl --context teleport.discord.tools-discord-anti-abuse-prd-cluster-1 --namespace druid2'

export PROD_DB_PW="3vB2QTzL6rNLSRBRyArq"
export STG_DB_PW="3CmfqYAErRtGKW5veMcw"
export LD_LIBRARY_PATH="$HOME/nix/store/*/lib:$LD_LIBRARY_PATH"
export SD_PSQL_CMD="printenv POSTGRES_HOSTS | cut -d "=" -f 2 | jq .discord_safety_dispatch | xargs echo"

export NANAMI_LOCAL_PASSWORD="8iIKPd7zrM754jMR"
export SDSTG_POD=$(sdstg get pods -l name=safety-dispatch -o jsonpath="{.items[0].metadata.name}")
export SDPRD_POD=$(sdprd get pods -l name=safety-dispatch -o jsonpath="{.items[0].metadata.name}")

alias sdstg_exec='echo $SD_PSQL_CMD; sdstg exec -it $SDSTG_POD -- /bin/bash'
alias sdprd_exec='echo $SD_PSQL_CMD; sdprd exec -it $SDPRD_POD -- /bin/bash'

alias hmstg_pgbouncer='hashmatchstg port-forward service/media-hasher-pgbouncer 7999:5432 & while true ; do sleep 10 ; pg_isready -d postgres -h 127.0.0.1 -p 7999 -U postgres ; done'
alias hmprd_pgbouncer='hashmatchprd port-forward service/media-hasher-pgbouncer 7999:5432 & while true ; do sleep 10 ; pg_isready -d postgres -h 127.0.0.1 -p 7999 -U postgres ; done'

alias sdprd-exec-safety-signals='sdprd exec -it $(sdprd get pods | grep safety-dispatch-safety-signals | cut -d " " -f1)';

alias druid-portforward='druidprdt port-forward deployment/druid-router 8080:8080'

export REPO_ROOT="$HOME/discord"
alias connect-k8s="$REPO_ROOT/discord_safety_dispatch/tools/connect-k8s.sh"

## Bazel
alias test_vd='bzl run //discord_harbormaster:cli -- --debug run_tests visual_detection_test discord_visual_detection_test'
alias build_vd='bzl run //discord_harbormaster:cli -- --push build discord_visual_detection'
alias apply_vd_stg='bzl run //discord_devops/k8s/configs/anti-abuse-stg/hasher_matcher:hasher_matcher_object.apply'
alias apply_vd_prd='bzl run //discord_devops/k8s/configs/anti-abuse-prd/cluster-1/hasher_matcher:hasher_matcher_object.apply'

# git repository greeter https://github.com/o2sh/onefetch/wiki/getting-started
last_repository=
check_directory_for_new_repository() {
	current_repository=$(git rev-parse --show-toplevel 2> /dev/null)
	
	if [ "$current_repository" ] && \
	   [ "$current_repository" != "$last_repository" ]; then
		onefetch
	fi
	last_repository=$current_repository
}

cd() {
	builtin cd "$@"
	check_directory_for_new_repository
}
# end git repository greeter

# Run neofetch on terminal login! (just looks kinda cool :3)
# TODO: Migrate off of neofetch since it is not maintained anymore :(
neofetch

# eval "$(starship init zsh)"

# # Plugins
# source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
# source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# source ~/.zsh/zsh-autocomplete/zsh-autocomplete.plugin.zsh
# source ~/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh

# Homebrew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
