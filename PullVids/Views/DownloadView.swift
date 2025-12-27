import SwiftUI

struct DownloadView: View {
    @EnvironmentObject var downloadManager: DownloadManager
    @State private var videoURL = ""
    @State private var selectedQuality: VideoQuality = .auto
    @State private var selectedFormat: DownloadFormat = .video
    @State private var showingOptions = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                        .padding(.top, 20)

                    Text("PullVids")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Download videos from 1000+ platforms")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()

                // URL Input Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "link")
                            .foregroundColor(.secondary)

                        TextField("Paste video URL here", text: $videoURL)
                            .textFieldStyle(.plain)
                            .autocapitalization(.none)
                            .keyboardType(.URL)
                            .disabled(downloadManager.isProcessing)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                    // Options Button
                    Button(action: {
                        showingOptions.toggle()
                    }) {
                        HStack {
                            Image(systemName: "gearshape.fill")
                            Text("Quality: \(selectedQuality.rawValue) • Format: \(selectedFormat.rawValue)")
                            Spacer()
                            Image(systemName: showingOptions ? "chevron.up" : "chevron.down")
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    }

                    if showingOptions {
                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Quality")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)

                                Picker("Quality", selection: $selectedQuality) {
                                    ForEach(VideoQuality.allCases) { quality in
                                        Text(quality.rawValue).tag(quality)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Format")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)

                                Picker("Format", selection: $selectedFormat) {
                                    ForEach(DownloadFormat.allCases) { format in
                                        Text(format.rawValue).tag(format)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }

                    // Download Button
                    Button(action: startDownload) {
                        HStack {
                            if downloadManager.isProcessing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                Text("Processing...")
                            } else {
                                Image(systemName: "arrow.down.circle.fill")
                                Text("Download")
                            }
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(videoURL.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(12)
                    }
                    .disabled(videoURL.isEmpty || downloadManager.isProcessing)
                }
                .padding()

                // Active Downloads
                if !downloadManager.downloads.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Downloads")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)

                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(downloadManager.downloads) { download in
                                    DownloadItemView(download: download)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }

                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func startDownload() {
        guard !videoURL.isEmpty else { return }

        downloadManager.addDownload(
            url: videoURL,
            quality: selectedQuality,
            format: selectedFormat
        )

        videoURL = ""
    }
}

#Preview {
    DownloadView()
        .environmentObject(DownloadManager())
}
