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
import MetalKit

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
    @State var boxNode: SCNNode = loadOBJModel(named: "BIODYN-100 v3")! // SCNNode(geometry: SCNBox(width: 0.3, height: 0.3, length: 0.3, chamferRadius: 0.01)) //
    @State var cameraNode: SCNNode = SCNNode()
    
    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        let scene = SCNScene()
        view.scene = scene
        view.allowsCameraControl = true
        view.backgroundColor = .black
        
        // Add box
        boxNode.simdScale = simd_float3(repeating: 0.18)
        //        boxNode.geometry?.materials.append(SCNMaterial())
        scene.rootNode.addChildNode(boxNode)
        
        // Add light
        let light = SCNLight()
        light.type = .omni
        light.intensity = 200
        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.simdPosition = simd_float3(x: 2, y: -3, z: 2)
        scene.rootNode.addChildNode(lightNode)
        
        let dirLight = SCNLight()
        dirLight.type = .omni
        dirLight.intensity = 100
        let ln2 = SCNNode()
        ln2.light = dirLight
        ln2.simdPosition = simd_float3(x: 2, y: 3, z: 2)
        scene.rootNode.addChildNode(ln2)
        
        // Add camera
        let camera = SCNCamera()
        camera.zFar = 100
        camera.zNear = 0.01
        camera.wantsExposureAdaptation = false
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 0, 2.0)
        scene.rootNode.addChildNode(cameraNode)
        
        return view
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        let q = biodyn.orientation
        let biodyn_rot = Self.bdToSKQuat(simd_quatf(ix: q.x, iy: q.y, iz: q.z, r: q.w))
        animateTo(boxNode, target: biodyn_rot, duration: 0.05)
//        boxNode.geometry?.firstMaterial?.diffuse.contents = UIColor(red: CGFloat(biodyn.emg / 5.0), green: 1, blue: 0, alpha: 1.0)
        cameraNode.simdPosition = boxNode.simdPosition + simd_float3(0, 0, 2.0)
    }
    
    func animateTo(_ node: SCNNode, target: simd_quatf, duration: CFTimeInterval = 0.6) {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = duration
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        node.simdOrientation = simd_normalize(target)
        SCNTransaction.commit()
    }
    
    static func bdToSKQuat(_ q: simd_quatf) -> simd_quatf {
        return simd_normalize(simd_quatf(real: q.real, imag: bdToSkVec(q.imag)))
    }
    
    static func bdToSkVec(_ v: simd_float3) -> simd_float3 {
        return simd_float3(x: -v.x, y: v.z, z: v.y)
    }
    
    static func loadOBJModel(named filename: String) -> SCNNode? {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "obj") else {
            log.error("[3DBiodynView] OBJ file not found \(filename)")
            return nil
        }
        
        let allocator = MTKMeshBufferAllocator(device: MTLCreateSystemDefaultDevice()!)
        let asset = MDLAsset(url: url, vertexDescriptor: nil, bufferAllocator: allocator)
        asset.loadTextures()
        
        guard let mdlMesh = asset.object(at: 0) as? MDLMesh else { return SCNNode() }
        
        // Smooth normals: π = fully smooth; use lower (e.g. 0.5) to keep sharp edges
        mdlMesh.addNormals(withAttributeNamed: MDLVertexAttributeNormal, creaseThreshold: .pi)
        
        // Optional but recommended for PBR + normal maps
        mdlMesh.addTangentBasis(
            forTextureCoordinateAttributeNamed: MDLVertexAttributeTextureCoordinate,
            normalAttributeNamed: MDLVertexAttributeNormal,
            tangentAttributeNamed: MDLVertexAttributeTangent
        )
        
        let scene = SCNScene(mdlAsset: asset)
        let node = SCNNode()
        for child in scene.rootNode.childNodes {
            node.addChildNode(child)
        }
        
        log.info("[3DBiodynView] Loaded: \(filename)")
        return node
    }
    
}
