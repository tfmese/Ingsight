//
//  CameraManager.swift
//  Ingsight
//
//  Created by Talha Fırat on 3.02.2026.
//

import Foundation
import AVFoundation
import Vision
import Combine

@MainActor
class CameraManager: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    private let videoOutput = AVCaptureVideoDataOutput()
    @Published var recognizedText: String = ""
    
    let captureSession = AVCaptureSession()
    private var isConfiguringSession = false
    private var isSessionConfigured = false
    private let queue = DispatchQueue(label: "camera.queue")
    private let queueSpecificKey = DispatchSpecificKey<Bool>()
    
    private enum CameraAuthorizationStatus {
        case authorized
        case notDetermined
        case denied
    }

    private func currentAuthorizationStatus() -> CameraAuthorizationStatus {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return .authorized
        case .notDetermined:
            return .notDetermined
        default:
            return .denied
        }
    }
    
    override init() {
        super.init()
        queue.setSpecific(key: queueSpecificKey, value: true)
    }
    
    private func configureSessionIfNeeded() async {
        if isSessionConfigured { return }
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            queue.async { [weak self] in
                guard let self = self else { continuation.resume(); return }
                self.isConfiguringSession = true
                self.setupSession()
                self.isConfiguringSession = false
                self.isSessionConfigured = true
                continuation.resume()
            }
        }
    }
    
    private func setupSession() {
        precondition(DispatchQueue.getSpecific(key: queueSpecificKey) != nil, "setupSession must be called on camera.queue")
        captureSession.beginConfiguration()
        
        captureSession.sessionPreset = .hd1920x1080
        
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
              captureSession.canAddInput(videoDeviceInput) else {
            captureSession.commitConfiguration()
            return
        }
        
        captureSession.addInput(videoDeviceInput)
        
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
            videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]
            if let connection = videoOutput.connection(with: AVMediaType.video) {
                let portraitAngle: CGFloat = 90
                if connection.isVideoRotationAngleSupported(portraitAngle) {
                    connection.videoRotationAngle = portraitAngle
                }
            }
            videoOutput.setSampleBufferDelegate(self, queue: queue)
            videoOutput.alwaysDiscardsLateVideoFrames = true
        }
        
        captureSession.commitConfiguration()
    }
    
    private var textRecognitionRequest = VNRecognizeTextRequest()
    private var isVisionConfigured = false
    
    private func setupVisionIfNeeded() {
        guard !isVisionConfigured else { return }
        
        textRecognitionRequest = VNRecognizeTextRequest { [weak self] (request, error) in
            guard let self = self else { return }
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            var detectedStrings = ""
            for observation in observations {
                if let topCandidate = observation.topCandidates(1).first {
                    detectedStrings += topCandidate.string + " "
                }
            }
            self.recognizedText = detectedStrings
        }
        
        // Dil ve doğruluk ayarları
        textRecognitionRequest.recognitionLevel = .accurate
        textRecognitionRequest.usesLanguageCorrection = true
        isVisionConfigured = true
    }
    
    func start() {
        Task { [weak self] in
            guard let self = self else { return }
            
            switch self.currentAuthorizationStatus() {
            case .authorized:
                await self.configureSessionIfNeeded()
                self.setupVisionIfNeeded()
            case .notDetermined:
                let granted = await withCheckedContinuation { (continuation: CheckedContinuation<Bool, Never>) in
                    AVCaptureDevice.requestAccess(for: .video) { granted in
                        continuation.resume(returning: granted)
                    }
                }
                guard granted else { return }
                await self.configureSessionIfNeeded()
                self.setupVisionIfNeeded()
            case .denied:
                // İstersen burada kullanıcıya ayarlardan izin vermesi için yönlendirme yapabilirsin.
                return
            }
            
            self.queue.async { [weak self] in
                guard let self = self else { return }
                guard !self.isConfiguringSession else { return }
                if !self.captureSession.isRunning {
                    self.captureSession.startRunning()
                }
            }
        }
    }
    
    func stop() {
        Task { [weak self] in
            guard let self = self else { return }
            self.queue.async { [weak self] in
                guard let self = self else { return }
                guard !self.isConfiguringSession else { return }
                if self.captureSession.isRunning {
                    self.captureSession.stopRunning()
                }
            }
        }
    }
    
    // AVCaptureVideoDataOutputSampleBufferDelegate
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
        do {
            try requestHandler.perform([textRecognitionRequest])
        } catch {
            print("Vision Error: \(error.localizedDescription)")
        }
    }
}

// MARK: - Concurrency bridging
// AVCaptureSession is not annotated as Sendable by Apple, but we access it from a dedicated serial queue.
// We declare it as @unchecked Sendable in our context to allow capturing it in @Sendable closures safely.
extension AVCaptureSession: @unchecked Sendable {}

