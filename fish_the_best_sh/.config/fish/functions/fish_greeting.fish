function fish_greeting
  # set MOTTO "Mater artium necessitas"
  set MOTTO "CRESCIT EUNDO"
  if [ "$PWD" = "$HOME" ]
    printf "%s %s\n" "$MOTTO $(uname -mnor)"
  end
end
