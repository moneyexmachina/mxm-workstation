Reproducible workstation configuration and bootstrap framework for Money Ex Machina.

`mxm-workstation` defines what constitutes a *canonical MXM workstation* and provides the configuration, bootstrap scripts and documentation required to reproduce that environment on any supported machine.

## Purpose

MXM workstations are designed to be:

- reproducible
- machine-independent
- terminal-first
- security-conscious
- aesthetically consistent
- easy to reason about and evolve

`mxm-workstation` achieves this through a small number of clearly separated components covering:

- workstation bootstrap
- system configuration
- dotfiles (managed through chezmoi)
- developer tooling
- desktop and terminal environment
- security hardening
- workstation documentation

A workstation built from `mxm-workstation` satisfies the MXM **workstation contract**.

## Repository Structure

```
bootstrap/      Machine bootstrap scripts
chezmoi/        Declarative home-directory configuration
docs/           Architecture and design decisions
scripts/        Workstation utilities
```

The `chezmoi` directory contains the canonical user configuration for supported applications, including:

- Kitty
- tmux
- Neovim
- Git
- Shell configuration
- Future desktop configuration (Sway)

## Bootstrap Process

The workstation is provisioned in layers.

1. Install a minimal supported operating system.
2. Bootstrap essential tooling.
3. Install and initialise chezmoi.
4. Apply the canonical workstation configuration.
5. Install developer tooling.
6. Verify workstation integrity.

This separates machine provisioning from user configuration while allowing the entire workstation to be recreated from version-controlled sources.

## Design Principles

- **Reproducible by construction**

  A workstation should be rebuildable from a clean operating system installation with minimal manual intervention.

- **Declarative configuration**

  Configuration lives in version control rather than being created interactively.

- **Layered architecture**

  Operating system, bootstrap, user configuration and applications each have clearly defined responsibilities.

- **Machine independence**

  The same repository should configure any supported workstation, independent of hostname or hardware.

- **Terminal-first workflow**

  The command line is the primary interface; graphical applications support rather than define the workflow.

- **Minimal implicit behaviour**

  Every significant workstation decision should be explicit, documented and reproducible.

## Current Scope

Initial development focuses on:

- chezmoi integration
- Kitty configuration
- bootstrap automation
- GitHub authentication
- workstation documentation

Future iterations will extend the workstation to include:

- tmux
- Neovim
- Sway
- development tooling
- security policies
- workstation validation

## License

MIT License. See [LICENSE](LICENSE).

