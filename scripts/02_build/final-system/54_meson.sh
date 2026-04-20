#!/bin/bash
# Final system 54/79 — Meson (build system)
set -euo pipefail
echo ">>> Meson"
cd /sources
tar -xf meson-*.tar.gz
cd meson-*/
pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
pip3 install --no-index --find-links dist meson
install -vDm644 data/shell-completions/bash/meson \
    /usr/share/bash-completion/completions/meson
install -vDm644 data/shell-completions/zsh/_meson \
    /usr/share/zsh/site-functions/_meson
cd /sources && rm -rf meson-*/
echo "<<< Meson done"
