cask "herdr" do
  version "0.1.18"
  sha256 "fd646b4a6db2c3e9b4700be7d10153440cb799c960b082d4ab60a5fd63f9372a"

  url "https://releases.herdr.dev/app/#{version}/herdr-app-macos-aarch64.tar.gz"
  name "Herdr"
  desc "Native app for coding agents that keep running when it closes"
  homepage "https://herdr.dev/"

  livecheck do
    url "https://releases.herdr.dev/app/latest.json"
    strategy :json do |json|
      json["version"]
    end
  end

  auto_updates true
  depends_on arch: :arm64
  depends_on :macos

  app "Herdr.app"
  binary "#{appdir}/Herdr.app/Contents/MacOS/Herdr", target: "herdr-app"
end
