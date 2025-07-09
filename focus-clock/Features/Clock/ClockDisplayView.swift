//
//  ClockDisplayView.swift
//  focus-clock
//
//  Created by Laughing Cheng on 30/5/2025.
//

import SwiftUI

struct ClockDisplayView: View {
  @ObservedObject var timeManager: TimeManager
  @ObservedObject var settings: UserSettings

  var body: some View {
    GeometryReader { geometry in
      VStack(alignment: .leading, spacing: 0) {
        // AM/PM display (only shown in 12-hour format)
        if !settings.timeFormat24Hour {
          Text(timeManager.amPmString())
            .font(
              .custom(
                settings.fontFamily,
                size: geometry.size.width * 0.06 * settings.fontSize
              )
            )
            .foregroundColor(settings.textColor)
        }

        // Main time display
        HStack(alignment: .bottom, spacing: 10) {
          textView(timeManager.hourString(format24Hour: settings.timeFormat24Hour), geometry: geometry, settings: settings)
          textView(timeManager.minuteString(), geometry: geometry, settings: settings)
          if settings.showSeconds {
            textView(timeManager.secondString(), geometry: geometry, settings: settings)
          }
        }
      }
      .frame(
        width: geometry.size.width,
        height: geometry.size.height,
        alignment: .center
      )
      .brightness(settings.brightness - 0.5)
    }
  }

  private func textView(_ value: String, geometry: GeometryProxy, settings: UserSettings) -> some View {
    Text(value)
      .font(
        .custom(
          settings.fontFamily,
          size: geometry.size.width * 0.18 * settings.fontSize
        )
      )
      .foregroundColor(settings.textColor)
      .padding(.horizontal, 10)
      .padding(.vertical, 15)
      .background(settings.backgroundColor.opacity(0.3))
      .cornerRadius(10)
      .contentTransition(.numericText())
  }
}

#Preview {
  ClockDisplayView(
    timeManager: TimeManager(),
    settings: UserSettings()
  )
}
