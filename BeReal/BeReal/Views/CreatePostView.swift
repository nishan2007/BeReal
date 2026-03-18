//
//  CreatePostView.swift
//  BeReal
//
//  Created by Nishan Narain on 3/18/26.
//

import SwiftUI
import ParseSwift

struct CreatePostView: View {
    @State private var selectedImage: UIImage?
    @State private var caption = ""
    @State private var showPicker = false
    @State private var isUploading = false
    @State private var statusText: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {

                // Image preview box
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [6]))
                        .frame(height: 250)

                    if let selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 250)
                            .clipped()
                            .cornerRadius(16)
                    } else {
                        Text("Tap to select image")
                            .foregroundColor(.gray)
                    }
                }
                .onTapGesture {
                    showPicker = true
                }

                // Caption
                TextField("Caption (optional)", text: $caption)
                    .textFieldStyle(.roundedBorder)

                // Status
                if let statusText {
                    Text(statusText)
                        .foregroundColor(.red)
                }

                // Upload button
                Button {
                    uploadPost()
                } label: {
                    if isUploading {
                        ProgressView()
                    } else {
                        Text("Upload Post")
                            .font(.headline)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(selectedImage == nil)

                Spacer()
            }
            .padding()
            .navigationTitle("New Post")
            .sheet(isPresented: $showPicker) {
                PhotoPicker(image: $selectedImage)
            }
        }
    }

    private func uploadPost() {
        guard let image = selectedImage,
              let data = image.jpegData(compressionQuality: 0.8) else {
            statusText = "Invalid image"
            return
        }

        isUploading = true
        statusText = nil

        let file = ParseFile(name: "photo.jpg", data: data)

        var post = Post()
        post.imageFile = file
        post.caption = caption
        post.user = User.current

        post.save { result in
            DispatchQueue.main.async {
                isUploading = false

                switch result {
                case .success:
                    statusText = "✅ Uploaded!"
                    selectedImage = nil
                    caption = ""
                case .failure(let error):
                    statusText = error.localizedDescription
                }
            }
        }
    }
}
