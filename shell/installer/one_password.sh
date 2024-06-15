#!/usr/bin/env sh

if ! has curl; then
    echo "curl is required to install 1Password CLI"
    return 1
fi

if ! has unzip; then
    echo "unzip is required to install 1Password CLI"
    return 1
fi


op_install() {
    BIN_DIR=${BIN_DIR:-$HOME/.local/bin}

    # Get the system architecture
    ARCH=$(uname -m)

    # convert uname -m to 386/amd64/arm/arm64 for use in the URL
    case $ARCH in
        x86_64) ARCH=amd64 ;;
        i386) ARCH=386 ;;
    esac

    curl -s "https://cache.agilebits.com/dist/1P/op2/pkg/v2.25.1/op_linux_${ARCH}_v2.25.1.zip" -o /tmp/op.zip
    unzip -o /tmp/op.zip -d /tmp
    mv /tmp/op "$BIN_DIR/op"
    rm -rfv /tmp/op*
}

op_install "$@"