import SwiftUI

struct SettingsView: View {
    
    init() {
        print("INIT SETTINGS VIEW")
    }
    
    var body: some View {
        Form {
            Section {
                Button {
                    
                } label: {
                    Text("Hello")
                }
            } header: {
                Text("Private Policy")
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
    }
}
