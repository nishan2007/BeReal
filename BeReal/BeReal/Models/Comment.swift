//
//  Comment.swift
//  BeReal
//
//  Created by Nishan Narain on 3/23/26.
//
import SwiftUI
import ParseSwift

struct Comment: ParseObject {
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?
    var postId: String?

    var text: String?
    var user: User?
    var post: Post?

    static var className: String { "Comment" }
}
