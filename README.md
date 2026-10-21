# fish-shell-commands-in-directory

A [fish](https://fishshell.com) extension that prints the commands you run most
often **in the current directory** above the prompt, and lets you re-run one with
`Ctrl`+a number.

```
1. npm run build (42x)   2. npm test (31x)   3. docker compose up (12x)
~/code/myapp main
>
```

Press `Ctrl`+`1` to drop `npm run build` onto the prompt, then `Enter`.

It reads its data from [atuin](https://atuin.sh)'s local history database — atuin
already records every command with the directory it ran in, so this is just a
query plus a key binding. No daemon, no extra history file.

## Requirements

- **fish** 4.0+ (uses the `bind ctrl-1` named-key syntax)
- **atuin**, set up and recording history (`atuin init fish` in your `config.fish`)
- **sqlite3** (ships with macOS; `apt install sqlite3` on Debian/Ubuntu)

## Install

### With [Fisher](https://github.com/jorgebucaran/fisher)

```fish
fisher install <your-github-user>/fish-shell-commands-in-directory
```

### Manual

Copy the one file into your fish config and start a new shell:

```fish
cp conf.d/dir_top_cmds.fish ~/.config/fish/conf.d/
exec fish
```

The suggestion line appears whenever you `cd` into a directory that has history.

## Usage

- A line of the most-used commands for the current directory is printed above the
  prompt on `cd` and at shell start.
- **`Ctrl`+`1` … `Ctrl`+`9`** loads suggestion _N_ onto the command line. Press
  `Enter` to run it (nothing runs automatically).

## Configuration

Set these before the plugin loads (e.g. near the top of `config.fish`):

| Variable | Default | Meaning |
|----------|---------|---------|
| `_dtc_tools` | `npm mvn docker git make gradle yarn pnpm node cargo go kubectl helm terraform python pip brew bun deno` | Only commands whose **command word** is in this list are suggested. Leading `VAR=value` env assignments are skipped first, so `OVERRIDE_APP=x docker compose up` matches `docker`. Set it to the tools you care about. |
| `_dtc_limit` | `3` | How many suggestions to show. Pickable via `Ctrl`+number up to 9. |
| `_dtc_db` | `~/.atuin/data/history.db` | Path to atuin's sqlite history database. |

Example — suggest only build tools:

```fish
set -g _dtc_tools npm mvn docker make
```

## Ctrl+number and your terminal

`Ctrl`+`<digit>` is only delivered to the shell as a distinct key when the
terminal speaks the [kitty keyboard
protocol](https://sw.kovidgoyal.net/kitty/keyboard-protocol/). In practice:

- **Works:** kitty, ghostty, WezTerm, foot, recent Alacritty — with fish 4.x.
- **May not work:** older terminals, and some embedded terminals (e.g. VS Code's)
  that don't implement the protocol — `Ctrl`+`1` sends nothing distinct there.

To see what your terminal actually sends, run `fish_key_reader --verbose`, press
`Ctrl`+`1`, then `Ctrl`+`C`. If it reports no distinct sequence, your terminal
can't bind `Ctrl`+digit; rebind to keys it does send by editing the
`fish_user_key_bindings` block in `conf.d/dir_top_cmds.fish`.

## Notes

- Querying sqlite on every `cd` is sub-millisecond — the history table is indexed
  on `cwd`, so there's no caching layer.
- A command containing a raw `0x1f` byte would mis-parse. Nobody types one.

## License

MIT
