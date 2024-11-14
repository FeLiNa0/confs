function fish_greeting
  if [ "$PWD" = "$HOME" ]
    printf "%s %s\n" "Mater artium necessitas"
    uname -mnors
  end
  # fish_prompt
  # echo
  # if command -v exa > /dev/null 2>&1
  #   exa "$PWD"
  # else
  #   ls "$PWD"
  # end
end
