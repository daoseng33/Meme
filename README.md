# Meme

Meme is an iOS project dedicated to exploring, collecting, and sharing fun meme images.

## Features

- Browse random meme images
- Favorite memes you like
- Supports GIF, PNG, JPG formats
- Full-screen image preview
- Browse and search by categories
- Manage history and favorites
- One-tap sharing to social media
- Dark mode support

## Tech Stack

- Swift
- UIKit
- SnapKit: UI layout automation
- Realm: Local data storage
- RxSwift/RxCocoa: Reactive programming
- Firebase: Cloud backend & analytics
- Google AdMob: Advertising
- Fastlane: CI/CD automation
- SwiftGen: Resource code generation

## Installation & Run

1. Clone this repository
2. `cd Meme`
3. Open `Meme.xcworkspace` in Xcode
4. Install CocoaPods dependencies if needed (`pod install`)
5. Add `GoogleService-Info.plist` for Firebase integration (if required)
6. Build and run on simulator or device

## CI/CD

This project integrates Fastlane for one-command TestFlight delivery:

```shell
bundle install
bundle exec fastlane beta
```

## Screenshots

> You can find built-in meme images in `Meme/Generated/XCAssets+Generated.swift` or preview them full-screen in the app.

## Contact

For suggestions or bug reports, please contact the developer via the Settings page or email <developer_email>.

---

© 2024 daoseng33. For learning and demonstration purposes only.
