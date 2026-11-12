# typed: false
# frozen_string_literal: true

class Gvisor < Formula
  desc "gVisor container runtime (unofficial Homebrew packaging of upstream binaries)"
  homepage "https://gvisor.dev/"
  license "Apache-2.0"

  version "20261109.0"

  url "https://github.com/google/gvisor/releases/download/release-20261109.0/gvisor-x86_64.tar.bz2"
  sha512 "1a6b8f74c37b4931ef473f67ec1f601690855bedc52ac709f2fac965c69677aa0426ef44598d8eee1aed72cfdb9df87a2a5f352cb3348880fc61a7732bc10f2a"

  depends_on :linux

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/google/gvisor/releases/download/release-20261109.0/gvisor-aarch64.tar.bz2"
      sha512 "411f2d6f7f98a93643725ce9933ff67a7f96f884c2317be3e2b579b976ceb54065bd1d4292a9d61de38da1940ef21b7e41070127874086b7992fb7b5e7a85897"
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
