# typed: false
# frozen_string_literal: true

class Gvisor < Formula
  desc "gVisor container runtime (unofficial Homebrew packaging of upstream binaries)"
  homepage "https://gvisor.dev/"
  license "Apache-2.0"

  version "20261109.0"

  url "https://github.com/google/gvisor/releases/download/release-20261109.0/gvisor-x86_64.tar.bz2"
  sha256 "REPLACE_WITH_OFFICIAL_X86_64_SHA256"

  depends_on :linux

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/google/gvisor/releases/download/release-20261109.0/gvisor-aarch64.tar.bz2"
      sha256 "REPLACE_WITH_OFFICIAL_AARCH64_SHA256"
    elsif !(Hardware::CPU.intel? && Hardware::CPU.is_64_bit?)
      odie "Unsupported CPU architecture for gVisor release artifacts"
    end
  end

  def install
    bin.install "runsc"
    bin.install "containerd-shim-runsc-v1"

    # gVisor expects to find gvisor-bin/ next to runsc.
    libexec.install "gvisor-bin"
    bin.install_symlink libexec/"gvisor-bin" => "gvisor-bin"
  end

  test do
    assert_match(/runsc version/, shell_output("#{bin}/runsc --version"))
    assert_match(/Subcommands/, shell_output("#{bin}/runsc help"))
    assert_predicate (bin/"gvisor-bin"), :directory
  end
end
