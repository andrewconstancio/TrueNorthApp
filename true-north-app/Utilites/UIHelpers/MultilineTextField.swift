import SwiftUI
import UIKit

// MARK: - TextViewWrapperDelegate
protocol TextViewWrapperDelegate: AnyObject {
    /// Clears the textfield.
    func clearText()

    /// Resigns the first responder.
    func resignFirstResponder()
}

// MARK: - UITextViewWrapper

public struct UITextViewWrapper: UIViewRepresentable {
    public typealias UIViewType = UITextView

    @Binding var text: String

    @Binding var calculatedHeight: CGFloat
    
    var keyboardType: UIKeyboardType
    
    var textContentType: UITextContentType?
    
    var onDone: (() -> Void)?
    
    /// Closure called when the UITextView begins or ends editing (true = active, false = inactive).
    var onEditingChanged: ((Bool) -> Void)?
    
    /// Maximum number of lines allowed (nil for no limit)
    var maxLines: Int?

    public func makeUIView(context: UIViewRepresentableContext<UITextViewWrapper>) -> UITextView {
        let textField = UITextView()
        textField.delegate = context.coordinator
        textField.isEditable = true
        textField.isSelectable = true
        textField.isUserInteractionEnabled = true
        textField.isScrollEnabled = false
        textField.backgroundColor = UIColor.clear
        textField.layer.cornerRadius = 30
        textField.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        textField.textContainer.lineFragmentPadding = 0
        textField.textColor = UIColor(Color.textPrimary)
        textField.font = UIFont(name: "Bungee-Regular", size: 26)
        if nil != onDone {
            textField.returnKeyType = .done
        }
        
        textField.keyboardType = keyboardType
        if nil != textContentType {
            textField.textContentType = textContentType
        }
        textField.keyboardDismissMode = .interactive
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        return textField
    }

    public func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<UITextViewWrapper>) {
        if uiView.text != self.text {
            uiView.text = self.text
        }
        UITextViewWrapper.recalculateHeight(view: uiView, result: $calculatedHeight)
    }

    fileprivate static func recalculateHeight(view: UIView, result: Binding<CGFloat>) {
        let newSize = view.sizeThatFits(CGSize(width: view.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        if result.wrappedValue != newSize.height {
            DispatchQueue.main.async {
                result.wrappedValue = newSize.height
            }
        }
    }

    public func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator(
            text: $text,
            height: $calculatedHeight,
            onDone: onDone,
            onEditingChanged: onEditingChanged,
            maxLines: maxLines
        )
        return coordinator
    }

    // MARK: - Coordinator

    public class Coordinator: NSObject, UITextViewDelegate, TextViewWrapperDelegate {
        var text: Binding<String>
        var thisTextView: UITextView?
        var calculatedHeight: Binding<CGFloat>
        var onDone: (() -> Void)?
        var onEditingChanged: ((Bool) -> Void)?
        var maxLines: Int?

        init(text: Binding<String>, height: Binding<CGFloat>, onDone: (() -> Void)? = nil, onEditingChanged: ((Bool) -> Void)? = nil, maxLines: Int? = nil) {
            self.text = text
            self.calculatedHeight = height
            self.onDone = onDone
            self.onEditingChanged = onEditingChanged
            self.maxLines = maxLines
        }

        public func textViewDidChange(_ uiView: UITextView) {
            text.wrappedValue = uiView.text
            thisTextView = uiView
            UITextViewWrapper.recalculateHeight(view: uiView, result: calculatedHeight)
        }

        public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
            thisTextView = textView
            return true
        }

        public func textViewDidBeginEditing(_ textView: UITextView) {
            onEditingChanged?(true)
        }

        public func textViewDidEndEditing(_ textView: UITextView) {
            onEditingChanged?(false)
        }

        public func textView(
            _ textView: UITextView,
            shouldChangeTextIn range: NSRange,
            replacementText text: String
        ) -> Bool {
            if let onDone = self.onDone, text == "\n" {
                textView.resignFirstResponder()
                onDone()
                return false
            }
            
            let currentText = textView.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
            
            // Check line limit if specified
            if let maxLines = self.maxLines {
                let numberOfLines = self.calculateNumberOfLines(for: updatedText, in: textView)
                if numberOfLines > maxLines {
                    return false
                }
            }
            
            return true
        }
        
        private func calculateNumberOfLines(for text: String, in textView: UITextView) -> Int {
            guard let font = textView.font else { return 1 }
            
            let textWidth = textView.frame.width - textView.textContainerInset.left - textView.textContainerInset.right
            
            let boundingRect = text.boundingRect(
                with: CGSize(width: textWidth, height: .greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: [.font: font],
                context: nil
            )
            
            let lineHeight = font.lineHeight
            let numberOfLines = Int(ceil(boundingRect.height / lineHeight))
            
            return max(1, numberOfLines)
        }

        func resignFirstResponder() {
            thisTextView?.resignFirstResponder()
            thisTextView?.endEditing(true)
        }

        /// Clears the text binding.
        public func clearText() {
            text.wrappedValue = ""
            thisTextView?.resignFirstResponder()
            thisTextView?.endEditing(true)
        }
    }
}

