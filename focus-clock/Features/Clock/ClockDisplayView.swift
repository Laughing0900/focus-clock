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
      VStack(alignment: .leading, spacing: -20) {
        // AM/PM display (only shown in 12-hour format)
        if !settings.timeFormat24Hour {
          Text(timeManager.amPmString())
            .font(
              .custom(
                settings.fontFamily,
                size: geometry.size.width * 0.05 * settings.fontSize
              )
            )
            .foregroundColor(settings.textColor)
        }

        // Main time display
        Text(
          timeManager.timeString(
            format24Hour: settings.timeFormat24Hour,
            showSeconds: settings.showSeconds
          )
        )
        .font(
          .custom(
            settings.fontFamily,
            size: geometry.size.width * 0.20 * settings.fontSize
          )
        )
        .foregroundColor(settings.textColor)
        .contentTransition(.numericText())
      }
      .frame(
        width: geometry.size.width,
        height: geometry.size.height,
        alignment: .center
      )
      .brightness(settings.brightness - 0.5)
    }
  }
}

#Preview {
  ClockDisplayView(
    timeManager: TimeManager(),
    settings: UserSettings()
  )
}
