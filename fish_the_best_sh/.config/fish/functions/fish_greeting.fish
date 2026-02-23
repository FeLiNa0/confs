function fish_greeting
  # set MOTTO "Mater artium necessitas"
  set MOTTO "Crescit Eundo"
  if [ "$PWD" = "$HOME" ]
    printf "%s %s\n" "$MOTTO $(uname -mnor)"
  end
end
