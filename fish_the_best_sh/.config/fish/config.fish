# Felina A. Rivera's FISH config
# Remember to run `install_plugins` once.

set LANG fr_FR.UTF-8

set START_TIME (date +%s.%N)
set FAST_STARTUP true
set DEBUG_OUTPUT true

function log
  set_color -i
  echo "$FISH_LOGO $argv"
  set_color normal
end

function debug
  if [ "$DEBUG_OUTPUT" = true ]
    log "$argv"
  end
end

function warn
  set_color bryellow black
  debug WARNING: $argv
end

function addpaths --argument-names 'path' 'verbose'
  if test -d "$path"
    if not contains -- "$path" $fish_user_paths
      # Must check if path is already added.
      # Without this check, fish becomes gradually slower to start as it
      # struggles to manage an enormous variable.
      set -U fish_user_paths $fish_user_paths "$path"
      debug Added path (trimdir.py "$path")
    end
  else if ! [ "$verbose" = "" ]
    warn addpaths could not find $argv[1]
  end
end

function load_file --argument-names 'file' 'verbose'
    if test -e $file
      source $file
      debug Loaded file $file
    else if ! [ "$verbose" = "" ]
      warn File not found: $file
    end
end

function set_global
  set -gx $argv
  debug Set variable $argv[1]
end

function set_global_if_unset
  if not set -q $argv[1]
    set_global $argv
  end
end

load_file $HOME/.config/fish/local_env.fish
set_global_if_unset FISH_LOGO # 🐠

addpaths $HOME/bin --verbose
addpaths $HOME/.local/bin  --verbose
addpaths $HOME/.cargo/bin
addpaths /opt/cuda/bin

set_global_if_unset ESHELL /bin/bash
set_global_if_unset SHELL (command -v fish)
set_global_if_unset EDITOR vis
set_global_if_unset VISUAL vis

# Caused bitsandbytes package from  oobabooga/text-generation-webui
# to crash as it scanned through all env vars in search of CUDA stuff
set --unexport XDG_GREETER_DATA_DIR
set_global CUDA_LIB /opt/cuda/targets/x86_64-linux/lib/

# This is used for speeding up integration/unit tests on a private repo
set_global TEST_TIMEOUT_SCALING_FACTOR 2

# To disable parallely notifications unless a failure happens
set_global_if_unset NOTIFY_COMMAND 'true'

set_global USE_GKE_GCLOUD_AUTH_PLUGIN True

set_global_if_unset PYTHONSTARTUP "$HOME/.ipython/profile_default/startup/10-imports.py"

if command -v most > /dev/null 2>&1
    set_global PAGER most
    set_global pager $PAGER
    set_global LESS $PAGER
    set_global MANPAGER $PAGER
    set_global SYSTEMD_PAGER $PAGER
    alias less=$PAGER
end

if command -v git > /dev/null
    abbr ga 'git add'
    abbr gc 'git commit'
    abbr gch 'git checkout'
    abbr gs 'git status'
    abbr gst 'git stash push --'
    abbr gstp 'git stash pop'
    abbr gd 'git diff'
    abbr gl 'git log'
    abbr gcl 'git clone'
    debug Setup Git abbreviations
end

if command -v kubectl > /dev/null
    abbr k kubectl
    abbr kx kubectx
    abbr kc 'kubectl config'
    # List and detail resources
    abbr kg 'kubectl get'
    abbr kgp 'kubectl get pods'
    abbr kgs 'kubectl get services'
    abbr kd 'kubectl describe'
    # Debugging pods
    abbr kl 'kubectl logs'
    abbr kcp 'kubectl cp'
    abbr kex 'kubectl exec'
    abbr kpf 'kubectl port-forward'
    # Emergency/local modifications. Prefer devops. Ensure correct cluster is targeted.
    abbr kdl 'correct-kubernetes-cluster.sh && kubectl delete'
    abbr kr 'correct-kubernetes-cluster.sh && kubectl rollout'
    abbr krr 'correct-kubernetes-cluster.sh && kubectl rollout restart'
    abbr kubectl-stop-sync-app 'correct-kubernetes-cluster.sh && kubectl -n argocd patch --type=merge application -p "{\"spec\":{\"syncPolicy\":null}}"'
    abbr kubectl-start-sync-app 'correct-kubernetes-cluster.sh && kubectl -n argocd patch --type=merge application -p "{\"spec\":{\"syncPolicy\":{\"automated\":{\"selfHeal\":true}}}}"'
    abbr ka 'correct-kubernetes-cluster.sh && kubectl apply'

    debug Setup Kubernetes abbreviations

    addpaths $HOME/.krew/bin
end

if command -v docker > /dev/null
    abbr dcls 'docker container ls'
    abbr dl 'docker logs'
    abbr dex 'docker exec'
    abbr dck "docker container kill (docker container ls --format json | jq 'select(.Networks != \"kind\") | .ID' | sed 's/\"//g')"
    abbr dck-all 'docker container kill (docker ps -q)'
    set_global BUILDKIT_PROGRESS plain
    set_global DOCKER_BUILDKIT 1
    debug Setup Docker abbreviations
end

