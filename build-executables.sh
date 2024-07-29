#!/usr/bin/env bash

# From: https://stackoverflow.com/a/53583797/23060
# From: https://gist.github.com/DimaKoz/06b7475317b12e7ffa724ef0e115a4ec

version=$1
if [[ -z "$version" ]]; then
  echo "usage: $0 <version>"
  exit 1
fi
package_name=uuid7

#
# The full list of the platforms is at: https://golang.org/doc/install/source#environment
platforms=(
"darwin/amd64"
"darwin/arm64"
"linux/amd64"
"linux/arm"
"linux/arm64"
"windows/amd64"
"windows/arm64"
)

rm -rf release/
mkdir -p release

set -x

for platform in "${platforms[@]}"
do
    platform_split=(${platform//\// })
    os=${platform_split[0]}
    GOOS=${platform_split[0]}
    GOARCH=${platform_split[1]}

    if [ $os = "darwin" ]; then
        os="macOS"
    fi

    output_name=$package_name
    zip_name=$package_name'-'$version'-'$os'-'$GOARCH
    if [ $os = "windows" ]; then
        output_name+='.exe'
    fi

    echo "Building release/$zip_name..."
    env GOOS=$GOOS GOARCH=$GOARCH go build \
      -ldflags "-X github.com/akrabat/rodeo/commands.Version=$version" \
      -o release/$output_name
    if [ $? -ne 0 ]; then
        echo 'An error has occurred! Aborting the script execution...'
        exit 1
    fi

    pushd release > /dev/null
    if [ $os = "windows" ]; then
        zip $zip_name.zip $output_name
        rm $output_name
    else
        chmod a+x $output_name
        zip $zip_name.zip $output_name
        rm $output_name
    fi
    popd > /dev/null
done
