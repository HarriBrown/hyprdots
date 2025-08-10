if status is-interactive
    # Commands to run in interactive sessions can go here
end

set -Ux fish_user_paths $fish_user_paths ~/.config/scripts

set distro (grep '^NAME=' /etc/os-release | cut -d '=' -f2 | tr -d '"')
echo "$distro [Version 10.0.19045.4529]"
echo "(c) GNU/Linux Corporation. All rights reserved."
echo ""


# Created by `pipx` on 2025-02-20 15:01:21
set PATH $PATH ~/.local/bin

