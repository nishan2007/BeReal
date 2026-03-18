//
//  MainTabView.swift
//  BeReal
//
//  Created by Nishan Narain on 2/12/26.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            FeedView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Feed")
                }

            CreatePostView()
                .tabItem {
                    Image(systemName: "plus.square.fill")
                    Text("Post")
                }

            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
        }
    }
}
