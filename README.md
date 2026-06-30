<div align="center">
  <h1>🎭 Fake Notification</h1>
  <p><strong>The ultimate, ultra-realistic local notification simulator with native Android injection.</strong></p>
  
  <p>
    <a href="https://flutter.dev"><img src="https://img.shields.io/badge/UI-Flutter-02569B?style=for-the-badge&logo=flutter" alt="Flutter"></a>
    <a href="https://kotlinlang.org"><img src="https://img.shields.io/badge/Backend-Kotlin-7F52FF?style=for-the-badge&logo=kotlin" alt="Kotlin"></a>
    <a href="https://github.com/fake-notification/releases"><img src="https://img.shields.io/badge/Download-APK-2ea44f?style=for-the-badge&logo=android" alt="Download"></a>
    <img src="https://img.shields.io/badge/License-MIT-blue?style=for-the-badge" alt="License">
  </p>
</div>

<br/>

<div align="center">
  <a href="https://github.com/fake-notification/releases/latest">
    <img src="https://img.shields.io/badge/⬇️_DOWNLOAD_LATEST_APK-Click_Here-brightgreen?style=for-the-badge&logo=android" alt="Download Latest Release" />
  </a>
</div>

<br/>

## 📸 Screenshots
<div align="center">
  <img src="https://raw.githubusercontent.com/thejulan/fake-notification/refs/heads/main/screenshot_home.png" width="250" alt="Home Screen" />
  &nbsp;&nbsp;&nbsp;&nbsp;
</div>
<p align="center"><i>Experience a breathtaking 2026 UI/UX built with pure Phosphor icons and the Outfit font.</i></p>

---

## ✨ Features
- **100% Native Spoofing:** We don't use standard Flutter plugins. The entire notification engine is custom-built in **Kotlin**. It queries your Android package manager to extract true system icons and spoofs the subtext app name perfectly.
- **Dynamic Variables & Looping:** Loop infinite notifications or set a specific burst count. Need realism? Auto-fill generates random order/transaction IDs on the fly!
- **Auto-Fill Data:** One tap to load up to 15 ultra-realistic texts from 20 different categories (WhatsApp, Instagram, Banking, Uber, Tinder, Deliveroo, etc.).
- **System App Visibility:** Gain the ability to select hidden system apps to generate notifications from standard system processes.
- **Save Your Presets:** Save complex setups (delays, selected apps, loop counts) into persistent local storage and launch them with a single tap.
- **Offline & Private:** Fake Notification requests *no* internet permission. All variations and operations occur strictly locally on your device.

## 🚀 Quick Start
1. Go to the [**Releases**](https://github.com/fake-notification/releases) page.
2. Download `app-release.apk`.
3. Install the APK on your Android device (ensure "Install from Unknown Sources" is allowed).
4. Launch the app, grant the requested notification permissions, and start spoofing!

## 🛠️ Building from Source
Because this app relies heavily on native Android Method Channels, ensure your Android SDK is up to date.

```bash
# Clone the repository
git clone https://github.com/fake-notification.git

# Navigate into the directory
cd fake-notification

# Get Flutter dependencies
flutter pub get

# Build the release APK
flutter build apk --release
```
The compiled APK will be available in `build/app/outputs/flutter-apk/app-release.apk`.

## 🛡️ Privacy Statement
Your data is yours. This app **does not** collect, store, or transmit any data externally. The `QUERY_ALL_PACKAGES` permission is solely utilized to populate the app selection list with your locally installed apps.

## 🤝 Contributing
Found a bug or have a brilliant idea for a new feature? 
We'd love to hear it! Open a [New Issue](https://github.com/fake-notification/issues/new) to report a bug or request a feature. Pull Requests are always welcome!

<div align="center">
  <sub>Built with ❤️ by Julan.</sub>
</div>
