![alias-motd showing a table of aliases when a new terminal opens](docs/alias-motd-screenshot.webp)
### Install

1. Download **alias-motd.sh** into your **Downloads** folder (most browsers save there by default).
2. Open a terminal, paste this block and press **Enter**:

bash

```bash
if [[ -f ~/Downloads/alias-motd.sh ]]; then
    mkdir -p ~/.local/bin
    command mv -f ~/Downloads/alias-motd.sh ~/.local/bin/alias-motd.sh
    chmod +x ~/.local/bin/alias-motd.sh
    command grep -qF 'alias-motd.sh' ~/.bashrc 2>/dev/null || command cat >> ~/.bashrc <<'ALIAS_MOTD_EOF'

# Show my aliases whenever a new terminal opens
if [[ $- == *i* && -x $HOME/.local/bin/alias-motd.sh ]]; then
    "$HOME/.local/bin/alias-motd.sh"
fi
ALIAS_MOTD_EOF
    ~/.local/bin/alias-motd.sh
    echo "alias-motd installed. Open a new terminal to see it."
else
    echo "Couldn't find ~/Downloads/alias-motd.sh. Download it to your Downloads folder, then paste this again."
fi
```

Your alias table prints straight away, and from then on it shows in every new terminal. To update later, download the new version and paste the same block again; it won’t add a second copy of the hook to `~/.bashrc`.

### Adding descriptions

In `~/.bash_aliases`, put a `##` comment directly above an alias:

bash

```bash
## Show all files including hidden ones
alias la='ls -A'
```

Aliases without a `##` line above them still appear in the table, with a blank description.

### Uninstall

bash

```bash
rm -f ~/.local/bin/alias-motd.sh
sed -i '/# Show my aliases whenever a new terminal opens/,/^fi$/d' ~/.bashrc
```