//
//  PostDetailView.swift
//  BeReal
//
//  Created by Nishan Narain on 3/23/26.
//

import SwiftUI
import ParseSwift

struct PostDetailView: View {
    let post: Post

    @State private var comments: [Comment] = []
    @State private var commentText = ""
    @State private var isLoadingComments = false
    @State private var isSendingComment = false
    @State private var errorText: String?

    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    PostRow(post: post)

                    Divider()

                    Text("Comments")
                        .font(.headline)

                    if isLoadingComments {
                        ProgressView("Loading comments...")
                    } else if comments.isEmpty {
                        Text("No comments yet")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(Array(comments.enumerated()), id: \.offset) { _, comment in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(comment.user?.username ?? "Unknown User")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)

                                Text(comment.text ?? "")
                                    .font(.body)

                                if let createdAt = comment.createdAt {
                                    Text(timeAgoString(from: createdAt))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.vertical, 6)

                            Divider()
                        }
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                TextField("Add a comment...", text: $commentText)
                    .textFieldStyle(.roundedBorder)

                Button {
                    sendComment()
                } label: {
                    if isSendingComment {
                        ProgressView()
                    } else {
                        Text("Send")
                    }
                }
                .disabled(commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSendingComment)
            }
            .padding()
        }
        .navigationTitle("Post")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            fetchComments()
        }
        .alert("Error", isPresented: .constant(errorText != nil)) {
            Button("OK") {
                errorText = nil
            }
        } message: {
            Text(errorText ?? "")
        }
    }

    private func fetchComments() {
        isLoadingComments = true
        errorText = nil

        Comment.query()
            .include("user")
            .order([.ascending("createdAt")])
            .find { result in
                DispatchQueue.main.async {
                    isLoadingComments = false

                    switch result {
                    case .success(let fetchedComments):
                        guard let currentPostObjectId = post.objectId else {
                            comments = []
                            return
                        }

                        comments = fetchedComments.filter { comment in
                            comment.postId == currentPostObjectId
                        }
                    case .failure(let error):
                        errorText = error.localizedDescription
                    }
                }
            }
    }

    private func sendComment() {
        guard let currentUser = User.current else {
            errorText = "You must be logged in to comment."
            return
        }

        let trimmedText = commentText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedText.isEmpty else { return }

        isSendingComment = true
        errorText = nil

        var comment = Comment()
        comment.text = trimmedText
        comment.user = currentUser
        comment.post = post
        comment.postId = post.objectId

        comment.save { result in
            DispatchQueue.main.async {
                isSendingComment = false

                switch result {
                case .success:
                    commentText = ""

                    var displayedComment = comment
                    displayedComment.user = currentUser
                    displayedComment.post = post
                    displayedComment.postId = post.objectId
                    comments.append(displayedComment)

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        fetchComments()
                    }
                case .failure(let error):
                    errorText = error.localizedDescription
                }
            }
        }
    }

    private func timeAgoString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
