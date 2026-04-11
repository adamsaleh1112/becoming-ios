import SwiftUI

struct HomeView: View {
    @EnvironmentObject var streakManager: StreakManager
    @EnvironmentObject var videoManager: VideoManager
    @State private var showingRecordingView = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Header - Just the streak message now
                    Text(streakManager.streakMessage)
                        .font(.custom("Times New Roman", size: 20))
                        .foregroundColor(.gray)
                        .padding(.top, 20)
                    
                    // Streak Display
                    StreakCard()
                    
                    Spacer()
                    
                    // Record Button
                    RecordButton()
                    
                    // Today's Status
                    TodayStatusCard()
                    
                    Spacer()
                }
                .padding()
            }
        }
        .sheet(isPresented: $showingRecordingView) {
            RecordingView()
        }
    }
    
    @ViewBuilder
    private func StreakCard() -> some View {
        VStack(spacing: 15) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Current streak")
                        .font(.custom("Times New Roman", size: 18))
                        .foregroundColor(.gray)
                    
                    Text("\(streakManager.currentStreak)")
                        .font(.custom("Times New Roman", size: 48))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Best streak")
                        .font(.custom("Times New Roman", size: 18))
                        .foregroundColor(.gray)
                    
                    Text("\(streakManager.longestStreak)")
                        .font(.custom("Times New Roman", size: 24))
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                }
            }
            
            Text(streakManager.consistencyTier)
                .font(.custom("Times New Roman", size: 16))
                .foregroundColor(.orange)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.orange.opacity(0.2))
                .cornerRadius(24)
        }
        .padding(20)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(24)
    }
    
    @ViewBuilder
    private func RecordButton() -> some View {
        Button(action: {
            showingRecordingView = true
        }) {
            VStack(spacing: 8) {
                Image(systemName: "video.fill")
                    .font(.system(size: 32))
                
                Text(videoManager.hasRecordedToday() ? "Record again" : "Record today")
                    .font(.custom("Times New Roman", size: 18))
                    .fontWeight(.medium)
            }
            .foregroundColor(.black)
            .frame(width: 140, height: 140)
            .background(Color.white)
            .cornerRadius(24)
        }
        .scaleEffect(videoManager.hasRecordedToday() ? 0.9 : 1.0)
        .opacity(videoManager.hasRecordedToday() ? 0.7 : 1.0)
    }
    
    @ViewBuilder
    private func TodayStatusCard() -> some View {
        HStack {
            Image(systemName: videoManager.hasRecordedToday() ? "checkmark.circle.fill" : "clock.fill")
                .foregroundColor(videoManager.hasRecordedToday() ? .green : .orange)
                .font(.title2)
            
            VStack(alignment: .leading) {
                Text(videoManager.hasRecordedToday() ? "Recorded today" : "Not recorded yet")
                    .font(.custom("Times New Roman", size: 18))
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text(streakManager.motivationalMessage)
                    .font(.custom("Times New Roman", size: 16))
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(20)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(24)
    }
}

#Preview {
    HomeView()
        .environmentObject(StreakManager())
        .environmentObject(VideoManager())
}
