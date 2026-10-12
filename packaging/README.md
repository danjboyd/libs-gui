# danjboyd/libs-gui: the carry branch

`carry` is GNUstep's libs-gui 0.32.0 (`gui-0_32_0`, the release MSYS2
packages) with the changes our Windows apps need before GNUstep has them.
It is what our MSIs ship. Every change of our own here is also a branch on
upstream master, meant to be sent upstream once it has proven itself;
nothing is sent without Dan's sign-off (the upstream policy in
plugins-themes-Adwaita's `Docs/UPSTREAM_POLICY.md`).

## What it carries

| Change | Source | Upstream |
| --- | --- | --- |
| MSYS2's patches to gnustep-gui 0.32.0 | msys2/MINGW-packages `mingw-w64-gnustep-gui`, 0.32.0-3 (9f888f32ed) | none: MSYS2 builds the 0.32.0 release tarball unpatched |

MSYS2's release tarball (`gnustep-gui-0.32.0.tar.gz`) has the same contents
as the `gui-0_32_0` tag, so `carry` starts from the tag. If MSYS2 adds a
patch, it goes on `carry` as its own commit naming the MSYS2 revision it
came from. Our own changes (per-monitor DPI first) will be listed here as
they arrive, each with its topic branch.

## The package

`packaging/msys2/PKGBUILD` is MSYS2's `mingw-w64-gnustep-gui` recipe, with
its configure flags and build environment, building this checkout. (It
also defines `__block` away, as libs-back's does, because Clang 23 rejects
the `__block` ivar in gnustep-base's headers.) Its
version, `0.32.0.N`, is newer than MSYS2's `0.32.0`, so pacman keeps it over
the stock package (until MSYS2 moves to a later release: then rebase
`carry` on it).

    cd packaging/msys2
    MINGW_ARCH=clang64 makepkg-mingw -Cf --nocheck
    pacman -U mingw-w64-clang-x86_64-gnustep-gui-0.32.0.N-1-any.pkg.tar.zst

A tag `carry-0.32.0.N` builds it in GitHub Actions
(`.github/workflows/msys2-package.yml`) and attaches it to a release of
that name; gnustep-packager's workflow installs it from there. Raise N
(the PKGBUILD's `pkgver`) for each release.

## Releasing with libs-back

gnustep-back is built against gnustep-gui and links to its DLL, and some
changes span both (gui asks, back answers). So gui and back carry releases
are made as a matched pair: when either `carry` branch changes, tag both
`danjboyd/libs-gui` and `danjboyd/libs-back` with the same
`carry-0.32.0.N`, built from carry heads that have been tested together,
and install both packages together. A gui release with no back change still
gets a back release of the same number, and the other way round.

## Keeping it current

- A change goes on its topic branch first (based on `upstream/master`),
  then is cherry-picked onto `carry`.
- When GNUstep releases, rebase the topic branches on upstream master,
  and rebuild `carry` on the new release tag (with whatever patches
  MSYS2's recipe for that release applies).
- When a change is merged upstream and released, it leaves `carry`.

The source of each released package is its tag here, which satisfies the
LGPL for the MSIs that ship it.
