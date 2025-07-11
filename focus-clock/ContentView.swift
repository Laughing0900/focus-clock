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

    @State private var selectedHeight: CGFloat = 200

    var body: some View {
        ZStack {
            // Background color from theme
            settings.backgroundColor
                .ignoresSafeArea()

            SliderView(settings: settings,showMenuOption: $showMenuOption)
//            CounterView(showMenuOption: $showMenuOption, settings: settings)

            ClockView(settings: settings)


            // Menu button overlay
            if showMenuOption {
                 GeometryReader { geometry in
                        Button(action: {
                            withAnimation(.easeIn(duration: 0.15)) {
                                showMenuView.toggle()
                            }
                        }) {
                            Image(systemName: "ellipsis.circle")
                                .font(.system(size: 32))
                                .foregroundColor(settings.textColor)

                        }
                        .buttonStyle(.plain)
                        .transition(.scale.combined(with: .opacity))
                        .position(x: geometry.size.width - 40, y: 20)
                }
                .brightness(settings.brightness - 0.5)
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
