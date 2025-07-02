//
//  AddPhoneNumberView.swift
//  true-north-app
//
//  Created by Andrew Constancio on 6/25/25.
//

import SwiftUI

struct AddPhoneNumberView: View {
    @Binding var path: NavigationPath
    
    @State private var phoneNumber: String = ""
    @State private var errorMessage: String?
    @State private var isLoading: Bool = false

    @EnvironmentObject var viewModel: AuthViewModel
    @StateObject private var keyboard = KeyboardObserver()

    private var isPhoneNumberValid: Bool {
        let digitsOnly = phoneNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        return digitsOnly.count == 10
    }

    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    UIApplication.shared.endEditing()
                }

            VStack(alignment: .leading, spacing: 16) {
                Spacer()
                
                Text("What's your number?")
                    .font(.title)
                    .fontWeight(.bold)
                    
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }

                CustomInputField(
                    imageName: nil,
                    placeholderText: "Phone Number",
                    keyboardType: .phonePad,
                    prependText: "+1",
                    maxLength: 10,
                    isTextBold: true,
                    formatAsPhoneNumber: true,
                    text: $phoneNumber
                )

                Spacer()
                Spacer()
            }
            .padding()

            // Floating Continue Button
            VStack {
                Spacer()

                Button {
                    
                    Task {
                        // Navigate to verification view
                        print("Navigating to VerifyPhoneCodeView")
                        path.append("VerifyPhoneCodeView")
                        
                        errorMessage = nil
                        isLoading = true
                        try await viewModel.registerPhoneNumber(phoneNumber: phoneNumber)
                        isLoading = false
                    }
                } label: {
                    if isLoading {
                        ProgressView()
                            .frame(width: 340, height: 65)
                    } else {
                        Text("Continue")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 340, height: 65)
                            .background(isPhoneNumberValid ? Color.themeColor : Color.black.opacity(0.4))
                            .clipShape(Capsule())
                            .padding()
                            .opacity(isPhoneNumberValid ? 1 : 0.5)
                    }
                }
                .disabled(isLoading || !isPhoneNumberValid)
                .animation(.easeOut(duration: 0.25), value: keyboard.keyboardHeight)
            }
        }
        .padding(.bottom, 40)
    }
}
