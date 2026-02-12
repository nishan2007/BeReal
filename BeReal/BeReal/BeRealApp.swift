//
//  BeRealApp.swift
//  BeReal
//
//  Created by Nishan Narain on 2/12/26.
//

import SwiftUI
import ParseSwift

@main
struct BeRealApp: App {
    init() {
        ParseSwift.initialize(
            applicationId: "seKG2qlTJOBFmIxZ15sVkst4MO7mvwtsoGhzlW14",
            clientKey: "1WblpOXPwc6Qa5j8uQ5kDzXSuAXfoSIPyK7kCPc0",
            serverURL: URL(string: "https://parseapi.back4app.com/")!
        )
    }
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
