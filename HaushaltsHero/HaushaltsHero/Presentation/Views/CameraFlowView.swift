//
//  CameraFlowView.swift
//  HaushaltsHero
//
//  Created by AI Agent on 2025-11-18.
//

import SwiftUI
import UIKit

/// View for capturing before/after photos
struct CameraFlowView: View {

    // MARK: - Properties

    @ObservedObject var viewModel: ChallengeViewModel
    @State private var showingCamera = false
    @State private var isCapturingBefore = true

    // MARK: - Body

    var body: some View {
        ZStack {
            // Background
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text(viewModel.selectedCategory?.description ?? "Challenge")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(isCapturingBefore ? "Schritt 1: Vorher-Foto" : "Schritt 2: Nachher-Foto")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)

                // Progress Indicator
                HStack(spacing: 8) {
                    ProgressDot(isActive: true, isCompleted: viewModel.beforeImage != nil)
                    ProgressLine(isCompleted: viewModel.beforeImage != nil)
                    ProgressDot(isActive: !isCapturingBefore, isCompleted: viewModel.afterImage != nil)
                }
                .padding(.horizontal, 60)

                Spacer()

                // Photo Preview or Placeholder
                if isCapturingBefore {
                    if let beforeImage = viewModel.beforeImage {
                        PhotoPreview(image: beforeImage, title: "Vorher-Foto")
                    } else {
                        PhotoPlaceholder(icon: "camera.circle", title: "Vorher-Foto aufnehmen")
                    }
                } else {
                    if let afterImage = viewModel.afterImage {
                        PhotoPreview(image: afterImage, title: "Nachher-Foto")
                    } else {
                        PhotoPlaceholder(icon: "camera.circle.fill", title: "Nachher-Foto aufnehmen")
                    }
                }

                Spacer()

                // Action Buttons
                VStack(spacing: 12) {
                    // Main action button
                    if isCapturingBefore && viewModel.beforeImage == nil {
                        PrimaryButton(title: "📸 Vorher-Foto aufnehmen", action: {
                            showingCamera = true
                        })
                    } else if isCapturingBefore && viewModel.beforeImage != nil {
                        PrimaryButton(title: "Weiter zum Nachher-Foto →", action: {
                            isCapturingBefore = false
                        })
                    } else if !isCapturingBefore && viewModel.afterImage == nil {
                        PrimaryButton(title: "📸 Nachher-Foto aufnehmen", action: {
                            showingCamera = true
                        })
                    }

                    // Secondary actions
                    if viewModel.beforeImage != nil && isCapturingBefore {
                        SecondaryButton(title: "Foto neu aufnehmen", action: {
                            viewModel.beforeImage = nil
                            showingCamera = true
                        })
                    } else if viewModel.afterImage != nil && !isCapturingBefore {
                        SecondaryButton(title: "Foto neu aufnehmen", action: {
                            viewModel.afterImage = nil
                            showingCamera = true
                        })
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $showingCamera) {
            ImagePicker(isPresented: $showingCamera) { image in
                if isCapturingBefore {
                    viewModel.captureBeforePhoto(image)
                } else {
                    viewModel.captureAfterPhoto(image)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Progress Indicator Components

struct ProgressDot: View {
    let isActive: Bool
    let isCompleted: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(isCompleted ? Color.green : (isActive ? Color.blue : Color.gray.opacity(0.3)))
                .frame(width: 20, height: 20)

            if isCompleted {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }
        }
    }
}

struct ProgressLine: View {
    let isCompleted: Bool

    var body: some View {
        Rectangle()
            .fill(isCompleted ? Color.green : Color.gray.opacity(0.3))
            .frame(height: 2)
    }
}

// MARK: - Photo Components

struct PhotoPlaceholder: View {
    let icon: String
    let title: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 80))
                .foregroundColor(.gray.opacity(0.5))

            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 300)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 10)
        )
        .padding(.horizontal)
    }
}

struct PhotoPreview: View {
    let image: UIImage
    let title: String

    var body: some View {
        VStack(spacing: 12) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity)
                .frame(height: 300)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: Color.black.opacity(0.1), radius: 10)

            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Button Components

struct PrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue)
                )
        }
    }
}

struct SecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.blue)
        }
    }
}

// MARK: - Image Picker

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let onImagePicked: (UIImage) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImagePicked(image)
            }
            parent.isPresented = false
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }
    }
}

// MARK: - Preview

#Preview {
    CameraFlowView(
        viewModel: ChallengeViewModel(repository: LocalRepository())
    )
}
