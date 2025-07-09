//
//  TimeManager.swift
//  focus-clock
//
//  Created by Laughing Cheng on 30/5/2025.
//

import Combine
import SwiftUI

class TimeManager: ObservableObject {
  @Published var currentTime = Date()

  private var timer: AnyCancellable?

  init() {
    startTimer()
  }

  private func startTimer() {
    timer = Timer.publish(every: 1, on: .main, in: .common)
      .autoconnect()
      .sink { [weak self] time in
        withAnimation {
          self?.currentTime = time
        }
      }
  }

  deinit {
    timer?.cancel()
  }

  func amPmString() -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeStyle = .none
    formatter.dateFormat = "a"
    formatter.amSymbol = "AM"
    formatter.pmSymbol = "PM"
    return formatter.string(from: currentTime)
  }

  func dateString() -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "d MMM, yyyy EE"
    return formatter.string(from: currentTime)
  }

  func hourString(format24Hour: Bool) -> String {
    let hour = Calendar.current.component(.hour, from: currentTime)
    let displayHour = format24Hour ? hour : (hour % 12 == 0 ? 12 : hour % 12)
    return String(format: "%02d", displayHour)
  }

  func minuteString() -> String {
    let minute = Calendar.current.component(.minute, from: currentTime)
    return String(format: "%02d", minute)
  }

  func secondString() -> String {
    let second = Calendar.current.component(.second, from: currentTime)
    return String(format: "%02d", second)
  }
}
