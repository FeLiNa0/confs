function fish_greeting
  if [ "$PWD" = "$HOME" ]

    uname -a

    if [ "$DO_NOT_CLEAR" != true ]
      clear
    end

    if command -v screenfetch > /dev/null 2>&1
      if command -v screenfetch-cached > /dev/null 2>&1
        screenfetch-cached
      else
        screenfetch
      end
    else if command -v neofetch > /dev/null 2>&1
      if command -v neofetch-cached > /dev/null 2>&1
        neofetch-cached
      else
        neofetch
      end
    end
    
    echo

    # echo (curl https://raw.githubusercontent.com/asdf-vm/asdf/master/ballad-of-asdf.md)
  else
    true
    fish_prompt
    echo
    if command -v exa > /dev/null 2>&1
      exa "$PWD"
    else
      ls "$PWD"
    end
  end
  
  echo

  if command -v fortune > /dev/null 2>&1
    fortune
  else
    echo FOTD: Create something beautiful.
    echo FOTY: Create something profitable.
  end
end