// MARK: - MultilineTextField

struct MultilineTextField: View {
    private var placeholder: String
    private var keyboardType: UIKeyboardType
    private var textContentType: UITextContentType?
    private var onCommit: (() -> Void)?
    private var maxLines: Int?
    private var isActive: Bool
    private var isSearchBar: Bool
    
    /// Closure to notify when the UITextView becomes active/inactive.
    var onEditingChanged: ((Bool) -> Void)?

    @Binding private var text: String

    @State private var dynamicHeight: CGFloat = 100

    init (
        _ placeholder: String = "",
        isActive: Bool = false,
        isSearchBar: Bool = false,
        keyboardType: UIKeyboardType = .default,
        textContentType: UITextContentType? = nil,
        text: Binding<String>,
        maxLines: Int? = nil,
        onCommit: (() -> Void)? = nil,
        onEditingChanged: ((Bool) -> Void)? = nil
    ) {
        self.placeholder = placeholder
        self.isActive = isActive
        self.isSearchBar = isSearchBar
        self.keyboardType = keyboardType
        self.textContentType = textContentType
        self.onCommit = onCommit
        self._text = text
        self.onEditingChanged = onEditingChanged
        self.maxLines = maxLines
    }

    var body: some View {
        HStack(spacing: 0) {
            if (isActive || !text.isEmpty) && isSearchBar {
                Image(systemName: "magnifyingglass")
                    .frame(width: 0)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                    .padding(.leading, 26)
            } else {
                Circle()
                    .frame(width: 0)
                    .padding(.leading, 12)
            }
            
            UITextViewWrapper(
                text: $text,
                calculatedHeight: $dynamicHeight,
                keyboardType: keyboardType,
                textContentType: textContentType,
                onDone: onCommit,
                onEditingChanged: onEditingChanged,
                maxLines: maxLines
            )
            .padding(.leading, -10)
        }
        .background(alignment: .leading, content: {
            if text.count == 0 {
                placeholderView
            } else {
                EmptyView()
            }
        })
        .frame(maxHeight: dynamicHeight)
    }

     var placeholderView: some View {
         Group {
             Text(placeholder)
                 .foregroundColor(.gray)
                 .padding(.leading, isActive ? 44 : 26)
         }
     }
 }

#if DEBUG
struct MultilineTextField_Previews: PreviewProvider {
    static var test: String = ""
    static var testBinding = Binding<String>(get: { test }, set: {
        test = $0 } )

    static var previews: some View {
        VStack(alignment: .leading) {
            Text("Description (max 3 lines):")
            MultilineTextField(
                "Enter some text here",
                text: testBinding,
                maxLines: 3,
                onCommit: {
                    print("Final text: \(test)")
                }
            )
            .background(Color(.green))
            .cornerRadius(30)
            Text("Something static here...")
            Spacer()
        }
        .padding()
    }
}

