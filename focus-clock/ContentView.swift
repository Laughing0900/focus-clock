//
//  ContentView.swift
//  digi-clock
//
//  Created by Laughing Cheng on 30/5/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var showMenuOption = true
    @State private var showMenuView = false
    @StateObject private var settings = UserSettings()

    var body: some View {
        ZStack {
            // Background color from theme
            settings.backgroundColor
                .ignoresSafeArea()

            // Clock display
            ClockView(settings: settings)

            // Menu button overlay
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
                    }
                    .padding(.top, 20)
                    .padding(.trailing, 20)
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
}

#Preview {
    ContentView()
}
