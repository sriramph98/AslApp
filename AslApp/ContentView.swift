import SwiftUI
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
    
    var body: some View {
        Canvas { context, size in
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
