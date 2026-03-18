//
//  AuthView.swift
//  BeReal
//
//  Created by Nishan Narain on 2/12/26.
//

import SwiftUI
import ParseSwift

struct AuthView: View {
    @EnvironmentObject var session: SessionStore

    var body: some View {
        NavigationStack {
            LoginView()
        }
    }
}

// MARK: - Login

struct LoginView: View {
    @EnvironmentObject var session: SessionStore

    @State private var username = ""
    @State private var password = ""
    @State private var errorText: String?
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 18) {
            Spacer(minLength: 30)

            Text("BeReal")
                .font(.system(size: 40, weight: .bold, design: .rounded))

            Text("Log in to continue")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            VStack(spacing: 12) {
                TextField("Username", text: $username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .textFieldStyle(.roundedBorder)

                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
            }
            .padding(.top, 10)

            if let errorText {
                Text(errorText)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            Button {
                login()
            } label: {
                HStack {
                    if isLoading { ProgressView() }
                    Text(isLoading ? "Logging in…" : "Log In")
                        .font(.system(size: 17, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLoading || username.isEmpty || password.isEmpty)
            .padding(.top, 8)

            Spacer()

            // Bottom sign up link
            NavigationLink {
                RegisterView()
            } label: {
                Text("Don’t have an account? ")
                    .foregroundStyle(.secondary)
                Text("Sign up")
                    .fontWeight(.semibold)
            }
            .padding(.bottom, 12)
        }
        .padding(.horizontal, 24)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func login() {
        errorText = nil
        isLoading = true

        User.login(username: username, password: password) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success:
                    session.refresh()
                case .failure(let error):
                    errorText = error.localizedDescription
                }
            }
        }
    }
}

// MARK: - Register

struct RegisterView: View {
    @EnvironmentObject var session: SessionStore
    @Environment(\.dismiss) private var dismiss

    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var errorText: String?
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 18) {
            Spacer(minLength: 30)

            Text("Create Account")
                .font(.system(size: 30, weight: .bold, design: .rounded))

            Text("Sign up to start posting")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            VStack(spacing: 12) {
                TextField("Username", text: $username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .textFieldStyle(.roundedBorder)

                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .textFieldStyle(.roundedBorder)

                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
            }
            .padding(.top, 10)

            if let errorText {
                Text(errorText)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            Button {
                signup()
            } label: {
                HStack {
                    if isLoading { ProgressView() }
                    Text(isLoading ? "Creating…" : "Create Account")
                        .font(.system(size: 17, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLoading || username.isEmpty || email.isEmpty || password.isEmpty)
            .padding(.top, 8)

            Spacer()
        }
        .padding(.horizontal, 24)
        .navigationTitle("Sign Up")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func signup() {
        errorText = nil
        isLoading = true

        var user = User()
        user.username = username
        user.email = email
        user.password = password

        user.signup { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success:
                    session.refresh()
                    dismiss()
                case .failure(let error):
                    errorText = error.localizedDescription
                }
            }
        }
    }
}
