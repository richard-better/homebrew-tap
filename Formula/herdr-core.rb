class HerdrCore < Formula
  desc "Terminals for coding agents that keep running"
  homepage "https://github.com/herdrdev/herdr-core"
  url "https://releases.herdr.dev/core/0.1.22/herdr-core-macos-aarch64.tar.gz"
  version "0.1.22"
  sha256 "90798daadefa8d126b90ef0bcdbe9c7dda9c6cfbf011a247065ab5da348f350e"
  license "Apache-2.0"

  livecheck do
    url "https://releases.herdr.dev/core/latest.json"
    strategy :json do |json|
      json["version"]
    end
  end

  depends_on arch: :arm64
  depends_on :macos

  def install
    bin.install "herdr-core"
    bin.install_symlink "herdr-core" => "hc"
  end

  def caveats
    <<~EOS
      A running core keeps its old version after an upgrade. Restart it with:
        hc server restart
      Your terminals keep running.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/herdr-core --version")
  end
end
