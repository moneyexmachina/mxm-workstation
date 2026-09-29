# Google Drive Integration

## Purpose

Expose the authoritative Google Drive filesystem at `/mnt/gdrive` for
Linux-first management of ordinary files.

Google-native Docs, Sheets and Slides remain browser-managed.

## Architecture

- Remote name: `gdrive:`
- Mount point: `/mnt/gdrive`
- Service: `rclone-gdrive.service`
- Configuration: `~/.config/rclone/rclone.conf`
- VFS cache: `~/.cache/rclone/gdrive-vfs`
- Authority: Google Drive

Google Drive remains the authoritative store. The mounted filesystem is an
operational Linux interface to that store, not a complete offline mirror.

## Security boundary

The workstation repository contains:

- the systemd user-service definition;
- bootstrap tooling;
- documentation of the setup and operational model.

It does not contain:

- OAuth refresh tokens;
- Google OAuth client secrets;
- `rclone.conf`;
- VFS cache contents.

The following paths contain local secret or runtime state and must not be added
to the dotfiles repository:

```text
~/.config/rclone/rclone.conf
~/.cache/rclone/gdrive-vfs/
```

## Repository components

The integration is represented in `mxm-workstation` by:

```text
dot_config/systemd/user/rclone-gdrive.service
scripts/bootstrap-gdrive-mount
docs/google-drive.md
```

Chezmoi deploys the service file to:

```text
~/.config/systemd/user/rclone-gdrive.service
```

The service is owned and operated by the `mxm` user through:

```bash
systemctl --user
```

## Prerequisites

The workstation must have:

- `rclone`;
- `fuse3`;
- a configured Google Drive OAuth client;
- an rclone remote named `gdrive`;
- a readable rclone configuration at
  `~/.config/rclone/rclone.conf`.

Verify the installed commands:

```bash
command -v rclone
command -v fusermount3
```

Verify the configured remote:

```bash
rclone listremotes
rclone lsd gdrive:
```

The remote listing should include:

```text
gdrive:
```

## Google OAuth configuration

The Google Drive connection uses a personal Google OAuth desktop client rather
than rclone's shared client.

The OAuth client must have access to the Google Drive API.

Run the interactive configuration as the `mxm` user:

```bash
rclone config
```

The resulting configuration is stored locally at:

```text
~/.config/rclone/rclone.conf
```

This file contains secret-bearing OAuth credentials and must not be committed
to Git.

Confirm its location:

```bash
rclone config file
```

Restrict its permissions:

```bash
chmod 600 ~/.config/rclone/rclone.conf
```

## Mount configuration

The Drive remote is mounted at:

```text
/mnt/gdrive
```

The system-level mount directory must be created once with administrative
privileges:

```bash
sudo install \
    -d \
    -o mxm \
    -g mxm \
    -m 0700 \
    /mnt/gdrive
```

The local VFS cache is stored at:

```text
~/.cache/rclone/gdrive-vfs
```

Create it with:

```bash
mkdir -p ~/.cache/rclone/gdrive-vfs
chmod 700 ~/.cache/rclone ~/.cache/rclone/gdrive-vfs
```

## Systemd user service

The mount is managed by:

```text
rclone-gdrive.service
```

The source file in `mxm-workstation` is:

```text
dot_config/systemd/user/rclone-gdrive.service
```

Chezmoi deploys it to:

```text
~/.config/systemd/user/rclone-gdrive.service
```

The service runs the equivalent of:

```bash
rclone mount gdrive: /mnt/gdrive \
    --config="$HOME/.config/rclone/rclone.conf" \
    --cache-dir="$HOME/.cache/rclone/gdrive-vfs" \
    --vfs-cache-mode=full \
    --vfs-cache-max-size=20G \
    --vfs-cache-max-age=168h \
    --dir-cache-time=72h \
    --poll-interval=1m \
    --drive-export-formats=link.html \
    --umask=077
```

The configuration provides:

- full VFS caching for normal Linux file-operation compatibility;
- a maximum local cache size of 20 GB;
- cached file retention for up to seven days;
- periodic detection of remote changes;
- browser-link representations for Google-native files;
- user-only filesystem permissions.

## Initial setup

Complete the following steps as the `mxm` user unless otherwise stated.

### 1. Install prerequisites

Install `rclone` and `fuse3` using the workstation's normal administrative
installation process.

### 2. Configure Google Drive

Run:

```bash
rclone config
```

Create or update the remote named:

```text
gdrive
```

Verify it:

```bash
rclone lsd gdrive:
```

### 3. Apply the workstation configuration

From the `mxm-workstation` repository, apply the chezmoi-managed files using the
normal workstation deployment process.

Confirm that the service file exists:

```bash
systemctl --user cat rclone-gdrive.service
```

### 4. Run the bootstrap script

Run:

```bash
scripts/bootstrap-gdrive-mount
```

The script:

- validates that it is running as `mxm`;
- verifies that `rclone` is installed;
- verifies that `rclone.conf` exists;
- creates `/mnt/gdrive`;
- creates the VFS cache directory;
- reloads the systemd user manager;
- enables and starts the service;
- verifies that the mount is active.

## Normal operations

### Check service status

```bash
systemctl --user status rclone-gdrive.service
```

For a compact result:

```bash
systemctl --user is-active rclone-gdrive.service
```

Expected output:

```text
active
```

### Check the mounted filesystem

```bash
findmnt /mnt/gdrive
mountpoint /mnt/gdrive
ls -la /mnt/gdrive
```

### Start the mount

```bash
systemctl --user start rclone-gdrive.service
```

