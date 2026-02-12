//
//  AuthView.swift
//  BeReal
//
//  Created by Nishan Narain on 2/12/26.
//

import SwiftUI

struct AuthView: View {
    var body: some View {
        @EnvironmentObject var session: SessionStore
        NavigationStack{
            LoginView()
        }
    }
    
}

struct LoginView: View {
    @EnvironmentObject var session: SessionStore

    @State private var username: String = ""
    @State private var password: String = ""
    
    
    var body: some View{
        VStack(spacing:18){
            Spacer(minLength: 30)
            Text("BeReal").font(.system(size: 40, weight: .bold, design: .rounded))
            Text("Login").font(.system(size: 40, weight: .bold, design: .rounded))

            
        }
    }
}
