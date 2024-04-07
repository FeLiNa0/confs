function fish_greeting
  if [ "$PWD" = "$HOME" ]
    uname -o -n -r
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
