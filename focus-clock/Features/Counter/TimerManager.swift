import Combine
import Foundation
import SwiftUI

enum TimerState {
  case idle
  case running
  case paused
  case completed
}

class TimerManager: ObservableObject {
  @Published var timeRemaining: TimeInterval = 10 * 60
  @Published var totalTime: TimeInterval = 0
  @Published var state: TimerState = .idle
  @Published var progress: Double = 0

  private var timer: Timer?
  private var cancellables = Set<AnyCancellable>()

  init() {
    // Update progress whenever timeRemaining changes
    $timeRemaining
      .sink { [weak self] remaining in
        guard let self = self, self.totalTime > 0 else { return }
        self.progress = (self.totalTime - remaining) / self.totalTime
      }
      .store(in: &cancellables)
  }

  // MARK: - Timer Controls

  func startTimer() {
    guard state == .idle else { return }
    startCountdown()
  }

  func pauseTimer() {
    guard state == .running else { return }
    state = .paused
    stopCountdown()
  }

  func resumeTimer() {
    guard state == .paused else { return }
    state = .running
    startCountdown()
  }

  func stopTimer() {
    state = .idle
    stopCountdown()
    timeRemaining = 0
    totalTime = 0
    progress = 0
  }

  func resetTimer(_ newTime: TimeInterval) {
    stopCountdown()
    timeRemaining = newTime
    progress = 0
    state = .idle
  }

  func updateTimeRemaining(_ newTime: TimeInterval) {
    // guard state == .paused else { return }
    timeRemaining = max(0, newTime)
  }

  // MARK: - Private Methods

  private func startCountdown() {
    stopCountdown()  // Stop any existing timer
    state = .running
    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
      guard let self = self else { return }

      if self.timeRemaining > 0 {
        self.timeRemaining -= 1
      } else {
        self.timerCompleted()
      }
    }
  }

  private func stopCountdown() {
    timer?.invalidate()
    timer = nil
  }

  private func timerCompleted() {
    state = .completed
    stopCountdown()
    timeRemaining = 0
    progress = 1.0

    // Trigger completion actions (notifications, sounds, etc.)
    handleTimerCompletion()
  }

  private func handleTimerCompletion() {
    // Add haptic feedback
    let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
    impactFeedback.impactOccurred()

    // You can add more completion actions here:
    // - Play sound
    // - Send notification
    // - Show alert
    print("Timer completed!")
  }

  // MARK: - Computed Properties

  var isRunning: Bool {
    state == .running
  }

  var isPaused: Bool {
    state == .paused
  }

  var isCompleted: Bool {
    state == .completed
  }

  var canStart: Bool {
    state == .idle
  }

  var canPause: Bool {
    state == .running
  }

  var canResume: Bool {
    state == .paused
  }

  // Format time for display
  var formattedTimeRemaining: String {
    let minutes = Int(timeRemaining) / 60
    let seconds = Int(timeRemaining) % 60
    return String(format: "%02d:%02d", minutes, seconds)
  }

  var formattedMinutesRemaining: Int {
    return Int(ceil(timeRemaining / 60))
  }

  deinit {
    stopCountdown()
  }
}
