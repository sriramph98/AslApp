import Vision
import CoreML

class ASLRecognizer: ObservableObject {
    static let shared = ASLRecognizer()
    
    @Published var currentSign: String = ""
    private var lastRecognitionTime = Date()
    private var dismissTimer: Timer?
    private let minimumTimeBetweenRecognitions: TimeInterval = 0.5
    private let displayDuration: TimeInterval = 2.0
    
    private let gesturePatterns: [String: (([VNHumanHandPoseObservation.JointName: CGPoint]) -> Bool)] = [
        "A": { landmarks in
            guard let thumbTip = landmarks[.thumbTip],
                  let indexTip = landmarks[.indexTip],
                  let middleTip = landmarks[.middleTip],
                  let wrist = landmarks[.wrist] else { return false }
            
            return thumbTip.y > indexTip.y && // Thumb beside fist
                   abs(indexTip.y - middleTip.y) < 0.1 && // Fingers together
                   indexTip.y < wrist.y // Closed fist
        },
        
        "B": { landmarks in
            guard let indexTip = landmarks[.indexTip],
                  let middleTip = landmarks[.middleTip],
                  let ringTip = landmarks[.ringTip],
                  let littleTip = landmarks[.littleTip],
                  let wrist = landmarks[.wrist] else { return false }
            
            return indexTip.y > wrist.y + 0.2 && // All fingers extended
                   abs(indexTip.y - middleTip.y) < 0.1 && // Fingers aligned
                   abs(middleTip.y - ringTip.y) < 0.1 &&
                   abs(ringTip.y - littleTip.y) < 0.1
        },
        
        "C": { landmarks in
            guard let thumbTip = landmarks[.thumbTip],
                  let indexTip = landmarks[.indexTip],
                  let middleTip = landmarks[.middleTip],
                  let wrist = landmarks[.wrist] else { return false }
            
            let curve = abs(thumbTip.x - indexTip.x) // C shape curve
            return curve > 0.1 && curve < 0.3 &&
                   abs(indexTip.y - middleTip.y) < 0.1
        },
        
        "D": { landmarks in
            guard let indexTip = landmarks[.indexTip],
                  let middleTip = landmarks[.middleTip],
                  let indexDIP = landmarks[.indexDIP],
                  let wrist = landmarks[.wrist] else { return false }
            
            return indexTip.y > wrist.y && // Index finger up
                   middleTip.y < wrist.y && // Other fingers down
                   indexTip.y > indexDIP.y // Index straight
        },
        
        // Add more letters here with similar pattern recognition
        // Each pattern should check the relative positions of landmarks
        // to identify specific hand shapes
    ]
    
    func recognizeGesture(from landmarks: [VNHumanHandPoseObservation.JointName: CGPoint]) {
        let now = Date()
        guard now.timeIntervalSince(lastRecognitionTime) >= minimumTimeBetweenRecognitions else { return }
        
        for (gesture, pattern) in gesturePatterns {
            if pattern(landmarks) {
                DispatchQueue.main.async {
                    self.currentSign = gesture
                    self.lastRecognitionTime = now
                    
                    // Cancel existing timer
                    self.dismissTimer?.invalidate()
                    
                    // Set new timer to clear the sign
                    self.dismissTimer = Timer.scheduledTimer(withTimeInterval: self.displayDuration, repeats: false) { _ in
                        self.currentSign = ""
                    }
                }
                return
            }
        }
    }
} 