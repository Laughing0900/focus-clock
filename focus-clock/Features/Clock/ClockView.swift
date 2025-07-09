//
//  ClockView.swift
//  focus-clock
//
//  Created by Laughing Cheng on 30/5/2025.
//

import SwiftUI

struct ClockView: View {
  @StateObject private var timeManager = TimeManager()
  @ObservedObject var settings: UserSettings

  var body: some View {
    // Main time display
    ClockDisplayView(
      timeManager: timeManager,
      settings: settings
    )

    // Date display overlay
    DateDisplayView(
      timeManager: timeManager,
      settings: settings
    )
  }
}

#Preview {
  ClockView(settings: UserSettings())
    .background(Color.black)
}
