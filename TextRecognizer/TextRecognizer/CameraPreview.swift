//
//  CameraPreview.swift
//  TextRecognizer
//
//  Created by Vlad Borisenko on 8/3/23.
//

import SwiftUI
import AVKit

struct CameraPreviewHolder: UIViewRepresentable {
    typealias UIViewType = UIView
    
    @ObservedObject var cameraService: CameraService
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
    
    func makeUIView(context: UIViewRepresentableContext<CameraPreviewHolder>) -> UIView {
        var view = UIView(frame: UIScreen.main.bounds)
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: cameraService.captureSession)
        previewLayer.frame = view.frame
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        view.backgroundColor = .brown
        
        cameraService.captureSession.startRunning()
        return view
        
    }
}

