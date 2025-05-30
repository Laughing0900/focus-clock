//
//  SettingsView.swift
//  focus-clock
//
//  Created by Laughing Cheng on 30/5/2025.
//

import SwiftUI

struct MenuRow: View {
  let icon: String
  let title: String

  var body: some View {
    HStack {
      Image(systemName: icon)
        .foregroundColor(.blue)
        .frame(width: 20)
      Text(title)
        .foregroundColor(.primary)
      Spacer()
      Image(systemName: "chevron.right")
        .foregroundColor(.gray)
        .font(.caption)
    }
    .padding(.horizontal)
    .padding(.vertical, 8)
    .background(Color.gray.opacity(0.1))
    .cornerRadius(8)
  }
}

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
            VStack(alignment: .leading) {
              Text("Time Format")
              Text(settings.timeFormat24Hour ? "24-Hour" : "12-Hour")
                .font(.caption)
                .foregroundColor(.secondary)
            }
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

          HStack {
            Image(systemName: "battery.100")
              .foregroundColor(.green)
              .frame(width: 25)
            Text("Show Battery Level")
            Spacer()
            Toggle("", isOn: $settings.showBatteryLevel)
              .labelsHidden()
          }
        }

      }
      .navigationTitle("Settings")
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
