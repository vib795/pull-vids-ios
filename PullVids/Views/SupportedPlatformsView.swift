import SwiftUI

struct SupportedPlatformsView: View {
    @State private var searchText = ""

    var filteredPlatforms: [SupportedPlatform] {
        if searchText.isEmpty {
            return SupportedPlatformsData.platforms
        }
        return SupportedPlatformsData.platforms.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("1000+ Supported Platforms")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("Download videos from your favorite platforms")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.top)

                    // Popular Platforms
                    LazyVStack(spacing: 12) {
                        ForEach(filteredPlatforms) { platform in
                            PlatformCard(platform: platform)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Platforms")
            .searchable(text: $searchText, prompt: "Search platforms")
        }
    }
}

struct PlatformCard: View {
    let platform: SupportedPlatform

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: platform.icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 40, height: 40)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)

                VStack(alignment: .leading, spacing: 4) {
                    Text(platform.name)
                        .font(.headline)

                    if !platform.examples.isEmpty {
                        Text(platform.examples.joined(separator: ", "))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }

                Spacer()

                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    SupportedPlatformsView()
}
