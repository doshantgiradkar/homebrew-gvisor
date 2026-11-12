# homebrew-gvisor

Unofficial community-maintained Homebrew tap for packaging Google’s gVisor release binaries.

## Disclaimer

This repository is **not** affiliated with Google. It packages official gVisor release tarballs and does not modify upstream binaries.

## Install

```bash
brew tap doshantgiradkar/brewvisor
brew install gvisor
```

## Supported platforms

- Linuxbrew (Linux) on x86_64 (amd64)
- Linuxbrew (Linux) on arm64 (aarch64)

gVisor requires a Linux kernel with suitable features; Homebrew packages only provide the user-space components.

## Verification

After installation:

```bash
/usr/local/bin/runsc --version
```

## Upstream links

- Install guide: https://gvisor.dev/docs/user_guide/install/
- Project: https://github.com/google/gvisor

## Licensing

gVisor is distributed under the Apache License 2.0. Upstream license and NOTICE requirements are preserved in the upstream artifacts.
