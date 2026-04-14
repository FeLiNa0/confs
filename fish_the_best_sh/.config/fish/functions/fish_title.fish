function title_get_project
  set PROJECTNAME (projectname.sh)
  if test "$PROJECTNAME" != ""
    printf "$PROJECTNAME"
  end
  printf " "
end

function ssh_info
  if ! test "$SSH_TTY" = ""
    printf "%s" "ssh " (hostname)
  end
  printf " "
end

function fish_title
  printf "🐠 %s %s%s" (ssh_info) (title_get_project)
end
