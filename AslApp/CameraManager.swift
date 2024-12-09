import AVFoundation
import SwiftUI

class CameraManager: ObservableObject {
    static let shared = CameraManager()
    
    @Published var availableCameras: [AVCaptureDevice] = []
    @Published var selectedCamera: AVCaptureDevice?
    
    private init() {
        // Request camera access first
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            guard granted else { return }
            DispatchQueue.main.async {
                self?.loadAvailableCameras()
            }
        }
    }
    
    func loadAvailableCameras() {
        // Get all video devices
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [
                .builtInWideAngleCamera,
                .external
            ],
            mediaType: .video,
            position: .unspecified
        )
        
        availableCameras = discoverySession.devices
        
        // Select the first camera if none is selected
        if selectedCamera == nil {
            selectedCamera = availableCameras.first
        }
        
        // Print available cameras for debugging
        print("Available cameras: \(availableCameras.map { $0.localizedName })")
    }
    
    func selectCamera(_ camera: AVCaptureDevice) {
        guard camera != selectedCamera else { return }
        
        selectedCamera = camera
        NotificationCenter.default.post(
            name: .cameraDidChange,
            object: camera
        )
    }
}

extension Notification.Name {
    static let cameraDidChange = Notification.Name("cameraDidChange")
} 
