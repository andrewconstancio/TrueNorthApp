//
//  SettingsView.swift
//  true-north-app
//
//  Created by Andrew Constancio on 7/7/25.
//
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
