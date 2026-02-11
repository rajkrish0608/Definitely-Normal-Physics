# Platform Build Configuration Guide

This document provides step-by-step instructions for configuring and generating builds for all target platforms.

## Prerequisites
- Godot 4.2+ (Standard Edition)
- Export templates installed (**Editor → Manage Export Templates → Download and Install**)

---

## 🖥️ Desktop Builds

### Windows (64-bit)
1. **Project → Export → Add → Windows Desktop**
2. **Settings:**
   - **Runnable:** ✅ Enabled
   - **Export PCK/Zip:** Disabled (embed resources)
   - **Executable Icon:** `res://icon.ico` (if available)
   - **Application → File Version:** `1.0.0.0`
   - **Application → Product Name:** `Definitely Normal Physics`
   - **Application → Company Name:** `[Your Studio]`
   - **Application → File Description:** `A precision platformer where physics lie.`
3. **Click "Export Project"** → Save as `DefinitelyNormalPhysics.exe`
4. **Create ZIP** containing `.exe` and `.pck` (if separate)

### macOS
1. **Project → Export → Add → macOS**
2. **Settings:**
   - **Application → Name:** `Definitely Normal Physics`
   - **Application → Icon:** `res://icon.icns` (macOS icon format)
   - **Application → Identifier:** `com.yourstudio.definitelynormalphysics`
   - **Application → Signature:** `[4-char code]`
   - **Code Signing:** Configure if publishing to App Store
3. **Export** → Save as `DefinitelyNormalPhysics.dmg` or `.app` bundle
4. **Notarize** if distributing outside App Store (macOS 10.15+)

### Linux (64-bit)
1. **Project → Export → Add → Linux/X11**
2. **Settings:**
   - **Binary Format → 64 Bits:** Enabled
   - **Texture Format → S3TC:** Enabled
3. **Export** → Save as `DefinitelyNormalPhysics.x86_64`
4. **Make executable:** `chmod +x DefinitelyNormalPhysics.x86_64`

---

## 📱 Mobile Builds

### Android
**Prerequisites:**
- Android SDK 33+ (Install via Android Studio or `sdkmanager`)
- Java JDK 17+
- Configure paths in **Editor → Editor Settings → Export → Android**:
  - `adb`: Path to `adb` executable
  - `jarsigner`: Path to `jarsigner`
  - `Debug Keystore`: Auto-generated or custom `.keystore` file

**Steps:**
1. **Project → Export → Add → Android**
2. **Settings:**
   - **Package → Unique Name:** `com.yourstudio.definitelynormalphysics`
   - **Package → Name:** `Definitely Normal Physics`
   - **Package → Version Name:** `1.0.0`
   - **Package → Version Code:** `1`
   - **Screen → Orientation → Portrait:** Disabled (Landscape or Sensor)
   - **Permissions:** No special permissions needed (remove unnecessary ones)
   - **Keystore → Debug/Release:** Configure for production builds
3. **Export All** → Generate `.apk` (debug) or `.aab` (Play Store)
4. **Test on device:** `adb install DefinitelyNormalPhysics.apk`

### iOS
**Prerequisites:**
- macOS with Xcode 14+
- Apple Developer Account ($99/year)

**Steps:**
1. **Project → Export → Add → iOS**
2. **Settings:**
   - **Application → Name:** `Definitely Normal Physics`
   - **Application → Bundle Identifier:** `com.yourstudio.definitelynormalphysics`
   - **Application → Version:** `1.0.0`
   - **Application → Short Version:** `1.0`
   - **Icons:** Provide all required sizes (20x20 to 1024x1024)
3. **Export Xcode Project** → Open in Xcode
4. **Configure Signing & Capabilities:**
   - Select Team
   - Provisioning Profile: Automatic or Manual
5. **Product → Archive** → Generate `.ipa`
6. **Upload to App Store Connect**

---

## 🌐 Web (HTML5) Build

1. **Project → Export → Add → Web**
2. **Settings:**
   - **HTML → Custom HTML Shell:** (Optional) Use custom `index.html` template
   - **HTML → Head Include:** Add analytics scripts if needed
   - **Variant → Threads:** **Disabled** (unless COOP/COEP headers configured)
   - **Variant → Extensions:** Disabled (not needed for vanilla GDScript)
   - **Texture Format → VRAM Compression:** Enabled (for faster load)
3. **Export** → Save to folder (generates `index.html`, `.wasm`, `.pck`)
4. **Test locally:**
   ```bash
   python3 -m http.server 8000
   # Open http://localhost:8000 in browser
   ```
5. **Deploy to itch.io:**
   - Zip the entire export folder
   - Upload to itch.io → Set "This file will be played in the browser"

---

## ✅ Pre-Release Checklist

- [ ] **Version number** updated in `project.godot`
- [ ] **Build all platforms** without errors
- [ ] **Test each build** on native hardware
- [ ] **Check file sizes** (Aim: <50MB for web, <100MB for mobile)
- [ ] **Icons** set for all platforms
- [ ] **Permissions** minimized (Android)
- [ ] **Code signing** configured (iOS, macOS)
- [ ] **Compliance:** COPPA, GDPR, age ratings set

---

## 📦 Distribution

| Platform | Distribution Method |
| :--- | :--- |
| **Windows / Linux** | itch.io, Steam, direct download from website |
| **macOS** | itch.io, Mac App Store, direct `.dmg` |
| **Android** | Google Play Store, itch.io, APK sideload |
| **iOS** | Apple App Store only (TestFlight for beta) |
| **Web** | itch.io, Newgrounds, Kongregate, self-hosted |
