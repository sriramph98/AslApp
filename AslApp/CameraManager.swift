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
        
        // Create an ordered array of points for visualization
        var newPoints: [CGPoint] = Array(repeating: .zero, count: 21)
        
        // Map Vision points to ordered array
        for (key, point) in recognizedPoints where point.confidence > 0.3 {
            let location = point.location
            let viewPoint = CGPoint(x: location.x * 640, y: (1 - location.y) * 480)
            
            // Map joint names to indices
            let index: Int
            switch key {
            case .wrist: index = 0
            case .thumbCMC: index = 1
            case .thumbMP: index = 2
            case .thumbIP: index = 3
            case .thumbTip: index = 4
            case .indexMCP: index = 5
            case .indexPIP: index = 6
            case .indexDIP: index = 7
            case .indexTip: index = 8
            case .middleMCP: index = 9
            case .middlePIP: index = 10
            case .middleDIP: index = 11
            case .middleTip: index = 12
            case .ringMCP: index = 13
            case .ringPIP: index = 14
            case .ringDIP: index = 15
            case .ringTip: index = 16
            case .littleMCP: index = 17
            case .littlePIP: index = 18
            case .littleDIP: index = 19
            case .littleTip: index = 20
            default: continue // Handle any future cases
            }
            
            newPoints[index] = viewPoint
        }
        
        DispatchQueue.main.async {
            self.displayPoints = newPoints
            self.detectedSign = newPoints.isEmpty ? "No hand detected" : "Hand detected"
        }
    }
} 