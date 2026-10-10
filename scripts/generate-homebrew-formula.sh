#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:-}"
REPO_SLUG="${2:-mgabs/look}"
ARM64_SHA="${3:-}"
INTEL_SHA="${4:-}"
OUT_FILE="${5:-Formula/look.rb}"

# Auto-resolve version if not supplied
if [[ -z "$VERSION" ]]; then
  LATEST_TAG="$(git describe --tags --abbrev=0 2>/dev/null || true)"
  if [[ -n "$LATEST_TAG" ]]; then
    VERSION="${LATEST_TAG#v}"
  else
    # Check latest manifest in dist/
    LATEST_MANIFEST="$(ls -t dist/Look-*-manifest.txt 2>/dev/null | head -n 1 || true)"
    if [[ -n "$LATEST_MANIFEST" ]]; then
      VERSION="$(grep '^version=' "$LATEST_MANIFEST" | cut -d= -f2 || true)"
    fi
  fi
fi

VERSION="${VERSION:-0.8.0}"
VERSION="${VERSION#v}"

# Resolve ARM64 SHA256
if [[ -z "$ARM64_SHA" ]]; then
  if [[ -f "dist/Look-${VERSION}-manifest.txt" ]]; then
    ARM64_SHA="$(grep '^sha256=' "dist/Look-${VERSION}-manifest.txt" | cut -d= -f2 || true)"
  elif [[ -f "dist/Look-${VERSION}-macOS.zip" ]]; then
    ARM64_SHA="$(shasum -a 256 "dist/Look-${VERSION}-macOS.zip" | awk '{print $1}')"
  fi
fi

# Resolve Intel SHA256
if [[ -z "$INTEL_SHA" ]]; then
  if [[ -f "dist/Look-${VERSION}-manifest-x86_64.txt" ]]; then
    INTEL_SHA="$(grep '^sha256=' "dist/Look-${VERSION}-manifest-x86_64.txt" | cut -d= -f2 || true)"
  elif [[ -f "dist/Look-${VERSION}-macOS-x86_64.zip" ]]; then
    INTEL_SHA="$(shasum -a 256 "dist/Look-${VERSION}-macOS-x86_64.zip" | awk '{print $1}')"
  fi
fi

# If either SHA is still empty, attempt to download checksums from GitHub release
EMPTY_SHA="e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"

if [[ -z "$ARM64_SHA" ]]; then
  ARM64_URL="https://github.com/${REPO_SLUG}/releases/download/v${VERSION}/Look-${VERSION}-macOS.zip"
  echo "Attempting to fetch arm64 binary checksum from ${ARM64_URL}..."
  FETCHED_SHA="$(curl -sSLf --max-time 15 "$ARM64_URL" 2>/dev/null | shasum -a 256 | awk '{print $1}' || true)"
  if [[ -n "$FETCHED_SHA" && "$FETCHED_SHA" != "$EMPTY_SHA" ]]; then
    ARM64_SHA="$FETCHED_SHA"
  fi
fi

if [[ -z "$INTEL_SHA" ]]; then
  INTEL_URL="https://github.com/${REPO_SLUG}/releases/download/v${VERSION}/Look-${VERSION}-macOS-x86_64.zip"
  echo "Attempting to fetch intel binary checksum from ${INTEL_URL}..."
  FETCHED_SHA="$(curl -sSLf --max-time 15 "$INTEL_URL" 2>/dev/null | shasum -a 256 | awk '{print $1}' || true)"
  if [[ -n "$FETCHED_SHA" && "$FETCHED_SHA" != "$EMPTY_SHA" ]]; then
    INTEL_SHA="$FETCHED_SHA"
  fi
fi

# Fallback if Intel is unavailable in a local single-arch build
if [[ -z "$INTEL_SHA" && -n "$ARM64_SHA" ]]; then
  INTEL_SHA="$ARM64_SHA"
