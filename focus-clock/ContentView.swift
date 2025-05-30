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

    var body: some View {
        ZStack {
            // Background color from theme
            settings.backgroundColor
                .ignoresSafeArea()

            // Date display in top left corner
            if settings.showDate {
                GeometryReader { geometry in
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
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
                        .brightness(settings.brightness - 0.5)
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
                        Spacer()  // Pushes menu button to right

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

                    Spacer()  // Pushes everything to top

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
        formatter.dateFormat = "d MMM, yyyy EE"
        return formatter.string(from: currentTime)
    }
}

#Preview {
    ContentView()
}
