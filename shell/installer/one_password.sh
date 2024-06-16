#!/usr/bin/env sh

if ! has curl; then
    log_error "curl is required to install 1Password CLI" 69
fi

if ! has unzip; then
    log_error "unzip is required to install 1Password CLI" 69
fi

op_install() {
    BIN_DIR=${BIN_DIR:-$HOME/.local/bin}
    VERSION=${1:-2.25.1}

    # Get the system architecture
    ARCH=$(uname -m)

    # convert uname -m to 386/amd64/arm/arm64 for use in the URL
    case $ARCH in
        x86_64) ARCH=amd64 ;;
        i386) ARCH=386 ;;
    esac

    curl -s "https://cache.agilebits.com/dist/1P/op2/pkg/v${VERSION}/op_linux_${ARCH}_v${VERSION}.zip" -o /tmp/op.zip
    unzip -o /tmp/op.zip -d /tmp > /dev/null
    mv /tmp/op "$BIN_DIR/op"
    rm -rf /tmp/op*
    log_success "1Password CLI has been installed to $BIN_DIR"
}

op_install "$@"