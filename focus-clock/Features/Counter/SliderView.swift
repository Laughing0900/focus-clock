
import SwiftUI

struct SliderView: View {
    @ObservedObject var settings: UserSettings
    @Binding var showMenuOption: Bool

    @StateObject private var timerManager = TimerManager()

    @State var value: Int = 10
    @State var tempValue: Int = 10
    @State var dragOffset: CGFloat = 0
    let range: ClosedRange<Int> = 0...120
    let stepWidth: CGFloat = 20

    @State private var isLongPressing: Bool = false

    var body: some View {
        GeometryReader { geo in
            let center = geo.size.height / 3
            ForEach(range, id: \.self) { tick in
                let x = center + CGFloat(tick - value) * stepWidth + dragOffset

                HStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 10)
                    .fill(tick==tempValue ? Color.white : Color.gray.opacity(0.4))
                    .frame(width: tick % 5 == 0 ? 20 : 10,height: tick==tempValue ? 3:1)

                }
                .position(x: geo.size.width / 2, y: x)
            }
            if showMenuOption || timerManager.isRunning || timerManager.isPaused {
                Text("\(timerManager.isRunning ? ":" : "")\(timerManager.formattedTimeRemaining)\(timerManager.isRunning ? ":" : "")")
                    .foregroundColor(settings.textColor.opacity(0.7))
                    .font(
                        .custom(
                            settings.fontFamily,
                            size: 36
                        )
                    )
                    .contentTransition(.numericText())
                    .sensoryFeedback(.selection, trigger: timerManager.formattedTimeRemaining)
                    .contentShape(Rectangle())
                    .padding(20)
                    .rotationEffect(.degrees(-90))
                    .position(x: geo.size.width - 18, y: geo.size.height / 2)
                    .onTapGesture {
                        if timerManager.canStart {
                            timerManager.startTimer()
                        } else if timerManager.isRunning {
                            timerManager.pauseTimer()
                        } else if timerManager.isPaused {
                            timerManager.resumeTimer()
                        }
                    }
                    .onLongPressGesture(minimumDuration: 1.0, maximumDistance: 50) {
                        timerManager.resetTimer(Double(10) * 60)
                        isLongPressing = false
                    } onPressingChanged: { pressing in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isLongPressing = pressing
                        }
                    }
            }
 
        }
        .contentShape(Rectangle())
        .brightness(settings.brightness - 0.5)
        .gesture(
            DragGesture(minimumDistance: 0)
            .onChanged({ gesture in
                withAnimation(.interactiveSpring()) {
                    let rawOffset = gesture.translation.height
                    let offsetSteps = (rawOffset / stepWidth)
                    var projected = CGFloat(value) - offsetSteps
                    let lower = CGFloat(range.lowerBound)
                    let upper = CGFloat(range.upperBound)
                    if projected < lower {
                        let overshoot = lower - projected
                        projected = lower - log(overshoot + 1) * 2
                    } else if projected > upper {
                        let overshoot = projected - upper
                        projected = upper + log(overshoot + 1) * 2
                    }
                    dragOffset =  (CGFloat(value) - projected) * stepWidth
                    let rounded = Int(projected.rounded())
                    tempValue = rounded.clamped(to: range)

                    timerManager.updateTimeRemaining(Double(tempValue) * 60)
                    // print("updateTimeRemaining",timerManager.timeRemaining)

                }
            })
            .onEnded({ gesture in
                let offsetSteps = gesture.translation.height / stepWidth
                let finalValue = Int((CGFloat(value) - offsetSteps).rounded()).clamped(to: range)
                withAnimation(.interpolatingSpring(stiffness: 120, damping: 20)) {
                    value = finalValue
                    tempValue = finalValue
                    dragOffset = 0
                }
            })
        )
    }

}
extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
