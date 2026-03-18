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
    @State private var pickerSourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var isUploading = false
    @State private var statusText: String?
    @State private var didUploadSucceed = false
    @State private var showingSourceDialog = false

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
                    showSourceOptions()
                }

                // Caption
                TextField("Caption (optional)", text: $caption)
                    .textFieldStyle(.roundedBorder)

                // Status
                if let statusText {
                    Text(statusText)
                        .foregroundColor(didUploadSucceed ? .green : .red)
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
                .disabled(selectedImage == nil || isUploading)

                Spacer()
            }
            .padding()
            .navigationTitle("New Post")
            .sheet(isPresented: $showPicker) {
                PhotoPicker(image: $selectedImage, sourceType: pickerSourceType)
            }
            .confirmationDialog("Select Photo Source", isPresented: $showingSourceDialog, titleVisibility: .visible) {
                Button("Take Photo") {
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        pickerSourceType = .camera
                        showPicker = true
                    } else {
                        statusText = "Camera not available"
                        didUploadSucceed = false
                    }
                }
                Button("Choose from Library") {
                    pickerSourceType = .photoLibrary
                    showPicker = true
                }
                Button("Cancel", role: .cancel) {}
            }
            .onAppear {
                if selectedImage == nil && caption.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    statusText = nil
                    didUploadSucceed = false
                }
            }
        }
    }

    private func showSourceOptions() {
        statusText = nil
        didUploadSucceed = false
        showingSourceDialog = true
    }

    private func uploadPost() {
        guard let currentUser = User.current else {
            didUploadSucceed = false
            statusText = "You must be logged in to post."
            return
        }

        guard let image = selectedImage,
              let data = image.jpegData(compressionQuality: 0.8) else {
            didUploadSucceed = false
            statusText = "Invalid image"
            return
        }

        isUploading = true
        didUploadSucceed = false
        statusText = nil

        let file = ParseFile(name: "photo.jpg", data: data)

        var post = Post()
        post.imageFile = file
        post.caption = caption.trimmingCharacters(in: .whitespacesAndNewlines)
        post.user = currentUser

        post.save { result in
            DispatchQueue.main.async {
                isUploading = false

                switch result {
                case .success:
                    didUploadSucceed = true
                    statusText = "✅ Uploaded!"
                    selectedImage = nil
                    caption = ""
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        if statusText == "✅ Uploaded!" {
                            statusText = nil
                            didUploadSucceed = false
                        }
                    }
                case .failure(let error):
                    didUploadSucceed = false
                    statusText = error.localizedDescription
                }
            }
        }
    }
}
