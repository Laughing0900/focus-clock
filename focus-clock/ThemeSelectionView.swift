//
//  ThemeSelectionView.swift
//  focus-clock
//
//  Created by Laughing Cheng on 30/5/2025.
//

import SwiftUI

struct ThemeSelectionView: View {
  @ObservedObject var settings: UserSettings

  let presetThemes = [
    "Default", "Light", "Dark Blue", "Forest", "Sunset", "Purple Dream", "Custom",
  ]

  var body: some View {
    List {
      // Preview Section
      Section {
        ZStack {
          RoundedRectangle(cornerRadius: 12)
            .fill(settings.backgroundColor)
            .frame(height: 120)
            .overlay(
              RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )

          VStack(spacing: 8) {
            Text("12:34")
              .font(.custom(settings.fontFamily, size: 32 * settings.fontSize))
              .foregroundColor(settings.textColor)
          }
        }
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets())
        .padding(.horizontal)
      }

      // Typography Section
      Section("Typography") {
        // Font Family Selection
        HStack {
          NavigationLink(destination: FontSelectionView(settings: settings)) {
            HStack {
              Image(systemName: "textformat")
                .foregroundColor(.blue)
                .frame(width: 25)
              Text("Font Family")
              Spacer()
              Text(settings.fontFamily)
                .foregroundColor(.secondary)
            }
          }
        }

        // Font Size Slider

        HStack {
          Image(systemName: "textformat.size")
            .foregroundColor(.green)
            .frame(width: 25)
          Text("A")
            .font(.caption2)
          Slider(value: $settings.fontSize, in: 0.5...2.0, step: 0.1)
          Text("A")
            .font(.title3)
            .fontWeight(.bold)
        }
        .foregroundColor(.secondary)
      }

      // Preset Themes Section
      Section("Preset Themes") {
        ForEach(presetThemes, id: \.self) { theme in
          HStack {
            // Theme color indicator
            HStack(spacing: 4) {
              Circle()
                .fill(backgroundColorForTheme(theme))
                .frame(width: 16, height: 16)
                .overlay(
                  Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
                )

              Circle()
                .fill(textColorForTheme(theme))
                .frame(width: 16, height: 16)
                .overlay(
                  Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
                )
            }

            Text(theme)

            Spacer()

            if settings.selectedTheme == theme {
              Image(systemName: "checkmark")
                .foregroundColor(.blue)
            }
          }
          .contentShape(Rectangle())
          .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
              settings.selectedTheme = theme
              settings.updateThemeColors()
            }
          }
        }
      }

      // Custom Colors Section (only show when Custom theme is selected)
      if settings.selectedTheme == "Custom" {
        Section("Custom Colors") {
          // Background Color Picker
          HStack {
            Image(systemName: "paintbrush.fill")
              .foregroundColor(.blue)
              .frame(width: 25)
            Text("Background Color")
            Spacer()
            ColorPicker("", selection: $settings.backgroundColor)
              .labelsHidden()
              .scaleEffect(1.2)
          }

          // Text Color Picker
          HStack {
            Image(systemName: "textformat")
              .foregroundColor(.green)
              .frame(width: 25)
            Text("Text Color")
            Spacer()
            ColorPicker("", selection: $settings.textColor)
              .labelsHidden()
              .scaleEffect(1.2)
          }
        }

        Section("Quick Actions") {
          Button("Reset to Default Colors") {
            withAnimation(.easeInOut(duration: 0.2)) {
              settings.backgroundColor = Color.black
              settings.textColor = Color.white
            }
          }
          .foregroundColor(.red)
        }
      }

      // Reset to Defaults Section (always visible)
      Section("Reset") {
        Button("Reset to Default Theme") {
          withAnimation(.easeInOut(duration: 0.3)) {
            // Reset theme
            settings.selectedTheme = "Default"
            settings.updateThemeColors()

            // Reset typography
            settings.fontFamily = "Helvetica Neue"
            settings.fontSize = 1.0
          }
        }
        .foregroundColor(.red)
      }
    }
    .navigationTitle("Themes")
  }

  private func backgroundColorForTheme(_ theme: String) -> Color {
    switch theme {
    case "Default": return Color.black
    case "Light": return Color.white
    case "Dark Blue": return Color(red: 0.05, green: 0.1, blue: 0.2)
    case "Forest": return Color(red: 0.1, green: 0.2, blue: 0.1)
    case "Sunset": return Color(red: 0.2, green: 0.1, blue: 0.05)
    case "Purple Dream": return Color(red: 0.15, green: 0.05, blue: 0.2)
    case "Custom": return settings.backgroundColor
    default: return Color.black
    }
  }

  private func textColorForTheme(_ theme: String) -> Color {
    switch theme {
    case "Default": return Color.white
    case "Light": return Color.black
    case "Dark Blue": return Color.white
    case "Forest": return Color.green
    case "Sunset": return Color.orange
    case "Purple Dream": return Color.purple
    case "Custom": return settings.textColor
    default: return Color.white
    }
  }
}
