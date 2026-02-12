//
//  SessionStore.swift
//  BeReal
//
//  Created by Nishan Narain on 2/12/26.
//
import SwiftUI
import ParseSwift
import Combine

struct User: ParseUser{
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?
    
    var username: String?
    var email: String?
    var emailVerified: Bool?
    var password: String?
    var authData: [String: [String: String]?]?
    var sessionToken: String?

}

final class SessionStore: Combine.ObservableObject {
    @Combine.Published var currentUser: User? = User.current

    func refresh() {
        currentUser = User.current
    }

    func logout() {
        User.logout { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                    case .success:
                        self?.currentUser = nil
                    case .failure:
                        break
                }
            }
        }
    }
}
