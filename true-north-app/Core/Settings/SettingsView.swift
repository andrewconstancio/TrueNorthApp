import SwiftUI

struct SettingsView: View {
    
    init() {
        print("INIT SETTINGS VIEW")
    }
    
    var body: some View {
        VStack {
            Text("Settings View")
        }
        .onAppear {
            print("init settings")
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
    }
}
