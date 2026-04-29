# Facet — Setup Guide

## 1. Create the Xcode Project

1. Open Xcode → **File → New → Project**
2. Choose **iOS → App**
3. Set:
   - Product Name: `Facet`
   - Interface: `SwiftUI`
   - Language: `Swift`
   - Uncheck "Include Tests" (add later)
4. Save inside `/Desktop/iOSApps/Facet/`
5. Delete the auto-generated `ContentView.swift`
6. Drag all folders (`App/`, `Domain/`, `Data/`, `Presentation/`) into Xcode's project navigator
   - Check **"Copy items if needed"** and **"Create groups"**

---

## 2. Host `home.json` on GitHub Gist (Free, Instant)

This is the recommended option — no backend, no cost, versioned.

### Steps:
1. Go to https://gist.github.com
2. Filename: `home.json`
3. Paste the contents of `home.json` (in this folder)
4. Click **"Create public gist"**
5. Click **Raw** → copy the URL

   It looks like:
   ```
   https://gist.githubusercontent.com/YOUR_USERNAME/abc123.../raw/home.json
   ```

6. Open `App/AppConfiguration.swift` and replace:
   ```swift
   "home": URL(string: "https://gist.githubusercontent.com/YOUR_GITHUB_USERNAME/YOUR_GIST_ID/raw/home.json")!
   ```
   with your actual raw URL.

> **To update UI later:** Edit the gist. No App Store update needed. This is the magic of SDUI.

---

## 3. Alternative: JSONBin.io

For a slightly more API-like experience with versioning:

1. Go to https://jsonbin.io → Sign up (free)
2. Create a new bin → paste `home.json`
3. Get your bin URL: `https://api.jsonbin.io/v3/b/YOUR_BIN_ID/latest`
4. Add header `X-Master-Key: YOUR_KEY` to `NetworkService.fetch()`

---

## 4. Switch to Live Data for App Store Build

In `FacetApp.swift`, the `#if DEBUG` block uses `MockScreenRepository`.
The `#else` block (Release build) uses `RemoteScreenRepository` with your Gist URL.

To test the live path in Simulator: **Product → Scheme → Edit Scheme → set Build Configuration to Release**.

---

## 5. Add Info.plist Privacy Key

Since the app loads remote images, add to `Info.plist`:
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
</dict>
```

Gist URLs are HTTPS so no special exceptions needed.
