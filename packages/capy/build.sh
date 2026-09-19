#!/bin/sh
set -ex

# The @capysc/cli source tarball is declared as a Source in build.ncl
# (extract = true, strip_prefix), so its contents are already unpacked into the
# working directory. Build it from source rather than installing the prebuilt
# npm artifact.

# This package builds with tsc only; drop the binary/bundle tooling so the
# sandbox doesn't fetch @yao-pkg/pkg or esbuild (neither is used here).
npm pkg delete devDependencies.@yao-pkg/pkg devDependencies.esbuild
npm install                  # no committed lockfile upstream -> install, not ci
npm run build                # tsc -> dist/
npm pkg delete bin.capy-dev  # match the published artifact (upstream prepublishOnly)

# Pack the built package, then install the tarball into the output prefix.
# Packing first copies real files in; a bare `npm install -g .` would instead
# symlink back to the source dir, which escapes $OUTPUT_DIR.
npm pack
npm install -g --prefix="$OUTPUT_DIR/usr" ./*.tgz
