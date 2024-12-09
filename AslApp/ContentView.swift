//
//  ContentView.swift
//  AslApp
//
//  Created by Sriram P H on 12/8/24.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var cameraManager = CameraManager()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("ASL to English Translator")
                .font(.largeTitle)
            
            ZStack {
                CameraPreview(session: cameraManager.session)
                    .frame(width: 640, height: 480)
                    .cornerRadius(12)
                
                HandLandmarkView(points: cameraManager.displayPoints)
                    .frame(width: 640, height: 480)
            }
            
            Text(cameraManager.detectedSign)
                .font(.title)
                .padding()
        }
        .padding()
        .frame(minWidth: 700, minHeight: 700)
        .onAppear {
            cameraManager.checkPermissionsAndSetup()
        }
    }
}

struct CameraPreview: NSViewRepresentable {
    let session: AVCaptureSession
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: NSRect(x: 0, y: 0, width: 640, height: 480))
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        
        previewLayer.frame = view.frame
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.connection?.automaticallyAdjustsVideoMirroring = false
        previewLayer.connection?.isVideoMirrored = true
        
        view.wantsLayer = true
        view.layer = previewLayer
        
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
}



#Preview {
    ContentView()
}
