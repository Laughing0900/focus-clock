//
//  ContentView.swift
//  digi-clock
//
//  Created by Laughing Cheng on 30/5/2025.
//

import SwiftUI

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
                                    .custom(
                                        settings.fontFamily,
                                        size: max(
                                            12, geometry.size.width * 0.03 * settings.fontSize)
                                    )
                                )
                                .foregroundColor(settings.textColor)
                                .contentTransition(.numericText())
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
                                    .custom(
                                        settings.fontFamily,
                                        size: geometry.size.width * 0.05 * settings.fontSize
                                    )
                                )
                                .foregroundColor(settings.textColor)
                        }

                        // Main time display
                        Text(timeString)
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
                                    .contentTransition(.numericText())
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

#Preview {
    ContentView()
}
