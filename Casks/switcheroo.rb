cask "switcheroo" do
  version "1.0.0"
  sha256 "9f09645cd892b848138739f2beb83ca4a339e4061b6df93232a5fa044d8b771d"

  url "https://github.com/richard-better/switcheroo/releases/download/switcheroo-v#{version}/Switcheroo-#{version}.zip"
  name "Switcheroo"
  desc "Window and browser tab switcher"
  homepage "https://github.com/richard-better/switcheroo"

  auto_updates true
  depends_on macos: :monterey

  app "Switcheroo.app"
end
