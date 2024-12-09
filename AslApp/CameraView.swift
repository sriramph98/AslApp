import SwiftUI
import AVFoundation

struct CameraView: NSViewRepresentable {
    @StateObject private var cameraManager = CameraManager.shared
    private let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.bounds
        previewLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        previewLayer.videoGravity = .resizeAspectFill
        view.layer = previewLayer
        view.wantsLayer = true
        
        setupCaptureSession()
        
        // Listen for camera changes
        NotificationCenter.default.addObserver(
            forName: .cameraDidChange,
            object: nil,
            queue: .main
        ) { notification in
            if let camera = notification.object as? AVCaptureDevice {
                updateCamera(camera)
            }
        }
        
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        nsView.layer?.frame = nsView.bounds
    }
    
    private func setupCaptureSession() {
        captureSession.beginConfiguration()
        
        // Add input
        if let camera = cameraManager.selectedCamera,
           let input = try? AVCaptureDeviceInput(device: camera) {
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
        }
        
        // Add output
        videoOutput.setSampleBufferDelegate(HandTrackingDelegate.shared, queue: DispatchQueue(label: "videoQueue"))
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        captureSession.commitConfiguration()
        
        DispatchQueue.global(qos: .userInitiated).async {
            captureSession.startRunning()
        }
    }
    
    private func updateCamera(_ camera: AVCaptureDevice) {
        captureSession.beginConfiguration()
        
        // Remove existing input
        captureSession.inputs.forEach { captureSession.removeInput($0) }
        
        // Add new input
        if let input = try? AVCaptureDeviceInput(device: camera) {
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
        }
        
        captureSession.commitConfiguration()
    }
} 