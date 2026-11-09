cask "switcheroo" do
  version "1.1.0"
  sha256 "4cc44ca2db02ce7250f728b56462059d16a07d8eb50c8fd307ff745ca6b70c27"

  url "https://github.com/richard-better/switcheroo/releases/download/switcheroo-v#{version}/Switcheroo-#{version}.zip"
  name "Switcheroo"
  desc "Window and browser tab switcher"
  homepage "https://github.com/richard-better/switcheroo"

  auto_updates true
  depends_on macos: :monterey

  app "Switcheroo.app"
end
