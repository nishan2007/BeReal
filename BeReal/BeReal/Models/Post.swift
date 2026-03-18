//
//  Post.swift
//  BeReal
//
//  Created by Nishan Narain on 2/12/26.
//
import SwiftUI
import ParseSwift

struct Post: ParseObject {
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?
    
    var imageFile: ParseFile?
    var caption: String?
    var user: User?
    
    
    // Pt2 location data
    var latitude: Double?
    var longitude: Double?
    var locationName: String?
    
    
    static var className: String {"Post"}
}
