# Felina A. Rivera's FISH config
# Remember to run `install_plugins` once.

set LANG fr_FR.UTF-8

set START_TIME (date +%s.%N)
set FAST_STARTUP true
set DEBUG_OUTPUT false

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

function addpaths --argument-names 'path' 'verbose' 'append'
  # For adding to PATH
  if test -d "$path"
    if not contains -- "$path" $fish_user_paths
      # Must check if path is already added.
      # Without this check, fish becomes gradually slower to start as it
      # struggles to manage an enormous variable.
      if [ "$append" = "no-append" ]
          set -U fish_user_paths "$path" $fish_user_paths
      else
          set -U fish_user_paths $fish_user_paths "$path"
      end
      debug Added path (trimdir.py "$path")
    end
  else if [ "$verbose" = "verbose" ]
    debug "WARNING: addpaths could not find $argv[1]"
  end
end

function load_file --argument-names 'file' 'verbose'
    if test -e $file
      source $file
      debug Loaded file $file
    else if ! [ "$verbose" = "" ]
      debug "WARNING: File not found to load as fish script: $file"
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

debug Starting FISH debug output. Set DO_NOT_CLEAR to leave it on the screen after startup.
set_global DO_NOT_CLEAR true

load_file $HOME/.config/fish/local_env.fish
# set_global FISH_LOGO 🐠

# Common binary paths
addpaths $HOME/bin --verbose
addpaths $HOME/.local/bin  --verbose
# Rust binaries
addpaths $HOME/.cargo/bin
# CUDA binaries
addpaths /opt/cuda/bin
# Raku (Perl 6)
addpaths $HOME/.rakudo-moar-2024.01-01-linux-x86_64-gcc/bin/
# Snap Linux binaries
addpaths /snap/bin
# Google Gcloud
addpaths /opt/google-cloud-cli/bin/

set_global EDITOR vis

# Caused bitsandbytes package from  oobabooga/text-generation-webui
# to crash as it scanned through all env vars in search of CUDA stuff
set --unexport XDG_GREETER_DATA_DIR
set_global CUDA_LIB /opt/cuda/targets/x86_64-linux/lib/

# This is used for speeding up integration/unit tests on a private repo
set_global TEST_TIMEOUT_SCALING_FACTOR 2

# For kubectl
set_global USE_GKE_GCLOUD_AUTH_PLUGIN True

# Load some common python libraries
set_global PYTHONSTARTUP "$HOME/.ipython/profile_default/startup/10-imports.py"

if command -v most > /dev/null 2>&1
    set_global PAGER most
    set_global pager $PAGER
    set_global LESS $PAGER
    set_global MANPAGER $PAGER
    set_global SYSTEMD_PAGER $PAGER
    alias less=$PAGER
end

# Load aliases before abbreviations
# I tried getting rid of tryalias with "alias tryalias alias", but it's actually
# almost as fast as plain alias so I'll keep it.
load_file $HOME/.aliases --verbose
# commacomma is defined as a fish function so should not be shared with other shells
alias ,,=commacomma

if command -v git > /dev/null
    abbr ga 'git add'
    abbr gc 'git commit'
    abbr gch 'git checkout'
    abbr gs '_fzf_search_git_status || git status'
    abbr gst 'git stash push --'
    abbr gstp 'git stash pop'
    abbr gd 'git diff'
    abbr gl '_fzf_search_git_log || git log'
    abbr gcl 'git clone'
    abbr gri 'git rebase -i'
    abbr grim 'git rebase -i main'
    debug Setup Git abbreviations
end

if command -v kubectl > /dev/null
    abbr k kubectl
    abbr kx kubectx
    abbr kc 'kubectl config'
    abbr kcn 'kubectl config set-context --current --namespace'
    # List and detail resources
    abbr kg 'kubectl get'
    abbr kga 'kubectl get applications'
    abbr kgcm 'kubectl get configmap'
    abbr kgi 'kubectl get ingress'
    abbr kgp 'kubectl get pods'
    abbr kgs 'kubectl get services'
    abbr kgcm 'kubectl get configmaps'
    abbr kgi 'kubectl get ingress'
    abbr kd 'kubectl describe'
    abbr ktop 'kubectl top'
    # Debugging pods
    abbr kl 'kubectl logs'
    abbr kcp 'kubectl cp'
    abbr kex 'kubectl exec'
    abbr kpf 'kubectl port-forward'
    # Emergency/local modifications. Prefer devops. Ensure correct cluster is targeted.
    abbr kdl 'correct-kubernetes-cluster.sh && kubectl delete'
    abbr krr 'correct-kubernetes-cluster.sh && kubectl rollout restart'
    abbr kubectl-stop-sync-app 'correct-kubernetes-cluster.sh && kubectl -n argocd patch --type=merge application -p "{\"spec\":{\"syncPolicy\":null}}"'
    abbr kubectl-start-sync-app 'correct-kubernetes-cluster.sh && kubectl -n argocd patch --type=merge application -p "{\"spec\":{\"syncPolicy\":{\"automated\":{\"selfHeal\":true}}}}"'
    debug Setup Kubernetes abbreviations

    addpaths $HOME/.krew/bin
end

if true
    abbr ff 'cd ~/pf/powerflex_edge_traffic_manager'
    abbr cs 'cd ~/pf/powerflex_edge_ocpp_central_system'
    abbr ev 'cd ~/pf/pfc_ev'
    abbr scale 'cd ~/pf/small_scale'
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

