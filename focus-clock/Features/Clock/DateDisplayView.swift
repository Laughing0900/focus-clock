//
//  DateDisplayView.swift
//  focus-clock
//
//  Created by Laughing Cheng on 30/5/2025.
//

import SwiftUI

struct DateDisplayView: View {
  @ObservedObject var timeManager: TimeManager
  @ObservedObject var settings: UserSettings

  var body: some View {
    if settings.showDate {
      GeometryReader { geometry in
        Text(timeManager.dateString())
              .font(
                .custom(
                  settings.fontFamily,
                  size: max(
                    12, geometry.size.width * 0.03 * settings.fontSize)
                )
              )
              .foregroundColor(settings.textColor)
              .contentTransition(.numericText())
          .position(
            x: geometry.size.width / 2,
            y: geometry.size.height
          )
          .brightness(settings.brightness - 0.5)
        }
    }
  }
}

#Preview {
  DateDisplayView(
    timeManager: TimeManager(),
    settings: UserSettings()
  )
  .background(Color.black)
}
