//
//  FeedView.swift
//  BeReal
//
//  Created by Nishan Narain on 3/18/26.
//
import SwiftUI
import ParseSwift
import UIKit

struct FeedView: View {
    @State private var posts: [Post] = []
    @State private var isLoading = false
    @State private var errorText: String?
    @State private var currentUserLatestPost: Post?

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading feed...")
                } else if posts.isEmpty {
                    Text("No recent posts in the last 24 hours")
                        .foregroundStyle(.secondary)
                } else {
                    List(posts, id: \.objectId) { post in
                        ZStack {
                            if shouldHidePost(post) {
                                PostRow(post: post)
                                    .blur(radius: 20)
                            } else {
                                NavigationLink {
                                    PostDetailView(post: post)
                                } label: {
                                    PostRow(post: post)
                                }
                                .buttonStyle(.plain)
                            }

                            if shouldHidePost(post) {
                                VStack(spacing: 8) {
                                    Image(systemName: "lock.fill")
                                        .font(.title2)
                                    Text("Post to unlock today's feed")
                                        .font(.headline)
                                    Text("You can view friends' posts after you upload your own.")
                                        .font(.caption)
                                        .multilineTextAlignment(.center)
                                }
                                .padding()
                                .background(.ultraThinMaterial)
                                .cornerRadius(12)
                                .padding()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Feed")
            .onAppear {
                fetchPosts()
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("PostUploaded"))) { _ in
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
                        let twentyFourHoursAgo = Date().addingTimeInterval(-(24 * 60 * 60))
                        let recentPosts = fetchedPosts.filter { post in
                            guard let createdAt = post.createdAt else { return false }
                            return createdAt >= twentyFourHoursAgo
                        }

                        posts = Array(recentPosts.prefix(10))

                        currentUserLatestPost = fetchedPosts.first(where: { belongsToCurrentUser($0) })
                    case .failure(let error):
                        errorText = error.localizedDescription
                        print("Error fetching posts: \(error)")
                    }
                }
            }
    }
    
    private func shouldHidePost(_ post: Post) -> Bool {
        guard User.current != nil else { return true }

        if belongsToCurrentUser(post) {
            return false
        }

        guard let latestUserPostDate = currentUserLatestPost?.createdAt else {
            return true
        }

        let now = Date()
        let userPostedWithinLast24Hours = latestUserPostDate >= now.addingTimeInterval(-(24 * 60 * 60))

        // Since `posts` already only contains the 10 most recent posts from the last 24 hours,
        // once the current user has posted within the last 24 hours, the feed should unlock.
        return !userPostedWithinLast24Hours
    }
    
    private func belongsToCurrentUser(_ post: Post) -> Bool {
        guard let currentUser = User.current else { return false }

        if post.user?.objectId == currentUser.objectId {
            return true
        }

        if let postUsername = post.user?.username,
           let currentUsername = currentUser.username,
           postUsername == currentUsername {
            return true
        }

        return false
    }

}