if command -v makeanywhere > /dev/null
    set -g MAKEANYWHERE (command -v makeanywhere)
    function makeanywhere --wraps make --description "makeanywhere --wraps make $MAKEANYWHERE"
        "$MAKEANYWHERE" $argv
    end
    function pma --wraps make --description "pma --wraps make pipenv run $MAKEANYWHERE"
        pipenv run "$MAKEANYWHERE" $argv
    end
    alias ma makeanywhere

    debug Setup makeanywhere alias
end

function pmake --wraps make --description "pma --wraps make pipenv run"
    pipenv run make $argv
end

# Load aliases
# TODO reduce number of aliases to speed up loading time or create ~/.essential_aliases
# I tried getting rid of tryalias with "alias tryalias alias", but it's actually
# almost as fast as plain alias so I'll keep it.
load_file $HOME/.aliases --verbose
tryalias ,, commacomma

# It's POSIX + my muscle memory now
abbr grep ag

load_file ~/.asdf/asdf.fish --verbose

if test -e ~/.asdf/completions/asdf.fish
  mkdir -p ~/.config/fish/completions
  rm -f ~/.config/fish/completions/asdf.fish
  cp -f ~/.asdf/completions/asdf.fish ~/.config/fish/completions
  debug Loaded ASDF fish completions
end

set_global MANPATH $MANPATH /usr/share/man /usr/local/share/man/

# darwin with some patches
addpaths /usr/local/opt/gettext/bin
addpaths /Library/Frameworks/Python.framework/Versions/3.7/bin
addpaths /usr/local/opt/openssl@1.1/bin
addpaths /usr/local/opt/openssl/bin

# Have fzf use ag to find files
if command -v ag > /dev/null 2>&1
  if command -v fzf > /dev/null 2>&1
    set_global FZF_DEFAULT_COMMAND 'ag --hidden -g ""'
    set_global FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"

    debug Set fzf variables
  end
end

function miniconda_fish_init
  set --local CONDA_BIN "$HOME/miniconda3/bin/conda"
  # set --local CONDA_BIN "/opt/miniconda3/bin/conda"
  # set --local CONDA_BIN "/usr/bin/conda"
  if ! command -v "$CONDA_BIN" > /dev/null
    return 1
  end
  eval "$CONDA_BIN" "shell.fish" "hook" | source
  conda activate $argv[1]
  debug Loaded miniconda and the $argv[1] environment
end

# If this is overwriting your system's Python:
# conda config --set auto_activate_base false
#
# miniconda_fish_init

if status is-interactive
  if command -v xset > /dev/null 2>&1 && [ -n "$DISPLAY" ]
    # Faster keyboard rate
    xset r rate 125 42
    debug Set faster keyboard rate
  end

  function fish_user_key_bindings
    if command -v fzf > /dev/null 2>&1
      # Use Ctrl-R to find command in history
      if command -v fzf_key_bindings > /dev/null 2>&1
          fzf_key_bindings
      end

      # Use Ctrl-P to find files
      bind \cp fzf

      if bind -M insert > /dev/null 2>&1 2>&1
        bind -M insert \cp fzf
      end
      # debug Configured interactive fzf features
    end

    # Ctrl-F is essential fish
    # It can become unbound, e.g. if in vi-mode
    # Right Arrow and Ctrl-E might work
    bind \cf forward-char
    # debug Bound Ctrl-F
  end

  if command -v starship > /dev/null
    starship init fish | source
  end
  
  set TOTAL_STARTUP_TIME (echo (date +%s.%N) "$START_TIME" | awk '{print ($1 - $2) * 1000}' || echo UNKNOWN)
  log "$TOTAL_STARTUP_TIME"ms

  set SHELL_TYPE ([ -n "$SSH_CLIENT" ] && echo ' SSH' || echo)

  echo 'Mater artium necessitas.'

  # RUN LAST so user can ctrl-c
  if command -v keychain > /dev/null 2>&1
    if [ "$FAST_STARTUP" = true ] && [ "$SSH_AGENT_PID" != "" ] && [ -e "/proc/$SSH_AGENT_PID/status" ]
        warn SPEEDUP Skipping calling keychain as SSH_AGENT_PID is already set and ssh-agent is running
    else
        # Timeout after 10 hours (600 minutes)
        # -Q --quick If an ssh-agent process is running then use it.  Don't verify the list of keys, other than making sure it's non-empty.  This option avoids locking when possible so that multiple terminals can be opened simultaneously without waiting on each other.
        eval (keychain --quick --timeout 600 --eval --agents ssh -Q --quiet --nogui id_ed25519_felina id_ed25519) &
        debug Started ssh-agent with keychain
        if ! [ -e "/proc/$SSH_AGENT_PID/status" ]
          if [ (ps "$SSH_AGENT_PID" | wc -l) -ge 2 ]
            warn Your system does not support procfs 
          else
            warn The SSH agent was not started!
          end
        end
    end
  end
end

function install_plugin_manager
  curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
end

function install_plugins
  # Done
  fisher install franciscolourenco/done

  # kubectl completion
  if command -v kubectl > /dev/null 2>&1
    fisher install evanlucas/fish-kubectl-completions
  end

  if command -v gh > /dev/null 2>&1
    gh completion --shell fish
  end
end
