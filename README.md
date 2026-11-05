# Debian LXC – Zsh Environment

Installs and configures a ready-to-use Zsh environment for Debian Linux containers running in Proxmox.

## What's included

- **Zsh** – Modern shell.
- **Oh My Zsh** – Zsh configuration framework.
- **Powerlevel10k** – Custom terminal prompt with Git information.
- **Git plugin** – Git aliases and shortcuts.
- **Z plugin** – Quick navigation between directories.
- **Extract** – Universal archive extraction command.
- **Common Aliases** – Useful everyday shortcuts.
- **Colored Man Pages** – Improved manual pages.
- **History Substring Search** – Search command history.
- **Zsh Autosuggestions** – Suggest commands based on history.
- **Zsh Syntax Highlighting** – Highlight commands as you type.

## Requirements

- Debian Linux (Proxmox LXC).
- Root access.
- Internet connectivity.
- Windows Terminal or another compatible terminal (recommended).

## Installation

Make the installation script executable:

```bash
chmod +x install-zsh.sh
```

Run it as root:

```bash
./install-zsh.sh
```

Alternatively:

```bash
bash install-zsh.sh
```

## First startup

Start Zsh:

```bash
exec zsh
```

Configure Powerlevel10k:

```bash
p10k configure
```

## Font configuration

For proper Powerlevel10k icons and symbols, install **MesloLGS NF** on your local computer and configure your terminal to use it.

The font is installed on the client machine, not inside the LXC.

## Configuration

| File / Directory | Purpose |
|---|---|
| `/root/.zshrc` | Main Zsh configuration |
| `/root/.p10k.zsh` | Powerlevel10k configuration |
| `/root/.oh-my-zsh/` | Oh My Zsh installation |
| `/root/.oh-my-zsh/custom/plugins/` | Additional plugins |
| `/root/.oh-my-zsh/custom/themes/` | Additional themes |

The installation script backs up an existing `.zshrc` before creating its managed configuration. Existing managed configurations are preserved on subsequent runs.

## Notes

- Intended for Debian containers running as root.
- Does not modify the Proxmox host.
- Does not install additional software on the Windows client.
- Requires an internet connection to download themes and plugins.
