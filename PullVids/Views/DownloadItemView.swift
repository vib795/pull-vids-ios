import SwiftUI

struct DownloadItemView: View {
    @EnvironmentObject var downloadManager: DownloadManager
    let download: VideoDownload

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title and Status
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(download.title)
                        .font(.headline)
                        .lineLimit(2)

                    Text(statusText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                statusIcon
            }

            // Progress Bar
            if download.status == .downloading || download.status == .pending {
                VStack(alignment: .leading, spacing: 4) {
                    ProgressView(value: download.progress)
                        .progressViewStyle(LinearProgressViewStyle())

                    HStack {
                        Text(download.formattedProgress)
                            .font(.caption2)
                            .foregroundColor(.secondary)

                        Spacer()

                        Text("\(Int(download.progress * 100))%")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }

            // Action Buttons
            HStack(spacing: 12) {
                if download.status == .downloading {
                    Button(action: { downloadManager.pauseDownload(download) }) {
                        Label("Pause", systemImage: "pause.circle.fill")
                            .font(.caption)
                    }
                } else if download.status == .paused {
                    Button(action: { downloadManager.resumeDownload(download) }) {
                        Label("Resume", systemImage: "play.circle.fill")
                            .font(.caption)
                    }
                }

                if download.status == .downloading || download.status == .paused {
                    Button(action: { downloadManager.cancelDownload(download) }) {
                        Label("Cancel", systemImage: "xmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }

                if download.status == .completed, let localURL = download.localURL {
                    ShareLink(item: localURL) {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .font(.caption)
                    }
                }

                if download.status == .failed {
                    Button(action: {
                        downloadManager.addDownload(
                            url: download.url,
                            quality: download.quality,
                            format: download.format
                        )
                        downloadManager.deleteDownload(download)
                    }) {
                        Label("Retry", systemImage: "arrow.clockwise.circle.fill")
                            .font(.caption)
                    }
                }

                Spacer()

                Button(action: { downloadManager.deleteDownload(download) }) {
                    Image(systemName: "trash")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private var statusText: String {
        switch download.status {
        case .pending:
            return "Waiting to start..."
        case .downloading:
            return "Downloading..."
        case .completed:
            if let date = download.completedAt {
                return "Completed \(date.formatted(date: .abbreviated, time: .shortened))"
            }
            return "Completed"
        case .failed:
            return download.errorMessage ?? "Failed"
        case .paused:
            return "Paused"
        }
    }

    private var statusIcon: some View {
        Group {
            switch download.status {
            case .pending:
                ProgressView()
            case .downloading:
                Image(systemName: "arrow.down.circle.fill")
                    .foregroundColor(.blue)
            case .completed:
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            case .failed:
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(.red)
            case .paused:
                Image(systemName: "pause.circle.fill")
                    .foregroundColor(.orange)
            }
        }
        .font(.title2)
    }
}

#Preview {
    DownloadItemView(download: VideoDownload(url: "https://youtube.com/watch?v=test"))
        .environmentObject(DownloadManager())
        .padding()
}
