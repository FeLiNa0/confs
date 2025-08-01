#!/usr/bin/env bash

# Exit on error, undeclared variable reference, and set pipeline exit code
# to that of failing command.
set -eu

if [[ "$#" != "2" || ( "$1" != restore && "$1" != backup ) ]]; then
  echo "USAGE: $0 [ backup | restore ] dir"
  exit 1
fi

HOST="$(hostname)"

CONFS_COPY_PARALLEL="${CONFS_COPY_PARALLEL-true}"
if [ "${VERBOSE-}" == "" ]; then
    VERBOSE=false
fi
VERBOSE="${VERBOSE-false}"
SILENCE="${SILENCE-false}"

debug() {
    if [ "$VERBOSE" = true ] ; then
        echo $@
    fi
}

log() {
    if [ "$SILENCE" = false ] ; then
        echo -e $@
    fi
}


# Either "restore" or "backup"
MODE=$1

LOG_FILE_DIR="$(mktemp -d)/config-logs-$(whoami)"
mkdir -p "$LOG_FILE_DIR"

# The location of this script
CONF_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
HOST_SPECIFIC_DIR="host-specific"

# Store backups here
BACKUP_B_DIR=$CONF_DIR/backup-bak
BACKUP_R_DIR=$CONF_DIR/restore-bak

if [ "$MODE" == backup ] ; then
    SRC=$2
    DST=$CONF_DIR
    debug "Backups are located in $BACKUP_B_DIR"

else
    SRC=$CONF_DIR
    DST=$2
    debug "Backups are located in $BACKUP_R_DIR"
fi

# Confirm changes
# echo "Press ENTER to $MODE files from $SRC to $DST"
# read -r changes_ok
changes_ok=""

if [[ "$changes_ok" != "" ]] ; then
  exit 1
fi

# -E means preserve executability and maybe other attributes
RSYNC_OPTS="--human-readable --recursive -E"
RSYNC_BAK="$RSYNC_OPTS"

if rsync -h | grep '\--ignore-missing-args' 2>&1 >/dev/null; then
  # Supports --ignore-missing-args
  RSYNC_BAK="$RSYNC_BAK --ignore-missing-args"
fi

RSYNC_BACKUP="$RSYNC_OPTS --delete-after --relative"
RSYNC_RESTORE="$RSYNC_OPTS --relative"

pids=()

# USAGE: copy_confs_for section_name [file1 [file2 ...]]
#
# Either copy all files from section_name/ to the destination
# or copy all files to section_name/, while preserving directory structure.
# Make backups before copying.
copy_confs_for() {
    SECTION="$1"
    if [ "$CONFS_COPY_PARALLEL" == true ]; then
        _copy_confs_for "$@" > "$LOG_FILE_DIR/$SECTION" &
        PID="$!"
        pids+=("$PID")
        log "$SECTION" > "$LOG_FILE_DIR/$PID"
    else
        _copy_confs_for "$@"
    fi
}

_copy_confs_for() {
    set -eu

    SECTION="$1"
    shift

    if ! [ -d "$SECTION" ]; then
        exit 0
    fi

    debug "\n--------- $SECTION ---------\n"

    log "$@"
    mkdir -p "$CONF_DIR/$SECTION"

    FILES=
    if [ "$MODE" == backup ] ; then
        mkdir -p "$BACKUP_B_DIR/$SECTION"
        FROM="$SRC"
    else
        mkdir -p "$BACKUP_R_DIR/$SECTION"
        FROM="$DST"
    fi

    for f in "$@" ; do
        FILES="$FILES $FROM/./$f"
    done

    if [ "$MODE" == backup ] ; then
        debug rsync $RSYNC_BAK "$DST/$SECTION" "$BACKUP_B_DIR"
        rsync $RSYNC_BAK "$DST/$SECTION" "$BACKUP_B_DIR" 2>&1
        debug rsync $RSYNC_BACKUP $FILES "$DST/$SECTION"
        rsync $RSYNC_BACKUP $FILES "$DST/$SECTION" 2>&1
    else
        debug rsync $RSYNC_BAK --relative $FILES "$BACKUP_R_DIR/$SECTION"
        rsync $RSYNC_BAK --relative $FILES "$BACKUP_R_DIR/$SECTION" 2>&1 || true
        debug rsync $RSYNC_RESTORE "$SRC/$SECTION/./" $DST
        rsync $RSYNC_RESTORE "$SRC/$SECTION/./" $DST 2>&1 
    fi
}

