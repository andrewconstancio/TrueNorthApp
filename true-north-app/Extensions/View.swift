//
//  View.swift
//  true-north-app
//
//  Created by Andrew Constancio on 6/24/25.
//
import SwiftUI

extension View {
    func withRootAppearance() -> some View {
        self.modifier(RootViewAppearance())
    }
    
    func navigate<NewView: View>(to view: NewView, when binding: Binding<Bool>) -> some View {
          NavigationView {
              ZStack {
                  self
                      .navigationBarTitle("")
                      .navigationBarHidden(true)

                  NavigationLink(
                      destination: view
                          .navigationBarTitle("")
                          .navigationBarHidden(true),
                      isActive: binding
                  ) {
                      EmptyView()
                  }
              }
          }
          .navigationViewStyle(.stack)
      }
}
