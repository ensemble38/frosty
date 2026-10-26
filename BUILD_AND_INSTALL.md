# Build and install Frosty S0und Test

## Windows preparation

Install Git and GitHub CLI, then authenticate with `gh auth login`. Install only the official
[iLoader](https://github.com/nab138/iloader) release (also linked from
[iloader.app](https://iloader.app/)). iLoader requires Apple's Windows device components; use
the Apple/iTunes installation it documents. Never store an Apple ID password or 2FA code in
this repository.

## Generate and download the IPA

The **Build unsigned iOS IPA** workflow uses the Flutter version pinned in `pubspec.yaml`, runs
code generation, analysis and tests, builds without code signing, validates the IPA structure
and bundle metadata, then uploads `Frosty-S0und-Test.ipa`.

```powershell
gh workflow run build-ios-ipa.yml --ref feature/s0und-playback-modes
gh run list --workflow build-ios-ipa.yml
gh run watch RUN_ID --exit-status
gh run download RUN_ID -n Frosty-S0und-Test -D .\artifacts
Get-FileHash .\artifacts\Frosty-S0und-Test.ipa -Algorithm SHA256
```

## Install with iLoader

1. Connect the iPhone by USB, unlock it, and accept **Trust This Computer** if prompted.
2. Open iLoader and confirm that the device appears.
3. Use **Import IPA** (or the current equivalent) and choose `Frosty-S0und-Test.ipa`.
4. Enter Apple ID and 2FA only in iLoader's interactive UI. Do not paste credentials into logs.
5. If requested by iOS, enable **Settings > Privacy & Security > Developer Mode**, restart,
   and approve the confirmation. If the developer certificate is not trusted, use the current
   **Settings > General > VPN & Device Management** screen.

If direct installation fails, save the complete iLoader log from **View Logs** or
`%APPDATA%\me.nabdev.iloader\logs` before changing anything. SideStore setup through iLoader is
the second-choice path after diagnosing direct USB installation.

### iOS 27 note (checked 2026-10-26)

iLoader 2.4.0 is the latest official release. Direct USB IPA import is still the first path on
iOS 27; wireless pairing is not required. Current issue reports show that provisioning-profile
errors can still affect individual free accounts, and SideStore has had separate iOS 27 launch
issues. Capture the exact direct-install error before trying SideStore.

## Test and update

Open one live channel in Frosty mode, then switch to S0und Token and S0und Full. Each mode change
destroys the player session and fetches a new access token. Copy the secret-redacted log from
**Settings > Video > Playback debug**. For an update, push the branch, rerun the workflow,
download the new artifact, and import it into iLoader. A free Apple ID signature normally expires
and requires re-signing/reinstallation; repeat the same import flow when iOS reports expiry.
