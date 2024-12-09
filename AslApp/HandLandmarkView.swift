import SwiftUI

struct HandLandmarkView: View {
    let points: [CGPoint]
    
    // Define connections for visualization
    private let connections: [(Int, Int)] = [
        // Thumb
        (0, 1), (1, 2), (2, 3), (3, 4),
        // Index finger
        (0, 5), (5, 6), (6, 7), (7, 8),
        // Middle finger
        (0, 9), (9, 10), (10, 11), (11, 12),
        // Ring finger
        (0, 13), (13, 14), (14, 15), (15, 16),
        // Pinky
        (0, 17), (17, 18), (18, 19), (19, 20)
    ]
    
    var body: some View {
        Canvas { context, size in
            // Draw connections
            for connection in connections {
                if connection.0 < points.count && connection.1 < points.count {
                    let start = points[connection.0]
                    let end = points[connection.1]
                    let path = Path { p in
                        p.move(to: start)
                        p.addLine(to: end)
                    }
                    context.stroke(path, with: .color(.blue), lineWidth: 2)
                }
            }
            
            // Draw points
            for point in points {
                let path = Path(ellipseIn: CGRect(x: point.x - 5, y: point.y - 5, width: 10, height: 10))
                context.stroke(path, with: .color(.green), lineWidth: 2)
                context.fill(path, with: .color(.green.opacity(0.5)))
            }
        }
    }
}

#Preview {
    // Example preview with sample points
    HandLandmarkView(points: [
        CGPoint(x: 100, y: 100),
        CGPoint(x: 120, y: 120),
        CGPoint(x: 140, y: 140),
        CGPoint(x: 160, y: 160),
        CGPoint(x: 180, y: 180)
    ])
    .frame(width: 640, height: 480)
    .background(Color.black.opacity(0.1))
} 