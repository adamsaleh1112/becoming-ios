import SwiftUI
import UIKit

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var notificationManager: NotificationManager
    @State private var selectedTime = Date()
    @State private var currentStep = 0
    
    var body: some View {
        ZStack {
            Color(red: 0.1, green: 0.1, blue: 0.1).ignoresSafeArea()
            
            VStack(alignment: .center, spacing: 0) {
                Spacer()
                
                // Animated content area
                VStack(spacing: 40) {
                    Group {
                        switch currentStep {
                        case 0:
                            WelcomeStep()
                                .transition(.asymmetric(
                                    insertion: .opacity.combined(with: .offset(x: 50)),
                                    removal: .opacity.combined(with: .offset(x: -50))
                                ))
                        case 1:
                            NotificationStep()
                                .transition(.asymmetric(
                                    insertion: .opacity.combined(with: .offset(x: 50)),
                                    removal: .opacity.combined(with: .offset(x: -50))
                                ))
                        default:
                            CompletionStep()
                                .transition(.asymmetric(
                                    insertion: .opacity.combined(with: .scale(scale: 0.9)),
                                    removal: .opacity.combined(with: .scale(scale: 1.1))
                                ))
                        }
                    }
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentStep)
                }
                .frame(maxWidth: .infinity)
                
                Spacer()
                
                // Button with animation
                Button(action: nextStep) {
                    Text(currentStep == 2 ? "Start your journey" : "Continue")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 40)
                                .fill(Color.white)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 40)
                                .stroke(Color.white.opacity(0.2), lineWidth: 8)
                        )
                }
                .padding(.horizontal, 24)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .offset(y: 20)),
                    removal: .opacity
                ))
                .animation(.spring(response: 0.6, dampingFraction: 0.7), value: currentStep)
            }
            .padding(.vertical, 40)
        }
    }
    
    @ViewBuilder
    private func WelcomeStep() -> some View {
        VStack(spacing: 50) {
            Text("Talk to your future self.")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            
            VStack(spacing: 24) {
                FeatureRow(icon: "video.fill", text: "Record daily video logs")
                FeatureRow(icon: "flame.fill", text: "Build consistency streaks")
                FeatureRow(icon: "clock.fill", text: "Max 10 minutes per day")
                FeatureRow(icon: "heart.fill", text: "Watch yourself grow")
            }
            .transition(.opacity.combined(with: .offset(y: 20)))
        }
        .padding(.horizontal, 32)
    }
    
    @ViewBuilder
    private func NotificationStep() -> some View {
        VStack(spacing: 50) {
            Text("Daily reminder")
                .font(.system(size: 38, weight: .bold))
                .foregroundColor(.white)
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            
            Text("When should we remind you to record?")
                .font(.system(size: 22))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .transition(.opacity.combined(with: .offset(y: 15)))
            
            DatePicker("Notification Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .colorScheme(.dark)
                .frame(maxWidth: 320)
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
        }
        .padding(.horizontal, 32)
    }
    
    @ViewBuilder
    private func CompletionStep() -> some View {
        VStack(spacing: 50) {
            Text("You're ready!")
                .font(.system(size: 38, weight: .bold))
                .foregroundColor(.white)
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
            
            Text("Don't let your life go unrecorded.")
                .font(.system(size: 22))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .transition(.opacity.combined(with: .offset(y: 15)))
            
            VStack(alignment: .leading, spacing: 20) {
                Text("Remember:")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("• Show up every day")
                    Text("• Speak honestly")
                    Text("• Watch yourself grow")
                }
                .font(.system(size: 18))
                .foregroundColor(.gray)
            }
            .transition(.opacity.combined(with: .offset(y: 20)))
        }
        .padding(.horizontal, 32)
    }
    
    private func nextStep() {
        // Soft haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        
        if currentStep < 2 {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                currentStep += 1
            }
        } else {
            // Complete onboarding
            appState.isOnboarded = true
            appState.saveUserDefaults()
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(.white)
                .frame(width: 24)
            
            Text(text)
                .font(.system(size: 16))
                .foregroundColor(.gray)
            
            Spacer()
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppState())
        .environmentObject(NotificationManager())
}
