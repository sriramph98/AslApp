import SwiftUI
import Vision
import AVFoundation

struct ContentView: View {
    @StateObject private var cameraManager = CameraManager.shared
    
    var body: some View {
        CameraView()
            .edgesIgnoringSafeArea(.all) // Make camera fill the window
            .overlay(
                HandTrackingOverlay()
                    .edgesIgnoringSafeArea(.all)
            )
    }
}

// Hand tracking overlay to show points
struct HandTrackingOverlay: View {
    @StateObject private var handTracker = HandTracker.shared
    
    // Define hand connections - which points should be connected with lines
    private let handConnections: [(VNHumanHandPoseObservation.JointName, VNHumanHandPoseObservation.JointName)] = [
        // Thumb
        (.thumbCMC, .thumbMP),
        (.thumbMP, .thumbIP),
        (.thumbIP, .thumbTip),
        
        // Index finger
        (.wrist, .indexMCP),
        (.indexMCP, .indexPIP),
        (.indexPIP, .indexDIP),
        (.indexDIP, .indexTip),
        
        // Middle finger
        (.wrist, .middleMCP),
        (.middleMCP, .middlePIP),
        (.middlePIP, .middleDIP),
        (.middleDIP, .middleTip),
        
        // Ring finger
        (.wrist, .ringMCP),
        (.ringMCP, .ringPIP),
        (.ringPIP, .ringDIP),
        (.ringDIP, .ringTip),
        
        // Little finger
        (.wrist, .littleMCP),
        (.littleMCP, .littlePIP),
        (.littlePIP, .littleDIP),
        (.littleDIP, .littleTip),
        
        // Palm
        (.wrist, .thumbCMC),
        (.indexMCP, .middleMCP),
        (.middleMCP, .ringMCP),
        (.ringMCP, .littleMCP)
    ]
    
    var body: some View {
        Canvas { context, size in
            // Draw connections first (so they appear behind the points)
            for connection in handConnections {
                if let startPoint = handTracker.handLandmarks[connection.0],
                   let endPoint = handTracker.handLandmarks[connection.1] {
                    let startScreenPoint = CGPoint(
                        x: startPoint.x * size.width,
                        y: (1 - startPoint.y) * size.height
                    )
                    let endScreenPoint = CGPoint(
                        x: endPoint.x * size.width,
                        y: (1 - endPoint.y) * size.height
                    )
                    
                    // Draw line between points
                    let path = Path { p in
                        p.move(to: startScreenPoint)
                        p.addLine(to: endScreenPoint)
                    }
                    context.stroke(path, with: .color(.green.opacity(0.6)), lineWidth: 1)
                }
            }
            
            // Draw points on top
            for (_, point) in handTracker.handLandmarks {
                let screenPoint = CGPoint(
                    x: point.x * size.width,
                    y: (1 - point.y) * size.height
                )
                
                context.stroke(
                    Path(ellipseIn: CGRect(x: screenPoint.x - 2, y: screenPoint.y - 2, width: 4, height: 4)),
                    with: .color(.green),
                    lineWidth: 2
                )
            }
        }
    }
} 
