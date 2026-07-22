Reproducible Linux workstation configuration and bootstrap framework for
Money Ex Machina.

`mxm-workstation` defines the canonical MXM workstation environment. It
contains the declarative user configuration, bootstrap specifications,
operational scripts and documentation required to reproduce and maintain that
environment across supported machines.

The repository converts workstation setup from undocumented, interactive
machine state into explicit, version-controlled and recoverable capabilities.

## Purpose

An MXM workstation should be:

- reproducible;
- terminal-first;
- security-conscious;
- operationally transparent;
- consistent across supported machines;
- straightforward to inspect, evolve and rebuild.

`mxm-workstation` provides the source-controlled definition of that
environment.

A workstation configured from this repository implements the MXM
**workstation contract**: the expected tools, configuration, services,
filesystem interfaces and operating conventions required for Money Ex Machina
development and operation.

## Operating model

The workstation separates three kinds of state.

### Declarative workstation configuration

Stable user configuration is stored in this repository and deployed through
chezmoi.

This includes:

- shell configuration;
- Kitty configuration;
- tmux configuration;
- Neovim configuration;
- Sway and Wayland configuration;
- status and notification services;
- systemd user-service definitions;
- reproducible application configuration.

### Machine-level provisioning

Changes requiring elevated privileges are performed explicitly through the
administrative account.

Examples include:

- installing system packages;
- creating directories under `/mnt`;
- changing system-level configuration;
- enabling machine-level capabilities.

These operations are deliberately separated from ordinary user configuration.

### Local identity, secrets and runtime state

Secret-bearing or machine-local state is not committed directly to this
repository.

Examples include:

- OAuth refresh tokens;
- rclone credentials;
- SSH private keys;
- application authentication tokens;
- password-manager state;
- runtime caches and logs.

The repository defines how these facilities are configured and operated, while
their live credentials remain local.

## User and privilege model

The normal workstation account is:

```text
mxm
```

The `mxm` account is used for:

- development;
- terminal and desktop sessions;
- chezmoi application;
- user-level systemd services;
- application configuration;
- user-owned credentials and caches.

Administrative work is performed through:

```text
adminsecure
```

The `adminsecure` account is used only when elevated privileges are required,
including:

- installing packages;
- creating root-owned filesystem structures;
- modifying machine-level configuration;
- performing explicitly authorised system maintenance.

The normal `mxm` account does not have unrestricted `sudo` access.

This creates a clear boundary between routine workstation operation and
privileged machine administration.

## Repository structure

```text
bootstrap/      Bootstrap specifications and package definitions
chezmoi/        Declarative home-directory source state
docs/           Architecture, setup, operation and recovery documentation
scripts/        Explicit workstation provisioning and utility scripts
```

The current repository structure includes:

```text
bootstrap/
├── neovim.md
└── packages.yaml

chezmoi/
├── dot_config/
│   ├── chezmoi/
│   ├── i3status/
│   ├── kitty/
│   ├── mako/
│   ├── nvim/
│   ├── sway/
│   ├── systemd/user/
│   ├── tmux/
│   └── starship.toml
├── dot_zprofile
└── dot_zshrc

docs/
└── google-drive.md

scripts/
├── bootstrap-gdrive-mount
└── bootstrap-gdrive-system
```

## Chezmoi source model

The `chezmoi/` directory is the source state for the normal `mxm` user's home
directory.

Chezmoi naming conventions map source paths to deployed paths.

For example:

```text
chezmoi/dot_config/kitty/kitty.conf
```

is deployed to:

```text
~/.config/kitty/kitty.conf
```

Similarly:

```text
chezmoi/dot_config/systemd/user/rclone-gdrive.service
```

is deployed to:

```text
~/.config/systemd/user/rclone-gdrive.service
```

The shell configuration files:

```text
chezmoi/dot_zprofile
chezmoi/dot_zshrc
```

are deployed to:

```text
~/.zprofile
~/.zshrc
```

Before applying changes, inspect the proposed deployment:

```bash
chezmoi diff
```

Apply the source state with:

```bash
chezmoi apply
```

Inspect managed-state differences with:

```bash
chezmoi status
```

The repository should remain the authority for declarative configuration.
Managed files should normally be changed in the source tree and then deployed
through chezmoi.

## Managed components

### Shell environment

The repository manages:

