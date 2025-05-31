import SwiftUI
import UIKit

struct VerticalRuler: View {
  @Binding var showMenuOption: Bool
  @ObservedObject var settings: UserSettings

  let maxTick: CGFloat = 60
  let majorTickInterval: CGFloat = 5  // 5 minutes
  let minorTickInterval: CGFloat = 1  // 1 minute
  @StateObject private var timerManager = TimerManager()

  @State private var scrollOffset: CGFloat = 0
  @State private var lastScrollOffset: CGFloat = 0
  @State private var isDragging: Bool = false
  @State private var isLongPressing: Bool = false

  // Add padding to prevent text clipping
  private let topPadding: CGFloat = 5
  private let bottomPadding: CGFloat = 5

  // Make valuePerPoint dynamic based on screen height
  private func valuePerPoint(for geometry: GeometryProxy) -> CGFloat {
    // Calculate tick spacing based on available height
    let availableHeight = geometry.size.height * 0.8 - topPadding - bottomPadding
    let idealTickSpacing = availableHeight / (maxTick * 0.8)  // Use 80% of max height for better spacing
    return max(8, min(20, idealTickSpacing))  // Clamp between reasonable values
  }

  var body: some View {
    GeometryReader { geometry in
      ZStack {
        if showMenuOption || timerManager.state == .running {
          VStack {
            Spacer()
            HStack {
              Spacer()

              Image(
                systemName: isLongPressing
                  ? "stop.circle.fill"
                  : (timerManager.isRunning ? "pause.circle" : "play.circle")
              )
              .font(.system(size: 32))
              .foregroundColor(settings.textColor)
              .onTapGesture {
                // Handle tap - play/pause functionality
                if timerManager.canStart {
                  timerManager.startTimer()
                } else if timerManager.isRunning {
                  timerManager.pauseTimer()
                } else if timerManager.isPaused {
                  timerManager.resumeTimer()
                }
              }
              .onLongPressGesture(minimumDuration: 1.0, maximumDistance: 50) {
                // Handle long press - reset functionality
                timerManager.resetTimer(10 * 60)
                resetRulerToValue(targetValue: 10, geometry: geometry)
                isLongPressing = false
              } onPressingChanged: { pressing in
                // Track long press state to change icon
                withAnimation(.easeInOut(duration: 0.2)) {
                  isLongPressing = pressing
                }
              }

              Text(
                timerManager.formattedTimeRemaining
              )
              .foregroundColor(settings.textColor)
              .font(
                .custom(
                  settings.fontFamily,
                  size: 24
                )
              )
              .contentTransition(.numericText())

            }
            .padding(20)

          }
        }
        if showMenuOption || timerManager.state == .running {
          HStack(spacing: 0) {
            Spacer()
            ZStack {
              // Ruler Canvas - this moves with scrollOffset
              Canvas { context, size in
                drawRulerMarks(context: context, totalHeight: size.height, geometry: geometry)
                drawLabels(context: context, totalHeight: size.height, geometry: geometry)
              }
              .frame(
                width: 60,
                height: maxTick * valuePerPoint(for: geometry) + topPadding + bottomPadding
              )
              .offset(y: scrollOffset)
              .gesture(
                DragGesture()
                  .onChanged { value in
                    if timerManager.isRunning {
                      return
                    }

                    // Calculate potential new scroll position
                    let potentialScrollOffset = lastScrollOffset + value.translation.height

                    // Calculate what the value would be at the arrow position
                    let arrowPosition = geometry.size.height / 2
                    let rulerPositionAtArrow = arrowPosition - potentialScrollOffset - topPadding
                    let potentialValue = rulerPositionAtArrow / valuePerPoint(for: geometry)

                    // Clamp the value to valid range and calculate corresponding scroll offset
                    let clampedValue = max(0, min(maxTick, potentialValue))
                    let clampedRulerPosition =
                      clampedValue * valuePerPoint(for: geometry) + topPadding
                    let clampedScrollOffset = arrowPosition - clampedRulerPosition

                    // Allow manual scrolling when timer is not running OR when paused
                    isDragging = true
                    scrollOffset = clampedScrollOffset

                    // Update time remaining
                    let newTimeInSeconds = clampedValue * 60
                    timerManager.updateTimeRemaining(newTimeInSeconds)
                  }
                  .onEnded { value in
                    isDragging = false
                    lastScrollOffset = scrollOffset
                  }
              )

              // Arrow - this stays fixed at center
              HStack {
                Spacer()
                Image(systemName: "arrowtriangle.left.fill")
                  .foregroundColor(settings.textColor)
                  .font(.caption2)
                  .opacity(0.8)
              }
              .frame(width: 60)
              .allowsHitTesting(false)  // Prevent arrow from interfering with drag gestures
            }
            .frame(height: geometry.size.height * 0.8)
            .clipped()
          }
        }
      }
      .brightness(settings.brightness - 0.5)
      .onAppear {
        // Initialize to start at 10 minutes
        let targetValue: CGFloat = 10
        let targetYPosition =
          targetValue * valuePerPoint(for: geometry) + topPadding + bottomPadding

        // The arrow should be at the center of the screen
        let arrowPosition = geometry.size.height / 2

        // Position the ruler so that targetYPosition aligns with arrowPosition
        scrollOffset = arrowPosition - targetYPosition
        lastScrollOffset = scrollOffset
      }
      .onChange(of: timerManager.timeRemaining) { newTimeRemaining in
        // Auto-scroll the ruler to show remaining time when timer is running
        // But NOT when user is actively dragging
        if (timerManager.isRunning || timerManager.isPaused) && !isDragging {
          let remainingMinutes = CGFloat(newTimeRemaining / 60)
          animateRulerToValue(targetValue: remainingMinutes, geometry: geometry)
        }
      }
    }
  }

