function fish_greeting
  if [ "$PWD" = "$HOME" ]
    printf "%s %s\n" "Mater artium necessitas" (uname -o -n -r)
  end
  # fish_prompt
  # echo
  # if command -v exa > /dev/null 2>&1
  #   exa "$PWD"
  # else
  #   ls "$PWD"
  # end
end
