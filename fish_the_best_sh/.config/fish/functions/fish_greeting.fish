function fish_greeting
  if [ "$PWD" = "$HOME" ]
    printf "%s %s\n" "Mater artium necessitas $(uname -mnor)"
  end
end
