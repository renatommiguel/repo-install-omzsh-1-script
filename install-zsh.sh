
#!/usr/bin/env bash
set -Eeuo pipefail

# ==================================================
# Debian LXC - Zsh + Oh My Zsh + Powerlevel10k
# Run as root
# ==================================================

if [[ "$EUID" -ne 0 ]]; then
    echo "Error: Run this script as root." >&2
    exit 1
fi

ROOT_HOME="$(getent passwd root | cut -d: -f6)"

if [[ -z "$ROOT_HOME" || ! -d "$ROOT_HOME" ]]; then
    echo "Error: Cannot determine root's home directory." >&2
    exit 1
fi

export USER="root"
export HOME="$ROOT_HOME"

OMZ="$HOME/.oh-my-zsh"
CUSTOM="$OMZ/custom"
CUSTOM_PLUGINS="$CUSTOM/plugins"
CUSTOM_THEMES="$CUSTOM/themes"

echo "=== Installing dependencies ==="

apt-get update

DEBIAN_FRONTEND=noninteractive apt-get install -y \
    zsh \
    git \
    curl \
    ca-certificates \
    passwd

ZSH_PATH="$(command -v zsh)"

# ==================================================
# 1. Install Oh My Zsh
# ==================================================

echo "=== Installing Oh My Zsh ==="

if [[ ! -f "$OMZ/oh-my-zsh.sh" ]]; then

    if [[ -e "$OMZ" ]]; then
        echo "Error: Incomplete Oh My Zsh directory: $OMZ"
        exit 1
    fi

    INSTALLER="$(mktemp)"
    trap 'rm -f "$INSTALLER"' EXIT

    curl -fsSL \
        https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh \
        -o "$INSTALLER"

    RUNZSH=no CHSH=no sh "$INSTALLER" --unattended

else
    echo "Oh My Zsh already installed."
fi

mkdir -p "$CUSTOM_PLUGINS" "$CUSTOM_THEMES"

# ==================================================
# 2. Clone themes and plugins
# ==================================================

install_repo() {
    local name="$1"
    local url="$2"
    local destination="$3"

    if [[ -d "$destination/.git" ]]; then
        echo "$name already installed."
    elif [[ -e "$destination" ]]; then
        echo "Error: $destination exists but is not a Git repository."
        exit 1
    else
        echo "Installing $name..."
        git clone --depth=1 "$url" "$destination"
    fi
}

echo "=== Installing Powerlevel10k ==="

install_repo \
    "Powerlevel10k" \
    "https://github.com/romkatv/powerlevel10k.git" \
    "$CUSTOM_THEMES/powerlevel10k"

echo "=== Installing external plugins ==="

install_repo \
    "Zsh Autosuggestions" \
    "https://github.com/zsh-users/zsh-autosuggestions.git" \
    "$CUSTOM_PLUGINS/zsh-autosuggestions"

install_repo \
    "Zsh Syntax Highlighting" \
    "https://github.com/zsh-users/zsh-syntax-highlighting.git" \
    "$CUSTOM_PLUGINS/zsh-syntax-highlighting"

# ==================================================
# 3. Configure .zshrc
# ==================================================

MARKER="# Debian LXC Zsh configuration"

if [[ ! -f "$HOME/.zshrc" ]] || \
   ! grep -Fq "$MARKER" "$HOME/.zshrc"; then

    if [[ -f "$HOME/.zshrc" ]]; then
        BACKUP="$HOME/.zshrc.backup.$(date +%Y%m%d-%H%M%S)"
        cp -a "$HOME/.zshrc" "$BACKUP"
        echo "Previous configuration backed up to $BACKUP"
    fi

    cat > "$HOME/.zshrc" <<'EOF'
# Debian LXC Zsh configuration

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM="$ZSH/custom"

# Theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Autosuggestions appearance
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

# History configuration
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
HIST_STAMPS="yyyy-mm-dd"

setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt SHARE_HISTORY
setopt AUTO_CD
setopt INTERACTIVE_COMMENTS

# Plugins
plugins=(
    git
    z
    extract
    colored-man-pages
    common-aliases
    history-substring-search

    # External plugins
    zsh-autosuggestions
    zsh-syntax-highlighting
)

# Initialize Oh My Zsh
# Keep syntax highlighting last in the plugin list.
source "$ZSH/oh-my-zsh.sh"

EOF

else
    echo "Existing managed .zshrc found. Keeping it."
fi

# ==================================================
# 4. Configure default shell
# ==================================================

echo "=== Configuring default shell ==="

if ! grep -Fxq "$ZSH_PATH" /etc/shells; then
    echo "$ZSH_PATH" >> /etc/shells
fi

CURRENT_SHELL="$(getent passwd root | cut -d: -f7)"

if [[ "$CURRENT_SHELL" != "$ZSH_PATH" ]]; then
    chsh -s "$ZSH_PATH" root
fi

# ==================================================
# 5. Finish
# ==================================================

echo
echo "============================================"
echo " Zsh environment successfully installed!"
echo "============================================"
echo
echo "Shell:       $ZSH_PATH"
echo "Oh My Zsh:   $OMZ"
echo "Theme:       Powerlevel10k"
echo "Plugins:     Git, Z, Extract, Autosuggestions,"
echo "             Syntax Highlighting and more"
echo
echo "Run now:     exec zsh"
echo "Configure:   p10k configure"
echo
echo "============================================"

