
import SwiftUI

struct SliderView: View {
    @State var value: Int = 0
    @State var tempValue: Int = 0
    @State var dragOffset: CGFloat = 0
    let range: ClosedRange<Int> = 0...60
    let stepWidth: CGFloat = 20



    var body: some View {
        VStack {
            Text("\(tempValue)").font(.system(size: 64, weight: .bold))
            .contentTransition(.numericText())
            .sensoryFeedback(.selection, trigger: tempValue)

            Text("min").font(.system(size: 20, weight:.medium)).foregroundColor(.gray)
            .gesture(DragGesture(minimumDistance: 0).onChanged({ value in
                let newOffset = value.translation.width / stepWidth
                let newValue = Int((Double(tempValue) + Double(newOffset)).rounded())
                if range.contains(newValue) {
                    tempValue = newValue
                }
            }))

            GeometryReader { geo in
                let center = geo.size.width / 2
                ForEach(range, id: \.self) { tick in
                    let x = center + CGFloat(tick - value) * stepWidth + dragOffset

                    VStack {
                        Spacer()
                        RoundedRectangle(cornerRadius: 10)
                        .fill(tick==tempValue ? Color.white : Color.gray.opacity(0.4))
                        .frame(width: tick==tempValue ? 3:1, height: tick % 5 == 0 ? 20 : 10)

                    }
                    .position(x: x, y: geo.size.height / 2)
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                .onChanged({ gesture in
                    withAnimation(.interactiveSpring()) {
                        let rawOffset = gesture.translation.width
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

                    }
                })
                .onEnded({ gesture in
                    let offsetSteps = gesture.translation.width / stepWidth
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

}
extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
