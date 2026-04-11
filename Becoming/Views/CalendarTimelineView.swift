import SwiftUI

struct CalendarTimelineView: View {
    @EnvironmentObject var videoManager: VideoManager
    @State private var selectedDate = Date()
    @State private var showingVideoPlayer = false
    @State private var selectedVideo: VideoEntry?
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 30) {
            // Month Header (centered, no arrows)
            Text(dateFormatter.string(from: selectedDate))
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white)
            
            // Swipable Calendar Container
            VStack(spacing: 12) {
                // Day headers
                HStack {
                    ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                        Text(day)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .frame(height: 20)
                    }
                }
                
                // Calendar Grid with swipe gestures
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
                    ForEach(calendarDays, id: \.self) { date in
                        CalendarDayView(
                            date: date,
                            hasVideo: hasVideoForDate(date),
                            isCurrentMonth: calendar.isDate(date, equalTo: selectedDate, toGranularity: .month),
                            isToday: calendar.isDateInToday(date)
                        ) {
                            if let video = videoManager.getVideoForDate(date) {
                                selectedVideo = video
                                showingVideoPlayer = true
                            }
                        }
                    }
                }
                .gesture(
                    DragGesture()
                        .onEnded { gesture in
                            let threshold: CGFloat = 50
                            if gesture.translation.x > threshold {
                                // Swipe right - go to previous month
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    previousMonth()
                                }
                            } else if gesture.translation.x < -threshold {
                                // Swipe left - go to next month
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    nextMonth()
                                }
                            }
                        }
                )
            }
        }
        .sheet(isPresented: $showingVideoPlayer) {
            if let video = selectedVideo {
                VideoPlayerView(videoURL: video.videoURL, entry: video)
            }
        }
    }
    
    private var calendarDays: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: selectedDate) else {
            return []
        }
        
        let monthFirstWeekday = calendar.component(.weekday, from: monthInterval.start)
        let daysToSubtract = monthFirstWeekday - 1
        
        guard let startDate = calendar.date(byAdding: .day, value: -daysToSubtract, to: monthInterval.start) else {
            return []
        }
        
        var days: [Date] = []
        var currentDate = startDate
        
        // Generate 42 days (6 weeks) to fill the calendar grid
        for _ in 0..<42 {
            days.append(currentDate)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
                break
            }
            currentDate = nextDate
        }
        
        return days
    }
    
    private func hasVideoForDate(_ date: Date) -> Bool {
        return videoManager.getVideoForDate(date) != nil
    }
    
    private func previousMonth() {
        guard let newDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) else { return }
        selectedDate = newDate
    }
    
    private func nextMonth() {
        guard let newDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) else { return }
        selectedDate = newDate
    }
}

struct CalendarDayView: View {
    let date: Date
    let hasVideo: Bool
    let isCurrentMonth: Bool
    let isToday: Bool
    let onTap: () -> Void
    
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 8)
                    .fill(backgroundColor)
                    .frame(height: 50)
                
                // Day number
                Text(dayFormatter.string(from: date))
                    .font(.system(size: 14, weight: hasVideo ? .semibold : .regular))
                    .foregroundColor(textColor)
                
                // Video indicator
                if hasVideo {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Circle()
                                .fill(Color.white)
                                .frame(width: 6, height: 6)
                                .offset(x: -2, y: -2)
                        }
                    }
                }
            }
        }
        .disabled(!hasVideo)
    }
    
    private var backgroundColor: Color {
        if isToday {
            return Color.white.opacity(0.2)
        } else if hasVideo {
            return Color.white.opacity(0.1)
        } else {
            return Color.clear
        }
    }
    
    private var textColor: Color {
        if !isCurrentMonth {
            return Color.gray.opacity(0.5)
        } else if isToday {
            return Color.white
        } else if hasVideo {
            return Color.white
        } else {
            return Color.gray
        }
    }
}

#Preview {
    CalendarTimelineView()
        .environmentObject(VideoManager())
        .background(Color(red: 0.1, green: 0.1, blue: 0.1))
}
