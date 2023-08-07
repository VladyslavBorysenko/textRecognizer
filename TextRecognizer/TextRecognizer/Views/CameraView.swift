//
//  ContentView.swift
//  TextRecognizer
//
//  Created by Vlad Borisenko on 8/3/23.
//

import SwiftUI

enum Constants {
    static let padding: CGFloat = 40
    static let imageSize: CGFloat = 27
    static let bigCircleSize: CGFloat = 55
    static let smallCircleSize: CGFloat = 45
    static let hudBackgroundOpacity: Double = 0.7
    static let cirlceLineWidth: CGFloat = 3
    static let cornerRadius: CGFloat = 10
    static let bannerTopPadding: CGFloat = 50
}

struct CameraView: View {
    @ObservedObject var cameraService: CameraService = CameraService()
    
    @State var isPhotoTaken: Bool = false
    @State var cropViewState = CGSize.zero
    
    @State var cropImageWidth: CGFloat = UIScreen.main.bounds.size.width / 1.5
    @State var cropImageHeight: CGFloat = UIScreen.main.bounds.size.height / 7
    
    @State var cropImageXPosition: CGFloat = 0
    @State var cropImageYPosition: CGFloat = 0
    
    var body: some View {
        if isPhotoTaken {
            ZStack {
                Image(uiImage: cameraService.capturedPhoto ?? UIImage())
                    .resizable(resizingMode: .stretch)
                    .ignoresSafeArea()
                    .scaledToFit()
                TextScannerHud(croppableImageRect: CGRect(x: cropViewState.width, y: cropViewState.height, width: cropImageWidth, height: cropImageHeight), isPhotoTaken: $isPhotoTaken)
                    .environmentObject(cameraService)
                CropView(
                    width: $cropImageWidth,
                    height: $cropImageHeight,
                    xPosition: $cropImageXPosition,
                    yPosition: $cropImageYPosition
                )
                    .offset(cropViewState)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                cropViewState = value.translation
                            }
                    )
            }
        } else {
            ZStack {
                CameraPreviewHolder(cameraService: cameraService)
                    .ignoresSafeArea()
                PhotoHud(isPhotoTaken: $isPhotoTaken)
                    .environmentObject(cameraService)
            }
            
        }
    }
}

struct InfoBanner: View {
    let title: String
    var body: some View {
        Text(title)
            .foregroundColor(.white)
            .padding(.horizontal, Constants.padding)
            .padding(.vertical, 10)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
