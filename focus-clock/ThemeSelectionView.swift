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

  @State private var selectedBackgroundColorName = "Black"
  @State private var selectedTextColorName = "White"
  @State private var selectedAccentColorName = "Blue"

  // Predefined color options as computed properties
  private var backgroundColors: [(String, Color)] {
    [
      ("Black", Color.black),
      ("White", Color.white),
      ("Dark Gray", Color.gray.opacity(0.2)),
      ("Navy", Color(red: 0.05, green: 0.1, blue: 0.2)),
      ("Dark Green", Color(red: 0.1, green: 0.2, blue: 0.1)),
      ("Dark Red", Color(red: 0.2, green: 0.1, blue: 0.05)),
      ("Dark Purple", Color(red: 0.15, green: 0.05, blue: 0.2)),
      ("Custom", settings.backgroundColor),
    ]
  }

  private var textColors: [(String, Color)] {
    [
      ("White", Color.white),
      ("Black", Color.black),
      ("Light Gray", Color.gray.opacity(0.8)),
      ("Blue", Color.blue),
      ("Green", Color.green),
      ("Orange", Color.orange),
      ("Purple", Color.purple),
      ("Red", Color.red),
      ("Yellow", Color.yellow),
      ("Cyan", Color.cyan),
      ("Custom", settings.textColor),
    ]
  }

  private var accentColors: [(String, Color)] {
    [
      ("Blue", Color.blue),
      ("Green", Color.green),
      ("Orange", Color.orange),
      ("Purple", Color.purple),
      ("Red", Color.red),
      ("Pink", Color.pink),
      ("Yellow", Color.yellow),
      ("Cyan", Color.cyan),
      ("Mint", Color.mint),
      ("Custom", settings.accentColor),
    ]
  }

  var body: some View {
    List {
      // Preview Section
      Section("Preview") {
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

            Text(
              "Font: \(settings.fontFamily) | Size: \(Int(settings.fontSize * 100))%"
            )
            .font(.caption)
            .foregroundColor(settings.textColor.opacity(0.7))
          }
        }
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets())
        .padding(.horizontal)
        .brightness(settings.brightness - 0.5)  // Apply same brightness as main view
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
                .foregroundColor(settings.accentColor)
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
        VStack(alignment: .leading, spacing: 8) {
          HStack {
            Image(systemName: "textformat.size")
              .foregroundColor(.green)
              .frame(width: 25)
            Text("Font Size")
            Spacer()
            Text("\(Int(settings.fontSize * 100))%")
              .foregroundColor(.secondary)
          }

          HStack {
            Text("A")
              .font(.caption2)
            Slider(value: $settings.fontSize, in: 0.5...2.0, step: 0.1)
            Text("A")
              .font(.title3)
              .fontWeight(.bold)
          }
          .foregroundColor(.secondary)
        }
      }

      // Custom Colors Section (only show when Custom theme is selected)
      if settings.selectedTheme == "Custom" {
        Section("Custom Colors") {
          // Background Color Dropdown
          VStack(alignment: .leading, spacing: 8) {
            HStack {
              Image(systemName: "paintbrush.fill")
                .foregroundColor(.blue)
                .frame(width: 25)
              Text("Background Color")
              Spacer()
              Picker("Background Color", selection: $selectedBackgroundColorName) {
                ForEach(backgroundColors, id: \.0) { colorName, color in
                  HStack {
                    Circle()
                      .fill(color)
                      .frame(width: 16, height: 16)
                      .overlay(
                        Circle()
                          .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
                      )
                    Text(colorName)
                  }
                  .tag(colorName)
                }
              }
              .pickerStyle(.menu)
              .onChange(of: selectedBackgroundColorName) { _, newValue in
                if let selectedColor = backgroundColors.first(where: {
                  $0.0 == newValue
                }) {
                  withAnimation(.easeInOut(duration: 0.2)) {
                    settings.backgroundColor = selectedColor.1
                  }
                }
              }
            }

            // Show ColorPicker only when Custom is selected
            if selectedBackgroundColorName == "Custom" {
              HStack {
                Spacer()
                ColorPicker(
                  "Custom Background", selection: $settings.backgroundColor
                )
                .labelsHidden()
                .scaleEffect(1.2)
              }
            }
          }

          // Text Color Dropdown
          VStack(alignment: .leading, spacing: 8) {
            HStack {
              Image(systemName: "textformat")
                .foregroundColor(.green)
                .frame(width: 25)
              Text("Text Color")
              Spacer()
              Picker("Text Color", selection: $selectedTextColorName) {
                ForEach(textColors, id: \.0) { colorName, color in
                  HStack {
                    Circle()
                      .fill(color)
                      .frame(width: 16, height: 16)
                      .overlay(
                        Circle()
                          .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
                      )
                    Text(colorName)
                  }
                  .tag(colorName)
                }
              }
              .pickerStyle(.menu)
              .onChange(of: selectedTextColorName) { _, newValue in
                if let selectedColor = textColors.first(where: { $0.0 == newValue }) {
                  withAnimation(.easeInOut(duration: 0.2)) {
                    settings.textColor = selectedColor.1
                  }
                }
              }
            }

            // Show ColorPicker only when Custom is selected
            if selectedTextColorName == "Custom" {
              HStack {
                Spacer()
                ColorPicker("Custom Text", selection: $settings.textColor)
                  .labelsHidden()
                  .scaleEffect(1.2)
              }
            }
          }

          // Accent Color Dropdown
          VStack(alignment: .leading, spacing: 8) {
            HStack {
              Image(systemName: "sparkles")
                .foregroundColor(.purple)
                .frame(width: 25)
              Text("Accent Color")
              Spacer()
              Picker("Accent Color", selection: $selectedAccentColorName) {
                ForEach(accentColors, id: \.0) { colorName, color in
                  HStack {
                    Circle()
                      .fill(color)
                      .frame(width: 16, height: 16)
                      .overlay(
                        Circle()
                          .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
                      )
                    Text(colorName)
                  }
                  .tag(colorName)
                }
              }
              .pickerStyle(.menu)
              .onChange(of: selectedAccentColorName) { _, newValue in
                if let selectedColor = accentColors.first(where: {
                  $0.0 == newValue
                }) {
                  withAnimation(.easeInOut(duration: 0.2)) {
                    settings.accentColor = selectedColor.1
                  }
                }
              }
            }

            // Show ColorPicker only when Custom is selected
            if selectedAccentColorName == "Custom" {
              HStack {
                Spacer()
                ColorPicker("Custom Accent", selection: $settings.accentColor)
                  .labelsHidden()
                  .scaleEffect(1.2)
              }
            }
          }
        }

        Section("Quick Actions") {
          Button("Reset to Default Colors") {
            withAnimation(.easeInOut(duration: 0.2)) {
              settings.backgroundColor = Color.black
              settings.textColor = Color.white
              settings.accentColor = Color.blue
              selectedBackgroundColorName = "Black"
              selectedTextColorName = "White"
              selectedAccentColorName = "Blue"
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

            // Reset color selections
            selectedBackgroundColorName = "Black"
            selectedTextColorName = "White"
            selectedAccentColorName = "Blue"
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
