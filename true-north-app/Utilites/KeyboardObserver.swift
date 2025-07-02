//
//  KeyboardObserver.swift
//  true-north-app
//
//  Created by Andrew Constancio on 6/25/25.
//

import Combine
import SwiftUI


final class KeyboardObserver: ObservableObject {
    @Published var keyboardHeight: CGFloat = 0
    private var cancellables = Set<AnyCancellable>()

    init() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
            .map { $0.height }
            .sink { [weak self] height in
                self?.keyboardHeight = height
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { [weak self] _ in
                self?.keyboardHeight = 0
            }
            .store(in: &cancellables)
    }
}
