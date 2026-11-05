cask "herdr" do
  version "0.1.13"
  sha256 "f5dd0bc81aa9ef61cfbfb6ef9fdbf4fe7f664d4ec676ee0dc88f13cc9759d0d0"

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
