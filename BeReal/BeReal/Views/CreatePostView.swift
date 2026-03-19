//
//  CreatePostView.swift
//  BeReal
//
//  Created by Nishan Narain on 3/18/26.
//

import SwiftUI
import ParseSwift
import CoreLocation

struct CreatePostView: View {
    @State private var selectedImage: UIImage?
    @State private var caption = ""
    @State private var showPicker = false
    @State private var pickerSourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var isUploading = false
    @State private var statusText: String?
    @State private var didUploadSucceed = false
    @State private var showingSourceDialog = false
    @StateObject private var locationManager = PostLocationManager()
    @State private var photoLocation: CLLocation?
    @State private var photoLocationName: String?

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

                // Location
                HStack(spacing: 8) {
                    Image(systemName: "location")
                        .foregroundColor(.secondary)

                    if let photoLocationName, !photoLocationName.isEmpty {
                        Text(photoLocationName)
                            .foregroundColor(.secondary)
                    } else if photoLocation != nil {
                        Text("Photo location found")
                            .foregroundColor(.secondary)
                    } else if let locationName = locationManager.locationName, !locationName.isEmpty {
                        Text(locationName)
                            .foregroundColor(.secondary)
                    } else if locationManager.currentLocation != nil {
                        Text("Current location found")
                            .foregroundColor(.secondary)
                    } else if let locationError = locationManager.locationError {
                        Text(locationError)
                            .foregroundColor(.red)
                    } else {
                        Text("Getting location...")
                            .foregroundColor(.secondary)
                    }

                    Spacer()
                }

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
                .disabled(selectedImage == nil || isUploading || (photoLocation == nil && locationManager.currentLocation == nil))

                Spacer()
            }
            .padding()
            .navigationTitle("New Post")
            .sheet(isPresented: $showPicker) {
                PhotoPicker(
                    image: $selectedImage,
                    photoLocation: $photoLocation,
                    sourceType: pickerSourceType
                )
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
                locationManager.requestLocationAccessAndFetch()
            }
            .onChange(of: photoLocation) { _, newValue in
                if let newValue {
                    resolvePhotoLocationName(from: newValue)
                } else {
                    photoLocationName = nil
                }
            }
        }
    }

    private func showSourceOptions() {
        statusText = nil
        didUploadSucceed = false
        photoLocation = nil
        photoLocationName = nil
        locationManager.requestLocation()
        showingSourceDialog = true
    }

    private func resolvePhotoLocationName(from location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, _ in
            DispatchQueue.main.async {
                if let placemark = placemarks?.first {
                    let city = placemark.locality
                    let state = placemark.administrativeArea
                    let country = placemark.country

                    if let city, let state {
                        photoLocationName = "\(city), \(state)"
                    } else if let city, let country {
                        photoLocationName = "\(city), \(country)"
                    } else if let name = placemark.name {
                        photoLocationName = name
                    } else {
                        photoLocationName = nil
                    }
                } else {
                    photoLocationName = nil
                }
            }
        }
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

        let finalLocation = photoLocation ?? locationManager.currentLocation

        isUploading = true
        didUploadSucceed = false
        statusText = nil

        let file = ParseFile(name: "photo.jpg", data: data)

        var post = Post()
        post.imageFile = file
        post.caption = caption.trimmingCharacters(in: .whitespacesAndNewlines)
        post.user = currentUser
        if let finalLocation {
            post.latitude = finalLocation.coordinate.latitude
            post.longitude = finalLocation.coordinate.longitude
        }

        post.locationName = photoLocationName ?? locationManager.locationName

        post.save { result in
            DispatchQueue.main.async {
                isUploading = false

                switch result {
                case .success:
                    didUploadSucceed = true
                    statusText = "✅ Uploaded!"
                    selectedImage = nil
                    caption = ""
                    photoLocation = nil
                    photoLocationName = nil
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
