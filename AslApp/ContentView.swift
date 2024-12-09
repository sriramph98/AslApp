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
    @StateObject private var aslRecognizer = ASLRecognizer.shared
    
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
        ZStack {
            // Hand tracking visualization
            Canvas { context, size in
                // Draw connections first
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
                        
                        let path = Path { p in
                            p.move(to: startScreenPoint)
                            p.addLine(to: endScreenPoint)
                        }
                        context.stroke(path, 
                            with: .color(Color.accentColor.opacity(0.7)), 
                            lineWidth: 2.5)
                    }
                }
                
                // Draw points on top
                for (_, point) in handTracker.handLandmarks {
                    let screenPoint = CGPoint(
                        x: point.x * size.width,
                        y: (1 - point.y) * size.height
                    )
                    
                    // Larger, more visible points
                    let pointRect = CGRect(x: screenPoint.x - 5, y: screenPoint.y - 5, width: 10, height: 10)
                    context.fill(Path(ellipseIn: pointRect), 
                        with: .color(Color.white.opacity(0.9)))
                    context.stroke(Path(ellipseIn: pointRect), 
                        with: .color(Color.accentColor), 
                        lineWidth: 2.5)
                }
            }
            
            // Overlays
            VStack(spacing: 0) {
                // Header
                HStack {
                    // Title and badge
                    HStack(spacing: 8) {
                        Text("ASL Translator")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.primary)
                        Text("BETA")
                            .font(.system(size: 11, weight: .bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.accentColor.opacity(0.15))
                            .foregroundColor(Color.accentColor)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .padding(.top, 16)
                    .padding(.leading, 16)
                    
                    Spacer()
                }
                
                Spacer()
                
                // Recognition results
                if !aslRecognizer.currentSign.isEmpty {
                    Text(aslRecognizer.currentSign)
                        .font(.system(size: 32, weight: .medium, design: .rounded))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .background(.ultraThinMaterial)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 2)
                        .padding(.bottom, 40)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
    }
} 
