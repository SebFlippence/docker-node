#!/bin/bash
set -e

hash npm 2>/dev/null || { echo >&2 "npm not found, exiting."; }

cd $(cd ${0%/*} && pwd -P);

versions=( "$@" )
if [ ${#versions[@]} -eq 0 ]; then
	versions=( */ )
fi
versions=( "${versions[@]%/}" )

npmVersion="$(npm show npm version 2>/dev/null)"
for version in "${versions[@]}"; do
	fullVersion="$(curl -sSL --compressed 'http://nodejs.org/dist' | grep '<a href="v'"$version." | sed -E 's!.*<a href="v([^"/]+)/?".*!\1!' | cut -f 3 -d . | sort -n | tail -1)"
	(
		sed -E -i.bak '
			s/^(ENV NPM_VERSION) .*/\1 '"$npmVersion"'/;
		' "$version/Dockerfile" "$version/slim/Dockerfile" "$version/wheezy/Dockerfile" "$version/centos/Dockerfile"
		rm $version/Dockerfile.bak $version/slim/Dockerfile.bak $version/wheezy/Dockerfile.bak $version/centos/Dockerfile.bak
	)
done
