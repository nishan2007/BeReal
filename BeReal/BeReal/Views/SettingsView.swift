//
//  SettingsView.swift
//  BeReal
//
//  Created by Nishan Narain on 3/18/26.
//

import SwiftUI

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var session: SessionStore

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Settings")
                    .font(.title)

                Button("Log Out") {
                    session.logout()
                }
                .buttonStyle(.borderedProminent)

                Spacer()
            }
            .padding()
            .navigationTitle("Settings")
        }
    }
}
