# Workstation profiles

`mxm-workstation` defines reusable workstation capabilities rather than
machine-specific configurations.

A workstation is composed from a baseline environment plus zero or more
workstation profiles.

Profiles describe roles and capabilities, not host identities. Configuration
must therefore not depend directly on hostnames such as `forge` or
`mxm-factory-agent`.

## Profiles

### `base`

The common terminal-first MXM working environment.

Examples include:

- shell configuration;
- tmux;
- Neovim;
- Starship;
- Git;
- command-line navigation and search tools.

### `desktop`

Capabilities required for a graphical MXM workstation.

Examples include:

- Kitty;
- Sway;
- i3status;
- Mako;
- graphical session configuration.

### `operator`

Capabilities required for an MXM operator workstation.

These are conveniences or interfaces used by the human operator and do not
grant MXM security authority.

Google Drive integration is currently an operator-workstation capability.

### `agent-development`

Capabilities required for interactive human-agent software development.

Examples include:

- remote-terminal compatibility;
- tmux/clipboard ergonomics;
- agent development tools;
- configuration required for interactive Droid use.

## Composition

An appliance may consume any appropriate set of profiles.

For example:

```text
Forge
    base
    + desktop
    + operator

mxm-factory-agent
    base
    + agent-development
```

Not every MXM appliance is an MXM workstation.

For example, an appliance whose only purpose is to run a service need not
consume any workstation profile.

## Responsibility boundary

`mxm-workstation` owns the desired user-facing workstation environment.

It may declare software requirements needed to provide those capabilities, but
machine-level realization of those requirements belongs to appliance
provisioning.

Profiles do not define:

- appliance construction;
- local Unix-account creation;
- security authority;
- credentials or secrets;
- network-security policy;
- MXM logical identities.

Chezmoi remains the single authority for MXM-managed home-directory
configuration.
