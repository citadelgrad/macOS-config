# Homebrew bundle for macOS setup.
# Install:  brew bundle --file=Brewfile
# Check:    brew bundle check --file=Brewfile
# Drift:    brew bundle cleanup --file=Brewfile   (lists installed items not listed here)
#
# Pruned from real usage (Claude Code transcripts + macOS app last-used dates), Nov 2026.

# --- Taps -------------------------------------------------------------------
tap "dicklesworthstone/tap"
tap "marsanne/cask"
tap "validatedev/tap"

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
brew "python@3.12"
brew "python@3.13"
brew "poetry"
brew "pdm"
brew "rust"
brew "golangci-lint"
# uv, bun: installed by their own installers (see roles/ai-tools)

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
brew "wireguard-tools"
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
brew "herdr"
brew "portless"
brew "dicklesworthstone/tap/ubs"
brew "dicklesworthstone/tap/cass"
brew "dicklesworthstone/tap/cm"
brew "dicklesworthstone/tap/xf"
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
cask "karabiner-elements"
cask "keepassxc"
cask "keka"
cask "cleanshot"
cask "caffeine"
cask "fluidvoice"
cask "slack"
cask "zoom"
cask "vuescan"
cask "postgres-app"       # provides psql, pg_ctl
cask "marsanne/cask/cork"
cask "validatedev/tap/brew-services-manager"
cask "memory-cleaner"
cask "micro-snitch"

# --- Services (scott/services, scott/local taps) ----------------------------
# Pending usage review. Add taps + formulae here once chosen.
