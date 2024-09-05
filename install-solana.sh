#
# This file maintains the solana version for use by CI.
#

if [[ -n $SOLANA_VERSION ]]; then
  solana_version="$SOLANA_VERSION"
else
  solana_version=v2.0.3
fi

export solana_version="$solana_version"
export PATH="$HOME"/.local/share/solana/install/active_release/bin:"$PATH"
sh -c "$(curl -sSfL https://release.anza.xyz/$solana_version/install)"
solana --version