fi
if [[ -z "$ARM64_SHA" && -n "$INTEL_SHA" ]]; then
  ARM64_SHA="$INTEL_SHA"
fi

if [[ -z "$ARM64_SHA" ]]; then
  echo "Warning: SHA256 checksums not found locally or remotely. Using placeholder." >&2
  ARM64_SHA="0000000000000000000000000000000000000000000000000000000000000000"
  INTEL_SHA="0000000000000000000000000000000000000000000000000000000000000000"
fi

mkdir -p "$(dirname "$OUT_FILE")"
mkdir -p Formula

# Generate Formula/look.rb
cat > "Formula/look.rb" <<EOF
class Look < Formula
  desc "Keyboard-first local launcher"
  homepage "https://github.com/${REPO_SLUG}"
  version "${VERSION}"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/${REPO_SLUG}/releases/download/v#{version}/Look-#{version}-macOS.zip"
      sha256 "${ARM64_SHA}"

      def install
        prefix.install "Look.app"
        bin.write_exec_script "#{prefix}/Look.app/Contents/MacOS/Look"
        mv "#{bin}/Look", "#{bin}/lookapp"
        ln_sf "#{bin}/lookapp", "#{bin}/lgtm"
      end
    end

    if Hardware::CPU.intel?
      url "https://github.com/${REPO_SLUG}/releases/download/v#{version}/Look-#{version}-macOS-x86_64.zip"
      sha256 "${INTEL_SHA}"

      def install
        prefix.install "Look.app"
        bin.write_exec_script "#{prefix}/Look.app/Contents/MacOS/Look"
        mv "#{bin}/Look", "#{bin}/lookapp"
        ln_sf "#{bin}/lookapp", "#{bin}/lgtm"
      end
    end
  end

  def caveats
    <<~EOS
      Look.app has been installed to #{opt_prefix}/Look.app.
      CLI binary available as 'lookapp' and 'lgtm'.
    EOS
  end

  test do
    assert_predicate prefix/"Look.app", :exist?
  end
end
EOF

# Generate Formula/lgtm.rb
cat > "Formula/lgtm.rb" <<EOF
class Lgtm < Formula
  desc "Keyboard-first local launcher"
  homepage "https://github.com/${REPO_SLUG}"
  version "${VERSION}"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/${REPO_SLUG}/releases/download/v#{version}/Look-#{version}-macOS.zip"
      sha256 "${ARM64_SHA}"

      def install
        prefix.install "Look.app"
        bin.write_exec_script "#{prefix}/Look.app/Contents/MacOS/Look"
        mv "#{bin}/Look", "#{bin}/lgtm"
        ln_sf "#{bin}/lgtm", "#{bin}/lookapp"
      end
    end

    if Hardware::CPU.intel?
      url "https://github.com/${REPO_SLUG}/releases/download/v#{version}/Look-#{version}-macOS-x86_64.zip"
      sha256 "${INTEL_SHA}"

      def install
        prefix.install "Look.app"
        bin.write_exec_script "#{prefix}/Look.app/Contents/MacOS/Look"
        mv "#{bin}/Look", "#{bin}/lgtm"
        ln_sf "#{bin}/lgtm", "#{bin}/lookapp"
      end
    end
  end

  def caveats
    <<~EOS
      Look.app has been installed to #{opt_prefix}/Look.app.
      CLI binary available as 'lgtm' and 'lookapp'.
    EOS
  end

  test do
    assert_predicate prefix/"Look.app", :exist?
  end
end
EOF

# If OUT_FILE was explicitly specified and not look.rb or lgtm.rb
if [[ "$OUT_FILE" != "Formula/look.rb" && "$OUT_FILE" != "Formula/lgtm.rb" ]]; then
  cp "Formula/look.rb" "$OUT_FILE"
fi

echo "Generated Homebrew formulas: Formula/look.rb and Formula/lgtm.rb (version: ${VERSION})"
