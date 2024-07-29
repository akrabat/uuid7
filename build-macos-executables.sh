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
)

rm -rf release/
mkdir -p release

set -e
set -x

echo "$MACOS_CERTIFICATE" | base64 --decode > certificate.p12
security create-keychain -p password1234 build.keychain
security default-keychain -s build.keychain
security unlock-keychain -p password1234 build.keychain
security import certificate.p12 -k build.keychain -P "$MACOS_CERTIFICATE_PWD" -T /usr/bin/codesign
security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k password1234 build.keychain


for platform in "${platforms[@]}"
do
    platform_split=(${platform//\// })
    os=${platform_split[0]}
    GOOS=${platform_split[0]}
    GOARCH=${platform_split[1]}

    if [ $os = "darwin" ]; then
        os="macOS"
    fi

    output_name="$package_name"
    zip_name="$package_name"'-'$version'-'$os'-'$GOARCH

    echo "Building release/$zip_name..."
    env GOOS=$GOOS GOARCH=$GOARCH go build \
      -ldflags "-X github.com/akrabat/uuid7/commands.Version=$version" \
      -o release/$output_name
    if [ $? -ne 0 ]; then
        echo 'An error has occurred! Aborting the script execution...'
        exit 1
    fi

    pushd release > /dev/null || exit

    # List
    ls -l
    
    # sign with identity 3D8D...
    /usr/bin/codesign --force -s "$MACOS_IDENTITY_ID" "$output_name" -v

    # create zip file
    chmod a+x "$output_name"
    zip "$zip_name".zip "$output_name"
    rm "$output_name"

    popd > /dev/null || exit
done

security delete-keychain build.keychain
