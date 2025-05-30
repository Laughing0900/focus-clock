//
//  ContentView.swift
//  digi-clock
//
//  Created by Laughing Cheng on 30/5/2025.
//

import SwiftUI

// Add UserSettings class for shared state management
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

struct ContentView: View {
    @State private var currentTime = Date()
    @State private var showMenuOption = true
    @State private var showMenuView = false
    @StateObject private var settings = UserSettings()

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    // Battery level computed property
    private var batteryLevel: Float {
        #if canImport(UIKit)
            UIDevice.current.isBatteryMonitoringEnabled = true
            return UIDevice.current.batteryLevel
        #else
            return 1.0
        #endif
    }

    private var batteryPercentage: Int {
        return Int(batteryLevel * 100)
    }

    private var batteryIcon: String {
        switch batteryPercentage {
        case 81...100:
            return "battery.100"
        case 61...80:
            return "battery.75"
        case 41...60:
            return "battery.50"
        case 21...40:
            return "battery.25"
        case 1...20:
            return "battery.0"
        default:
            return "battery.0"
        }
    }

    private var batteryColor: Color {
        switch batteryPercentage {
        case 21...100:
            return .green
        case 11...20:
            return .orange
        default:
            return .red
        }
    }

    var body: some View {
        ZStack {
            // Background color from theme
            settings.backgroundColor
                .ignoresSafeArea()

            // Date display in top left corner
            if settings.showDate {
                GeometryReader { geometry in
                    VStack {
                        HStack {
                            Text(dateString)
                                .font(
                                    .system(
                                        size: max(
                                            12, geometry.size.width * 0.03 * settings.fontSize),
                                        weight: .medium,
                                        design: settings.getFontDesign())
                                )
                                .foregroundColor(settings.textColor)
                            Spacer()
                        }
                        .padding(.top, 20)
                        .padding(.leading, 20)
                        .brightness(settings.brightness - 0.5)
                        Spacer()
                    }
                }
            }

            VStack {
                GeometryReader { geometry in
                    VStack(alignment: .leading, spacing: -20) {
                        // AM/PM display (only shown in 12-hour format) - positioned at top left
                        if !settings.timeFormat24Hour {
                            Text(amPmString)
                                .font(
                                    .system(
                                        size: geometry.size.width * 0.05 * settings.fontSize,
                                        weight: .medium,
                                        design: settings.getFontDesign())
                                )
                                .foregroundColor(settings.textColor)
                        }

                        // Main time display
                        Text(timeString)
                            .font(
                                .system(
                                    size: geometry.size.width * 0.20 * settings.fontSize,
                                    weight: .light,
                                    design: settings.getFontDesign())
                            )
                            .foregroundColor(settings.textColor)
                    }
                    .frame(
                        width: geometry.size.width, height: geometry.size.height,
                        alignment: .center
                    )
                    .brightness(settings.brightness - 0.5)
                }
            }
            .padding()
            .onReceive(timer) { input in
                currentTime = input
            }

            if showMenuOption {
                VStack {
                    HStack {
                        // Battery display on the left
                        if settings.showBatteryLevel {
                            ZStack {
                                Image(systemName: batteryIcon)
                                    .font(.title)
                                    .foregroundColor(batteryColor)

                                Text("\(batteryPercentage)")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(settings.textColor)
                            }
                            .padding(.leading, 20)
                        }

                        Spacer()

                        // Menu button on the right
                        Button(action: {
                            withAnimation(.easeIn(duration: 0.15)) {
                                showMenuView.toggle()
                            }
                        }) {
                            Image(systemName: "list.dash")
                                .font(.title2)
                                .foregroundColor(settings.textColor)
                                .padding(10)
                                .overlay(
                                    Circle()
                                        .stroke(settings.textColor, lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                        .transition(.scale.combined(with: .opacity))
                        .padding(.trailing, 20)
                    }
                    .padding(.top, 20)
                    .brightness(settings.brightness - 0.5)

                    Spacer()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.12)) {
                showMenuOption.toggle()
                if !showMenuOption {
                    showMenuView = false
                }
            }
        }
        .sheet(isPresented: $showMenuView) {
            SettingsView(settings: settings)
        }
    }

    private var timeString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")  // Force consistent formatting
        formatter.timeStyle = .none

        if settings.timeFormat24Hour {
            // 24-hour format
            formatter.dateFormat = settings.showSeconds ? "HH:mm:ss" : "HH:mm"
        } else {
            // 12-hour format (without AM/PM since it's displayed separately)
            // Using lowercase 'h' for 1-12 hour format, not 'H' which is 24-hour
            formatter.dateFormat = settings.showSeconds ? "hh:mm:ss" : "hh:mm"

        }

        return formatter.string(from: currentTime)
    }

    private var amPmString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")  // Force consistent formatting
        formatter.timeStyle = .none
        formatter.dateFormat = "a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter.string(from: currentTime)
    }

    // Add date formatting property
    private var dateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: currentTime)
    }

}

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
                            Text("Brightness")
                            Spacer()
                            Text("\(Int(settings.brightness * 100))%")
                                .foregroundColor(.secondary)
                        }

                        HStack {
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

struct ThemeSelectionView: View {
    @ObservedObject var settings: UserSettings

    let presetThemes = [
        "Default", "Light", "Dark Blue", "Forest", "Sunset", "Purple Dream", "Custom",
    ]

    let fontFamilies = [
        "Default",
        "Rounded",
        "Monospaced",
        "Serif",
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
                            .font(
                                .system(
                                    size: 32 * settings.fontSize,
                                    weight: .light,
                                    design: settings.getFontDesign())
                            )
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
                    Image(systemName: "textformat")
                        .foregroundColor(.blue)
                        .frame(width: 25)
                    Spacer()
                    Picker("Font Family", selection: $settings.fontFamily) {
                        ForEach(fontFamilies, id: \.self) { family in
                            HStack {
                                Text("\(family)")
                                    .font(
                                        .system(
                                            size: 16, weight: .medium,
                                            design: getFontDesignForFamily(family)))
                            }
                            .tag(family)
                        }
                    }
                    .pickerStyle(.menu)
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
                                if let selectedColor = textColors.first(where: { $0.0 == newValue })
                                {
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
                        settings.fontFamily = "Default"
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

    private func getFontDesignForFamily(_ family: String) -> Font.Design {
        switch family {
        case "Default": return .default
        case "Rounded": return .rounded
        case "Monospaced": return .monospaced
        case "Serif": return .serif
        default: return .default
        }
    }
}

#Preview {
    ContentView()
}