# Load OCaml
load_file $HOME/.opam/opam-init/init.fish

load_file ~/.asdf/asdf.fish --verbose

if test -e ~/.asdf/completions/asdf.fish
  mkdir -p ~/.config/fish/completions
  rm -f ~/.config/fish/completions/asdf.fish
  cp -f ~/.asdf/completions/asdf.fish ~/.config/fish/completions
  debug Loaded ASDF fish completions
end

if command -v go > /dev/null 2>&1
  if [ "$FAST_STARTUP" ]
    debug SPEEDUP: Guessing GOPATH
    set_global GOPATH "$HOME/go"
  else
    set_global GOPATH (go env GOPATH)
  end
  addpaths $GOPATH/bin --verbose
  debug Set Go variables and paths
end


set_global MANPATH $MANPATH /usr/share/man /usr/local/share/man/

# darwin with some patches
addpaths /usr/local/opt/gettext/bin
addpaths /Library/Frameworks/Python.framework/Versions/3.7/bin
addpaths /usr/local/opt/openssl@1.1/bin
addpaths /usr/local/opt/openssl/bin

if test -d /usr/local/opt/openssl/
  set_global LDFLAGS "-L/usr/local/opt/openssl/lib"
  set_global CPPFLAGS "-I/usr/local/opt/openssl/include"
  set_global PKG_CONFIG_PATH "/usr/local/opt/openssl/lib/pkgconfig"

  debug Set local openssl variables
end

if test -d /usr/local/opt/gettext/lib
  set_global LDFLAGS "-L/usr/local/opt/gettext/lib"
  set_global CPPFLAGS "-I/usr/local/opt/gettext/include"

  debug Set local gettext variables
end

if test -d /usr/local/opt/openssl@1.1/lib
  set_global LDFLAGS "-L/usr/local/opt/openssl@1.1/lib"
  set_global CPPFLAGS "-I/usr/local/opt/openssl@1.1/include"
  set_global PKG_CONFIG_PATH "/usr/local/opt/openssl@1.1/lib/pkgconfig"

  debug Set local openssl@1.1 variables
end


# Have fzf use ag to find files
if command -v ag > /dev/null 2>&1
  if command -v fzf > /dev/null 2>&1
    set_global FZF_DEFAULT_COMMAND 'ag --hidden -g ""'
    set_global FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
    debug fzf will now use the silver searcher ag
  end
end

function miniconda_fish_init
  # If this function is overwriting your system's Python:
  # conda config --set auto_activate_base false
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
  echo 'Bienvenido a FISH, la shell amigable e interactiva :)'
  echo 'Bienvenue dans FISH, le shell amical et interactif :)'
  echo '    ^                     ^    '
  echo '   / \       _____       / \   '
  echo '__/   \__----     ----__/   \__'
  echo 'Mater artium necessitas.'

  if command -v xset > /dev/null 2>&1 && [ -n "$DISPLAY" ]
    xset r rate 125 42
    debug Set faster keyboard rate
  end

  function fish_user_key_bindings
    # Use fzf.fish to implement the famous ctrl-p binding for searching files
    command -v fzf 2>&1 >/dev/null && bind \cp _fzf_search_directory

    # Ctrl-F is an essential fish command to autocomplete based on history
    bind \cf forward-char
    # debug Bound Ctrl-F
  end

  # Waiting for https://github.com/starship/starship/issues/3305 to be fixed
  # Applying temp fix manually
  if command -v starship > /dev/null
    starship init fish | source
  end
  
  set TOTAL_STARTUP_TIME (echo (date +%s.%N) "$START_TIME" | awk '{print ($1 - $2) * 1000}' || echo UNKNOWN)
  log "$TOTAL_STARTUP_TIME"ms
  echo "Mater artium necessitas."

  set_global fzf_preview_file_cmd cat

  if command -v fzf 2>&1 >/dev/null && ! grep PatrickF1/fzf.fish ~/.config/fish/fish_plugins >/dev/null
    # Dependencies are:
    # fzf
    # fd, find alternative https://github.com/sharkdp/fd (fd-find in fedora)
    # optional bat, cat replacement
    echo 'Installing fzf.fish https://github.com/PatrickF1/fzf.fish for git log, git status, ctrl-p (file search), and ctrl-r (history)'
    fisher install PatrickF1/fzf.fish
  end

  # RUN LAST so user can ctrl-c
  if command -v keychain > /dev/null 2>&1
    # Timeout after 10 hours (600 minutes)
    # -Q --quick If an ssh-agent process is running then use it.  Don't verify the list of keys, other than making sure it's non-empty.  This option avoids locking when possible so that multiple terminals can be opened simultaneously without waiting on each other.
    eval (keychain --quick --timeout 600 --eval --agents ssh -Q --quiet id_ed25519)
  end
end

function install_plugin_manager
  curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
end

function install_plugins
  # Notification when commands finish
  fisher install franciscolourenco/done
  fisher install PatrickF1/fzf.fish
  fisher install evanlucas/fish-kubectl-completions
  gh completion --shell fish > ~/.config/fish/completions/gh.fish || echo "No gh"
  omnictl completion fish > ~/.config/fish/completions/omnictl.fish || echo "No omnictl"
end

# Fish does lots of things by default:
# ignore dups and blank lines in history
# interactive cd and autocompletion
# etc
