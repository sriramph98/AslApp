import AVFoundation
import SwiftUI

class CameraManager: ObservableObject {
    static let shared = CameraManager()
    
    @Published var availableCameras: [AVCaptureDevice] = []
    @Published var selectedCamera: AVCaptureDevice?
    
    private init() {
        loadAvailableCameras()
        selectedCamera = availableCameras.first
    }
    
    func loadAvailableCameras() {
        availableCameras = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: .unspecified
        ).devices
    }
    
    func selectCamera(_ camera: AVCaptureDevice) {
        selectedCamera = camera
        // Notify your capture session to switch cameras
        NotificationCenter.default.post(name: .cameraDidChange, object: camera)
    }
}

extension Notification.Name {
    static let cameraDidChange = Notification.Name("cameraDidChange")
} 