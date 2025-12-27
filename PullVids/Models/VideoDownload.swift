import Foundation

enum DownloadStatus {
    case pending
    case downloading
    case completed
    case failed
    case paused
}

enum VideoQuality: String, CaseIterable, Identifiable {
    case auto = "Auto"
    case quality4K = "4K (2160p)"
    case quality1080p = "1080p"
    case quality720p = "720p"
    case quality480p = "480p"
    case quality360p = "360p"

    var id: String { self.rawValue }

    var height: Int {
        switch self {
        case .auto: return 0
        case .quality4K: return 2160
        case .quality1080p: return 1080
        case .quality720p: return 720
        case .quality480p: return 480
        case .quality360p: return 360
        }
    }
}

enum DownloadFormat: String, CaseIterable, Identifiable {
    case video = "Video"
    case audioMP3 = "Audio (MP3)"
    case audioM4A = "Audio (M4A)"

    var id: String { self.rawValue }
}

struct VideoDownload: Identifiable {
    let id: UUID
    var url: String
    var title: String
    var thumbnail: URL?
    var quality: VideoQuality
    var format: DownloadFormat
    var status: DownloadStatus
    var progress: Double
    var fileSize: Int64?
    var downloadedBytes: Int64
    var createdAt: Date
    var completedAt: Date?
    var localURL: URL?
    var errorMessage: String?

    init(url: String,
         quality: VideoQuality = .auto,
         format: DownloadFormat = .video) {
        self.id = UUID()
        self.url = url
        self.title = "Loading..."
        self.thumbnail = nil
        self.quality = quality
        self.format = format
        self.status = .pending
        self.progress = 0.0
        self.fileSize = nil
        self.downloadedBytes = 0
        self.createdAt = Date()
        self.completedAt = nil
        self.localURL = nil
        self.errorMessage = nil
    }

    var formattedFileSize: String {
        guard let size = fileSize else { return "Unknown" }
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }

    var formattedProgress: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file

        let downloaded = formatter.string(fromByteCount: downloadedBytes)
        if let total = fileSize {
            let totalSize = formatter.string(fromByteCount: total)
            return "\(downloaded) / \(totalSize)"
        }
        return downloaded
    }
}
