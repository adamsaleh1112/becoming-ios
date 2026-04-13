import UIKit

class HapticManager {
    static let shared = HapticManager()
    
    // Cached generators for better performance
    private let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let softGenerator = UIImpactFeedbackGenerator(style: .soft)
    private let rigidGenerator = UIImpactFeedbackGenerator(style: .rigid)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let selectionGenerator = UISelectionFeedbackGenerator()
    
    private init() {
        // Pre-prepare all generators for instant response
        lightGenerator.prepare()
        mediumGenerator.prepare()
        softGenerator.prepare()
        rigidGenerator.prepare()
        notificationGenerator.prepare()
        selectionGenerator.prepare()
    }
    
    func light() {
        lightGenerator.impactOccurred()
        // Re-prepare for next use
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.lightGenerator.prepare()
        }
    }
    
    func medium() {
        mediumGenerator.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.mediumGenerator.prepare()
        }
    }
    
    func soft() {
        softGenerator.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.softGenerator.prepare()
        }
    }
    
    func rigid() {
        rigidGenerator.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.rigidGenerator.prepare()
        }
    }
    
    func success() {
        notificationGenerator.notificationOccurred(.success)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.notificationGenerator.prepare()
        }
    }
    
    func warning() {
        notificationGenerator.notificationOccurred(.warning)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.notificationGenerator.prepare()
        }
    }
    
    func error() {
        notificationGenerator.notificationOccurred(.error)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.notificationGenerator.prepare()
        }
    }
    
    func selection() {
        selectionGenerator.selectionChanged()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.selectionGenerator.prepare()
        }
    }
    
    // Explicit prepare methods for performance-critical sections
    func prepareLight() { lightGenerator.prepare() }
    func prepareMedium() { mediumGenerator.prepare() }
    func prepareSoft() { softGenerator.prepare() }
    func prepareRigid() { rigidGenerator.prepare() }
}
