import Foundation
import SwiftUI

struct VideoEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    let videoFilename: String
    let duration: TimeInterval
    let thumbnailFilename: String?
    let rating: Int? // 1-10 day rating
    
    // Cache documents path for performance
    private static let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    init(id: UUID? = nil, date: Date, videoFilename: String, duration: TimeInterval, thumbnailFilename: String? = nil, rating: Int? = nil) {
        self.id = id ?? UUID()
        self.date = date
        self.videoFilename = videoFilename
        self.duration = duration
        self.thumbnailFilename = thumbnailFilename
        self.rating = rating
    }
    
    // Rating color based on 1-10 scale
    var ratingColor: Color {
        guard let rating = rating else { return .gray }
        switch rating {
        case 1...2: return Color(red: 0.5, green: 0, blue: 0) // Dark red
        case 3...4: return .red
        case 5...6: return .orange
        case 7...8: return .yellow
        case 9...10: return .green
        default: return .gray
        }
    }
    
    // Optimized URL properties using cached documents path
    var videoURL: URL {
        Self.documentsPath.appendingPathComponent(videoFilename)
    }
    
    var thumbnailURL: URL? {
        thumbnailFilename.map { Self.documentsPath.appendingPathComponent($0) }
    }
    
    var daysSinceRecording: Int {
        Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 0
    }
    
    var isFromToday: Bool {
        Calendar.current.isDate(date, inSameDayAs: Date())
    }
    
    var isFromYesterday: Bool {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        return Calendar.current.isDate(date, inSameDayAs: yesterday)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
