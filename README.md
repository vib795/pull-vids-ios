# PullVids iOS

<div align="center">

📱 **Download videos from 1000+ platforms on your iPhone**

A free, open-source iOS app for downloading videos and audio from YouTube, Vimeo, TikTok, Instagram, Twitter/X, and 1000+ other platforms.

</div>

## Features

- **1000+ Supported Platforms**: YouTube, Vimeo, TikTok, Instagram, Twitch, Twitter/X, Facebook, Reddit, and many more
- **Multiple Quality Options**: Download in 360p, 480p, 720p, 1080p, or 4K resolution
- **Audio Extraction**: Extract audio in MP3 or M4A format
- **Download Management**: Track progress, pause, resume, and cancel downloads
- **Video Library**: Browse and play your downloaded videos
- **Modern UI**: Beautiful SwiftUI interface optimized for iPhone 15+

## Requirements

- **iPhone 15 or newer**
- **iOS 17.0+**
- Active internet connection

## Installation

### Option 1: Build from Source

1. Clone this repository:
   ```bash
   git clone https://github.com/vib795/pull-vids-ios.git
   cd pull-vids-ios
   ```

2. Open `PullVids.xcodeproj` in Xcode

3. Select your development team in the Signing & Capabilities tab

4. Build and run on your device (⌘R)

### Option 2: TestFlight (Coming Soon)

TestFlight distribution coming soon!

## Usage

1. **Copy a video URL** from any supported platform
2. **Open PullVids** on your iPhone
3. **Paste the URL** into the download field
4. **Select quality and format** (optional)
5. **Tap Download** and wait for completion
6. **Access your downloads** in the Library tab

## Supported Platforms

### Popular Platforms
- YouTube (videos, playlists, channels)
- Vimeo
- TikTok
- Instagram (posts, reels, stories)
- Twitter/X
- Twitch (VODs, clips)
- Facebook
- Reddit

### And Many More
The app supports 1000+ video platforms through integration with powerful video download APIs.

## Architecture

**Tech Stack:**
- SwiftUI for the user interface
- Combine for reactive programming
- URLSession for network requests
- AVFoundation for video playback
- Background download support

**Project Structure:**
```
PullVids/
├── App/                    # App entry point
├── Views/                  # SwiftUI views
│   ├── ContentView.swift
│   ├── DownloadView.swift
│   ├── LibraryView.swift
│   └── ...
├── Models/                 # Data models
├── Services/              # Business logic
│   └── DownloadManager.swift
└── Resources/             # Assets and resources
```

## Limitations

### DRM-Protected Content
This app **cannot** download DRM-protected content from:
- Netflix
- Disney+
- Amazon Prime Video
- HBO Max
- Apple TV+
- Other subscription streaming services

This is due to legal and technical restrictions on DRM content.

### Legal Notice
Users are responsible for ensuring they have the right to download content. Respect copyright laws and platform terms of service.

## Privacy

- **No data collection**: This app does not collect, store, or transmit any personal data
- **Local storage**: All downloads are stored locally on your device
- **No analytics**: No tracking or analytics services are used

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Related Projects

- [pull-vids](https://github.com/vib795/pull-vids) - CLI version for macOS, Windows, and Linux

## License

This project is open source and available under the MIT License.

## Acknowledgments

- Built with SwiftUI
- Powered by video download APIs
- Inspired by the need for a free alternative to commercial download apps

## Disclaimer

This software is provided for educational purposes. The developers are not responsible for any misuse of this application. Please respect copyright laws and the terms of service of the platforms you download from.

---

Made with ❤️ for the iOS community
