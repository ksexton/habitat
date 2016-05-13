#!/bin/bash

git log HEAD~1..HEAD | grep -q '!!! Temporary Commit !!!'
is_tmp_commit=$?
studio_path=/hab/studios/travis-build
studio="hab-studio -r $studio_path"

# If we are not on a pull request, on the "auto" branch (which homu uses when
# auto-merging master), and not on a temporary commit, then run the publish
# script.
if [ "${TRAVIS_PULL_REQUEST}" = "false" ] &&
   [ "${TRAVIS_BRANCH}" = "auto" ] &&
   [[ $is_tmp_commit = 1 ]]; then
  set -ex
  components/studio/install.sh
  $studio new
  # Use environment variables set by Travis to write out the origin key
  openssl aes-256-cbc -K $encrypted_c4f852370b68_key -iv $encrypted_c4f852370b68_iv -in core-20160423193745.sig.key.enc -out $studio_path/hab/cache/keys/core-20160423193745.sig.key -d
  $studio build components/builder-web/plan
  $studio run "hab artifact upload /hab/cache/artifacts/core-habitat-builder-web-*"
else echo "Not on master; skipping publish"; fi