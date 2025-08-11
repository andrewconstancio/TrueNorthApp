import SwiftUI

struct CustomInputField: View {
    let imageName: String?
    let placeholderText: String
    var textCase: Text.Case?
    var keyboardType: UIKeyboardType?
    var textContentType: UITextContentType?
    var textInputAutoCapital: TextInputAutocapitalization?
    var isSecureField: Bool? = false
    var prependText: String?
    var maxLength: Int?
    var isTextBold: Bool = false
    var formatAsPhoneNumber: Bool = false
    
    @Binding var text: String
    
    var body: some View {
        VStack {
            HStack {
                if let imageName = imageName {
                    Image(systemName: imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color(.darkGray))
                }
                
                if let prependText = prependText {
                    Text(prependText)
                        .bold()
                }
                
                if isSecureField ?? false {
                    SecureField(placeholderText, text: $text)
                        .textContentType(textContentType != nil ? textContentType : .none)
                } else {
                    TextField(placeholderText, text: $text)
                        .keyboardType(keyboardType != nil ? keyboardType! : .default)
                        .textContentType(textContentType != nil ? textContentType : .none)
                        .disableAutocorrection(true)
                        .textInputAutocapitalization(textInputAutoCapital != nil ? textInputAutoCapital : .none)
                        .font(FontManager.Bungee.regular.font(size: 18))
                        .foregroundStyle(.textPrimary)
                }
            }
            .padding()
            .frame(width: 340, height: 65)
            .background(Color(light: .gray.opacity(0.1), dark: .white.opacity(0.1)))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.6), lineWidth: 1)
            )
            .cornerRadius(16)
        }
    }
}

#Preview {
    CustomInputField(
        imageName: nil,
        placeholderText: "Email",
        isSecureField: false,
        prependText: "+1",
        maxLength: nil,
        text: .constant("")
    )
}

extension CustomInputField {
    
    func setTextCase(text: String) -> String {
        if let textCase = textCase {
            if textCase == .uppercase {
                return text.uppercased()
            } else if textCase == .lowercase {
                return text.lowercased()
            }
        }
        return text
    }
}

func formatPhoneNumber(_ number: String) -> String {
    let digits = number.filter(\.isNumber)
    var result = ""

    for (index, digit) in digits.prefix(10).enumerated() {
        if index == 3 || index == 6 {
            result.append("-")
        }
        result.append(digit)
    }

    return result
}
