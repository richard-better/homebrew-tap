cask "herdr" do
  version "0.1.14"
  sha256 "0da6ca214214389ca39e05fdf6523fd6e4be423a4be7dfd39b677d68a410fa8b"

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
