import SwiftUI

struct CounterView: View {
  @Binding var showMenuOption: Bool
  @ObservedObject var settings: UserSettings
  @StateObject private var timerManager = TimerManager()

  var body: some View {
    VerticalRuler(showMenuOption: $showMenuOption, settings: settings)
      .onTapGesture {
        withAnimation(.easeInOut(duration: 0.12)) {
          showMenuOption.toggle()
        }
      }
      .onChange(of: timerManager.isRunning) { isRunning in
        if isRunning {
          showMenuOption = true
        }
      }
      .onChange(of: timerManager.isPaused) { isPaused in
        if isPaused {
          showMenuOption = true
        }
      }
  }
}