### Stop the mount

```bash
systemctl --user stop rclone-gdrive.service
```

### Restart the mount

```bash
systemctl --user restart rclone-gdrive.service
```

### Enable automatic startup

```bash
systemctl --user enable rclone-gdrive.service
```

### Disable automatic startup

```bash
systemctl --user disable rclone-gdrive.service
```

### Enable and start together

```bash
systemctl --user enable --now rclone-gdrive.service
```

## Logs

Show recent logs:

```bash
journalctl --user \
    -u rclone-gdrive.service \
    -n 100 \
    --no-pager
```

Follow logs live:

```bash
journalctl --user \
    -u rclone-gdrive.service \
    -f
```

Press `Ctrl-C` to stop following the journal. This does not stop the mount.

Show logs from the current boot:

```bash
journalctl --user \
    -u rclone-gdrive.service \
    -b \
    --no-pager
```

## Filesystem behaviour

Ordinary files can be managed through Linux using normal commands and
applications:

```bash
cp document.pdf /mnt/gdrive/0\ Inbox/
mv old-name.pdf new-name.pdf
mkdir /mnt/gdrive/1\ Projects/example-project
rm unwanted-file.pdf
```

Changes made under `/mnt/gdrive` are sent to Google Drive.

The following operations have been validated:

- creating a directory;
- creating a file;
- renaming a file;
- deleting a file or directory;
- observing the resulting change in the Google Drive web interface.

Google Drive remains authoritative.

## Write caching

The service uses:

```text
--vfs-cache-mode=full
```

Applications write initially through the local VFS cache. Rclone then uploads
the completed file to Google Drive.

The cache is operational state, not an independent authoritative copy.

Before shutting down or stopping the service during active writes, confirm that
applications using files under `/mnt/gdrive` have closed those files.

Service logs can be inspected for pending uploads or failures:

```bash
journalctl --user \
    -u rclone-gdrive.service \
    -n 100 \
    --no-pager
```

## Google-native files

Google Docs, Sheets and Slides are not ordinary stored document files.

They appear in the mount as browser-link files because the service uses:

```text
--drive-export-formats=link.html
```

Open those links in a browser and continue to manage the native documents
through the Google web applications.

Do not treat the link files as locally editable Word, Excel or PowerPoint
documents.

## Deletion behaviour

Deleting an ordinary file through `/mnt/gdrive` normally moves it to Google
Drive Trash.

For example:

```bash
rm /mnt/gdrive/path/to/file.pdf
```

Deletion remains a consequential operation because it changes the
authoritative Google Drive state.

Verify important or bulk deletion operations in the Google Drive web interface.

## Offline behaviour

The mount is not a complete offline mirror.

Files that have not been cached may be unavailable while the workstation has no
network connection.

Previously accessed files may remain available temporarily through the VFS
cache, but this should not be treated as a guaranteed offline-storage policy.

A separate, explicit backup or synchronisation design is required for durable
offline copies.

## Recovery

### Service is inactive

Inspect the status and logs:

```bash
systemctl --user status rclone-gdrive.service

journalctl --user \
    -u rclone-gdrive.service \
    -n 100 \
    --no-pager
```

Restart it:

```bash
systemctl --user restart rclone-gdrive.service
```

### Mount point is stale

Stop the service first:

```bash
systemctl --user stop rclone-gdrive.service
```

Attempt a normal FUSE unmount:

```bash
fusermount3 -u /mnt/gdrive
```

Restart the service:

```bash
systemctl --user start rclone-gdrive.service
```

Use a lazy unmount only when the normal unmount fails:

```bash
fusermount3 -uz /mnt/gdrive
```

Then restart:

```bash
systemctl --user start rclone-gdrive.service
```

### Mount directory is missing

Recreate it administratively:

```bash
sudo install \
    -d \
    -o mxm \
    -g mxm \
    -m 0700 \
    /mnt/gdrive
```

Then restart:

```bash
systemctl --user restart rclone-gdrive.service
```

### Rclone configuration is missing

Confirm:

```bash
rclone config file
```

If necessary, recreate the remote:

```bash
rclone config
```

Then verify:

```bash
rclone lsd gdrive:
```

Restart the service after authentication succeeds:

```bash
systemctl --user restart rclone-gdrive.service
```

### OAuth credentials have been revoked

Reconnect the remote:

```bash
rclone config reconnect gdrive:
```

Complete browser authentication and then restart the service:

```bash
systemctl --user restart rclone-gdrive.service
```

## Validation after workstation login

After logging into the workstation as `mxm`, run:

```bash
systemctl --user is-enabled rclone-gdrive.service
systemctl --user is-active rclone-gdrive.service
findmnt /mnt/gdrive
```

Expected service results:

```text
enabled
active
```

The Drive contents should then be available under:

```text
/mnt/gdrive
```

## Secret-safety checks

Inspect repository changes before committing:

```bash
git status --short
```

Search tracked content for accidental secret references:

```bash
git grep -nE \
    'client_secret|refresh_token|rclone\.conf' \
    || true
```

Do not run:

```bash
chezmoi add ~/.config/rclone/rclone.conf
```

Do not commit files from:

```text
~/.config/rclone/
~/.cache/rclone/
```

## Authority model

The integration uses the following authority split:

```text
Google Drive
    authoritative file store

/mnt/gdrive
    Linux operational interface

rclone VFS cache
    temporary runtime state

mxm-workstation
    declarative mount configuration and setup documentation

rclone.conf
    local secret-bearing identity configuration
```

This model permits Linux-first file management without introducing a separate
bidirectional mirror or competing local source of truth.
