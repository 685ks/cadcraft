# Releasing CADCraft

Releases go through the shared Arthavan Projects release workflow
(`685ks/craft-actions/.github/workflows/release-rust-app.yml`), called from `.github/workflows/release.yml`. It reads the packaging metadata (ids, display name, publisher `Arthavan Projects`, icon, categories) from [`packaging/app.toml`](../packaging/app.toml), builds and packages CADCraft for Windows, and creates the GitHub Release `v<version>` on this repository. The Arthavan Projects launcher installs and updates CADCraft from these releases.

- **Version:** `[workspace.package] version` in the root `Cargo.toml` is the single source. `cargo xtask version` prints it; `cargo xtask version set X.Y.Z[-pre]` changes it. The app shows it in About, `cadcraft --version` and `cadcraft-cli --version`; release builds also embed the commit (`CADCRAFT_BUILD_SHA`).
- **Cut a release:** bump the version on `main`, then run *Actions → Release → Run workflow* with `version` set to it (without the leading `v`). The release stays a draft unless `publish` is set; set `prerelease` for `-rc` builds.
- **Artifacts:** what the shared workflow builds for Windows (and the web), named `cadcraft-<version>-<os>-<arch>[-portable].<ext>`. The packaging scripts in `packaging/` (MSI, web) remain for local builds.
- **Secrets:** signing secrets are the repository's own and reach the shared workflow through `secrets: inherit`; a build without them is unsigned.
- **Windows installer:** `packaging/windows/cadcraft.wxs` (WiX v5 + `WixToolset.UI.wixext`; this fork's own UpgradeCode, fixed forever). Its wizard has a Shortcuts page: the Start Menu shortcut is always created, the desktop shortcut is opt-in (`DESKTOPSHORTCUT=1` for silent installs, `DESKTOPSHORTCUT=0` drops it on an upgrade; otherwise upgrades keep the previous choice).
- **File types:** `.dxf` and `.dwg` (Windows "Open with").
- **Local packaging test:** `packaging/windows/package.ps1`, `packaging/web/package.sh`.
