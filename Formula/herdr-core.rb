class HerdrCore < Formula
  desc "Terminals for coding agents that keep running"
  homepage "https://github.com/herdrdev/herdr-core"
  url "https://releases.herdr.dev/core/0.1.20/herdr-core-macos-aarch64.tar.gz"
  version "0.1.20"
  sha256 "e58985d3fef6e909f33d3c5a4426e4898c81564a557d4636591cec9e3a06af26"
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
