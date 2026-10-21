#!/usr/bin/env fish
# Installs atuin, wires it into fish, and installs this plugin.
# Safe to re-run.

set -l here (dirname (status filename))
set -l plugin_src $here/conf.d/dir_top_cmds.fish
test -f $plugin_src; or begin
    echo "Can't find $plugin_src — run this from the repo." >&2
    exit 1
end

# 1. atuin
if not type -q atuin
    echo "Installing atuin..."
    if type -q brew
        brew install atuin
    else
        curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
    end
end
if not type -q atuin
    echo "atuin isn't on PATH yet — open a new shell and re-run this script." >&2
    exit 1
end

# 2. sqlite3 (needed to read atuin's history db)
type -q sqlite3; or echo "WARNING: sqlite3 not found — install it (macOS ships it; 'apt install sqlite3')." >&2

# 3. wire atuin into fish config (idempotent)
mkdir -p $__fish_config_dir/conf.d
set -l cfg $__fish_config_dir/config.fish
test -f $cfg; or touch $cfg
if not grep -q 'atuin init fish' $cfg
    echo "Adding atuin init to $cfg"
    printf '\nif status is-interactive\n    atuin init fish | source\nend\n' >>$cfg
end

# 4. install the plugin
cp $plugin_src $__fish_config_dir/conf.d/dir_top_cmds.fish

echo ""
echo "Done. Optional: import your existing shell history with  atuin import auto"
echo "Open a new fish shell to activate."
