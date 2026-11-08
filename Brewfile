# Homebrew bundle for macOS setup.
# Install:  brew bundle --file=Brewfile
# Check:    brew bundle check --file=Brewfile
# Drift:    brew bundle cleanup --file=Brewfile   (lists installed items not listed here)
#
# Pruned from real usage (Claude Code transcripts + macOS app last-used dates), Nov 2026.

# --- Taps -------------------------------------------------------------------
# Homebrew 7 refuses to load formulae and casks from non-official taps unless they are trusted.
# `trusted:` below lists exactly what is trusted. Your own taps are trusted whole.
# The private taps need SSH access to GitHub first (gh auth login). If brew bundle fails on them,
# tap them by hand first:  brew tap scott/services git@github.com:citadelgrad/homebrew-services.git
tap "dicklesworthstone/tap", trusted: { formulae: ["ubs", "cass", "cm", "xf"] }
tap "marsanne/cask", trusted: { casks: ["cork"] }
tap "validatedev/tap", trusted: { casks: ["brew-services-manager"] }
tap "scott/services", "git@github.com:citadelgrad/homebrew-services.git", trusted: true   # private
tap "scott/local", "git@github.com:citadelgrad/homebrew-local.git", trusted: true         # private

# --- Shell, prompt, core CLI ------------------------------------------------
brew "fish"
brew "starship"
brew "atuin"
brew "direnv"
brew "tmux"
brew "uutils-coreutils"   # aliases in fish config; do not put on PATH
brew "bat"
brew "lsd"
brew "fd"
brew "ripgrep"
brew "fzf"
brew "dust"
brew "procs"
brew "jq"
brew "tree"
brew "wget"
brew "pv"
brew "rename"
brew "gum"
brew "watchman"
brew "ast-grep"
brew "pandoc"
brew "poppler"
brew "displayplacer"
brew "duti"
brew "pam-reattach"

# --- Git and secrets --------------------------------------------------------
brew "git"
brew "git-lfs"
brew "git-delta"
brew "git-filter-repo"
brew "gh"
brew "gitleaks"
brew "sops"
brew "age"
brew "doppler"
brew "mkcert"

# --- Dotfiles and config management -----------------------------------------
brew "chezmoi"
brew "ansible"

# --- Languages and package managers -----------------------------------------
brew "node@24"
brew "yarn"
brew "python@3.13"
brew "uv"                 # manages Python versions and venvs (replaces pyenv)
brew "poetry"
brew "pdm"
brew "rust"
brew "golangci-lint"
# bun: installed by its own installer (~/.bun)

# --- Lint, format, quality --------------------------------------------------
brew "pre-commit"
brew "ruff"
brew "biome"
brew "shfmt"
brew "actionlint"
brew "semgrep"

# --- Cloud and infra --------------------------------------------------------
brew "awscli"
brew "terraform"
brew "hcloud"
brew "colima"
brew "docker-compose"
brew "redis"
cask "gcloud-cli"
cask "orbstack"

# --- AI and agent tools -----------------------------------------------------
brew "beads"
brew "rtk"
brew "pi-coding-agent"
brew "opencode"
brew "portless"
cask "codex"
cask "codexbar"
cask "antigravity"
cask "antigravity-cli"

# --- Media ------------------------------------------------------------------
brew "ffmpeg"
brew "yt-dlp"

# --- Image libraries (Python/PIL) -------------------------------------------
brew "zlib"
brew "libtiff"
brew "libjpeg"
brew "webp"
brew "little-cms2"

# --- Browser ----------------------------------------------------------------
cask "microsoft-edge"

# --- Editors and terminals --------------------------------------------------
cask "zed"
cask "ghostty"
cask "wezterm"
cask "font-symbols-only-nerd-font"
cask "temurin"

# --- Productivity and system utilities --------------------------------------
cask "raycast"
cask "maccy"
cask "itsycal"
cask "espanso"
cask "cleanshot"
cask "caffeine"
cask "fluidvoice"
cask "slack"
cask "zoom"
cask "vuescan"
cask "marsanne/cask/cork"
cask "validatedev/tap/brew-services-manager"

# --- Services (private taps above) -----------------------------------------
# Formulae are thin launchd wrappers around code that lives outside Homebrew.
# Installing them does NOT start them. Services start EMPTY on a new computer (old data
# is not migrated). Put the code in place first (see "Services" in README.md), then:
#   brew services start <name>
# Busy on the old computer:
brew "scott/services/lightrag"               # clone HKUDS/LightRAG; venv at ~/services/lightrag/.venv
brew "scott/services/hermes-backup-daily"    # useless until Hermes is installed (~/.local/bin/hermes-backup)
brew "scott/services/hermes-backup-weekly"
brew "scott/local/paperclip"                 # clone paperclipai/paperclip to ~/paperclip
# Nearly idle, kept by choice:
brew "scott/services/zeno-backend"           # /Volumes/qwiizlab/projects/zeno (copied with projects)
brew "scott/services/zeno-frontend"
brew "scott/services/nixonnote"
brew "scott/services/skill-cabinet"          # npm package under ~/.local/lib/node_modules
# beads-dashboard: off. Its formula watches ~/gt/baseball, and ~/gt is not migrated.
# brew "scott/services/beads-dashboard"
# Not migrated: redis (idle), mission-control, hermes-webapi, hermes-workspace.
