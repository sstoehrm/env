# JVM toolchain through mise, which Omarchy ships and activates in its bash
# defaults. `omarchy install dev-env java` does the same thing.

mise_use java temurin-25
mise_use kotlin latest
mise_use maven latest
mise_use gradle latest

# mise has no visualvm plugin; Arch packages it directly.
pkg visualvm
