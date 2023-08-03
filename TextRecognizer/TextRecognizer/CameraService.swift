//
//  CameraService.swift
//  TextRecognizer
//
//  Created by Vlad Borisenko on 8/3/23.
//

import Foundation
import AVFoundation
import UIKit

protocol CameraServiceDelegate: AnyObject {
    func setPhoto(image: UIImage)
}

class CameraService: NSObject {
    private var captureDevice: AVCaptureDevice?
    private var backCamera: AVCaptureDevice?
    private var frontCamera: AVCaptureDevice?
    
    private var backInput: AVCaptureInput!
    private var frontInput: AVCaptureInput!
    private let cameraQueue = DispatchQueue(label: "com.capturing.model")
    
    private var backCameraOn = true
    
    weak var delegate: CameraServiceDelegate?
    
    let captureSession = AVCaptureSession()
    let photoOutput = AVCapturePhotoOutput()
    
    override init() {
        super.init()
        setupAndStartCaptureSession()
    }
    
    private func currentDevice() -> AVCaptureDevice? {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInDualCamera],
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
        backCamera = currentDevice()

        guard let backCamera = backCamera else { return }
        
        do {
            backInput = try AVCaptureDeviceInput(device: backCamera)
            guard captureSession.canAddInput(backInput) else { return }
        } catch {
            fatalError("back camera didn't work")
        }
        
        captureDevice = backCamera
        
        captureSession.addInput(backInput)
    }
    
    private func setupOutput() {
        guard captureSession.canAddOutput(photoOutput) else { return }
        
        photoOutput.maxPhotoDimensions = CMVideoDimensions()
        photoOutput.maxPhotoQualityPrioritization = .balanced
        
        captureSession.addOutput(photoOutput)
    }
}

extension CameraService: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil else {
            print("Fail to capture photo: \(String(describing: error))")
            return
        }
        guard let imageData = photo.fileDataRepresentation() else {
            return
        }
        guard let image = UIImage(data: imageData) else {
            return
        }
        
        DispatchQueue.main.async {
            self.delegate?.setPhoto(image: image)
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
    }
}
