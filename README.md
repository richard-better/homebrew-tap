# Richard's Homebrew tap

This tap distributes apps from [richard-better](https://github.com/richard-better).

Switcheroo's cask is added after its first signed and notarized release. Once that release is published, install it with:

```sh
brew install --cask richard-better/tap/switcheroo
```

Release metadata comes from [Switcheroo's release workflow](https://github.com/richard-better/switcheroo/actions/workflows/release.yml). The cask points to the same notarized ZIP used for direct downloads and automatic updates.
