import Foundation

class StreakManager: ObservableObject {
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    @Published var lastRecordingDate: Date?
    @Published var consistencyTier: String = "Getting Started"
    
    // Cache calendar for performance
    private let calendar = Calendar.current
    
    // Cache consistency tiers
    private let consistencyTiers = [
        (0, "Getting Started"),
        (7, "Building Momentum"),
        (30, "Consistent Creator"),
        (100, "Dedicated Documenter"),
        (365, "Life Chronicler")
    ]
    
    // Batch UserDefaults writes
    private var needsSave = false
    
    init() {
        loadStreakData()
        updateConsistencyTier()
    }
    
    func recordVideo() {
        let today = Date()
        
        // Check if already recorded today to avoid duplicate processing
        if let lastDate = lastRecordingDate, calendar.isDate(lastDate, inSameDayAs: today) {
            return
        }
        
        if let lastDate = lastRecordingDate {
            let daysBetween = calendar.dateComponents([.day], from: lastDate, to: today).day ?? 0
            
            if daysBetween == 1 {
                // Consecutive day
                currentStreak += 1
            } else if daysBetween > 1 {
                // Streak broken
                currentStreak = 1
            }
        } else {
            // First recording ever
            currentStreak = 1
        }
        
        lastRecordingDate = today
        
        if currentStreak > longestStreak {
            longestStreak = currentStreak
        }
        
        updateConsistencyTier()
        needsSave = true
        
        // Batch save after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if self.needsSave {
                self.saveStreakData()
            }
        }
    }
    
    func checkDailyStreak() {
        guard let lastDate = lastRecordingDate else { return }
        
        let today = Date()
        let daysBetween = calendar.dateComponents([.day], from: lastDate, to: today).day ?? 0
        
        if daysBetween > 1 {
            // Streak is broken
            currentStreak = 0
            updateConsistencyTier()
            needsSave = true
            saveStreakData()
        }
    }
    
    func hasRecordedToday() -> Bool {
        guard let lastDate = lastRecordingDate else { return false }
        return calendar.isDate(lastDate, inSameDayAs: Date())
    }
    
    private func updateConsistencyTier() {
        for (threshold, tier) in consistencyTiers.reversed() {
            if currentStreak >= threshold {
                consistencyTier = tier
                break
            }
        }
    }
    
    var streakMessage: String {
        if currentStreak == 0 {
            return "Start your journey today"
        } else if currentStreak == 1 {
            return "You've shown up 1 day"
        } else {
            return "You've shown up \(currentStreak) days in a row"
        }
    }
    
    var motivationalMessage: String {
        switch currentStreak {
        case 0:
            return "Every journey begins with a single step."
        case 1...6:
            return "Building the habit, one day at a time."
        case 7...29:
            return "Momentum is building. Keep going!"
        case 30...99:
            return "You're in the top 15% consistency tier."
        case 100...364:
            return "Incredible dedication. You're unstoppable."
        default:
            return "You're a true life chronicler. Inspiring!"
        }
    }
    
    private func loadStreakData() {
        currentStreak = UserDefaults.standard.integer(forKey: "currentStreak")
        longestStreak = UserDefaults.standard.integer(forKey: "longestStreak")
        
        if let dateData = UserDefaults.standard.data(forKey: "lastRecordingDate"),
           let date = try? JSONDecoder().decode(Date.self, from: dateData) {
            lastRecordingDate = date
        }
    }
    
    private func saveStreakData() {
        guard needsSave else { return }
        
        let defaults = UserDefaults.standard
        defaults.set(currentStreak, forKey: "currentStreak")
        defaults.set(longestStreak, forKey: "longestStreak")
        
        if let lastDate = lastRecordingDate,
           let dateData = try? JSONEncoder().encode(lastDate) {
            defaults.set(dateData, forKey: "lastRecordingDate")
        }
        
        needsSave = false
    }
}
