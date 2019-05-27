#!/usr/bin/env bash
#
# This is the release script.
# It installs hub and prepares a release
#
# Execution Requirements:
#   - GITHUB_TOKEN variable set with GitHub token
#   - github/hub being acccessible so that we download and use it
#
# Copyright: SPDX-License-Identifier: GPL-3.0-or-later
#
# Author: Pawel Krupa (@paulfantom)
# Author: Pavlos Emm. Katsoulakis (paul@netdata.cloud)

set -e

# If we are not in netdata git repo, at the top level directory, fail
TOP_LEVEL=$(basename "$(git rev-parse --show-toplevel)")
CWD=$(git rev-parse --show-cdup || echo "")
if [ -n "${CWD}" ] || [ ! "${TOP_LEVEL}" == "go.d.plugin" ]; then
    echo "Run as .travis/$(basename "$0") from top level directory of go.d.plugin local git repository"
    echo "Changelog generation process aborted"
    exit 1
fi

if [ -z ${TRAVIS_TAG+x} ]; then
	echo "Nothing to do - TRAVIS_TAG is not defined (val:${TRAVIS_TAG})"
	exit 0
fi

HUB_VERSION=${HUB_VERSION:-"2.7.0"}

echo "--- Download hub version: ${HUB_VERSION} ---"
wget "https://github.com/github/hub/releases/download/v${HUB_VERSION}/hub-linux-amd64-${HUB_VERSION}.tgz" -O "/tmp/hub-linux-amd64-${HUB_VERSION}.tgz"
tar -C /tmp -xvf "/tmp/hub-linux-amd64-${HUB_VERSION}.tgz"
export PATH=$PATH:"/tmp/hub-linux-amd64-${HUB_VERSION}/bin"

for i in bin/*; do
	echo "--- Call hub to Release ${TRAVIS_TAG} for ${i} ---"
	hub release edit -a "${i}" -m "${TRAVIS_TAG}" "${TRAVIS_TAG}"
	sleep 2
done

echo "---- Submit PR to netdata/netdata to sync new version information ----"
./.travis/netdata_sync.sh
