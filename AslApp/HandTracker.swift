import Vision
import CoreImage

class HandTracker: ObservableObject {
    static let shared = HandTracker()
    
    @Published var handLandmarks: [VNHumanHandPoseObservation.JointName: CGPoint] = [:]
    
    private let handPoseRequest = VNDetectHumanHandPoseRequest()
    
    func processFrame(_ pixelBuffer: CVPixelBuffer) {
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        
        try? handler.perform([handPoseRequest])
        
        guard let observation = handPoseRequest.results?.first else {
            DispatchQueue.main.async {
                self.handLandmarks.removeAll()
            }
            return
        }
        
        // Get all landmarks
        var newLandmarks: [VNHumanHandPoseObservation.JointName: CGPoint] = [:]
        try? observation.recognizedPoints(.all).forEach { (joint, point) in
            if point.confidence > 0.3 {
                newLandmarks[joint] = CGPoint(x: point.location.x, y: point.location.y)
            }
        }
        
        // Update landmarks on main thread
        DispatchQueue.main.async {
            self.handLandmarks = newLandmarks
        }
    }
} 