import SwiftUI
import AVFoundation

struct CameraView: NSViewRepresentable {
    @StateObject private var cameraManager = CameraManager.shared
    let captureSession = AVCaptureSession()
    let videoOutput = AVCaptureVideoDataOutput()
    
    class Coordinator: NSObject {
        var captureSession: AVCaptureSession
        var videoOutput: AVCaptureVideoDataOutput
        var observer: NSObjectProtocol?
        
        init(captureSession: AVCaptureSession, videoOutput: AVCaptureVideoDataOutput) {
            self.captureSession = captureSession
            self.videoOutput = videoOutput
            super.init()
            
            // Listen for camera changes
            observer = NotificationCenter.default.addObserver(
                forName: .cameraDidChange,
                object: nil,
                queue: .main
            ) { [weak self] notification in
                guard let camera = notification.object as? AVCaptureDevice else { return }
                self?.updateCamera(camera)
            }
        }
        
        deinit {
            if let observer = observer {
                NotificationCenter.default.removeObserver(observer)
            }
        }
        
        func updateCamera(_ camera: AVCaptureDevice) {
            captureSession.beginConfiguration()
            
            // Remove existing inputs
            captureSession.inputs.forEach { captureSession.removeInput($0) }
            
            // Add new input
            do {
                let input = try AVCaptureDeviceInput(device: camera)
                if captureSession.canAddInput(input) {
                    captureSession.addInput(input)
                }
            } catch {
                print("Error setting up camera input: \(error.localizedDescription)")
            }
            
            captureSession.commitConfiguration()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(captureSession: captureSession, videoOutput: videoOutput)
    }
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.bounds
        previewLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        previewLayer.videoGravity = .resizeAspectFill
        view.layer = previewLayer
        view.wantsLayer = true
        
        setupCaptureSession()
        
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
} 