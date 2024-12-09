import AVFoundation

class HandTrackingDelegate: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    static let shared = HandTrackingDelegate()
    private let handTracker = HandTracker.shared
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        handTracker.processFrame(pixelBuffer)
    }
} 