All notable changes to this project will be documented in this file.

This project adheres to [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

#### Workstation configuration

- Added a chezmoi-managed source state for the canonical MXM Linux workstation.
- Added Zsh login and interactive-shell configuration.
- Added Starship prompt configuration.
- Added Kitty terminal configuration.
- Added tmux workspace configuration.
- Added Neovim configuration based on Kickstart.nvim, including:
  - language-server integration;
  - Mason-managed development tooling;
  - debugging support;
  - linting support;
  - Git integration;
  - file-tree navigation;
  - automatic pair insertion;
  - custom MXM key mappings;
  - Python virtual-environment support;
  - CSV-specific editing configuration.
- Added Sway Wayland desktop configuration.
- Added display-output and desktop-session startup configuration.
- Added i3status status-bar configuration.
- Added Mako notification configuration.
- Added systemd user-service support under
  `chezmoi/dot_config/systemd/user/`.

#### Bootstrap and provisioning

- Added `bootstrap/packages.yaml` for recording workstation package
  requirements.
- Added `bootstrap/neovim.md` for Neovim bootstrap and setup guidance.
- Added explicit separation between:
  - machine-level provisioning;
  - chezmoi-managed user configuration;
  - local identity and secret state.
- Added the `adminsecure` and `mxm` privilege model:
  - `adminsecure` performs explicitly authorised system administration;
  - `mxm` performs routine development and workstation operation without
    unrestricted `sudo` access.

#### Google Drive integration

- Added an rclone-based Google Drive filesystem mount at:

  ```text
  /mnt/gdrive
  ```

- Added the systemd user unit:

  ```text
  chezmoi/dot_config/systemd/user/rclone-gdrive.service
  ```

- Configured the Google Drive mount with:
  - full rclone VFS caching;
  - a bounded local cache;
  - automatic polling for remote changes;
  - user-only filesystem permissions;
  - browser-link representations for Google-native files;
  - automatic startup with the `mxm` user session.
- Added:

  ```text
  scripts/bootstrap-gdrive-system
  ```

  for privileged preparation of the system mount point.

- Added:

  ```text
  scripts/bootstrap-gdrive-mount
  ```

  for validating, enabling and starting the `mxm` user-level mount service.

- Added:

  ```text
  docs/google-drive.md
  ```

  documenting:
  - architecture;
  - authority and privilege boundaries;
  - Google OAuth setup;
  - initial provisioning;
  - normal operation;
  - systemd service management;
  - VFS caching behaviour;
  - deletion behaviour;
  - offline limitations;
  - validation;
  - troubleshooting and recovery;
  - secret-safety requirements.

#### Documentation

- Added a project README describing:
  - the purpose of `mxm-workstation`;
  - the workstation contract;
  - the repository structure;
  - the chezmoi source and deployment model;
  - the `mxm` and `adminsecure` privilege boundary;
  - managed shell, terminal, editor and desktop components;
  - machine provisioning;
  - local identity and secret state;
  - current workstation capabilities;
  - the capability-oriented development workflow.
- Added operational documentation under `docs/`.
- Added this workstation-specific changelog.

### Changed

- Replaced the inherited `mxm-foundry` README content with documentation
  specific to `mxm-workstation`.
- Replaced the inherited `mxm-foundry` changelog history with a
  workstation-specific changelog.
- Updated the documented current scope to reflect capabilities already present
  in the repository rather than treating tmux, Neovim and Sway as future work.
- Clarified that the repository uses a top-level `chezmoi/` source-state
  directory.
- Clarified the mapping between chezmoi source paths and deployed home-directory
  paths.
- Defined the repository as the authority for stable declarative workstation
  configuration.
- Defined explicit machine-level bootstrap steps for operations that cannot be
  performed through ordinary user dotfile application.
- Established capability-oriented workstation development as the standard
  workflow:

  ```text
  identify a missing capability
  → implement its source configuration
  → document its operating and authority model
  → inspect with chezmoi diff
  → apply with chezmoi
  → test the deployed behaviour
  → inspect repository changes
  → commit the proven capability
  ```

### Security

- Kept Google OAuth credentials and refresh tokens outside the repository.
- Kept the live rclone configuration outside the repository:

  ```text
  ~/.config/rclone/rclone.conf
  ```

- Kept rclone VFS cache state outside the repository:

  ```text
  ~/.cache/rclone/
  ```

- Configured the Google Drive mount with user-only permissions through:

  ```text
  --umask=077
  ```

- Replaced rclone's retiring shared Google OAuth client with a dedicated
  personal Google OAuth desktop client.
- Separated root-owned mount-point creation from user-level service activation.
- Prevented the normal `mxm` account from requiring unrestricted administrative
  privileges.
- Documented that private keys, OAuth tokens, application sessions, caches and
  runtime logs must not be committed.

### Fixed

- Corrected the README's outdated description of the repository's implemented
  components.
- Corrected the README's previous treatment of tmux, Neovim and Sway as future
  scope.
- Corrected the changelog, which previously documented `mxm-foundry` rather
  than `mxm-workstation`.
- Removed the conceptual ambiguity between:
  - declarative dotfiles;
  - privileged machine provisioning;
  - local secret-bearing state.
- Prevented the rclone bootstrap process from attempting to invoke `sudo`
  through the unprivileged `mxm` account.
- Split Google Drive provisioning into:
  - an administrative system-preparation script;
  - an unprivileged user-service activation script.

### Validated

- Verified the Google Drive remote using:

  ```bash
  rclone lsd gdrive:
  ```

- Verified creation, rename and deletion of ordinary files through the mounted
  Linux filesystem.
- Verified propagation of Linux filesystem changes to the Google Drive web
  interface.
- Verified that deletions are represented through Google Drive Trash.
- Verified the rclone mount manually before systemd automation.
- Verified the systemd user-unit configuration.
- Verified automatic service enablement.
- Verified that the Google Drive mount is active at:

  ```text
  /mnt/gdrive
  ```

- Verified that the mount can be stopped and restarted through:

  ```bash
  systemctl --user
  ```

### Notes

- Google Drive remains the authoritative file store.
- `/mnt/gdrive` is a Linux operational interface, not a complete local mirror.
- Google Docs, Sheets and Slides remain browser-managed.
- The rclone service starts when the `mxm` user session starts.
- The Google Drive bootstrap scripts are normally run once per machine.
- Runtime caches and generated logs are operational state rather than
  declarative workstation configuration.
- Historical releases have not been reconstructed from the previous changelog
  because that file described a different project. The first formal
  `mxm-workstation` release should be created deliberately from this
  workstation-specific baseline.
