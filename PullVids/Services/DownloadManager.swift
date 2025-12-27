import Foundation
import AVFoundation
import Combine

class DownloadManager: NSObject, ObservableObject {
    @Published var downloads: [VideoDownload] = []
    @Published var isProcessing = false

    private var downloadTasks: [UUID: URLSessionDownloadTask] = [:]
    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier: "com.pullvids.download")
        config.isDiscretionary = false
        config.sessionSendsLaunchEvents = true
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()

    private let ytDlpAPIBaseURL = "https://api.cobalt.tools/api/json"

    override init() {
        super.init()
        loadDownloads()
    }

    func addDownload(url: String, quality: VideoQuality, format: DownloadFormat) {
        var download = VideoDownload(url: url, quality: quality, format: format)

        DispatchQueue.main.async {
            self.downloads.insert(download, at: 0)
        }

        fetchVideoInfo(for: download)
    }

    private func fetchVideoInfo(for download: VideoDownload) {
        guard let index = downloads.firstIndex(where: { $0.id == download.id }) else { return }

        Task {
            do {
                let info = try await getVideoMetadata(url: download.url)

                DispatchQueue.main.async {
                    self.downloads[index].title = info.title
                    self.downloads[index].thumbnail = info.thumbnail
                    self.startDownload(at: index)
                }
            } catch {
                DispatchQueue.main.async {
                    self.downloads[index].status = .failed
                    self.downloads[index].errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func getVideoMetadata(url: String) async throws -> (title: String, thumbnail: URL?) {
        guard let requestURL = URL(string: ytDlpAPIBaseURL) else {
            throw DownloadError.invalidURL
        }

        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "url": url,
            "vCodec": "h264",
            "vQuality": "720",
            "aFormat": "mp3",
            "isAudioOnly": false
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw DownloadError.networkError
        }

        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let status = json["status"] as? String,
           status == "stream" || status == "redirect",
           let urlString = json["url"] as? String {

            let title = extractTitle(from: url)
            return (title: title, thumbnail: nil)
        }

        throw DownloadError.videoInfoFetchFailed
    }

    private func extractTitle(from urlString: String) -> String {
        if let url = URL(string: urlString) {
            let pathComponents = url.pathComponents.filter { $0 != "/" }
            if let lastComponent = pathComponents.last {
                return lastComponent.replacingOccurrences(of: "-", with: " ")
                    .replacingOccurrences(of: "_", with: " ")
                    .capitalized
            }
        }
        return "Video"
    }

    private func startDownload(at index: Int) {
        guard index < downloads.count else { return }

        let download = downloads[index]

        Task {
            do {
                let downloadURL = try await getDownloadURL(for: download)

                guard let url = URL(string: downloadURL) else {
                    throw DownloadError.invalidURL
                }

                let task = session.downloadTask(with: url)
                downloadTasks[download.id] = task

                DispatchQueue.main.async {
                    self.downloads[index].status = .downloading
                }

                task.resume()
            } catch {
                DispatchQueue.main.async {
                    self.downloads[index].status = .failed
                    self.downloads[index].errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func getDownloadURL(for download: VideoDownload) async throws -> String {
        guard let requestURL = URL(string: ytDlpAPIBaseURL) else {
            throw DownloadError.invalidURL
        }

        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let isAudioOnly = download.format != .video
        let audioFormat = download.format == .audioMP3 ? "mp3" : "best"

        let body: [String: Any] = [
            "url": download.url,
            "vCodec": "h264",
            "vQuality": qualityToString(download.quality),
            "aFormat": audioFormat,
            "isAudioOnly": isAudioOnly
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw DownloadError.networkError
        }

        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let status = json["status"] as? String,
           (status == "stream" || status == "redirect"),
           let urlString = json["url"] as? String {
            return urlString
        }

        throw DownloadError.downloadURLFetchFailed
    }

    private func qualityToString(_ quality: VideoQuality) -> String {
        switch quality {
        case .auto: return "max"
        case .quality4K: return "2160"
        case .quality1080p: return "1080"
        case .quality720p: return "720"
        case .quality480p: return "480"
        case .quality360p: return "360"
        }
    }

    func pauseDownload(_ download: VideoDownload) {
        guard let task = downloadTasks[download.id],
              let index = downloads.firstIndex(where: { $0.id == download.id }) else { return }

        task.suspend()
        DispatchQueue.main.async {
            self.downloads[index].status = .paused
        }
    }

    func resumeDownload(_ download: VideoDownload) {
        guard let task = downloadTasks[download.id],
              let index = downloads.firstIndex(where: { $0.id == download.id }) else { return }

        task.resume()
        DispatchQueue.main.async {
            self.downloads[index].status = .downloading
        }
    }

    func cancelDownload(_ download: VideoDownload) {
        guard let task = downloadTasks[download.id],
              let index = downloads.firstIndex(where: { $0.id == download.id }) else { return }

        task.cancel()
        downloadTasks.removeValue(forKey: download.id)
        DispatchQueue.main.async {
            self.downloads.remove(at: index)
        }
    }

    func deleteDownload(_ download: VideoDownload) {
        guard let index = downloads.firstIndex(where: { $0.id == download.id }) else { return }

        if let localURL = download.localURL {
            try? FileManager.default.removeItem(at: localURL)
        }

        cancelDownload(download)
    }

    private func saveDownloads() {
        // Persist downloads to UserDefaults or local storage
    }

    private func loadDownloads() {
        // Load downloads from UserDefaults or local storage
    }
}

extension DownloadManager: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let downloadID = downloadTasks.first(where: { $0.value == downloadTask })?.key,
              let index = downloads.firstIndex(where: { $0.id == downloadID }) else { return }

        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destinationURL = documentsPath.appendingPathComponent("\(downloads[index].title).mp4")

        do {
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            try FileManager.default.moveItem(at: location, to: destinationURL)

            DispatchQueue.main.async {
                self.downloads[index].status = .completed
                self.downloads[index].localURL = destinationURL
                self.downloads[index].completedAt = Date()
                self.downloads[index].progress = 1.0
            }
        } catch {
            DispatchQueue.main.async {
                self.downloads[index].status = .failed
                self.downloads[index].errorMessage = error.localizedDescription
            }
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard let downloadID = downloadTasks.first(where: { $0.value == downloadTask })?.key,
              let index = downloads.firstIndex(where: { $0.id == downloadID }) else { return }

        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)

        DispatchQueue.main.async {
            self.downloads[index].progress = progress
            self.downloads[index].downloadedBytes = totalBytesWritten
            self.downloads[index].fileSize = totalBytesExpectedToWrite
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let error = error,
              let downloadID = downloadTasks.first(where: { $0.value == task as? URLSessionDownloadTask })?.key,
              let index = downloads.firstIndex(where: { $0.id == downloadID }) else { return }

        DispatchQueue.main.async {
            self.downloads[index].status = .failed
            self.downloads[index].errorMessage = error.localizedDescription
        }
    }
}

enum DownloadError: LocalizedError {
    case invalidURL
    case networkError
    case videoInfoFetchFailed
    case downloadURLFetchFailed
    case unsupportedPlatform

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL provided"
        case .networkError:
            return "Network error occurred"
        case .videoInfoFetchFailed:
            return "Failed to fetch video information"
        case .downloadURLFetchFailed:
            return "Failed to get download URL"
        case .unsupportedPlatform:
            return "This platform is not supported"
        }
    }
}
