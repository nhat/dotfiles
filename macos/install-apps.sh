#!/bin/bash

set -euo pipefail

TMP_DIR="/tmp/app_installer"
mkdir -p "$TMP_DIR"

# List of apps: format "Name|URL"
# Usage for GitHub: "Name|github:username/repo"
APP_LIST=(
  "1Piece|https://app1piece.com/1Piece-4.2.1.zip"
  "BetterZip|https://macitbetter.com/BetterZip.zip"
  "Calendr|github:pakerwreah/calendr"
)

download_and_install() {
    local name="$1"
    local url="$2"
    local filename
    local filepath
    local app_dest="/Applications/$name.app"

    if [ -d "$app_dest" ]; then
        echo "$name is already installed. Skipping."
        return
    fi

    if [[ "$url" == github:* ]]; then
        # Parse github:username/repo
        gh_ref="${url#github:}"
        gh_user="${gh_ref%%/*}"
        gh_repo="${gh_ref#*/}"
        api_url="https://api.github.com/repos/$gh_user/$gh_repo/releases/latest"
        echo "Fetching latest release for $gh_user/$gh_repo from GitHub..."
        asset_url=$(curl -s "$api_url" | grep "browser_download_url" | grep -E '\.(zip|dmg|pkg)' | head -n 1 | cut -d '"' -f 4)
        if [ -z "$asset_url" ]; then
            echo "No downloadable asset found for $gh_user/$gh_repo."
            return
        fi
        url="$asset_url"
        filename=$(basename "${url%%\?*}")
        filepath="$TMP_DIR/$filename"
    else
        filename=$(basename "${url%%\?*}")
        filepath="$TMP_DIR/$filename"
    fi

    echo "Downloading $name from $url..."
    curl --http1.1 -# -L "$url" -o "$filepath"

    case "$filename" in
        *.zip)
            echo "Unzipping $filename..."
            unzip -q "$filepath" -d "$TMP_DIR/$name"
            app_path=$(find "$TMP_DIR/$name" -name "*.app" -maxdepth 2 | head -n 1)
            if [ -d "$app_path" ]; then
                echo "Installing $app_path to /Applications as $name..."
                cp -R "$app_path" "$app_dest"
            else
                echo "No .app found in zip for $name."
            fi
            ;;
        *.dmg)
            echo "Mounting $filename..."
            mount_dir=$(hdiutil attach "$filepath" -nobrowse | grep Volumes | awk '{print $3}')
            app_path=$(find "$mount_dir" -name "*.app" -maxdepth 2 | head -n 1)
            if [ -d "$app_path" ]; then
                echo "Installing $app_path to /Applications as $name..."
                cp -R "$app_path" "$app_dest"
            else
                echo "No .app found in dmg for $name."
            fi
            hdiutil detach "$mount_dir"
            ;;
        *.pkg)
            echo "Installing $filename..."
            sudo installer -pkg "$filepath" -target /
            ;;
        *)
            echo "Unknown file type for $filename. Skipping."
            ;;
    esac

    # Clean up downloaded file and extracted/mounted files
    if [[ "$filename" == *.zip ]]; then
        rm -rf "$filepath"
        # Remove extracted .app if it exists in TMP_DIR
        if [ -n "$app_path" ] && [[ "$app_path" == "$TMP_DIR/$name"* ]]; then
            rm -rf "$TMP_DIR/$name"
        fi
    elif [[ "$filename" == *.dmg ]]; then
        rm -rf "$filepath"
        # No need to remove .app, as it's copied from the mounted volume
    elif [[ "$filename" == *.pkg ]]; then
        rm -rf "$filepath"
    fi
}

# Main loop
for entry in "${APP_LIST[@]}"; do
    name="${entry%%|*}"
    url="${entry#*|}"
    download_and_install "$name" "$url"
done

echo "All done."
