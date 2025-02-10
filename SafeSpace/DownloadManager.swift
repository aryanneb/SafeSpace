//
//  DownloadManager.swift
//  SafeSpace
//
//  Created by Aryan Neb on 2025-02-10.
//

import Foundation
import SwiftUI
import LLM

// A manager that downloads the model file while publishing progress updates.
class DownloadManager: ObservableObject {
    @Published var progress: Double = 0.0
    @Published var isDownloading: Bool = false
    
    // A closure that is called when the download successfully completes.
    var onDownloadComplete: (() -> Void)?
    
    // Download the model file if needed.
    // This uses URLSession's async bytes API to stream data and update progress.
    func downloadModelIfNeeded() async {
        let localURL = Bot.localModelFileURL()
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: localURL.path) {
            await MainActor.run { self.isDownloading = true }
            print("Downloading model to \(localURL.path)...")
            do {
                // Stream the bytes.
                let (bytes, response) = try await URLSession.shared.bytes(from: Bot.remoteModelURL)
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                // Get total byte count from Content-Length header.
                guard let contentLengthString = httpResponse.allHeaderFields["Content-Length"] as? String,
                      let totalBytes = Int(contentLengthString) else {
                    throw URLError(.unknown)
                }
                
                var receivedBytes = 0
                var data = Data()
                var buffer = Data()
                
                // Stream the bytes, appending to our data and updating progress.
                for try await byte in bytes {
                    buffer.append(byte)
                    receivedBytes += 1
                    if buffer.count >= 4096 {
                        data.append(buffer)
                        buffer.removeAll(keepingCapacity: true)
                    }
                    
                    let currentProgress = Double(receivedBytes) / Double(totalBytes)
                    await MainActor.run {
                        self.progress = currentProgress
                    }
                }
                // Append any remaining bytes.
                if !buffer.isEmpty {
                    data.append(buffer)
                }
                try data.write(to: localURL)
                print("Download complete.")
                await MainActor.run {
                    self.progress = 1.0
                    self.isDownloading = false
                    self.onDownloadComplete?()
                }
            } catch {
                print("Download failed: \(error)")
                await MainActor.run { self.isDownloading = false }
            }
        } else {
            print("Model already exists locally.")
            await MainActor.run {
                self.onDownloadComplete?()
            }
        }
    }
}

// A SwiftUI view that shows a centered "Download Model" button.
// When tapped, it starts the download and shows a blue progress bar.
struct DownloadModelView: View {
    @StateObject var downloadManager = DownloadManager()
    
    var body: some View {
        VStack {
            if downloadManager.isDownloading {
                ProgressView(value: downloadManager.progress)
                    .progressViewStyle(LinearProgressViewStyle())
                    .accentColor(.blue)
                    .padding()
                Text("Downloading: \(Int(downloadManager.progress * 100))%")
                    .padding(.top, 4)
            } else {
                Button("Download Model") {
                    Task {
                        await downloadManager.downloadModelIfNeeded()
                    }
                }
                .font(.title)
                .padding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

struct DownloadModelView_Previews: PreviewProvider {
    static var previews: some View {
        DownloadModelView()
    }
}