# Either copy all files from host-specific/$hostname/section_name/ to the
# destination or copy all files to host-specific/$hostname/section_name/, while
# preserving directory structure.  Make backups before copying.
copy_confs_for_host() {
    SECTION="$1"
    if [ "$CONFS_COPY_PARALLEL" == true ]; then
        _copy_confs_for_host "$@" > "$LOG_FILE_DIR/$SECTION-$HOST" &
        PID="$!"
        pids+=("$PID")
        log "$SECTION-$HOST" > "$LOG_FILE_DIR/$PID"
    else
        _copy_confs_for_host "$@"
    fi
}

_copy_confs_for_host() {
    SECTION="$1"
    shift

    debug "\n--------- $SECTION for $HOST ---------\n"
    log "$@"
    mkdir -p "$CONF_DIR/$SECTION"

    FILES=
    if [ "$MODE" == backup ] ; then
        THIS_DST="$DST/$HOST_SPECIFIC_DIR/$HOST/$SECTION"
        mkdir -p "$BACKUP_B_DIR/$SECTION"
        mkdir -p "$THIS_DST"
        FROM="$SRC"
    else
        THIS_SRC="$SRC/$HOST_SPECIFIC_DIR/$HOST/$SECTION"
        if ! [ -d "$THIS_SRC" ]; then
            debug "Ignoring"
            exit 0
        fi
        log "UNIMPLEMENTED: cannot restore from host specific directory"
        exit 3
    fi

    for f in "$@" ; do
        FILES="$FILES $FROM/./$f"
    done

    if [ "$MODE" == backup ] ; then
        debug rsync $RSYNC_BAK "$THIS_DST" "$BACKUP_B_DIR"
        rsync $RSYNC_BAK "$THIS_DST" "$BACKUP_B_DIR" 2>&1
        debug rsync $RSYNC_BACKUP $FILES "$THIS_DST"
        rsync $RSYNC_BACKUP $FILES "$THIS_DST" 2>&1
    fi
}

debug "VERBOSE=$VERBOSE CONFS_COPY_PARALLEL=$CONFS_COPY_PARALLEL"

copy_confs_for vim \
  .vimrc \
  .vimrc.minimal \
  .config/nvim/coc-settings.json \
  .config/nvim/init.lua \
  .bash_vim

copy_confs_for vis \
  .config/vis/visrc.lua \
  .config/vis/prep.sh \
  bin/vc bin/vp

copy_confs_for zathura \
  .config/zathura/zathurarc

copy_confs_for polybar .config/polybar/config \
  .config/polybar/config \
  .config/polybar/openweathermap-fullfeatured.sh \
  .config/polybar/player-ctrl.sh \
  .config/polybar/player-mpris-tail.py \
  .config/polybar/system-nvidia-smi.sh \
  bin/polybar.sh

copy_confs_for x11 \
  .xinitrc .xbindkeysrc bin/calculator.sh

copy_confs_for_host f16 bin/f16-startup.sh
copy_confs_for_host gitconfig .gitconfig
# git config rerere.enabled true --global

copy_confs_for starship_rust_portable_shell_prompt \
  .config/starship.toml bin/uname-m-if-not-typical.sh

copy_confs_for "{ba,z,tc,c}sh" \
  .bashrc .bashrc_ps1 .bash_profile .tryalias.sh .aliases bin/trimdir.py bin/gitinfo.sh bin/projectname.sh bin/projectroot.sh bin/real-deal-turbo-charged-cd.sh

