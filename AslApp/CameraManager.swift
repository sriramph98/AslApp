import Foundation
import AVFoundation
import Vision
import SwiftUI

class CameraManager: NSObject, ObservableObject {
    @Published var session = AVCaptureSession()
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private let handPoseRequest = VNDetectHumanHandPoseRequest()
    @Published var detectedSign: String = "No sign detected"
    @Published var displayPoints: [CGPoint] = []
    
    // Dictionary to store hand landmark points
    private var handLandmarks: [VNHumanHandPoseObservation.JointName: CGPoint] = [:]
    private var gestureHistory: [CGPoint] = []
    private let maxGestureHistoryLength = 30
    
    private let aslConfigurations: [String: ([VNHumanHandPoseObservation.JointName: CGPoint]) -> Bool] = [
        "A": { landmarks in
            // Define the conditions for the letter "A"
            guard let thumbTip = landmarks[.thumbTip],
                  let indexTip = landmarks[.indexTip],
                  let middleTip = landmarks[.middleTip],
                  let ringTip = landmarks[.ringTip],
                  let littleTip = landmarks[.littleTip] else { return false }
            
            // Check if fingers are closed (close to palm) except thumb
            let fingersAreClosed = indexTip.y < 0.3 && middleTip.y < 0.3 && ringTip.y < 0.3 && littleTip.y < 0.3
            let thumbIsUp = thumbTip.y > 0.5
            
            return fingersAreClosed && thumbIsUp
        },
        "B": { landmarks in
            // Define the conditions for the letter "B"
            guard let indexTip = landmarks[.indexTip],
                  let middleTip = landmarks[.middleTip],
                  let ringTip = landmarks[.ringTip],
                  let littleTip = landmarks[.littleTip] else { return false }
            
            // Check if all fingers are extended upward
            let fingersAreUp = indexTip.y > 0.7 && middleTip.y > 0.7 && ringTip.y > 0.7 && littleTip.y > 0.7
            
            return fingersAreUp
        }
        // Add more configurations for other letters
    ]
    
    override init() {
        super.init()
        handPoseRequest.maximumHandCount = 1
    }
    
    func checkPermissionsAndSetup() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        self?.setupCamera()
                    }
                }
            }
        default:
            break
        }
    }
    
    private func setupCamera() {
        session.beginConfiguration()
        
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                       for: .video,
                                                       position: .front) else {
            print("Failed to get camera")
            return
        }
        
        do {
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            guard session.canAddInput(videoDeviceInput) else { return }
            session.addInput(videoDeviceInput)
            
            videoDataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as String): Int(kCVPixelFormatType_32BGRA)]
            videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            
            guard session.canAddOutput(videoDataOutput) else { return }
            session.addOutput(videoDataOutput)
            
            if let connection = videoDataOutput.connection(with: .video) {
                connection.automaticallyAdjustsVideoMirroring = false
                connection.isVideoMirrored = true
            }
            
            session.commitConfiguration()
            
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.session.startRunning()
            }
            
        } catch {
            print("Error setting up camera: \(error)")
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        do {
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
            try handler.perform([handPoseRequest])
            
            guard let observation = handPoseRequest.results?.first else { return }
            try processHandPose(observation)
            
        } catch {
            print("Failed to perform hand pose detection: \(error)")
        }
    }
    
    private func processHandPose(_ observation: VNHumanHandPoseObservation) throws {
        let recognizedPoints = try observation.recognizedPoints(.all)
        
        // Create a dictionary of recognized points
        var landmarks: [VNHumanHandPoseObservation.JointName: CGPoint] = [:]
        
        for (key, point) in recognizedPoints where point.confidence > 0.3 {
            landmarks[key] = CGPoint(x: point.location.x, y: point.location.y)
        }
        
        // Check each ASL configuration
        for (letter, configuration) in aslConfigurations {
            if configuration(landmarks) {
                DispatchQueue.main.async {
                    self.detectedSign = "Detected: \(letter)"
                }
                return
            }
        }
        
        DispatchQueue.main.async {
            self.detectedSign = "No sign detected"
        }
    }
} 