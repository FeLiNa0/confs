#!/usr/bin/env bash

# Exit on error, undeclared variable reference, and set pipeline exit code
# to that of failing command.
set -eu

if [[ "$#" != "2" || ( "$1" != restore && "$1" != backup ) ]]; then
  echo "USAGE: $0 [ backup | restore ] dir"
  exit 1
fi

CONFS_COPY_PARALLEL="${CONFS_COPY_PARALLEL-true}"
if [ "${VERBOSE-}" == "" ]; then
    VERBOSE=true
fi
VERBOSE="${VERBOSE-false}"

# Either "restore" or "backup"
MODE=$1

LOG_FILE_DIR="$(mktemp --directory)/config-logs-$(whoami)"
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
    echo "Backups are located in $BACKUP_B_DIR"

else
    SRC=$CONF_DIR
    DST=$2
    echo "Backups are located in $BACKUP_R_DIR"
fi

# Confirm changes
echo "Press ENTER to $MODE files from $SRC to $DST"
read -r changes_ok

if [[ "$changes_ok" != "" ]] ; then
  exit 1
fi

RSYNC_OPTS="--human-readable --recursive --xattrs"
# Some platfomrs do not support attributes
# RSYNC_OPTS="--human-readable --recursive"
RSYNC_BAK="$RSYNC_OPTS"
RSYNC_BACKUP="$RSYNC_OPTS --delete-after --relative"
RSYNC_RESTORE="$RSYNC_OPTS --relative"

pids=()

log() {
    if [[ "$VERBOSE" == true ]] ; then
        echo $@
    fi
}

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
        echo "$SECTION" > "$LOG_FILE_DIR/$PID"
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

    printf "\n--------- $SECTION ---------\n"

    echo "$@"
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
    echo FILES: "$FILES"

    if [ "$MODE" == backup ] ; then
        log rsync $RSYNC_BAK "$DST/$SECTION" "$BACKUP_B_DIR"
        rsync $RSYNC_BAK "$DST/$SECTION" "$BACKUP_B_DIR"
        log rsync $RSYNC_BACKUP $FILES "$DST/$SECTION"
        rsync $RSYNC_BACKUP $FILES "$DST/$SECTION"
    else
        log rsync $RSYNC_BAK --relative --ignore-missing-args $FILES "$BACKUP_R_DIR/$SECTION"
        rsync $RSYNC_BAK --relative --ignore-missing-args $FILES "$BACKUP_R_DIR/$SECTION"
        log rsync $RSYNC_RESTORE "$SRC/$SECTION/./" $DST
        rsync $RSYNC_RESTORE "$SRC/$SECTION/./" $DST
    fi
}

# Either copy all files from host-specific/$hostname/section_name/ to the
# destination or copy all files to host-specific/$hostname/section_name/, while
# preserving directory structure.  Make backups before copying.
copy_confs_for_host() {
    SECTION="$1"
    HOST="$(hostname)"
    if [ "$CONFS_COPY_PARALLEL" == true ]; then
        _copy_confs_for_host "$@" > "$LOG_FILE_DIR/$SECTION-$HOST" &
        PID="$!"
        pids+=("$PID")
        echo "$SECTION-$HOST" > "$LOG_FILE_DIR/$PID"
    else
        _copy_confs_for_host "$@"
    fi
}

_copy_confs_for_host() {
    SECTION="$1"
    HOST="$(hostname)"
    shift

    printf "\n--------- $SECTION for $HOST ---------\n"
    echo "$@"
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
            echo "Ignoring"
            exit 0
        fi
        echo "Unimplemented: cannot restore from host specific directory"
        exit 1
    fi

    for f in "$@" ; do
        FILES="$FILES $FROM/./$f"
    done
    echo FILES: "$FILES"

    if [ "$MODE" == backup ] ; then
        log rsync $RSYNC_BAK "$THIS_DST" "$BACKUP_B_DIR"
        rsync $RSYNC_BAK "$THIS_DST" "$BACKUP_B_DIR"
        log rsync $RSYNC_BACKUP $FILES "$THIS_DST"
        rsync $RSYNC_BACKUP $FILES "$THIS_DST"
    fi
}

log "VERBOSE=$VERBOSE CONFS_COPY_PARALLEL=$CONFS_COPY_PARALLEL"

copy_confs_for vim \
  .vimrc \
  .vimrc.minimal \
  .config/nvim/coc-settings.json \
  .bash_vim \
  bin/pyston-pylint \
  bin/pyston-black \
  bin/pyston-isort \
  bin/try-pyston

copy_confs_for vis \
  .config/vis/visrc.lua \
  .config/vis/prep.sh

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
  .xinitrc .xbindkeysrc bin/autostart.sh bin/signal.sh

copy_confs_for "{ba,z,tc,c}sh" \
  .bashrc .bashrc_ps1 .bash_profile .zshrc .cshrc .tryalias.sh .aliases bin/trimdir.py bin/gitinfo.sh bin/projectroot.sh bin/real-deal-turbo-charged-cd.sh

copy_confs_for git \
    bin/git-show-commits-not-in-branch.sh bin/git-remove-branches-gone-in-remote.sh bin/git-push-new-branch.sh bin/gitdiff.sh .git-template/HEAD