copy_confs_for git \
    bin/git-show-commits-not-in-branch.sh bin/git-remove-branches-gone-in-remote.sh bin/git-push-new-branch.sh bin/gitdiff.sh .git-template/HEAD

copy_confs_for utils \
  bin/cpufreq.sh bin/systemload.sh bin/mem.sh bin/screenshot.sh bin/screenshot-select.sh bin/pip-update-outdated.sh \
  .xsession \
  bin/rsync-for-src.sh \
  bin/rsync-parallel.sh \
  bin/dropbox-status.sh \
  bin/speedtest-info.sh \
  bin/reset-rescan-thunderbolt.sh \
  bin/open-starlink.html

copy_confs_for alacritty .config/alacritty/alacritty.yml bin/alacritty-cwd.sh

copy_confs_for cli \
  .tmux.conf

copy_confs_for compton .config/compton.conf

copy_confs_for conky bin/conky.sh .conkyrc.d/

copy_confs_for dunst .config/dunst .config/dunst/dunstrc bin/dunst.sh

copy_confs_for emacs.d .emacs.d/init.el .emacs.d/ui.el

# fish_starship_prompt.fish is temporary while https://github.com/starship/starship/issues/3305 is fixed
copy_confs_for fish_the_best_sh \
  .aliases \
  .config/fish/{config,functions/{commacomma,tryalias,load_theme,fisher,default_fish_prompt,fish_{title,prompt,right_prompt,greeting}}}.fish \
  .config/fish/fish_starship_prompt.fish \
  bin/{🐠,string_split.py,real-deal-turbo-charged-cd.sh} \

copy_confs_for bash-cache bin/bash-cache

copy_confs_for fetch-cached bin/{neofetch-cached,screenfetch-cached,bash-cache}

copy_confs_for fluxbox .fluxbox/menu .fluxbox/keys

copy_confs_for htop .config/htop/htoprc

copy_confs_for protonvpn .config/systemd/user/protonvpn-autostart.service

copy_confs_for backup \
  bin/pacman-Qie-install.py \
  bin/backup-this-pacman-machine.sh \
  bin/backup-this-dnf-machine.sh \
  bin/backup-this-apt-machine.sh \
  bin/backup.sh \
  bin/backup-games.sh \
  bin/get-backup-root.sh

copy_confs_for i3 \
  .i3status.conf \
  .xbindkeysrc \
  .profile \
  bin/backlightoff.sh \
  bin/i3empty.py \
  bin/i3txt.py \
  bin/calculator.sh \
  bin/hue_lights_toggle_all.sh \
  bin/launcher.sh \
  bin/locker.sh \
  bin/read-one-mouse-char.sh \
  bin/terminal.sh \
  bin/terminal2.sh \
  bin/wallpaper.sh \
  bin/welcome-shell.sh \
  .config/i3status-rust/ .i3/config bin/nvidia-i3-status.sh

copy_confs_for udiskie .config/udiskie/config.yml

copy_confs_for ipython \
    .ipython/profile_default/ipython_config.py \
    .ipython/profile_default/startup/00-prompt.py \
    .ipython/profile_default/startup/10-imports.py

copy_confs_for conda .condarc

copy_confs_for kitty .config/kitty/kitty.conf

# Remember to load this file with xrdb -merge ~/.Xresources
copy_confs_for xterm .Xresources

copy_confs_for nvm .nvm/default-packages

copy_confs_for work bin/open_work_howtos.sh bin/open_todays_work_journal.sh bin/todays_work_journal.sh bin/borg-backup-work.sh

copy_confs_for org bin/open_todays_org_journal.sh bin/todays_org_journal.sh

copy_confs_for top .config/procps/toprc

copy_confs_for readline .inputrc

copy_confs_for serial bin/save_jt48_ttyUSB_logs.sh

copy_confs_for pywal bin/wal-set-theme.sh bin/theme-post.sh .cache/wal/{sequences,colors.*}

copy_confs_for unison .unison/default.prf

copy_confs_for osync .osync.conf

copy_confs_for tern .tern-config

copy_confs_for hyper .hyper.js

