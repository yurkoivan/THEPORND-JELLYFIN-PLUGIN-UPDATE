# Creating GitHub Releases for ThePornDB Plugin

## Overview
Your manifest.json now includes the complete version history. To make all versions available for installation, you need to create GitHub releases for each version.

## Current Status
- ✅ **Repository**: https://github.com/yurkoivan/THEPORND-JELLYFIN-PLUGIN-UPDATE
- ✅ **Manifest**: Updated with complete version history
- ✅ **Latest Version**: v1.6.0.0 (ready for release)
- ⏳ **Historical Versions**: Need to be created

## Required Releases

### 1. Latest Release (v1.6.0.0) - PRIORITY
**Status**: Ready to create
- **Tag**: v1.6.0.0
- **File**: Jellyfin.Plugin.ThePornDB.zip (66KB)
- **Target**: Jellyfin 10.10.0.0
- **Description**: Jellyfin 10.10 compatibility update; framework to net8.0; dependency bump.

### 2. Historical Releases (Optional)
These are for users who need older versions:

- **v1.5.0.10**: Fixed missing performer image on init
- **v1.4.0.9**: Fixed search with id; Removed obsolete task
- **v1.3.0.8**: Added Support Jellyfin 10.9; Remove Obsolete Externalds
- **v1.2.0.7**: Changed Endpoint; Added Movies, JAV Support
- **v1.1.0.6**: Added Latest Jellyfin Support (10.8.0)
- **v1.0.5.5**: Reworked collections; Added logo for Emby
- **v1.0.4.4**: Added Creating Collections based on studios
- **v1.0.3.3**: Added HTTP caching; Added using FilePath for search
- **v1.0.2.2**: Added custom title; Added more studio
- **v1.0.1.1**: Added Performers Provider
- **v1.0.0.0**: Initial Release

## Quick Setup Instructions

### Step 1: Create the Main Release (v1.6.0.0)
1. Go to: https://github.com/yurkoivan/THEPORND-JELLYFIN-PLUGIN-UPDATE/releases
2. Click "Create a new release"
3. **Tag version**: `v1.6.0.0`
4. **Release title**: `ThePornDB Plugin v1.6.0.0 - Jellyfin 10.10 Support`
5. **Description**:
   ```
   ## What's New in v1.6.0.0
   - ✅ Jellyfin 10.10 compatibility
   - ✅ Framework updated to .NET 8.0
   - ✅ Dependency updates
   - ✅ Improved metadata provider for adult content
   
   ## Installation
   ### Repository Method (Recommended)
   Add this URL to Jellyfin: `https://raw.githubusercontent.com/yurkoivan/THEPORND-JELLYFIN-PLUGIN-UPDATE/main/manifest.json`
   
   ### Manual Installation
   Download the attached .zip file and install via Jellyfin's plugin manager.
   
   ## Requirements
   - Jellyfin Server 10.10.0 or higher
   - .NET 8.0 runtime
   ```
6. **Upload**: Drag `Jellyfin.Plugin.ThePornDB.zip` from your project folder
7. Click "Publish release"

### Step 2: Verify Installation
After creating the release, users can install your plugin by:
1. Adding your repository URL to Jellyfin
2. Installing from the plugin catalog
3. Or downloading the .zip file manually

## Repository URL for Users
```
https://raw.githubusercontent.com/yurkoivan/THEPORND-JELLYFIN-PLUGIN-UPDATE/main/manifest.json
```

## Notes
- The manifest.json now points all version URLs to your repository
- Users can install any version they need
- Your plugin will appear in Jellyfin's plugin catalog once the repository is added
- The latest version (v1.6.0.0) is the most important to release first
