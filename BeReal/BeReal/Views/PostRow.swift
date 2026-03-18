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
        }
        .padding(.vertical, 8)
    }
}
