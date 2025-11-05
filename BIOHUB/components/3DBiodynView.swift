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
import SceneKit.ModelIO

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
    @State var boxNode: SCNNode = SCNNode(geometry: SCNBox(width: 0.3, height: 0.3, length: 0.3, chamferRadius: 0.01)) // loadSTLModel(named: "BIODYN-100 v3")!
    @State var cameraNode: SCNNode = SCNNode()
    
    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        let scene = SCNScene()
        view.scene = scene
        view.allowsCameraControl = true
        view.backgroundColor = .black
        
        // Add box
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
        
        cameraNode.simdPosition = boxNode.simdPosition + simd_float3(0, 0, 2.0)
        log.info("[3DBiodynView] Biodyn at \(boxNode.simdPosition), camera at \(cameraNode.simdPosition)")
    }
    
    static func loadSTLModel(named filename: String) -> SCNNode? {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "stl") else {
            log.error("[3DBiodynView] STL file not found")
            return nil
        }
        let asset = MDLAsset(url: url)

        let scene = SCNScene(mdlAsset: asset)
        let node = SCNNode()
        for child in scene.rootNode.childNodes {
            node.addChildNode(child)
        }
        node.simdScale = simd_float3(repeating: 0.01)
        
        log.info("[3DBiodynView] Loaded 3MF: \(filename)")
        
        return node
    }
}
