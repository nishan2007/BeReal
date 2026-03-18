//
//  FeedView.swift
//  BeReal
//
//  Created by Nishan Narain on 3/18/26.
//
import SwiftUI
import ParseSwift

struct FeedView: View {
    @State private var posts: [Post] = []
    @State private var isLoading = false
    @State private var errorText: String?

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading feed...")
                } else if posts.isEmpty {
                    Text("No posts yet")
                        .foregroundStyle(.secondary)
                } else {
                    List(posts, id: \.objectId) { post in
                        PostRow(post: post)
                    }
                }
            }
            .navigationTitle("Feed")
            .onAppear {
                fetchPosts()
            }
        }
    }

    private func fetchPosts() {
        isLoading = true
        errorText = nil

        Post.query()
            .include("user")
            .order([.descending("createdAt")])
            .find { result in
                DispatchQueue.main.async {
                    isLoading = false

                    switch result {
                    case .success(let fetchedPosts):
                        posts = fetchedPosts
                    case .failure(let error):
                        errorText = error.localizedDescription
                        print("Error fetching posts: \(error)")
                    }
                }
            }
    }
}
