//
//  3DBiodynView.swift
//  BIOHUB
//
//  Created by Callum Mackenzie on 2025-10-27.
//

import SwiftUI
import SceneKit
import simd
import Observation

struct BiodynView3D<B: PBiodyn, BD: PeripheralsDiscovery<B>>: View
where BD.Listener == any PeripheralsDiscoveryListener<B> {
    
    @Binding var biodyn: B
    
    var body: some View {
        BiodynView3DSK().ignoresSafeArea()
    }
    
}

fileprivate struct BiodynView3DSK: UIViewRepresentable {
    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        let scene = SCNScene()
        view.scene = scene
        view.allowsCameraControl = true
        view.backgroundColor = .black
        
        // Add box
        let box = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0.01)
        box.firstMaterial?.diffuse.contents = UIColor.systemTeal
        let boxNode = SCNNode(geometry: box)
        scene.rootNode.addChildNode(boxNode)
        
        // Add light
        let light = SCNLight()
        light.type = .omni
        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3(1, 1, 1)
        scene.rootNode.addChildNode(lightNode)
        
        // Add camera
        let camera = SCNCamera()
        camera.zFar = 100
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 0, 1.0)
        scene.rootNode.addChildNode(cameraNode)
        
        // Spin animation for now
        let spin = SCNAction.repeatForever(.rotateBy(x: 0, y: CGFloat.pi, z: 0, duration: 2))
        boxNode.runAction(spin)
        
        return view
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {}
}
