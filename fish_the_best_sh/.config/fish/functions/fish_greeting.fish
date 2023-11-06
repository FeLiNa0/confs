function fish_greeting
  if [ "$PWD" = "$HOME" ]

    uname -o -n -r

    if [ "$DO_NOT_CLEAR" != true ]
      clear
    end
  end
  
  true
  fish_prompt
  echo
  if command -v exa > /dev/null 2>&1
    exa "$PWD"
  else
    ls "$PWD"
  end
end
