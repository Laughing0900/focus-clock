//
//  UserSettings.swift
//  focus-clock
//
//  Created by Laughing Cheng on 30/5/2025.
//

import SwiftUI

// UserSettings class for shared state management
class UserSettings: ObservableObject {
  @Published var timeFormat24Hour = false
  @Published var showSeconds = false
  @Published var showDate = false
  @Published var brightness: Double = 0.8
  @Published var keepScreenOn = true {
    didSet {
      updateScreenIdleTimer()
    }
  }
  @Published var showBatteryLevel = true

  // Theme properties
  @Published var selectedTheme = "Default"
  @Published var backgroundColor = Color.black
  @Published var textColor = Color.white
  @Published var accentColor = Color.blue

  // Typography properties
  @Published var fontFamily = "Default"
  @Published var fontSize: Double = 1.0  // Multiplier for base font size

  init() {
    // Set default theme colors
    updateThemeColors()
    // Initialize screen idle timer setting
    updateScreenIdleTimer()
  }

  private func updateScreenIdleTimer() {
    #if canImport(UIKit)
      DispatchQueue.main.async {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
          UIApplication.shared.isIdleTimerDisabled = self.keepScreenOn
        }
      }
    #endif
  }

  func updateThemeColors() {
    switch selectedTheme {
    case "Default":
      backgroundColor = Color.black
      textColor = Color.white
      accentColor = Color.blue
    case "Light":
      backgroundColor = Color.white
      textColor = Color.black
      accentColor = Color.blue
    case "Dark Blue":
      backgroundColor = Color(red: 0.05, green: 0.1, blue: 0.2)
      textColor = Color.white
      accentColor = Color.cyan
    case "Forest":
      backgroundColor = Color(red: 0.1, green: 0.2, blue: 0.1)
      textColor = Color.green
      accentColor = Color.mint
    case "Sunset":
      backgroundColor = Color(red: 0.2, green: 0.1, blue: 0.05)
      textColor = Color.orange
      accentColor = Color.yellow
    case "Purple Dream":
      backgroundColor = Color(red: 0.15, green: 0.05, blue: 0.2)
      textColor = Color.purple
      accentColor = Color.pink
    case "Custom":
      // Keep current custom colors
      break
    default:
      backgroundColor = Color.black
      textColor = Color.white
      accentColor = Color.blue
    }
  }

  func getFontDesign() -> Font.Design {
    switch fontFamily {
    case "Default": return .default
    case "Rounded": return .rounded
    case "Monospaced": return .monospaced
    case "Serif": return .serif
    default: return .default
    }
  }
}
