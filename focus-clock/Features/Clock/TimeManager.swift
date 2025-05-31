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

  // Time formatting methods
  func timeString(format24Hour: Bool, showSeconds: Bool) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeStyle = .none

    if format24Hour {
      formatter.dateFormat = showSeconds ? "HH:mm:ss" : "HH:mm"
    } else {
      formatter.dateFormat = showSeconds ? "hh:mm:ss" : "hh:mm"
    }

    return formatter.string(from: currentTime)
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
}
