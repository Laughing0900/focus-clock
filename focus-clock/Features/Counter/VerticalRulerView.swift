import SwiftUI
import UIKit

struct VerticalRuler: View {
  let maxTick: CGFloat = 60
  let majorTickInterval: CGFloat = 5  // 5 minutes
  let minorTickInterval: CGFloat = 1  // 1 minute

  @StateObject private var settings = UserSettings()
  @StateObject private var timerManager = TimerManager()

  @State private var scrollOffset: CGFloat = 0
  @State private var lastScrollOffset: CGFloat = 0
  @State private var isDragging: Bool = false

  let tickSpacing: CGFloat = 12

  // Add padding to prevent text clipping
  private let topPadding: CGFloat = 5
  private let bottomPadding: CGFloat = 5

  private var valuePerPoint: CGFloat {
    minorTickInterval * tickSpacing
  }

  var body: some View {
    GeometryReader { geometry in
      ZStack {
        VStack {
          Spacer()
          HStack {
            Spacer()

            Button {
              if timerManager.canStart {
                timerManager.startTimer()
              } else if timerManager.isRunning {
                timerManager.pauseTimer()
              } else if timerManager.isPaused {
                timerManager.resumeTimer()
              }
            } label: {
              Image(systemName: timerManager.isRunning ? "pause.circle" : "play.circle")
                .font(.system(size: 32))
                .foregroundColor(settings.textColor)

            }

            Text(
              timerManager.formattedTimeRemaining
            )
            .font(.title2)
            .foregroundColor(settings.textColor)

            Button {
              // Reset ruler to 10 minutes
              timerManager.resetTimer(10 * 60)
              resetRulerToValue(targetValue: 10, geometry: geometry)
            } label: {
              Image(systemName: "stop.circle")
                .font(.system(size: 32))
                .foregroundColor(settings.textColor)

            }

          }

        }

        HStack(spacing: 0) {
          Spacer()
          ZStack {
            HStack {
              Canvas { context, size in
                drawRulerMarks(context: context, totalHeight: size.height)
                drawLabels(context: context, totalHeight: size.height)
              }
              .frame(width: 60, height: maxTick * valuePerPoint + topPadding + bottomPadding)
              .offset(y: scrollOffset)
              .gesture(
                DragGesture()
                  .onChanged { value in
                    if timerManager.isRunning {
                      return
                    }

                    // Allow manual scrolling when timer is not running OR when paused
                    isDragging = true
                    scrollOffset = lastScrollOffset + value.translation.height

                    // Calculate the value directly for time remaining update
                    let arrowPosition = geometry.size.height / 2
                    let rulerPositionAtArrow =
                      arrowPosition - scrollOffset - topPadding - bottomPadding
                    let valueAtArrow = max(0, min(maxTick, rulerPositionAtArrow / valuePerPoint))

                    let newTimeInSeconds = valueAtArrow * 60
                    timerManager.updateTimeRemaining(newTimeInSeconds)
                  }
                  .onEnded { value in
                    isDragging = false
                    lastScrollOffset = scrollOffset

                  }
              )

              Image(systemName: "arrowtriangle.left.fill")
                .foregroundColor(.white)
                .font(.caption2)
                .opacity(0.8)
                .offset(y: -valuePerPoint - topPadding - bottomPadding)

            }
          }
          .frame(height: geometry.size.height * 0.8)
          .clipped()

        }

      }
      .onAppear {
        // Initialize to start at 10 minutes
        let targetValue: CGFloat = 10
        let targetYPosition = targetValue * valuePerPoint + topPadding + bottomPadding

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

  private func drawLabels(context: GraphicsContext, totalHeight: CGFloat) {
    for index in 0...Int(maxTick / majorTickInterval) {
      let value = CGFloat(index) * majorTickInterval
      let yPosition = value * valuePerPoint + topPadding

      if value <= maxTick {
        let text = Text("\(Int(value))")
          .font(.caption2)
          .foregroundColor(settings.textColor)

        context.draw(text, at: CGPoint(x: 15, y: yPosition))
      }
    }
  }

  private func drawRulerMarks(context: GraphicsContext, totalHeight: CGFloat) {
    // Draw minor ticks (1 minute intervals)

    for minute in stride(from: 0, through: maxTick, by: minorTickInterval) {
      let yPosition = minute * valuePerPoint + topPadding

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
      let yPosition = minute * valuePerPoint + topPadding
      let tickPath = Path { path in
        path.move(to: CGPoint(x: 30, y: yPosition))
        path.addLine(to: CGPoint(x: 60, y: yPosition))
      }
      context.stroke(tickPath, with: .color(settings.textColor), lineWidth: 1.5)
    }
  }

  // MARK: - Helper Methods

  private func animateRulerToValue(targetValue: CGFloat, geometry: GeometryProxy) {
    let targetYPosition = targetValue * valuePerPoint + topPadding
    let arrowPosition = geometry.size.height / 2
    let newScrollOffset = arrowPosition - targetYPosition

    withAnimation(.easeInOut(duration: 0.5)) {
      scrollOffset = newScrollOffset
    }
    lastScrollOffset = scrollOffset
  }

  private func resetRulerToValue(targetValue: CGFloat, geometry: GeometryProxy) {
    let targetYPosition = targetValue * valuePerPoint + topPadding
    let arrowPosition = geometry.size.height / 2

    withAnimation(.easeInOut(duration: 0.3)) {
      scrollOffset = arrowPosition - targetYPosition
    }
    lastScrollOffset = scrollOffset
  }
}