copy_confs_for asdf .default-python-packages .default-npm-packages .tool-versions

copy_confs_for jsstuffff .npmrc

copy_confs_for fanciness bin/showoff-linux-desktop-unixporn-sexy-oh-wow-screenshot-time-here-we-go-fancy-extra-nice-UNDO.sh bin/showoff-linux-desktop-unixporn-sexy-oh-wow-screenshot-time-here-we-go-fancy-extra-nice.sh

# git@github.com:roguh/git-quick-stats.git
copy_confs_for performance bin/cerberus.sh bin/cerberus-notify-send.sh

copy_confs_for feh_sane_defaults bin/feh-sane-defaults.sh bin/feh-sane-defaults-gallery.sh

copy_confs_for pacman_scripts bin/pacman-remove-orphans.sh bin/defuck-a-pacman-install.sh bin/pacman-sort-by-size.sh

copy_confs_for arandr bin/switch-displays-xrandr.sh

copy_confs_for system-space-cleaner.sh bin/system-space-cleaner.sh

copy_confs_for pass bin/pass-custom.sh

copy_confs_for kubernetes \
    bin/correct-kubernetes-cluster.sh \
    bin/kubectl-get-image-sizes.sh \
    bin/kubectl-monitor-zigbee.sh \
    bin/kubectl-synth-configs.sh \
    bin/generate_kubeconfigs.sh \
    bin/kubectl-get-argocd-ui-password.sh \
    bin/k9s.sh   .config/k9s/plugin.yml \
    bin/python-wget-curl-replacement.sh

copy_confs_for ollama bin/ollama.sh bin/ollama-setup.sh bin/ollama-forward-7918.sh

# Good startup command: kitty -e bash -c 'backup.sh ; fish'
copy_confs_for xfce4_and_xubuntu \
    .xscreensaver \
    .config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml \
    .config/autostart/caffeine-ng.desktop \
    .config/autostart/dropbox.desktop \
    .config/autostart/dunst_notifs.desktop \
    .config/autostart/redshift.desktop \
    .config/autostart/zeal.desktop

copy_confs_for discord .config/config/settings.json

copy_confs_for Zed_text_editor .config/zed/settings.json .config/zed/keymap.json

# TODO copy to Code - OSS config too, symlink like my vim/nvim configs
copy_confs_for thedevil bin/thedevil.sh bin/code-notoss.sh .config/Code/User/settings.json

# https://github.com/Fellowship-The/minecraft-server
copy_confs_for gaming bin/minecraft-launcher.sh bin/minecraft-backup.sh bin/veloren-launcher-betterthanminecraft.sh

copy_confs_for qubes bin/mount-manjaro.sh .config/autostart/dropbox.desktop

HOST=qubes-dom0 copy_confs_for_host qubes-dom0 QubesIncoming/dom0/{bin,config.fish,.bashrc,.xscreensaver,xfce4-keyboard-shortcuts.xml}

HOST=qubes-fedora-37 copy_confs_for_host qubes-fedora-37 QubesIncoming/fedora-37/du-niiice.sh

# MAKE SURE TO INSTALL docker-credential-pass
# trizen -S docker-credential-pass-bin
copy_confs_for DOCKER bin/docker-remove-images.sh bin/docker-remove-stopped-containers.sh

FAILURE=false
FAILED_SECTIONS=""
FAILURES=0
SUCCESS=0
for PID in "${pids[@]}"; do
  if ! wait "$PID"; then
    SECTION="$(cat "$LOG_FILE_DIR/$PID" 2>&1)"
    log "\nFailure in PID=$PID SECTION=$SECTION: $(cat "$LOG_FILE_DIR/$SECTION" 2>&1)"
    FAILURE=true
    FAILURES="$((FAILURES + 1))"
    FAILED_SECTIONS="$SECTION $FAILED_SECTIONS"
  else
    SUCCESS="$((SUCCESS + 1))"
  fi
done

echo "UPDATED $SUCCESS sections, $FAILURES failures"
if [ "$FAILURE" = true ]; then
    exit 1
fi
