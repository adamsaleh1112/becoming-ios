import Foundation
import AVFoundation
import Photos

class VideoManager: ObservableObject {
    @Published var videoEntries: [VideoEntry] = []
    @Published var isRecording: Bool = false
    @Published var recordingDuration: TimeInterval = 0
    
    private let maxRecordingDuration: TimeInterval = 600 // 10 minutes
    private var recordingTimer: Timer?
    
    // Cache documents path for performance
    private lazy var documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    // Background queue for file operations
    private let fileQueue = DispatchQueue(label: "video.file.operations", qos: .utility)
    
    init() {
        loadVideoEntries()
    }
    
    func startRecording() {
        isRecording = true
        recordingDuration = 0
        
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.recordingDuration += 1.0
            if self.recordingDuration >= self.maxRecordingDuration {
                self.stopRecording()
            }
        }
    }
    
    func stopRecording() {
        isRecording = false
        recordingTimer?.invalidate()
        recordingTimer = nil
    }
    
    func saveVideo(url: URL, rating: Int? = nil) {
        let timestamp = Date().timeIntervalSince1970
        let fileName = "video_\(timestamp).mp4"
        let destinationURL = documentsPath.appendingPathComponent(fileName)
        
        fileQueue.async { [weak self] in
            guard let self = self else { return }
            
            // Generate thumbnail first (faster on background queue)
            let thumbnailFilename = self.generateThumbnail(for: url, timestamp: timestamp)
            
            // Export with compression
            let asset = AVURLAsset(url: url)
            guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPreset1920x1080) else {
                try? FileManager.default.copyItem(at: url, to: destinationURL)
                self.createVideoEntry(fileName: fileName, thumbnailFilename: thumbnailFilename, rating: rating)
                return
            }
            
            exportSession.outputURL = destinationURL
            exportSession.outputFileType = .mp4
            exportSession.shouldOptimizeForNetworkUse = true
            
            exportSession.exportAsynchronously {
                self.createVideoEntry(fileName: fileName, thumbnailFilename: thumbnailFilename, rating: rating)
                try? FileManager.default.removeItem(at: url)
            }
        }
    }
    
    private func createVideoEntry(fileName: String, thumbnailFilename: String?, rating: Int?) {
        DispatchQueue.main.async {
            let videoEntry = VideoEntry(
                date: Date(),
                videoFilename: fileName,
                duration: self.recordingDuration,
                thumbnailFilename: thumbnailFilename,
                rating: rating
            )
            
            self.videoEntries.insert(videoEntry, at: 0)
            self.saveVideoEntries()
        }
    }
    
    private func generateThumbnail(for videoURL: URL, timestamp: TimeInterval) -> String? {
        let asset = AVURLAsset(url: videoURL, options: [
            AVURLAssetPreferPreciseDurationAndTimingKey: false,
            AVURLAssetReferenceRestrictionsKey: AVAssetReferenceRestrictions.forbidAll.rawValue
        ])
        
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.maximumSize = CGSize(width: 300, height: 533) // Direct target size
        imageGenerator.requestedTimeToleranceBefore = .zero
        imageGenerator.requestedTimeToleranceAfter = CMTime(seconds: 0.5, preferredTimescale: 1)
        
        let time = CMTime(seconds: 0.5, preferredTimescale: 1)
        
        do {
            let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            let filename = "thumb_\(timestamp).jpg"
            let thumbnailURL = documentsPath.appendingPathComponent(filename)
            
            // Create CGContext for more efficient rendering
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            guard let context = CGContext(data: nil, width: 300, height: 533, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
                return nil
            }
            
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: 300, height: 533))
            
            guard let resizedCGImage = context.makeImage() else { return nil }
            
            // Convert to JPEG data directly
            let mutableData = NSMutableData()
            guard let destination = CGImageDestinationCreateWithData(mutableData, "public.jpeg" as CFString, 1, nil) else {
                return nil
            }
            
            CGImageDestinationAddImage(destination, resizedCGImage, [kCGImageDestinationLossyCompressionQuality: 0.6] as CFDictionary)
            
            if CGImageDestinationFinalize(destination) {
                try mutableData.write(to: thumbnailURL)
                return filename
            }
        } catch {
            print("Error generating thumbnail: \(error)")
        }
        
        return nil
    }
    
    func getVideoForDate(_ date: Date) -> VideoEntry? {
        return videoEntries.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    func hasRecordedToday() -> Bool {
        return getVideoForDate(Date()) != nil
    }
    
    func getVideosFromLastYear() -> [VideoEntry] {
        let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        return videoEntries.filter { $0.date >= oneYearAgo }
    }
    
    func getVideoFromSameDateLastYear() -> VideoEntry? {
        let lastYear = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        return videoEntries.first { Calendar.current.isDate($0.date, inSameDayAs: lastYear) }
    }
    
    private func loadVideoEntries() {
        if let data = UserDefaults.standard.data(forKey: "videoEntries"),
           let entries = try? JSONDecoder().decode([VideoEntry].self, from: data) {
            videoEntries = entries.sorted { $0.date > $1.date }
        }
    }
    
    private func saveVideoEntries() {
        if let data = try? JSONEncoder().encode(videoEntries) {
            UserDefaults.standard.set(data, forKey: "videoEntries")
        }
    }
    
    func deleteVideo(_ entry: VideoEntry) {
        guard let index = videoEntries.firstIndex(where: { $0.id == entry.id }) else { return }
        
        videoEntries.remove(at: index)
        saveVideoEntries()
        
        // Delete files on background queue
        fileQueue.async {
            try? FileManager.default.removeItem(at: self.documentsPath.appendingPathComponent(entry.videoFilename))
            if let thumbnailFilename = entry.thumbnailFilename {
                try? FileManager.default.removeItem(at: self.documentsPath.appendingPathComponent(thumbnailFilename))
            }
        }
    }
    
    func resetAllVideos() {
        // Delete all video and thumbnail files
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        for entry in videoEntries {
            try? FileManager.default.removeItem(at: documentsPath.appendingPathComponent(entry.videoFilename))
            if let thumbnailFilename = entry.thumbnailFilename {
                try? FileManager.default.removeItem(at: documentsPath.appendingPathComponent(thumbnailFilename))
            }
        }
        
        // Clear all entries
        videoEntries.removeAll()
        saveVideoEntries()
    }
}
