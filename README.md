# mxm-workstation

Opinionated, reproducible Linux workstation configuration for Money Ex Machina.

`mxm-workstation` defines the user-facing workstation environment used to develop and operate MXM.

It turns workstation setup from undocumented machine state into explicit, version-controlled and recoverable capabilities.

The repository is intentionally opinionated. It describes the environment used by MXM rather than attempting to provide a general-purpose Linux workstation framework.

## Design goals

An MXM workstation should be:

- reproducible;
- terminal-first;
- security-conscious;
- operationally transparent;
- composed from explicit capabilities;
- straightforward to inspect, evolve and rebuild.

The workstation definition is configuration rather than authority.

Knowing the contents of this repository must not grant access to MXM systems, credentials or private data.

## Profile model

Different machines require different subsets of workstation capabilities.

`mxm-workstation` therefore defines composable profiles rather than one universal workstation image.

Current profiles are:

```text
base
desktop
operator
agent-development
```

Example compositions are:

```text
Forge
    = base
    + desktop
    + operator

mxm-factory-agent
    = base
    + agent-development
```

Not every MXM appliance is a workstation, and not every workstation requires every profile.

Profiles describe roles and capabilities rather than particular hostnames.

## Repository structure

```text
.
├── bootstrap/
│   └── neovim.md
├── chezmoi/
│   ├── .chezmoiignore
│   ├── dot_config/
│   │   ├── i3status/
│   │   ├── kitty/
│   │   ├── mako/
│   │   ├── nvim/
│   │   ├── sway/
│   │   ├── systemd/user/
│   │   ├── tmux/
│   │   └── starship.toml
│   ├── dot_zprofile
│   └── dot_zshrc
├── profiles/
│   ├── README.md
│   ├── base/
│   │   └── requirements.yaml
│   ├── desktop/
│   ├── operator/
│   │   ├── requirements.yaml
│   │   └── google-drive/
│   │       ├── README.md
│   │       └── scripts/
│   └── agent-development/
│       └── requirements.yaml
├── CHANGELOG.md
├── LICENSE
└── README.md
```

The exact tree evolves as capabilities are added, but the responsibility boundaries should remain stable.

## Responsibility model

The workstation separates four distinct concerns.

### Workstation contract

Profile requirements describe what must exist for a machine to satisfy a workstation role.

For example:

```text
profiles/base/requirements.yaml
profiles/operator/requirements.yaml
profiles/agent-development/requirements.yaml
```

These files are descriptive contracts.

They are not package-manager input and are not intended to become an alternative provisioning language.

A machine-level provisioning system is responsible for realizing the required capabilities.

For MXM cloud appliances this responsibility currently belongs to `mxm-infra`.

### Declarative user configuration

Stable home-directory configuration is managed through one shared chezmoi source tree:

```text
chezmoi/
```

This includes, where applicable:

- Zsh configuration;
- Starship;
- tmux;
- Neovim;
- Kitty;
- Sway;
- status and notification configuration;
- systemd user services;
- application configuration.

There is deliberately not one independent chezmoi source tree per profile.

### Machine-level provisioning

Operating-system and privileged machine configuration belongs outside ordinary home-directory configuration.

Examples include:

- installing operating-system packages;
- installing external applications;
- creating Unix users;
- configuring login shells;
- creating system-owned filesystem structures;
- installing system services;
- realizing appliance-specific capabilities.

For MXM appliances these operations can be performed declaratively by `mxm-infra`.

Local workstations may use a different realization mechanism.

### Identity, secrets and runtime state

Secret-bearing or transient state is not part of the public workstation configuration.

Examples include:

```text
SSH private keys
OAuth credentials and refresh tokens
GitHub authentication state
OpenBao credentials
Tailscale provisioning credentials
application session tokens
~/.config/rclone/rclone.conf
runtime caches
logs
Git working trees
```

The repository may document how such facilities are used, but it must not contain their live authority.

## Profile requirements

### `base`

`base` defines the common terminal development environment.

It currently includes capabilities around:

- Git;
- shell operation;
- Zsh;
- tmux;
- Neovim;
- `ripgrep`;
- `fd`;
- `fzf`;
- JSON and filesystem inspection;
- Neovim language/tooling dependencies;
- chezmoi;
- Starship.

Machines using other workstation profiles normally also select `base`.

### `desktop`

`desktop` contains configuration specific to a graphical local workstation.

This includes configuration such as:

```text
Kitty
Sway
i3status
Mako
```

Desktop configuration is excluded from machines that do not select the `desktop` profile.

### `operator`

`operator` contains capabilities used from the trusted human operator workstation.

Current operator functionality includes Google Drive integration through `rclone`.

Google Drive documentation and bootstrap scripts live under:

```text
profiles/operator/google-drive/
```

Operator capabilities must not be assumed to belong on lower-authority MXM appliances.

### `agent-development`

`agent-development` defines the environment used for interactive and bounded AI-assisted software development.

Current requirements include capabilities around:

