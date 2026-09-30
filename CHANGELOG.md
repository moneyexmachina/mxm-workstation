All notable changes to this project will be documented in this file.

This project follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and uses semantic versioning for tagged workstation releases.

## [Unreleased]

### Added

#### Workstation profiles

- Added composable workstation profiles:
  - `base`;
  - `desktop`;
  - `operator`;
  - `agent-development`.
- Added `profiles/README.md` documenting the profile model.
- Added profile-specific `requirements.yaml` files describing the capabilities and applications required by each role.
- Defined example workstation compositions:
  - Forge as `base + desktop + operator`;
  - `mxm-factory-agent` as `base + agent-development`.
- Defined requirements as workstation contracts rather than package-manager or provisioning input.

#### Declarative workstation configuration

- Added a shared chezmoi source state for MXM workstation configuration.
- Added Zsh login and interactive-shell configuration.
- Added Starship prompt configuration.
- Added tmux workspace configuration.
- Added Neovim configuration based on Kickstart.nvim, including:
  - language-server integration;
  - Mason-managed development tooling;
  - debugging;
  - linting;
  - Git integration;
  - fuzzy navigation;
  - automatic pair insertion;
  - Python virtual-environment support;
  - CSV-specific editing behaviour;
  - MXM-specific mappings.
- Added Kitty terminal configuration.
- Added Sway Wayland desktop configuration.
- Added i3status status-bar configuration.
- Added Mako notification configuration.
- Added systemd user-service support.

#### Profile-aware deployment

- Added profile selection through machine-local chezmoi data:
  - `workstationProfiles`.
- Added `.chezmoiignore` rules for selecting profile-specific configuration from the single shared chezmoi source tree.
- Prevented desktop configuration from being deployed to headless workstations.
- Prevented operator-only Google Drive configuration from being deployed to machines that do not select the `operator` profile.
- Kept workstation profile selection instance-specific rather than deriving it from hostnames.

#### Agent-development environment

- Added requirements for the remote agent-development environment, including:
  - GitHub CLI;
  - pipx;
  - ShellCheck;
  - Kitty terminal information;
  - Poetry;
  - Droid.
- Added OSC-52 remote clipboard capability for direct:

  ```text
  Kitty → SSH → tmux
  ```

  development sessions.
- Configured tmux to propagate copy-mode selections to the outer terminal clipboard without requiring a graphical clipboard stack on the remote host.

#### Google Drive integration

- Added Google Drive as an `operator` capability.
- Added an rclone-based Google Drive filesystem mount at:

  ```text
  /mnt/gdrive
  ```

- Added a systemd user service for the mount.
- Added separate privileged and user-level bootstrap operations.
- Added documentation covering:
  - architecture;
  - authority boundaries;
  - OAuth setup;
  - initial provisioning;
  - normal operation;
  - caching;
  - deletion behaviour;
  - validation;
  - troubleshooting;
  - recovery;
  - secret handling.

### Changed

- Replaced the previous flat workstation package list with profile-specific requirements under:

  ```text
  profiles/<profile>/requirements.yaml
  ```

- Defined one shared chezmoi source tree rather than separate configuration trees per workstation role.
- Moved Google Drive documentation and bootstrap scripts under:

  ```text
  profiles/operator/google-drive/
  ```

- Separated:
  - workstation capability specification;
  - declarative user configuration;
  - machine-level realization;
  - identity and secrets;
  - runtime state.
- Clarified that machine-level provisioning is external to ordinary chezmoi application.
- Clarified that systems such as `mxm-infra` may realize the workstation contract for specific appliances.
- Removed machine-specific profile selection from the shared chezmoi source configuration.
- Defined profile selection as local workstation instance state.
- Reframed the workstation from one canonical machine image into composable role and capability profiles.
- Established capability-oriented workstation development as the normal workflow:

  ```text
  identify capability
  → assign profile
  → update contract
  → implement configuration
  → realize prerequisites
  → apply
  → test
  → commit
  ```

### Removed

- Removed the previous flat `bootstrap/packages.yaml` package declaration.
- Removed Tailscale tailnet management from the workstation configuration.
  Tailnet policy belongs to the external security/infrastructure management domain rather than to a user workstation profile.
- Removed the assumption that every workstation has the same privileged local-administration account.

### Security

- Kept credentials and authority-bearing state outside the repository, including:
  - SSH private keys;
  - OAuth credentials and refresh tokens;
  - GitHub authentication state;
  - password-manager state;
  - OpenBao credentials;
  - Tailscale provisioning credentials;
  - application session tokens.
- Kept the live rclone configuration outside the repository:

  ```text
  ~/.config/rclone/rclone.conf
  ```

- Kept rclone cache state outside the repository:

  ```text
  ~/.cache/rclone/
  ```

- Configured the Google Drive mount with user-only filesystem permissions.
- Separated root-owned Google Drive mount preparation from user-level service operation.
- Established the repository as open-resistant configuration:
  knowledge of the workstation definition must not itself confer authority.

### Validated

- Verified Google Drive access through the rclone remote.
- Verified creation, rename and deletion of ordinary files through `/mnt/gdrive`.
- Verified propagation of filesystem changes to Google Drive.
- Verified user-level systemd management of the Google Drive mount.
- Applied and exercised the chezmoi-managed configuration on the existing workstation.

### Notes

- Google Drive remains the authoritative store for content exposed through `/mnt/gdrive`; the mount is not a complete local mirror.
- Google-native Docs, Sheets and Slides remain browser-managed.
- Runtime caches, logs, credentials and Git working state are operational state rather than workstation configuration.
- The first tagged `mxm-workstation` release will be cut from a deliberately tested public baseline.
