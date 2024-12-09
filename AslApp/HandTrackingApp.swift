import SwiftUI

@main
struct HandTrackingApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar) // Hide window title
        .commands {
            CommandMenu("Camera") {
                CameraSelectionMenu()
            }
        }
    }
}

struct CameraSelectionMenu: View {
    @StateObject private var cameraManager = CameraManager.shared
    
    var body: some View {
        ForEach(cameraManager.availableCameras, id: \.uniqueID) { camera in
            Button(camera.localizedName) {
                cameraManager.selectCamera(camera)
            }
            .checkmark(camera == cameraManager.selectedCamera)
        }
    }
} 