- GitHub CLI;
- Poetry;
- Droid;
- ShellCheck;
- remote Kitty terminal compatibility;
- remote development tooling;
- OSC-52 clipboard integration.

The intended remote-terminal topology is:

```text
Kitty on the local workstation
        ↓
OpenSSH
        ↓
tmux on the remote workstation
```

OSC-52 allows tmux on the remote workstation to write to the clipboard owned by the local Kitty terminal.

Pasting in the opposite direction uses ordinary terminal paste through the SSH session.

Nested tmux sessions are not currently part of the workstation contract.

## Profile selection

The selected workstation profiles are instance-specific state.

They are provided to chezmoi through its local configuration, for example:

```toml
sourceDir = "/home/mxm/mxm-workstation/chezmoi"

[data]
workstationProfiles = ["base", "agent-development"]
```

A different machine might use:

```toml
[data]
workstationProfiles = ["base", "desktop", "operator"]
```

The repository does not hard-code profile selection based on hostname.

`chezmoi/.chezmoiignore` uses the selected profiles to decide which parts of the shared source state should be materialized.

For example, desktop configuration is not applied to a headless agent-development workstation.

## Chezmoi source model

The `chezmoi/` directory is the authoritative source state for managed home-directory configuration.

For example:

```text
chezmoi/dot_config/tmux/tmux.conf
```

is deployed to:

```text
~/.config/tmux/tmux.conf
```

and:

```text
chezmoi/dot_zshrc
```

is deployed to:

```text
~/.zshrc
```

Inspect proposed changes with:

```bash
chezmoi diff
```

Apply them with:

```bash
chezmoi apply
```

Inspect remaining differences with:

```bash
chezmoi status
```

Managed configuration should normally be changed in the source tree and then applied rather than edited independently in the target location.

## Managed terminal environment

### Shell

The repository manages:

- Zsh login and interactive-shell behaviour;
- Starship prompt configuration;
- fuzzy command-history search;
- terminal-oriented navigation and search tooling.

### tmux

tmux provides persistent and structured terminal workspaces.

Configuration is stored at:

```text
chezmoi/dot_config/tmux/tmux.conf
```

The configuration includes OSC-52 clipboard support suitable for direct:

```text
Kitty → SSH → tmux
```

sessions.

### Neovim

Neovim is the primary development editor.

Configuration lives under:

```text
chezmoi/dot_config/nvim/
```

It includes support for:

- language servers;
- development tooling;
- debugging;
- linting;
- Git integration;
- fuzzy navigation;
- Python virtual environments;
- MXM-specific mappings and editing behaviour.

Additional bootstrap notes are stored in:

```text
bootstrap/neovim.md
```

## Google Drive

Google Drive is an `operator` capability.

It is exposed to Linux through:

```text
/mnt/gdrive
```

using `rclone` and a systemd user service.

The implementation and operating instructions live under:

```text
profiles/operator/google-drive/
```

Live Google OAuth credentials and the resulting `rclone.conf` remain machine-local and are never committed.

## Realization

`mxm-workstation` describes the workstation contract and contains the user configuration required to realize it.

The mechanism that constructs a particular machine remains separate.

For example:

```text
mxm-workstation
    defines:
        base + agent-development

mxm-infra
    realizes:
        mxm-factory-agent
```

A typical disposable appliance flow is:

```text
create machine
    ↓
install system requirements
    ↓
install required external applications
    ↓
retrieve a pinned mxm-workstation revision
    ↓
provide machine-local profile selection
    ↓
chezmoi apply
    ↓
usable workstation
```

This separation avoids turning the workstation requirements into a second infrastructure provisioning system.

## Security model

The repository follows an open-resistant configuration model.

The workstation definition may reveal:

- which tools MXM uses;
- shell and editor preferences;
- filesystem conventions;
- configuration structure;
- security architecture;
- operational patterns.

Possession of that information must not grant authority.

Authority-bearing state remains separate.

Before committing changes, inspect the repository:

```bash
git status --short
git diff
git diff --cached
```

Search for likely accidental credentials where appropriate:

```bash
git grep -nEi \
  'client_secret|refresh_token|access_token|private.?key|api.?key|password' \
  || true
```

Matches in documentation may be legitimate. Actual credential values must never be committed.

## Development workflow

A normal workstation change follows:

```text
identify a missing capability
        ↓
decide which profile owns it
        ↓
update the workstation contract
        ↓
implement declarative configuration
        ↓
realize any machine-level prerequisites
        ↓
chezmoi diff
        ↓
chezmoi apply
        ↓
test the capability
        ↓
commit the proven state
```

Prefer deterministic mechanisms whenever a deterministic implementation exists.

Agents may help design or implement workstation changes, but stable workstation behaviour should ultimately be represented by explicit configuration, scripts and tests rather than requiring an agent to reconstruct the intended state.

## Project status

`mxm-workstation` is an actively evolving operational repository.

Its scope expands as workstation behaviour is converted from machine-specific or manual state into explicit, composable and recoverable capabilities.

It is currently used as the workstation contract and configuration source for MXM development environments.

## License

MIT License. See [LICENSE](LICENSE).