//import SwiftUI
//import UIKit
//
//// MARK: - TextViewWrapperDelegate
//protocol TextViewWrapperDelegate: AnyObject {
//    /// Clears the textfield.
//    func clearText()
//
//    /// Resigns the first responder.
//    func resignFirstResponder()
//}
//
//// MARK: - UITextViewWrapper
//
//public struct UITextViewWrapper: UIViewRepresentable {
//    public typealias UIViewType = UITextView
//
//    @Binding var text: String
//
//    @Binding var calculatedHeight: CGFloat
//    
//    var keyboardType: UIKeyboardType
//    
//    var textContentType: UITextContentType?
//    
//    var onDone: (() -> Void)?
//    
//    /// Closure called when the UITextView begins or ends editing (true = active, false = inactive).
//    var onEditingChanged: ((Bool) -> Void)?
//    
//    /// Maximum number of lines allowed (nil for no limit)
//    var maxLines: Int?
//    
//    /// Custom font (optional)
//    var font: UIFont?
//    
//    /// Custom text color (optional)
//    var textColor: UIColor?
//    
//    /// Custom text container inset (optional)
//    var textContainerInset: UIEdgeInsets?
//    
//    /// Custom line fragment padding (optional)
//    var lineFragmentPadding: CGFloat?
//    
//    /// Custom corner radius (optional)
//    var cornerRadius: CGFloat?
//
//    public func makeUIView(context: UIViewRepresentableContext<UITextViewWrapper>) -> UITextView {
//        let textField = UITextView()
//        textField.delegate = context.coordinator
//        textField.isEditable = true
//        textField.isSelectable = true
//        textField.isUserInteractionEnabled = true
//        textField.isScrollEnabled = false
//        textField.backgroundColor = UIColor.clear
//        textField.textContainerInset = textContainerInset ?? UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
//        textField.textContainer.lineFragmentPadding = lineFragmentPadding ?? 0
//        textField.layer.cornerRadius = cornerRadius ?? 30
//        textField.textColor = textColor ?? .textPrimary
//        textField.font = font ?? UIFont(name: "Nunito-Bold", size: 18)
//        if nil != onDone {
//            textField.returnKeyType = .done
//        }
//        
//        textField.keyboardType = keyboardType
//        if nil != textContentType {
//            textField.textContentType = textContentType
//        }
//        textField.keyboardDismissMode = .interactive
//        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
//        
//        return textField
//    }
//
//    public func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<UITextViewWrapper>) {
//        if uiView.text != self.text {
//            uiView.text = self.text
//        }
//        if let font = font {
//            uiView.font = font
//        }
//        if let textColor = textColor {
//            uiView.textColor = textColor
//        }
//        if let textContainerInset = textContainerInset {
//            uiView.textContainerInset = textContainerInset
//        }
//        if let lineFragmentPadding = lineFragmentPadding {
//            uiView.textContainer.lineFragmentPadding = lineFragmentPadding
//        }
//        if let cornerRadius = cornerRadius {
//            uiView.layer.cornerRadius = cornerRadius
//        }
//        UITextViewWrapper.recalculateHeight(view: uiView, result: $calculatedHeight)
//    }
//
//    fileprivate static func recalculateHeight(view: UIView, result: Binding<CGFloat>) {
//        let newSize = view.sizeThatFits(CGSize(width: view.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
//        if result.wrappedValue != newSize.height {
//            DispatchQueue.main.async {
//                result.wrappedValue = newSize.height
//            }
//        }
//    }
//
//    public func makeCoordinator() -> Coordinator {
//        let coordinator = Coordinator(
//            text: $text,
//            height: $calculatedHeight,
//            onDone: onDone,
//            onEditingChanged: onEditingChanged,
//            maxLines: maxLines
//        )
//        return coordinator
//    }
//
//    // MARK: - Coordinator
//
//    public class Coordinator: NSObject, UITextViewDelegate, TextViewWrapperDelegate {
//        var text: Binding<String>
//        var thisTextView: UITextView?
//        var calculatedHeight: Binding<CGFloat>
//        var onDone: (() -> Void)?
//        var onEditingChanged: ((Bool) -> Void)?
//        var maxLines: Int?
//
//        init(text: Binding<String>, height: Binding<CGFloat>, onDone: (() -> Void)? = nil, onEditingChanged: ((Bool) -> Void)? = nil, maxLines: Int? = nil) {
//            self.text = text
//            self.calculatedHeight = height
//            self.onDone = onDone
//            self.onEditingChanged = onEditingChanged
//            self.maxLines = maxLines
//        }
//
//        public func textViewDidChange(_ uiView: UITextView) {
//            text.wrappedValue = uiView.text
//            thisTextView = uiView
//            UITextViewWrapper.recalculateHeight(view: uiView, result: calculatedHeight)
//        }
//
//        public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
//            thisTextView = textView
//            return true
//        }
//
//        public func textViewDidBeginEditing(_ textView: UITextView) {
//            onEditingChanged?(true)
//        }
//
//        public func textViewDidEndEditing(_ textView: UITextView) {
//            onEditingChanged?(false)
//        }
//
//        public func textView(
//            _ textView: UITextView,
//            shouldChangeTextIn range: NSRange,
//            replacementText text: String
//        ) -> Bool {
//            if let onDone = self.onDone, text == "\n" {
//                textView.resignFirstResponder()
//                onDone()
//                return false
//            }
//            
//            let currentText = textView.text ?? ""
//            guard let stringRange = Range(range, in: currentText) else { return false }
//            let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
//            
//            // Check line limit if specified
//            if let maxLines = self.maxLines {
//                let numberOfLines = self.calculateNumberOfLines(for: updatedText, in: textView)
//                if numberOfLines > maxLines {
//                    return false
//                }
//            }
//            
//            return true
//        }
//        
//        private func calculateNumberOfLines(for text: String, in textView: UITextView) -> Int {
//            guard let font = textView.font else { return 1 }
//            
//            let textWidth = textView.frame.width - textView.textContainerInset.left - textView.textContainerInset.right
//            
//            let boundingRect = text.boundingRect(
//                with: CGSize(width: textWidth, height: .greatestFiniteMagnitude),
//                options: [.usesLineFragmentOrigin, .usesFontLeading],
//                attributes: [.font: font],
//                context: nil
//            )
//            
//            let lineHeight = font.lineHeight
//            let numberOfLines = Int(ceil(boundingRect.height / lineHeight))
//            
//            return max(1, numberOfLines)
//        }
//
//        func resignFirstResponder() {
//            thisTextView?.resignFirstResponder()
//            thisTextView?.endEditing(true)
//        }
//
//        /// Clears the text binding.
//        public func clearText() {
//            text.wrappedValue = ""
//            thisTextView?.resignFirstResponder()
//            thisTextView?.endEditing(true)
//        }
//    }
//}
//
//// MARK: - MultilineTextField
//
//struct MultilineTextField: View {
//    private var placeholder: String
//    private var keyboardType: UIKeyboardType
//    private var textContentType: UITextContentType?
//    private var onCommit: (() -> Void)?
//    private var maxLines: Int?
//    private var isActive: Bool
//    private var isSearchBar: Bool
//    private var font: UIFont?
//    private var textColor: UIColor?
//    private var textContainerInset: UIEdgeInsets?
//    private var lineFragmentPadding: CGFloat?
//    private var cornerRadius: CGFloat?
//    
//    /// Closure to notify when the UITextView becomes active/inactive.
//    var onEditingChanged: ((Bool) -> Void)?
//
//    @Binding private var text: String
//
//    @State private var dynamicHeight: CGFloat = 100
//
//    init (
//        _ placeholder: String = "",
//        isActive: Bool = false,
//        isSearchBar: Bool = false,
//        keyboardType: UIKeyboardType = .default,
//        textContentType: UITextContentType? = nil,
//        text: Binding<String>,
//        maxLines: Int? = nil,
//        font: UIFont? = nil,
//        textColor: UIColor? = nil,
//        textContainerInset: UIEdgeInsets? = nil,
//        lineFragmentPadding: CGFloat? = nil,
//        cornerRadius: CGFloat? = nil,
//        onCommit: (() -> Void)? = nil,
//        onEditingChanged: ((Bool) -> Void)? = nil
//    ) {
//        self.placeholder = placeholder
//        self.isActive = isActive
//        self.isSearchBar = isSearchBar
//        self.keyboardType = keyboardType
//        self.textContentType = textContentType
//        self.onCommit = onCommit
//        self._text = text
//        self.onEditingChanged = onEditingChanged
//        self.maxLines = maxLines
//        self.font = font
//        self.textColor = textColor
//        self.textContainerInset = textContainerInset
//        self.lineFragmentPadding = lineFragmentPadding
//        self.cornerRadius = cornerRadius
//    }
//
//    var body: some View {
//        HStack(spacing: 0) {
//            if (isActive || !text.isEmpty) && isSearchBar {
//                Image(systemName: "magnifyingglass")
//                    .frame(width: 0)
//                    .fontWeight(.bold)
//                    .foregroundColor(.gray)
//                    .padding(.leading, 26)
//            } else {
//                Circle()
//                    .frame(width: 0)
//                    .padding(.leading, 12)
//            }
//            
//            UITextViewWrapper(
//                text: $text,
//                calculatedHeight: $dynamicHeight,
//                keyboardType: keyboardType,
//                textContentType: textContentType,
//                onDone: onCommit,
//                onEditingChanged: onEditingChanged,
//                maxLines: maxLines,
//                font: font,
//                textColor: textColor,
//                textContainerInset: textContainerInset,
//                lineFragmentPadding: lineFragmentPadding,
//                cornerRadius: cornerRadius
//            )
//            .padding(.leading, -10)
//        }
//        .background(alignment: .leading, content: {
//            if text.count == 0 {
//                placeholderView
//            } else {
//                EmptyView()
//            }
//        })
////        .frame(minHeight: 60, maxHeight: dynamicHeight)
//    }
//
//     var placeholderView: some View {
//         Group {
//             Text(placeholder)
//                 .foregroundColor(.gray)
//                 .padding(.leading, isActive ? 44 : 26)
//         }
//     }
// }
//
//#if DEBUG
//struct MultilineTextField_Previews: PreviewProvider {
//    static var test: String = ""
//    static var testBinding = Binding<String>(get: { test }, set: {
//        test = $0 } )
//
//    static var previews: some View {
//        VStack(alignment: .leading) {
//            Text("Description (max 3 lines):")
//            MultilineTextField(
//                "Enter some text here",
//                text: testBinding,
//                maxLines: 3,
//                onCommit: {
//                    print("Final text: \(test)")
//                }
//            )
//            .background(Color(.green))
//            .cornerRadius(30)
//            Text("Something static here...")
//            Spacer()
//        }
//        .padding()
//    }
//}
#endif
