import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject var videoManager: VideoManager
    @EnvironmentObject var streakManager: StreakManager
    
    var body: some View {
        Group {
            if !appState.isOnboarded {
                OnboardingView()
            } else {
                MainView()
            }
        }
    }
}

struct MainView: View {
    @EnvironmentObject var videoManager: VideoManager
    @EnvironmentObject var streakManager: StreakManager
    @State private var showingRecordingView = false
    @State private var showingSettingsView = false
    
    var body: some View {
        ZStack {
            Color(red: 0.1, green: 0.1, blue: 0.1).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Date Header
                DateHeaderView()
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                
                // Calendar Timeline - expanded to take more vertical space
                CalendarTimelineView()
                    .padding(.horizontal, 20)
                    .padding(.top, 30)
                
                Spacer()
            }
            
            // Floating Record Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        showingRecordingView = true
                    }) {
                        Image(systemName: "video.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.black)
                            .frame(width: 60, height: 60)
                            .background(Color.white)
                            .cornerRadius(30)
                            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .sheet(isPresented: $showingRecordingView) {
            RecordingView()
        }
        .sheet(isPresented: $showingSettingsView) {
            SettingsView()
        }
    }
}

struct DateHeaderView: View {
    private let today = Date()
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        return formatter.string(from: today)
    }
    
    private var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: today)
    }
    
    private var monthAndDay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd"
        return formatter.string(from: today)
    }
    
    var body: some View {
        HStack {
            // Large day number on the left
            Text(dayNumber)
                .font(.system(size: 64, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            // Day name and date on the right
            VStack(alignment: .trailing, spacing: 4) {
                Text(dayName)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.gray)
                
                Text(monthAndDay)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 10)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
        .environmentObject(NotificationManager())
        .environmentObject(VideoManager())
        .environmentObject(StreakManager())
}
