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
    
    @Bindable var biodyn: Biodyn3D<B, BD>
    
    var body: some View {
        BiodynView3DSK(biodyn: biodyn).ignoresSafeArea().frame(height: 400)
    }
    
}

fileprivate struct BiodynView3DSK<B: PBiodyn, BD: PeripheralsDiscovery<B>>:  UIViewRepresentable
where BD.Listener == any PeripheralsDiscoveryListener<B> {
    
    @Bindable var biodyn: Biodyn3D<B, BD>
    @State var boxNode: SCNNode = SCNNode(geometry: SCNBox(width: 0.3, height: 0.3, length: 0.3, chamferRadius: 0.01))
    @State var cameraNode: SCNNode = SCNNode()
    
    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        let scene = SCNScene()
        view.scene = scene
        view.allowsCameraControl = true
        view.backgroundColor = .black
        
        // Add box
        boxNode.geometry?.firstMaterial?.diffuse.contents = UIColor.systemTeal
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
        camera.zNear = 0.05
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 0, 2.0)
        scene.rootNode.addChildNode(cameraNode)
        
        return view
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        boxNode.simdEulerAngles.x = biodyn.angle.y
        boxNode.simdEulerAngles.y = biodyn.angle.z
        boxNode.simdEulerAngles.z = biodyn.angle.x
        boxNode.simdPosition.x = biodyn.position.x
        boxNode.simdPosition.y = biodyn.position.z
        boxNode.simdPosition.z = biodyn.position.y
        cameraNode.simdPosition.y = biodyn.position.z
        log.info("[3DBiodynView] Biodyn at \(boxNode.simdPosition), camera at \(cameraNode.simdPosition)")
    }
}
