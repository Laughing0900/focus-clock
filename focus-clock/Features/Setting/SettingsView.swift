//
//  SettingsView.swift
//  focus-clock
//
//  Created by Laughing Cheng on 30/5/2025.
//

import SwiftUI

struct SettingsView: View {
  @Environment(\.dismiss) private var dismiss
  @ObservedObject var settings: UserSettings

  var body: some View {
    NavigationView {
      List {
        // Display Settings Section
        Section("Display") {
          HStack {
            Image(systemName: "clock")
              .foregroundColor(.blue)
              .frame(width: 25)
            Text("12/24 Hour")
            Spacer()
            Toggle("", isOn: $settings.timeFormat24Hour)
              .labelsHidden()
          }

          HStack {
            Image(systemName: "timer")
              .foregroundColor(.green)
              .frame(width: 25)
            Text("Show Seconds")
            Spacer()
            Toggle("", isOn: $settings.showSeconds)
              .labelsHidden()
          }

          HStack {
            Image(systemName: "calendar")
              .foregroundColor(.red)
              .frame(width: 25)
            Text("Show Date")
            Spacer()
            Toggle("", isOn: $settings.showDate)
              .labelsHidden()
          }
        }

        // Appearance Section
        Section("Appearance") {
          HStack {
            NavigationLink(destination: ThemeSelectionView(settings: settings)) {
              HStack {
                Image(systemName: "paintbrush")
                  .foregroundColor(.purple)
                  .frame(width: 25)
                Text("Themes")
                Spacer()
                Text(settings.selectedTheme)
                  .foregroundColor(.secondary)
              }
            }
          }

          VStack(alignment: .leading) {
            HStack {
              Image(systemName: "sun.max")
                .foregroundColor(.orange)
                .frame(width: 25)
              Image(systemName: "sun.min")
                .font(.caption)

              Slider(value: $settings.brightness, in: 0.1...1.0)

              Image(systemName: "sun.max")
                .font(.caption)
            }
          }
        }

        // Behavior Section
        Section("Behavior") {
          HStack {
            Image(systemName: "iphone")
              .foregroundColor(.gray)
              .frame(width: 25)
            Text("Keep Screen On")
            Spacer()
            Toggle("", isOn: $settings.keepScreenOn)
              .labelsHidden()
          }

        }

      }
      .toolbar {
        ToolbarItem(placement: .primaryAction) {
          Button("Done") {
            dismiss()
          }
        }
      }
    }
  }
}
