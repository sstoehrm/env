# `omarchy install dev-env node` is just `mise use --global node`.
#
# Pinned to the major only. This was 24, inherited from the main branch, while
# the machine had already moved to 26 -- with a version-aware mise_use that
# stale pin would have quietly downgraded node on the next run.
mise_use node 26