- Zsh startup configuration;
- login-session configuration;
- Starship prompt configuration;
- terminal-oriented navigation and search behaviour;
- integration with command-line tools such as `fzf`, `fd` and `ripgrep`.

Relevant source files include:

```text
chezmoi/dot_zprofile
chezmoi/dot_zshrc
chezmoi/dot_config/starship.toml
```

### Terminal environment

Kitty provides the primary terminal emulator.

Configuration is stored under:

```text
chezmoi/dot_config/kitty/
```

The workstation also uses tmux for persistent and structured terminal
workspaces:

```text
chezmoi/dot_config/tmux/tmux.conf
```

### Editing environment

Neovim provides the primary text-editing and development environment.

Its configuration is stored under:

```text
chezmoi/dot_config/nvim/
```

The configuration includes:

- plugin management;
- language-server integration;
- development tooling;
- debugging and linting support;
- fuzzy file and content navigation;
- MXM-specific key mappings and utilities;
- Python virtual-environment support.

Additional bootstrap guidance is stored in:

```text
bootstrap/neovim.md
```

### Desktop environment

Sway provides the primary Wayland desktop environment.

Configuration is stored under:

```text
chezmoi/dot_config/sway/
```

This includes:

- the main Sway configuration;
- display-output configuration;
- session-startup commands.

Related desktop components include:

```text
chezmoi/dot_config/i3status/
chezmoi/dot_config/mako/
```

These provide status-bar and notification functionality.

### User services

User-level systemd units are stored under:

```text
chezmoi/dot_config/systemd/user/
```

They are deployed to:

```text
~/.config/systemd/user/
```

and controlled as `mxm` using:

```bash
systemctl --user
```

After changing a user-service definition:

```bash
chezmoi apply
systemctl --user daemon-reload
systemctl --user restart <service>
```

### Google Drive integration

Google Drive is exposed to Linux at:

```text
/mnt/gdrive
```

The mount is provided by rclone and managed through:

```text
rclone-gdrive.service
```

The service definition is stored at:

```text
chezmoi/dot_config/systemd/user/rclone-gdrive.service
```

The integration provides Linux-first management of ordinary files while
retaining Google Drive as the authoritative store.

Google-native Docs, Sheets and Slides remain browser-managed and appear through
the mount as browser-link files.

Provisioning is divided across the privilege boundary:

```text
scripts/bootstrap-gdrive-system
```

prepares the system-owned mount point and is run through the administrative
account.

```text
scripts/bootstrap-gdrive-mount
```

validates and enables the user-level mount and is run as `mxm`.

Full setup, operation and recovery instructions are documented in:

```text
docs/google-drive.md
```

## Bootstrap model

A workstation is provisioned in layers.

### 1. Install a supported operating system

Begin with a minimal supported Linux installation.

Machine-specific requirements such as disk encryption, firmware, networking
and hardware support are handled before applying the user configuration.

### 2. Establish the account boundary

Create or restore:

- the normal `mxm` account;
- the privileged `adminsecure` account;
- the intended access and group-membership policy.

### 3. Install bootstrap dependencies

Install the tools required to retrieve and apply the workstation configuration.

Package requirements are recorded in:

```text
bootstrap/packages.yaml
```

System package installation is performed from the administrative context.

### 4. Initialise the workstation repository

Clone or otherwise retrieve `mxm-workstation`.

Configure chezmoi to use:

```text
mxm-workstation/chezmoi
```

as its source state.

Inspect the proposed changes:

```bash
chezmoi diff
```

Then apply them:

```bash
chezmoi apply
```

### 5. Complete privileged provisioning

Run explicit administrative bootstrap operations for capabilities requiring
system-level access.

Examples include:

- installing packages;
- creating `/mnt/gdrive`;
- enabling machine-level services;
- configuring hardware access.

These operations should not be hidden inside ordinary dotfile application.

### 6. Configure local identity and secrets

Create machine-local authentication state as required, including:

- GitHub authentication;
- SSH identities;
- rclone OAuth configuration;
- password-manager access;
- YubiKey-backed credentials.

Secret-bearing files remain outside the repository unless a separate encrypted
secret-management mechanism is explicitly adopted.

### 7. Enable user services

After applying service definitions:

```bash
systemctl --user daemon-reload
```

Enable an individual service with:

```bash
systemctl --user enable --now <service>
```

Capability-specific bootstrap scripts may perform these operations after
validating their prerequisites.