copy_confs_for_host git .gitconfig

copy_confs_for utils \
  bin/cpufreq.sh bin/systemload.sh bin/mem.sh bin/screenshot.sh bin/screenshot-select.sh bin/pip-update-outdated.sh \
  .xsession .profile

copy_confs_for alacritty .config/alacritty/alacritty.yml bin/alacritty-cwd.sh

copy_confs_for cli \
  .tmux.conf \
  .config/lxterminal/lxterminal.conf \
  .config/terminator/config

copy_confs_for compton .config/compton.conf

copy_confs_for conky bin/conky.sh .conkyrc.d/

copy_confs_for dunst .config/dunst .config/dunst/dunstrc bin/dunst.sh

copy_confs_for emacs.d .emacs.d/init.el .emacs.d/ui.el

copy_confs_for fish_the_best_sh \
  .aliases \
  .config/fish/{config,functions/{commacomma,tryalias,load_theme,fisher,fish_{title,prompt,greeting}}}.fish \
  bin/{🐠,string_split.py,real-deal-turbo-charged-cd.sh} \

copy_confs_for_host fish_local \
  .config/fish/local_env.fish

copy_confs_for bash-cache bin/bash-cache

copy_confs_for screenfetch-cached bin/{screenfetch-cached,bash-cache}

copy_confs_for fluxbox .fluxbox/menu .fluxbox/keys

copy_confs_for htop .config/htop/htoprc

copy_confs_for i3 \
  .i3status.conf \
  bin/backlightoff.sh \
  bin/backup-this-pacman-machine.sh \
  bin/backup.sh \
  bin/get-backup-root.sh \
  bin/i3empty.py \
  bin/i3txt.py

copy_confs_for i3 \
  bin/launcher.sh \
  bin/locker.sh \
  bin/read-one-mouse-char.sh \
  bin/terminal.sh \
  bin/terminal2.sh \
  bin/wallpaper.sh \
  bin/welcome-shell.sh \

copy_confs_for_host i3 .config/i3status-rust/ .i3/config

copy_confs_for ipython .ipython/profile_default/ipython_config.py

copy_confs_for kitty .config/kitty/kitty.conf

copy_confs_for nvm .nvm/default-packages

copy_confs_for work bin/open_work_howtos.sh bin/open_todays_work_journal.sh bin/todays_work_journal.sh bin/borg-backup-work.sh

copy_confs_for org bin/open_todays_org_journal.sh bin/todays_org_journal.sh

copy_confs_for top .config/procps/toprc

copy_confs_for readline .inputrc

copy_confs_for pywal bin/wal-set-theme.sh bin/theme-post.sh .cache/wal/{sequences,colors.*}

copy_confs_for ranger .config/ranger/rc.conf

copy_confs_for unison .unison/default.prf

copy_confs_for osync .osync.conf

copy_confs_for tern .tern-config

copy_confs_for hyper .hyper.js

copy_confs_for asdf .default-python-packages .default-npm-packages .tool-versions

copy_confs_for fanciness bin/showoff-linux-desktop-unixporn-sexy-oh-wow-screenshot-time-here-we-go-fancy-extra-nice-UNDO.sh bin/showoff-linux-desktop-unixporn-sexy-oh-wow-screenshot-time-here-we-go-fancy-extra-nice.sh

# git@github.com:roguh/git-quick-stats.git
copy_confs_for performance bin/cerberus.sh bin/cerberus-notify-send.sh

copy_confs_for feh_sane_defaults bin/feh-sane-defaults.sh bin/feh-sane-defaults-gallery.sh

copy_confs_for pacman_scripts bin/defuck-a-pacman-install.sh

copy_confs_for arandr .screenlayout/select-arandr-display.sh

copy_confs_for system-space-cleaner.sh bin/system-space-cleaner.sh

copy_confs_for pass bin/pass-with-custom-editor.sh

copy_confs_for kubernetes bin/kubectl-get-image-sizes.sh

# MAKE SURE TO INSTALL docker-credential-pass
# trizen -S docker-credential-pass-bin
copy_confs_for DOCKER bin/docker-remove-images.sh bin/docker-remove-stopped-containers.sh

FAILURE=false
FAILED_SECTIONS=""
FAILURES=0
SUCCESS=0
for PID in "${pids[@]}"; do
  if ! wait "$PID"; then
    echo
    echo Failure in PID="$PID"
    SECTION="$(cat "$LOG_FILE_DIR/$PID")"
    echo cat "$LOG_FILE_DIR/$SECTION"
    cat "$LOG_FILE_DIR/$SECTION"
    echo Failure in SECTION="$SECTION"
    FAILURE=true
    FAILURES="$((FAILURES + 1))"
    FAILED_SECTIONS="$SECTION $FAILED_SECTIONS"
  else
    SUCCESS="$((SUCCESS + 1))"
  fi
done

echo "$SUCCESS" sections copied successfully
if [ "$FAILURE" = true ]; then
    echo "$FAILURES section(s) could not be copied: $FAILED_SECTIONS"
    exit 1
fi
