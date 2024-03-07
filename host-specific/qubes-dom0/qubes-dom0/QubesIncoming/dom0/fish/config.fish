alias v vis

if status is-interactive
    # Commands to run in interactive sessions can go here
    echo Mater atrium necessitas

    if command -v starship > /dev/null
        starship init fish | source
    end
end
