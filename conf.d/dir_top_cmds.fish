set -q _dtc_db; or set -g _dtc_db "$HOME/.atuin/data/history.db"
set -g _dtc_sep (printf '\x1f')

# Only suggest commands whose command word is one of these tools. Edit freely.
set -q _dtc_tools; or set -g _dtc_tools npm mvn docker git make gradle yarn pnpm \
    node cargo go kubectl helm terraform python python3 pip pip3 brew pnpm bun deno

# First real command word, skipping any leading VAR=value env assignments
# (e.g. `OVERRIDE_APP=x docker compose up` -> docker).
function _dtc_firsttool
    for w in (string split ' ' -- $argv[1])
        test -n "$w"; or continue
        string match -qr '^[A-Za-z_][A-Za-z0-9_]*=' -- $w; and continue
        echo $w
        return
    end
end

# Recompute + print the top tool-commands for this directory whenever PWD changes.
# ponytail: queries sqlite on every cd; indexed on cwd so it's sub-ms, no cache.
function _dtc_refresh --on-variable PWD
    set -g _dtc_cmds # global + cleared; a bare `set -a` here would be function-local
    status is-interactive; or return
    test -r "$_dtc_db"; or return
    set -l cwd (string replace -a "'" "''" -- $PWD)
    set -l rows (sqlite3 -separator "$_dtc_sep" "$_dtc_db" \
        "SELECT count(*), command FROM history WHERE cwd='$cwd' AND deleted_at IS NULL GROUP BY command ORDER BY 1 DESC LIMIT 200;")
    set -l out
    set -l i 0
    for row in $rows
        # ponytail: a command containing the 0x1f byte would mis-split; nobody types it.
        set -l f (string split -m1 "$_dtc_sep" -- $row)
        contains -- (_dtc_firsttool $f[2]) $_dtc_tools; or continue
        set i (math $i + 1)
        set -ga _dtc_cmds $f[2]
        set -a out (set_color brblack)"$i."(set_color normal)" $f[2] "(set_color -o blue)"($f[1]x)"(set_color normal)
        test $i -ge 9; and break
    end
    test -n "$out"; or return
    printf '%s   ' $out
    echo
end

# Ctrl+1 .. Ctrl+9 -> load that suggestion into the prompt (press Enter to run).
function _dtc_pick
    set -q _dtc_cmds[$argv[1]]; or return
    commandline -r -- $_dtc_cmds[$argv[1]]
    commandline -f repaint
end

# Bindings must be registered via this hook: fish calls it AFTER loading its
# default bindings, so they survive (a `bind` at conf.d load time gets wiped).
function fish_user_key_bindings
    for n in 1 2 3 4 5 6 7 8 9
        bind ctrl-$n "_dtc_pick $n"
    end
end

if status is-interactive
    _dtc_refresh # first prompt (PWD event doesn't fire at startup)
end
