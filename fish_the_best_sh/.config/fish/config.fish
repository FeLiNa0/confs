# Felina A. Rivera's FISH config
# Remember to run `install_plugins` once.
set START_TIME (date +%s.%N)
set FAST_STARTUP true
set DEBUG_OUTPUT false

function debug
  if status is-interactive && [ "$DEBUG_OUTPUT" = true ]
    set_color -i
    echo "$FISH_LOGO $(date +%s.%N) $argv"
    set_color normal
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
      debug Added path "$path"
    end
  else if [ "$verbose" = "verbose" ]
    debug "WARNING: addpaths could not find $argv[1]"
  end
end

function source_if_exists --argument-names 'file' 'verbose'
    if test -e "$file"
      source "$file"
      debug "Source $file"
    else if ! [ "$verbose" = "" ]
      debug "WARNING: File not found to load as fish script: $file"
    end
end

function set_global
  set -gx $argv
  debug Set variable $argv[1]
end

# source_if_exists $HOME/.config/fish/local_env.fish
# set_global FISH_LOGO 🐠

# Common binary paths
addpaths $HOME/bin --verbose
addpaths $HOME/.local/bin  --verbose
# Lua
# addpaths $HOME/.luarocks/bin  --verbose
# Rust binaries
addpaths $HOME/.cargo/bin
# CUDA binaries
# addpaths /opt/cuda/bin
# Raku (Perl 6)
# addpaths $HOME/.rakudo-moar-2024.01-01-linux-x86_64-gcc/bin/
# Snap Linux binaries
# addpaths /snap/bin
# Google Gcloud
# addpaths /opt/google-cloud-cli/bin/

# still needed?
# set_global MANPATH $MANPATH /usr/share/man /usr/local/share/man/

# ASDF language version manager
source_if_exists /opt/asdf-vm/asdf.fish
addpaths /opt/asdf-vm/bin  # from AUR

set_global EDITOR vis

# Caused bitsandbytes package from  oobabooga/text-generation-webui
# to crash as it scanned through all env vars in search of CUDA stuff
set --unexport XDG_GREETER_DATA_DIR
set_global CUDA_LIB /opt/cuda/targets/x86_64-linux/lib/

# set_global DEVICE_MANAGER_FORCE_PASS true
# For kubectl
# still needed? set_global USE_GKE_GCLOUD_AUTH_PLUGIN True

# Disable legacy algorithms in OpenSSL 3.0+
# A fix when using the Python cryptography library.
# still needed? set_global CRYPTOGRAPHY_OPENSSL_NO_LEGACY true

# Load some common python libraries
set_global PYTHONSTARTUP "$HOME/.ipython/profile_default/startup/10-imports.py"

# Configure ollama, also see .bashrc
# set_global DEFAULT_OLLAMA_MODEL "smollm:1.7b"    # keep this updated
set_global DEFAULT_OLLAMA_MODEL "qwen3:14b"    # keep this updated
set_global OLLAMA_KEEP_ALIVE 8h
set_global OLLAMA_MAX_LOADED_MODELS 3
set_global OLLAMA_NUM_PARALLEL 3
set_global OLAMA_ORIGINS localhost
set_global OLLAMA_NOPRUNE true  # allow continuing downloads


# Load aliases before abbreviations
# I tried getting rid of tryalias with "alias tryalias alias", but it's actually
# almost as fast as plain alias so I'll keep it.
source_if_exists $HOME/.aliases --verbose

# commacomma is defined as a fish function so should not be shared with other shells
alias ,,=commacomma

