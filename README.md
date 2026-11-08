# macOS Configuration

Ansible playbook for automated macOS setup on Apple Silicon Macs. Sets up a complete development environment with modern CLI tools, applications, and shell configuration.

## Quick Start

```bash
# Clone the repo
git clone git@github.com:citadelgrad/macOS-config.git
cd macOS-config

# Run bootstrap (installs Xcode CLI tools, Homebrew, Ansible, then runs playbook)
./bootstrap.sh
```

The bootstrap script will prompt for your password (required for some installations).

## What Gets Installed

All Homebrew packages (taps, formulae, casks, fonts) are listed in the [`Brewfile`](Brewfile).
It holds only tools in active use. Usage data came from Claude Code transcripts and macOS app last-used dates (Nov 2026).

```bash
brew bundle --file=Brewfile            # install everything
brew bundle check --file=Brewfile      # show what is missing
brew bundle cleanup --file=Brewfile    # list installed items not in the Brewfile
brew bundle dump --force --file=Brewfile   # regenerate from this machine (then prune by hand)
```

Ansible runs `brew bundle` in `roles/homebrew`. Non-Homebrew setup stays in Ansible:
`uv`, `ty`, `dcg` (roles/ai-tools), pip config (roles/python), oh-my-zsh (roles/zsh).
Shell and app dotfiles (fish, wezterm, git, uv, pip) are managed by chezmoi under `home/`.

## Services

Services come from two private taps (`scott/services`, `scott/local`), hosted at
`citadelgrad/homebrew-services` and `citadelgrad/homebrew-local`. Each formula is a launchd
wrapper around code that lives outside Homebrew, so `brew bundle` installs the wrapper but does
not start it. The new computer needs SSH access to GitHub first.

**Most services start empty.** Their old data is not migrated (decision: Nov 2026). Exceptions: `~/.hermes` (with lightrag inside it) is copied, and the Graphiti memory graph is exported with `graphiti-migrate.sh`. Before you run
`brew services start <name>`, put the code in place:

| Service | Code the wrapper expects | How to get it |
|---------|--------------------------|---------------|
| lightrag | `~/services/lightrag/.venv/bin/lightrag-server` | Comes with `~/.hermes` (the `hermes` section of `copy.sh`). `~/services` is a link into the drive. Stop lightrag before the final copy |
| paperclip | `~/paperclip/server/node_modules/.bin/tsx` | Clone `https://github.com/paperclipai/paperclip` to `~/paperclip`, install dependencies |
| zeno-backend, zeno-frontend | `/Volumes/qwiizlab/projects/zeno` | Comes with the `projects` section of `copy.sh` (or clone `citadelgrad/zeno`) |
| beads-dashboard | not installed | Off by choice. Its formula watches `~/gt/baseball`, and `~/gt` is not migrated |
| skill-cabinet | `~/.local/lib/node_modules/skill-cabinet` | Install the npm package under `~/.local` |
| nixonnote | `~/Library/Application Support/NixonNote` | Created on first start |
| hermes-backup-daily/weekly | `~/.local/bin/hermes-backup` | `~/.hermes` is copied, but `~/.local` is not (it is in `services-data`). Copy that one script, or reinstall Hermes, before you start these |

Port assignments are in `home/dot_config/ports/ports.yaml`.

## Project Structure

```
macOS-config/
├── Brewfile              # All Homebrew packages
├── bootstrap.sh          # Initial setup script
├── local.yml             # Main playbook
├── hosts                 # Inventory (localhost)
├── requirements.yml      # Ansible Galaxy dependencies
├── home/                 # chezmoi source (dotfiles)
└── roles/
    ├── homebrew/         # brew update + brew bundle
    ├── common/           # Non-Homebrew common setup
    ├── python/           # pip config
    ├── zsh/              # oh-my-zsh
    └── ai-tools/         # uv, ty, dcg, git, package-age config
```

## Running Individual Roles

```bash
ansible-playbook local.yml -K --tags homebrew   # just Homebrew packages
ansible-playbook local.yml -K --tags python
ansible-playbook local.yml -K --tags zsh
```

## Customization

### Adding or removing applications

Edit the `Brewfile`. Add a line such as `brew "my-tool"` or `cask "my-app"`, then run `brew bundle --file=Brewfile`.

## Requirements

- macOS 13.0 (Ventura) or newer
- Apple Silicon (M1/M2/M3/M4) or Intel Mac
- Internet connection

## Notes

### uutils-coreutils

The playbook installs `uutils-coreutils`, a Rust rewrite of GNU coreutils. The shell config uses aliases (`tail → uu-tail`) instead of PATH changes so the system `readlink` stays first.

## Troubleshooting

**Ansible "module not found" errors**

Run: `ansible-galaxy collection install -r requirements.yml`

**Permission denied during bootstrap**

The `-K` flag prompts for sudo password. Some casks require admin rights.
