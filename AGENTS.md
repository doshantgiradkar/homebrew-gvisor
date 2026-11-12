# AGENTS.md

## What this repo is
Homebrew tap that packages Google gVisor release artifacts as a Homebrew formula. It downloads upstream *release binaries* and installs only the expected user-space components (no modification of upstream binaries).

## Repo layout
- `Formula/gvisor.rb`: the Homebrew formula for the `gvisor` package.
- `.github/workflows/test.yml`: CI checks for Ruby syntax and runs Homebrew’s formula audit/test.
- `.github/workflows/update-formula.yml`: scheduled workflow to check for upstream release updates (currently the “download artifacts + open PR” step is a placeholder).
- `README.md`: installation/verification instructions for users.

## The main source of truth: `Formula/gvisor.rb`
### How the formula is structured
- Uses Homebrew’s `Formula` class.
- Includes Ruby magic header:
  - `# typed: false`
  - `# frozen_string_literal: true`
- Uses `on_linux` to choose between upstream release URLs based on CPU:
  - Default URL/sha512 are for **x86_64**.
  - On **arm64 (aarch64)** it overrides `url` and `sha512`.
  - If the CPU is neither `intel?` 64-bit nor ARM 64-bit, it fails with `odie`.

### Install behavior and the key filesystem expectation
The install logic preserves a gVisor expectation that a `gvisor-bin/` directory exists next to `runsc`.

Specifically:
- Installs these executables into `bin/`:
  - `runsc`
  - `containerd-shim-runsc-v1`
- Installs `gvisor-bin` into `libexec/`:
  - `libexec.install "gvisor-bin"`
- Creates a symlink so `gvisor-bin` appears in the expected relative location:
  - `bin.install_symlink libexec/"gvisor-bin" => "gvisor-bin"`

If you change how upstream artifacts are laid out, keep the `gvisor-bin` alongside `runsc` requirement intact.

### Test block (`brew test gvisor`)
The formula’s `test do ... end` asserts:
- `#{bin}/runsc --version` output matches `/runsc version/`
- `#{bin}/runsc help` output matches `/Subcommands/`
- `#{bin}/gvisor-bin` exists as a directory

## CI and local commands
### CI workflow: `.github/workflows/test.yml`
CI performs three checks:
1. **Ruby syntax check**: `ruby -c Formula/gvisor.rb`
2. **Formula audit**: installs the formula and runs `brew audit --strict gvisor`
3. **Formula test**: installs the formula and runs `brew test gvisor`

### Suggested local equivalents for agents
From the repo root, on a machine with Homebrew available:
- Syntax check:
  - `ruby -c Formula/gvisor.rb`
- Audit:
  - `brew install ./Formula/gvisor.rb`
  - `brew audit --strict gvisor`
- Formula test:
  - `brew install ./Formula/gvisor.rb`
  - `brew test gvisor`

## Update automation workflow caveat
`.github/workflows/update-formula.yml`:
- Finds the latest upstream stable release by listing gVisor releases.
- Compares it against the current `version` in `Formula/gvisor.rb`.
- If a new version exists, the workflow currently stops at a placeholder step:
  - it echoes that update automation is not implemented.

So for now, version bumps are manual and should include updating:
- `version`, `url`, and `sha512` (and the ARM64 overrides inside `on_linux` when applicable).

## Non-obvious gotchas
- **Architectures**: the formula selects ARM64 artifacts only when `Hardware::CPU.arm? && Hardware::CPU.is_64_bit?`. x86_64 is the default.
- **Directory expectation**: gVisor expects `gvisor-bin/` to be adjacent to `runsc`, hence the `libexec` + `bin` symlink approach.
- **Tests are minimal**: the formula test does not run containers or validate runtime behavior beyond basic binary/help output and filesystem layout.

## When editing `gvisor.rb`
- Keep changes aligned with the upstream artifact layout expectations.
- After edits, run at least:
  - `ruby -c Formula/gvisor.rb`
  - `brew audit --strict gvisor`
  - `brew test gvisor`
