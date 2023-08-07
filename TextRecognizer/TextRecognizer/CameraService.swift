//
//  CameraService.swift
//  TextRecognizer
//
//  Created by Vlad Borisenko on 8/3/23.
//

import Foundation
import AVFoundation
import UIKit
import SwiftUI

class CameraService: NSObject, ObservableObject {
    private var captureDevice: AVCaptureDevice?
    @Published private var backCamera: AVCaptureDevice?
    @Published private var frontCamera: AVCaptureDevice?
    
    private var backInput: AVCaptureInput? = nil
    private let cameraQueue = DispatchQueue(label: "com.capturing.model")
    
    @Published var captureSession = AVCaptureSession()
    @Published var photoOutput = AVCapturePhotoOutput()
    @Published var capturedPhoto: UIImage? = UIImage()
    
    override init() {
        super.init()
        setupAndStartCaptureSession()
    }
    
    private func currentDevice() -> AVCaptureDevice? {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInDualCamera, .builtInDualWideCamera, .builtInWideAngleCamera],
            mediaType: .video,
            position: .back
        )
        
        guard let device = discoverySession.devices.first else { return nil }
        
        return device
    }
    
    func takePhoto(completion: () -> () ) {
         let photoSettings = AVCapturePhotoSettings()
         photoSettings.isHighResolutionPhotoEnabled = true
         //photoSettings.flashMode = topBar.isTorchOn ? .on : .off
         photoOutput.capturePhoto(with: photoSettings, delegate: self)

         let generator = UIImpactFeedbackGenerator(style: .medium)
         generator.impactOccurred()
         completion()
     }
    
    private func setupAndStartCaptureSession() {
        cameraQueue.async { [weak self] in
            self?.captureSession.beginConfiguration()
            
            if let canSetSessionPreset = self?.captureSession.canSetSessionPreset(.photo), canSetSessionPreset {
                self?.captureSession.sessionPreset = .photo
            }
            self?.captureSession.automaticallyConfiguresCaptureDeviceForWideColor = true
            
            self?.setupInputs()
            self?.setupOutput()
            
            self?.captureSession.commitConfiguration()
            self?.captureSession.startRunning()
        }
    }
    
    private func setupInputs() {
        checkPermissions()
        backCamera = currentDevice()

        guard let backCamera = backCamera else { return }
        
        do {
            backInput = try AVCaptureDeviceInput(device: backCamera)
            guard let backInput = backInput else { return }
            guard captureSession.canAddInput(backInput) else { return }
        } catch {
            fatalError("back camera didn't work")
        }
        
        captureDevice = backCamera
        do {
            defer { captureDevice?.unlockForConfiguration() }
            try captureDevice?.lockForConfiguration()
            captureDevice?.videoZoomFactor = 2.0
        } catch {
            print(error.localizedDescription)
        }
        guard let backInput = backInput else { fatalError("Back input not found") }
        captureSession.addInput(backInput)
    }
    
    private func setupOutput() {
        guard captureSession.canAddOutput(photoOutput) else { return }
        
        photoOutput.isHighResolutionCaptureEnabled = true
        photoOutput.maxPhotoQualityPrioritization = .balanced
        
        captureSession.addOutput(photoOutput)
    }
    
    
    private func checkPermissions() {
            let cameraAuthStatus =  AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            switch cameraAuthStatus {
            case .authorized:
                return
            case .denied:
                abort()
            case .notDetermined:
                AVCaptureDevice.requestAccess(
                    for: AVMediaType.video,
                    completionHandler: { authorized in
                    if(!authorized){
                        abort()
                    }
                })
            case .restricted:
                abort()
            @unknown default:
                fatalError()
            }
    }
    
    func cropImage(toRect: CGRect) {
        // Cropping is available trhough CGGraphics
        guard let image = capturedPhoto else { return }
        let cgImage: CGImage? = image.cgImage
        guard let croppedCGImage = cgImage?.cropping(to: toRect) else { return }
        capturedPhoto = UIImage(cgImage: croppedCGImage)
    }
}

extension CameraService: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil else {
            print("Fail to capture photo: \(String(describing: error))")
            return
        }
        guard let imageData = photo.fileDataRepresentation() else { return }
        guard let image = UIImage(data: imageData) else { return }
        
        DispatchQueue.main.async { [weak self] in
            self?.capturedPhoto = image
            let request = ImageUploader(uploadImage: image)
            request.uploadImage { (result) in
                switch result {
                case .success(let value):
                    print(value)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
    }
}