  private func drawLabels(context: GraphicsContext, totalHeight: CGFloat, geometry: GeometryProxy) {
    for index in 0...Int(maxTick / majorTickInterval) {
      let value = CGFloat(index) * majorTickInterval
      let yPosition = value * valuePerPoint(for: geometry) + topPadding

      if value <= maxTick {
        let text = Text("\(Int(value))")
          .font(.caption2)
          .foregroundColor(settings.textColor)

        context.draw(text, at: CGPoint(x: 15, y: yPosition))
      }
    }
  }

  private func drawRulerMarks(
    context: GraphicsContext, totalHeight: CGFloat, geometry: GeometryProxy
  ) {
    // Draw minor ticks (1 minute intervals)
    for minute in stride(from: 0, through: maxTick, by: minorTickInterval) {
      let yPosition = minute * valuePerPoint(for: geometry) + topPadding

      if minute.truncatingRemainder(dividingBy: majorTickInterval) != 0 {
        let tickPath = Path { path in
          path.move(to: CGPoint(x: 40, y: yPosition))
          path.addLine(to: CGPoint(x: 60, y: yPosition))
        }
        context.stroke(tickPath, with: .color(settings.textColor.opacity(0.7)), lineWidth: 0.5)
      }
    }

    // Draw major ticks (5 minute intervals)
    for minute in stride(from: 0, through: maxTick, by: majorTickInterval) {
      let yPosition = minute * valuePerPoint(for: geometry) + topPadding
      let tickPath = Path { path in
        path.move(to: CGPoint(x: 30, y: yPosition))
        path.addLine(to: CGPoint(x: 60, y: yPosition))
      }
      context.stroke(tickPath, with: .color(settings.textColor), lineWidth: 1.5)
    }
  }

  private func animateRulerToValue(targetValue: CGFloat, geometry: GeometryProxy) {
    let targetYPosition = targetValue * valuePerPoint(for: geometry) + topPadding
    let arrowPosition = geometry.size.height / 2
    let newScrollOffset = arrowPosition - targetYPosition

    withAnimation(.easeInOut(duration: 0.5)) {
      scrollOffset = newScrollOffset
    }
    lastScrollOffset = scrollOffset
  }

  private func resetRulerToValue(targetValue: CGFloat, geometry: GeometryProxy) {
    let targetYPosition = targetValue * valuePerPoint(for: geometry) + topPadding
    let arrowPosition = geometry.size.height / 2

    withAnimation(.easeInOut(duration: 0.3)) {
      scrollOffset = arrowPosition - targetYPosition
    }
    lastScrollOffset = scrollOffset
  }
}
