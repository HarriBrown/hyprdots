if status is-interactive
    # Commands to run in interactive sessions can go here
end

set -Ux fish_user_paths $fish_user_paths ~/.config/scripts

fastfetch

set PATH $PATH ~/.local/bin