### 8. Verify operational capabilities

A bootstrap is complete only when the resulting workstation behaviour has been
tested.

Verification should cover, as relevant:

- chezmoi state;
- expected commands;
- terminal and editor behaviour;
- desktop-session startup;
- systemd user services;
- remote access;
- mounted filesystems;
- authentication paths;
- development tooling.

## Current capabilities

The repository currently provides or records configuration for:

- reproducible chezmoi-managed home-directory state;
- Zsh login and interactive-shell behaviour;
- Starship prompt configuration;
- Kitty terminal configuration;
- tmux terminal workspace configuration;
- Neovim development and editing configuration;
- Sway and Wayland desktop configuration;
- status-bar and notification services;
- fuzzy shell history and file discovery;
- systemd-managed user services;
- Google Drive access through `/mnt/gdrive`;
- explicit separation of normal and administrative identities;
- documented capability setup and recovery procedures.

The repository continues to evolve as additional workstation behaviours are
converted from manual machine state into reproducible capabilities.

## Design principles

### Reproducible by construction

A workstation should be recoverable from a clean installation using
version-controlled configuration and documented provisioning steps.

### Declarative where possible

Stable configuration belongs in source control rather than being recreated
through interactive application interfaces.

### Explicit where necessary

Operations requiring elevated privileges, hardware interaction or
authentication should be clearly documented and intentionally executed.

They should not be hidden behind surprising automation.

### Layered responsibility

Operating-system provisioning, user configuration, local identity, secrets and
runtime state have distinct responsibilities and authority boundaries.

### Terminal-first operation

The terminal is the primary operational interface.

Graphical applications supplement the workflow where useful, but should not be
the only means of controlling or understanding the system.

### Least privilege

Routine work is performed as `mxm` without administrative privileges.

Privileged operations are isolated and deliberate.

### Minimal implicit behaviour

Significant workstation behaviour should be:

- visible;
- inspectable;
- documented;
- version-controlled where appropriate;
- testable after deployment.

### Capability-oriented development

Workstation changes should deliver concrete capabilities: something the
workstation can reliably do after the change that it could not do before.

A capability is complete when it is:

- implemented;
- documented;
- deployed;
- operationally tested;
- recoverable on another machine.

## Secrets and runtime state

Do not commit secret-bearing or transient runtime state.

Examples include:

```text
~/.config/rclone/rclone.conf
~/.cache/rclone/
SSH private keys
OAuth refresh tokens
application session tokens
runtime logs
```

Before committing workstation changes, inspect the repository:

```bash
git status --short
git diff
git diff --cached
```

Search for likely accidental credential material where appropriate:

```bash
git grep -nE \
    'client_secret|refresh_token|access_token|private_key' \
    || true
```

Documentation may legitimately mention credential field names. Actual secret
values must not be present.

Generated logs must not be stored in the chezmoi source tree. Files such as:

```text
tmux-client-*.log
tmux-server-*.log
```

are runtime artefacts rather than workstation configuration.

## Development workflow

A typical workstation change follows this sequence:

```text
identify a missing capability
→ implement its source configuration
→ document its authority and operating model
→ inspect with chezmoi diff
→ apply with chezmoi
→ test the deployed behaviour
→ inspect repository changes
→ commit the proven capability
```

Useful commands include:

```bash
git status --short
git diff
chezmoi diff
chezmoi apply
chezmoi status
```

For systemd user-service changes:

```bash
systemd-analyze --user verify \
    ~/.config/systemd/user/<service>

systemctl --user daemon-reload
systemctl --user restart <service>
systemctl --user status <service>
```

## Documentation

Capability documentation is stored under:

```text
docs/
```

Documentation should describe, where relevant:

- purpose;
- architecture;
- authority model;
- source and deployed paths;
- prerequisites;
- initial setup;
- normal operations;
- validation;
- security boundaries;
- recovery procedures.

Current documentation includes:

```text
docs/google-drive.md
```

## Project status

`mxm-workstation` is an actively evolving operational repository.

Its scope expands incrementally as workstation behaviours are converted from
manual or machine-specific state into documented and reproducible
capabilities.

The repository is the authority for the canonical MXM workstation
configuration, subject to the explicit boundaries around machine provisioning,
credentials, secrets and runtime state.

## License

MIT License. See [LICENSE](LICENSE).
