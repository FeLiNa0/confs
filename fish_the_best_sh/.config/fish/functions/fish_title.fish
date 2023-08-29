function title_get_project
  set PROJECTNAME (projectname.sh)
  if test "$status" = 0 && test "$PROJECTNAME" != ""
    printf "$PROJECTNAME "
  end
  printf " "
end

function ssh_info
  if ! test "$SSH_TTY" = ""
    printf "%s" "ssh " (hostname)
  end
  printf " "
end

function fish_info
  printf "%s" $fish_pid
end

function fish_title
  printf "ꕀ🐱ꕀ %s %s%s %s %s" (ssh_info) (title_get_project) (trimdir.py (pwd) || pwd) (fish_info)
end
