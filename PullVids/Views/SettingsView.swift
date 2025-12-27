import SwiftUI

struct SettingsView: View {
    @AppStorage("autoSaveToPhotos") private var autoSaveToPhotos = false
    @AppStorage("downloadQuality") private var defaultQuality = "Auto"
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true

    var body: some View {
        NavigationView {
            Form {
                Section("Downloads") {
                    Toggle("Auto Save to Photos", isOn: $autoSaveToPhotos)

                    Picker("Default Quality", selection: $defaultQuality) {
                        ForEach(VideoQuality.allCases) { quality in
                            Text(quality.rawValue).tag(quality.rawValue)
                        }
                    }

                    Toggle("Download Notifications", isOn: $notificationsEnabled)
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }

                    Link(destination: URL(string: "https://github.com/vib795/pull-vids")!) {
                        HStack {
                            Text("GitHub Repository")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                        }
                    }

                    HStack {
                        Text("Platform Support")
                        Spacer()
                        Text("iPhone 15+")
                            .foregroundColor(.secondary)
                    }
                }

                Section("Legal") {
                    NavigationLink("Terms of Service") {
                        LegalTextView(title: "Terms of Service", content: termsOfService)
                    }

                    NavigationLink("Privacy Policy") {
                        LegalTextView(title: "Privacy Policy", content: privacyPolicy)
                    }

                    Text("DRM Notice")
                        .foregroundColor(.primary)

                    Text("This app cannot download DRM-protected content from Netflix, Disney+, Amazon Prime Video, or similar streaming services due to legal restrictions.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Section {
                    Button("Clear Download History") {
                        // Clear history logic
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
        }
    }

    private var termsOfService: String {
        """
        Terms of Service for PullVids

        Last Updated: December 2024

        1. Acceptance of Terms
        By using PullVids, you agree to these terms of service.

        2. Use Restrictions
        - You may only download content you have the right to download
        - Do not use this app to infringe on copyrights
        - Do not download DRM-protected content
        - Respect platform terms of service

        3. Disclaimer
        PullVids is provided "as is" without warranty of any kind.

        4. Liability
        We are not responsible for how you use this software.
        """
    }

    private var privacyPolicy: String {
        """
        Privacy Policy for PullVids

        Last Updated: December 2024

        1. Data Collection
        PullVids does not collect, store, or transmit any personal data.

        2. Local Storage
        All downloads are stored locally on your device.

        3. Network Access
        The app only accesses the internet to download videos you request.

        4. Third-Party Services
        We use yt-dlp for video downloading, which may contact video platforms directly.
        """
    }
}

struct LegalTextView: View {
    let title: String
    let content: String

    var body: some View {
        ScrollView {
            Text(content)
                .padding()
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SettingsView()
}
