# Installation Guide for Jellyfin.Plugin.ThePornDB

## Quick Installation (Recommended)

### Method 1: Repository Installation (Easiest)
1. Open your Jellyfin server dashboard
2. Go to **Plugins** → **Repositories**
3. Click **Add Repository**
4. Enter this URL: `https://raw.githubusercontent.com/yurkoivan/THEPORND-JELLYFIN-PLUGIN-UPDATE/main/manifest.json`
5. Click **Save**
6. Go to **Plugins** → **Catalog**
7. Find **ThePornDB** and click **Install**
8. Restart your Jellyfin server

### Method 2: Manual Installation
1. Download the plugin file: [Jellyfin.Plugin.ThePornDB.zip](https://github.com/yurkoivan/THEPORND-JELLYFIN-PLUGIN-UPDATE/releases/download/v1.6.0.0/Jellyfin.Plugin.ThePornDB.zip)
2. Go to your Jellyfin server dashboard
3. Navigate to **Plugins** → **Catalog**
4. Click **Install from .zip**
5. Select the downloaded file
6. Restart your Jellyfin server

## Configuration
1. After installation, go to **Libraries** → **Your Adult Content Library**
2. Click **Manage Library** → **Metadata**
3. Enable **ThePornDB** as a metadata provider
4. Configure your ThePornDB API key (optional but recommended)
5. Save and scan your library

## Requirements
- Jellyfin Server 10.10.0 or higher
- .NET 8.0 runtime
- ThePornDB API key (optional)

## Support
- **Repository**: https://github.com/yurkoivan/THEPORND-JELLYFIN-PLUGIN-UPDATE
- **Issues**: https://github.com/yurkoivan/THEPORND-JELLYFIN-PLUGIN-UPDATE/issues

## Version Information
- **Current Version**: 1.6.0.0
- **Target Jellyfin**: 10.10.0.0
- **Framework**: .NET 8.0
