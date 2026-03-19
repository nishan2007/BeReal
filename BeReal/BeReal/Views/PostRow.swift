//
//  PostRow.swift
//  BeReal
//
//  Created by Nishan Narain on 3/18/26.
//

import SwiftUI
import ParseSwift

struct PostRow: View {
    let post: Post

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(post.user?.username ?? "Unknown User")
                .font(.headline)

            if let url = post.imageFile?.url {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 250)
                .frame(maxWidth: .infinity)
                .clipped()
                .cornerRadius(12)
            }

            if let caption = post.caption, !caption.isEmpty {
                Text(caption)
                    .font(.body)
            }
            HStack(spacing: 6) {
                Label(timeAgoString(from: post.createdAt), systemImage: "clock")

                if let locationName = post.locationName, !locationName.isEmpty {
                    Label(locationName, systemImage: "location")
                }
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}
private func timeAgoString(from date: Date?) -> String {
    guard let date = date else { return "Unknown time" }

    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .abbreviated
    return formatter.localizedString(for: date, relativeTo: Date())
}
