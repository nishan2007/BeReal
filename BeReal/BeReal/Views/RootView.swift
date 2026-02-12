//
//  Root.swift
//  BeReal
//
//  Created by Nishan Narain on 2/12/26.
//

import SwiftUI
import ParseSwift

struct RootView: View {
    @StateObject private var session = SessionStore()

    var body: some View {
        Group {
            if session.currentUser != nil {
                MainTabView()
                    .environmentObject(session)
            } else {
                AuthView()
                    .environmentObject(session)
            }
        }
        .onAppear { session.refresh() }
    }
}
