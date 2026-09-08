# Omarchy's dev-env runs the rustup.rs shell installer; on Arch the packaged
# rustup is the same tool, kept current by pacman and without a second copy
# under ~/.cargo.

pkg rustup

if rustup show active-toolchain >/dev/null 2>&1; then
  skip "rust toolchain already selected"
else
  info "installing the stable toolchain"
  rustup default stable
fi
