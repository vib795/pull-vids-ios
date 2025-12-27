import SwiftUI
import AVKit

struct LibraryView: View {
    @EnvironmentObject var downloadManager: DownloadManager

    var completedDownloads: [VideoDownload] {
        downloadManager.downloads.filter { $0.status == .completed }
    }

    var body: some View {
        NavigationView {
            Group {
                if completedDownloads.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(completedDownloads) { download in
                                LibraryItemView(download: download)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Library")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "folder")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text("No Downloads Yet")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Your completed downloads will appear here")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct LibraryItemView: View {
    @EnvironmentObject var downloadManager: DownloadManager
    @State private var showingPlayer = false
    let download: VideoDownload

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Thumbnail and Play Button
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray5))
                    .aspectRatio(16/9, contentMode: .fit)

                if download.format == .video {
                    Button(action: { showingPlayer = true }) {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                            .shadow(radius: 4)
                    }
                } else {
                    Image(systemName: "music.note")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                }
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(download.title)
                    .font(.headline)
                    .lineLimit(2)

                HStack {
                    Image(systemName: download.format == .video ? "video.fill" : "music.note")
                        .font(.caption)

                    Text(download.formattedFileSize)
                        .font(.caption)

                    Text("•")
                        .font(.caption)

                    if let date = download.completedAt {
                        Text(date.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                    }
                }
                .foregroundColor(.secondary)
            }

            // Actions
            HStack(spacing: 12) {
                if let localURL = download.localURL {
                    ShareLink(item: localURL) {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .font(.subheadline)
                    }
                    .buttonStyle(.bordered)
                }

                Spacer()

                Button(action: { downloadManager.deleteDownload(download) }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .sheet(isPresented: $showingPlayer) {
            if let url = download.localURL {
                VideoPlayerView(url: url)
            }
        }
    }
}

struct VideoPlayerView: View {
    let url: URL
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VideoPlayer(player: AVPlayer(url: url))
                .ignoresSafeArea()
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
        }
    }
}

#Preview {
    LibraryView()
        .environmentObject(DownloadManager())
}
