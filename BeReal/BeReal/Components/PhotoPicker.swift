//
//  PhotoPicker.swift
//  BeReal
//
//  Created by Nishan Narain on 3/18/26.
//
import SwiftUI
import UIKit
import Photos
import PhotosUI
import CoreLocation

struct PhotoPicker: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss

    @Binding var image: UIImage?
    @Binding var photoLocation: CLLocation?
    var sourceType: UIImagePickerController.SourceType

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> PickerHostController {
        let controller = PickerHostController()
        controller.coordinator = context.coordinator
        controller.sourceType = sourceType
        return controller
    }

    func updateUIViewController(_ uiViewController: PickerHostController, context: Context) {
        uiViewController.coordinator = context.coordinator
        uiViewController.sourceType = sourceType
    }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate, PHPickerViewControllerDelegate {
        let parent: PhotoPicker

        init(_ parent: PhotoPicker) {
            self.parent = parent
        }

        private func resolvePhotoLocation(from assetIdentifier: String) {
            let fetchLocation = {
                let assets = PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier], options: nil)
                let asset = assets.firstObject

                DispatchQueue.main.async {
                    self.parent.photoLocation = asset?.location
                }
            }

            let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)

            switch status {
            case .authorized, .limited:
                fetchLocation()
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                    if newStatus == .authorized || newStatus == .limited {
                        fetchLocation()
                    } else {
                        DispatchQueue.main.async {
                            self.parent.photoLocation = nil
                        }
                    }
                }
            default:
                DispatchQueue.main.async {
                    self.parent.photoLocation = nil
                }
            }
        }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let selectedImage = info[.originalImage] as? UIImage {
                parent.image = selectedImage
            }

            if let asset = info[.phAsset] as? PHAsset {
                parent.photoLocation = asset.location
            } else {
                parent.photoLocation = nil
            }

            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            guard let result = results.first else {
                DispatchQueue.main.async {
                    self.parent.photoLocation = nil
                    self.parent.dismiss()
                }
                return
            }

            if let assetIdentifier = result.assetIdentifier {
                resolvePhotoLocation(from: assetIdentifier)
            } else {
                DispatchQueue.main.async {
                    self.parent.photoLocation = nil
                }
            }

            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { object, _ in
                    DispatchQueue.main.async {
                        self.parent.image = object as? UIImage
                        self.parent.dismiss()
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.parent.dismiss()
                }
            }
        }
    }
}

final class PickerHostController: UIViewController {
    var coordinator: PhotoPicker.Coordinator?
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    private var hasPresented = false

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard !hasPresented else { return }
        hasPresented = true

        if sourceType == .camera {
            let picker = UIImagePickerController()
            picker.delegate = coordinator
            picker.sourceType = .camera

            if UIImagePickerController.isCameraDeviceAvailable(.rear) {
                picker.cameraDevice = .rear
            }

            present(picker, animated: true)
        } else {
            var configuration = PHPickerConfiguration(photoLibrary: .shared())
            configuration.filter = .images
            configuration.selectionLimit = 1
            configuration.preferredAssetRepresentationMode = .current

            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = coordinator
            present(picker, animated: true)
        }
    }
}