abbr ` ls
abbr o 'ollama.sh run "$DEFAULT_OLLAMA_MODEL" -- '
abbr os 'ollama.sh run smollm -- '  # only 1.7B parameters!
abbr l 'ls -F -a'
abbr ll 'ls -F -a -l -h'
abbr e evince   # alternatives: 'zathura --fork' mupdf mupdf-x11 qpdfview 'wine READER10.exe'
abbr feh viewnior
abbr MONKEY 'echo MONKEY'
abbr em 'emacs -nw'
abbr emc 'emacsclient -nw --alternate-editor=""'
abbr emacsc 'emacsclient --alternate-editor=""'
abbr rsync 'rsync -rh --info=progress2'
abbr pmake 'poetry run make'


abbr k "rlwrap ngnk"  # The K language

# Python and Scientific commands
abbr py python3
abbr ipy ipython3
## abbr sci "ipython3 -i -c 'import numpy as np, scipy, sympy, astropy; from numba import jit'"
abbr jwt_decode "python3 -c \"import jwt,json ; print(json.dumps(jwt.api_jwt.decode(input('token> '), options={'verify_signature': False}), indent=2)) # Please run pip install PyJWT if this fails\""

# Common directories
abbr mc "cd ~/src/min*"
abbr art "cd ~/src/art/"
abbr games "cd ~/src/games/"
abbr golf "cd ~/src/golf/"
abbr leet "cd ~/src/golf/0notgolf/speed/Fire_of_the_Phoenix/1/3/3/7/faang_likes_puzzles/leetcode"
abbr z 'zeditor .'

# Git shortcuts
if command -v git > /dev/null
    # When I retire, I'll switch to mercurial or someshit
    abbr GP 'echo u-sure-homie && read && gp -f && gh pr create -f'
    abbr ga 'git add'
    abbr gr 'git rebase'
    abbr gc 'git commit'
    abbr gch 'git checkout'
    abbr gs '_fzf_search_git_status || git status'
    abbr gst 'git stash push --'
    abbr gstp 'git stash pop'
    abbr gd 'git diff'
    abbr gl '_fzf_search_git_log || git log'
    abbr gcl 'git clone'
    debug Setup Git abbreviations
end

# Github-specific shortcuts
if command -v gh > /dev/null
    abbr ghch 'gh pr checkout'
    ## abbr ghw 'gh pr checks --watch'
    ## abbr ghwm 'gh pr checks --watch && gh pr merge --delete-branch --merge'
end

# KUUUUUUUUUUUUUUUBBBBBBBBBBBBBBBBB
if command -v kubectl > /dev/null
    abbr k kubectl
    abbr kx kubectx
    abbr kcp 'kubectl cp'
    # List and detail resources
    abbr kg 'kubectl get'
    abbr kgp 'kubectl get pods'
    abbr kd 'kubectl describe'
    # Debugging pods
    abbr kl stern  ## Kubectl logs
    abbr kex 'kubectl exec'
    abbr kpf 'kubectl port-forward'
    # Emergency/local modifications. Prefer devops. Ensure correct cluster is targeted.
    ## abbr kdl 'correct-kubernetes-cluster.sh && kubectl delete'
    abbr krr 'correct-kubernetes-cluster.sh && kubectl rollout restart'
    ## abbr kubectl-stop-sync-app 'correct-kubernetes-cluster.sh && kubectl -n argocd patch --type=merge application -p "{\"spec\":{\"syncPolicy\":null}}"'
    ## abbr kubectl-start-sync-app 'correct-kubernetes-cluster.sh && kubectl -n argocd patch --type=merge application -p "{\"spec\":{\"syncPolicy\":{\"automated\":{\"selfHeal\":true}}}}"'
    debug Setup Kubernetes abbreviations
    #### Rarely used:
    ## kubectl exec -it rfr-edge-redis-0 -n default -c redis -- redis-cli
    ## kubectl get apps -A | grep -v Synced 
    ## abbr kc 'kubectl config'
    ## abbr kcc 'kubectl config current-context'
    ## abbr whereami 'kubectl config current-context'
    ## abbr kcn 'kubectl config set-context --current --namespace'
    ## abbr kgs 'kubectl get services'
    ## abbr kgcm 'kubectl get configmaps'
    ## abbr kgi 'kubectl get ingress'
    ## abbr ktop 'kubectl top'
end

if command -v aws > /dev/null 2>&1
    # https://docs.aws.amazon.com/cli/latest/userguide/getting-started-quickstart.html
    abbr a aws
    abbr s3 'aws s3'
end

if true
    abbr ff 'cd ~/pf && cd ~/pf/powerflex_edge_traffic_manager'
    abbr cs 'cd ~/pf && cd ~/pf/powerflex_edge_ocpp_central_system'
    abbr ev 'cd ~/pf && cd ~/pf/pfc_ev'
    abbr devman 'cd ~/pf && cd ~/pf/powerflex_cloud_edge_device_manager'
    abbr scale 'cd ~/pf && cd ~/pf/scale'
    abbr passman 'cd ~/pf && cd ~/pf/scale/powerflex_cloud_nexus_password_management'
    abbr uplo 'cd ~/pf && ~/pf/pfc_site_uploader'
    abbr uplob 'cd ~/pf && ~/pf/pfc_site_uploader/site-uploader/'
    abbr uploo 'cd ~/pf && ~/pf/pfc_site_uploader/site-uploader/'
    abbr uplof 'cd ~/pf && ~/pf/pfc_site_uploader/*front*/'
    abbr pfapi 'cd ~/pf && ~/pf/powerflex_api'
    abbr powerflex_api 'cd ~/pf && ~/pf/powerflex_api'
    abbr natsinfra 'cd ~/pf && cd ~/pf/pfc_nats_infrastructure/'
    abbr ax 'cd ~/pf && cd ~/pf/powerflex_cloud_customer_portal'
end

# Docker shortcuts
if command -v docker > /dev/null
    abbr dcls 'docker container ls'
    abbr dl 'docker logs'
    abbr dex 'docker exec'
    abbr dck "docker container kill (docker container ls --format json | jq 'select(.Networks != \"kind\") | .ID' | sed 's/\"//g')"
    abbr docker-norestart "docker update --restart=no (docker container ls --format json | jq 'select(.Networks != \"kind\") | .ID' | sed 's/\"//g')"
    ## abbr dck-all 'docker container kill (docker ps -q)'
    debug Setup Docker abbreviations
end
    
## still needed? set_global BUILDKIT_PROGRESS plain
## still set_global DOCKER_BUILDKIT 1

# kubectl krew plugins
set -q KREW_ROOT; and set -gx PATH $PATH $KREW_ROOT/.krew/bin; or set -gx PATH $PATH $HOME/.krew/bin

if command -v makeanywhere > /dev/null
    set -g MAKEANYWHERE (command -v makeanywhere)
    function makeanywhere --wraps make --description "makeanywhere --wraps make $MAKEANYWHERE"
        "$MAKEANYWHERE" $argv
    end
    function pma --wraps make --description "pma --wraps make pipenv run $MAKEANYWHERE"
        python -m pipenv run "$MAKEANYWHERE" $argv
    end
    alias ma makeanywhere

    debug Setup makeanywhere alias
end

# function pmake --wraps make --description "pma --wraps make pipenv run"
#     python -m pipenv run make $argv
# end

# adjust PATH for a darwin OS with certain patches (MacOS)
## addpaths /usr/local/opt/gettext/bin
## addpaths /Library/Frameworks/Python.framework/Versions/3.7/bin
## addpaths /usr/local/opt/openssl@1.1/bin
## addpaths /usr/local/opt/openssl/bin

# Have fzf use ag to find files
if command -v ag > /dev/null 2>&1
  if command -v fzf > /dev/null 2>&1
    set_global FZF_DEFAULT_COMMAND 'ag -l --path-to-ignore .gitignore --nocolor --hidden -g ""'
    set_global FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
    debug fzf will now use the silver searcher ag
  end
end

if status is-interactive
  if command -v xset > /dev/null 2>&1 && [ -n "$DISPLAY" ]
    xset r rate 88 42
    debug Set faster keyboard rate
  end

  function fish_user_key_bindings
    # Use fzf.fish to implement the famous ctrl-p binding for searching files
    command -v fzf 2>&1 >/dev/null && bind \cp _fzf_search_directory

    # Ctrl-F is an essential fish command to autocomplete based on history
    bind \cf forward-char
  end

  if command -v starship > /dev/null
    starship init fish | source
  end

  if command -v pyenv > /dev/null
    pyenv init - fish | source
  end
  
  set_global fzf_preview_file_cmd cat

  if ! grep PatrickF1/fzf.fish ~/.config/fish/fish_plugins >/dev/null && command -v fzf 2>&1 >/dev/null
    # Dependencies are:
    # fzf
    # fd, find alternative https://github.com/sharkdp/fd (fd-find in fedora)
    # optional bat, cat replacement
    echo 'Installing fzf.fish https://github.com/PatrickF1/fzf.fish for git log, git status, ctrl-p (file search), and ctrl-r (history)'
    fisher install PatrickF1/fzf.fish
  end
  
  set TOTAL_STARTUP_TIME (echo (date +%s.%N) "$START_TIME" | awk '{print ($1 - $2) * 1000}' || echo UNKNOWN)
  if status is-interactive && [ "$DEBUG_OUTPUT" = true ]
    echo "$TOTAL_STARTUP_TIME"ms
  end

  # RUN LAST so user can ctrl-c
  if command -v keychain > /dev/null 2>&1
    # Timeout after 10 hours (600 minutes)
    # -Q --quick If an ssh-agent process is running then use it.  Don't verify the list of keys, other than making sure it's non-empty.  This option avoids locking when possible so that multiple terminals can be opened simultaneously without waiting on each other.
    eval (keychain --quick --timeout 600 --eval -Q --quiet id_ed25519)
  end
end

function install_plugin_manager
  curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
end

function install_plugins
  ########### Use this function on first run to install plugins
  # Notification when commands finish
  fisher install franciscolourenco/done
  fisher install PatrickF1/fzf.fish
  fisher install evanlucas/fish-kubectl-completions
  gh completion --shell fish > ~/.config/fish/completions/gh.fish || echo "No gh"
  omnictl completion fish > ~/.config/fish/completions/omnictl.fish || echo "No omnictl"
end

function miniconda_fish_init
  ########### Use this function to init miniconda (Anaconda distribution)
  # If this function is overwriting your system's Python:
  # conda config --set auto_activate_base false
  # set --local CONDA_BIN "$HOME/miniconda3/bin/conda"
  set --local CONDA_BIN "/opt/miniconda3/bin/conda"
  # set --local CONDA_BIN "/usr/bin/conda"
  if ! command -v "$CONDA_BIN" > /dev/null
    return 1
  end
  eval "$CONDA_BIN" "shell.fish" "hook" | source
  conda activate $argv[1]
  debug Loaded miniconda and the $argv[1] environment
end

