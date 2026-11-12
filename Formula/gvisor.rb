# typed: false
# frozen_string_literal: true

class Gvisor < Formula
  desc "Sandboxed container runtime for Linux"
  homepage "https://gvisor.dev/"
  license "Apache-2.0"

  url "https://github.com/google/gvisor/releases/download/release-20261109.0/gvisor-x86_64.tar.bz2"
  sha256 "0846228061b05eb936a96ed2ea205cbd8ddf6936c946f8a390b699cff3b5c138"
  version "20261109.0"

  depends_on :linux

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/google/gvisor/releases/download/release-20261109.0/gvisor-aarch64.tar.bz2"
      sha256 "795f87ab171b7a228d8b0e7e2d422c41c29dc7e37792f21099589dc3527ab1f0"
    elsif !(Hardware::CPU.intel? && Hardware::CPU.is_64_bit?)
      odie "Unsupported CPU architecture for gVisor release artifacts"
    end
  end

  def install
    # Keep gvisor-bin next to runsc; upstream runsc locates it relative to its
    # executable. Put the upstream files in libexec and expose executable
    # wrappers in bin so Homebrew audit does not flag the data directory.
    libexec.install "runsc", "containerd-shim-runsc-v1", "gvisor-bin"

    %w[runsc containerd-shim-runsc-v1].each do |command|
      (bin/command).write <<~EOS
        #!/bin/bash
        exec "#{libexec}/#{command}" "$@"
      EOS
      (bin/command).chmod(0755)
    end
  end

  test do
    assert_match(/runsc version/, shell_output("#{bin}/runsc --version"))
    assert_match(/Subcommands/, shell_output("#{bin}/runsc help"))
    assert_predicate libexec/"gvisor-bin", :directory?
  end
end
