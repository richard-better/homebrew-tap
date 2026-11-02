# Richard's Homebrew tap

This tap distributes apps from [richard-better](https://github.com/richard-better), and casks for third-party apps that Homebrew doesn't carry.

## Switcheroo

Install [Switcheroo](https://github.com/richard-better/switcheroo/releases/latest) with:

```sh
brew install --cask richard-better/tap/switcheroo
```

Release metadata comes from [Switcheroo's release workflow](https://github.com/richard-better/switcheroo/actions/workflows/release.yml). The cask points to the same notarized ZIP used for direct downloads and automatic updates.

After publishing a Switcheroo release, run:

```sh
gh workflow run update.yml --repo richard-better/homebrew-tap -f cask=switcheroo
```

The workflow downloads the latest published release, verifies the ZIP and cask checksums, and commits `Casks/switcheroo.rb`. It uses this repository's GitHub token and needs no Apple credentials. To update a local checkout instead, run `scripts/update.sh` from its root.

## TrainStack Ride

Install [TrainStack Ride](https://github.com/richard-better/trainstack), the indoor cycling app, with one of:

```sh
brew install --cask richard-better/tap/trainstack-ride        # named releases
brew install --cask richard-better/tap/trainstack-ride@alpha  # every change to main
```

The two casks install the same app, so only one can be installed at a time. TrainStack's release workflows publish each build as a notarized Developer ID ZIP on its GitHub releases, then start this tap's update for `trainstack-ride` or `trainstack-ride@alpha`. To run it by hand:

```sh
gh workflow run update.yml --repo richard-better/homebrew-tap -f cask=trainstack-ride@alpha
```

`scripts/update-trainstack-ride.sh stable|alpha` picks the newest published release of the channel, checks the ZIP against its `SHA256SUMS`, and writes the cask. It never moves a cask to an older version, even if newer releases are deleted. Each cask appears with its channel's first release.

## Herdr

Install [Herdr](https://herdr.dev/), the native app for coding agents, with:

```sh
brew install --cask richard-better/tap/herdr
```

Herdr ships no cask of its own. This one installs the same Developer ID signed build as Herdr's install script, from the release manifest at `https://releases.herdr.dev/app/latest.json`, and adds `herdr-app` to the PATH. The app updates itself, and installs herdr-core when it first opens.

The update workflow runs daily, and `scripts/update-herdr.sh` checks the download against the manifest's checksum and never moves the cask to an older version. To run it by hand:

```sh
gh workflow run update.yml --repo richard-better/homebrew-tap -f cask=herdr
```

All updates share one concurrency group and rebase before pushing, so they never overwrite each other.
