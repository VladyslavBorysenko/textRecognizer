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
                    completionHandler:
                                                { authorized in
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
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
    }
}
