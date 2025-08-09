import SwiftUI
import Combine

final class KeyboardResponder: ObservableObject {
    @Published var keyboardHeight: CGFloat = 0

    private var cancellables: Set<AnyCancellable> = []

    init() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)
            .merge(with: NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification))
            .sink { notification in
                guard
                    let userInfo = notification.userInfo,
                    let endFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
                    let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
                    let curveValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
                else { return }

                let animation = Animation.timingCurve(0.25, 0.1, 0.25, 1, duration: duration)
                let height = notification.name == UIResponder.keyboardWillHideNotification ? 0 : endFrame.height

                withAnimation(animation) {
                    self.keyboardHeight = height
                }
            }
            .store(in: &cancellables)
    }
}
