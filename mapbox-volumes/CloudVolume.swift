//
//  CloudVolume.swift
//  mapbox-volumes
//
//  Created by Jim Martin on 6/20/18.
//  Copyright © 2018 Mapbox.
//
//  Create volumetric clouds.
//

import Foundation
import SceneKit
import MetalKit

class CloudVolume: SCNNode {

    var debugPlane: SCNNode!

    private var densityVolume: MTLTexture?
    private var noiseVolume: MTLTexture?

    private func loadVolumeTexture(named name: String) -> MTLTexture? {
        guard let url = Bundle.main.url(forResource: name, withExtension: nil) else { return nil }
        guard let device = MTLCreateSystemDefaultDevice() else { return nil }

        let loader = MTKTextureLoader(device: device)
        let options: [MTKTextureLoader.Option : Any] = [
            .textureUsage : NSNumber(value: MTLTextureUsage.shaderRead.rawValue),
            .textureStorageMode : NSNumber(value: MTLStorageMode.private.rawValue)
        ]
        return try? loader.newTexture(URL: url, options: options)
    }
    
    private var minLat: Double!
    private var maxLat: Double!
    private var minLon: Double!
    private var maxLon: Double!
    
    override init(){
        super.init()
    }
    
    convenience init(minLat: Double, maxLat: Double, minLon: Double, maxLon: Double) {
        self.init()
        
        self.minLat = minLat
        self.maxLat = maxLat
        self.minLon = minLon
        self.maxLon = maxLon
        
        setGeometry()
        setCloudShader()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // We assume a 1x1x1 cube, but other shapes would work as well.
    private func setGeometry() {
        self.geometry = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.0)
    }
    
    private func setCloudShader() {
        // Create cloud material
        let cloudMaterial = SCNMaterial()
        self.geometry?.firstMaterial = cloudMaterial
        
        // Set shader program
        let program = SCNProgram()
        program.fragmentFunctionName = "cloudFragment" // In Shaders/Programs/clouds.metal
        program.vertexFunctionName = "cloudVertex"     // In Shaders/Programs/clouds.metal
        program.isOpaque = false
        cloudMaterial.program = program
        
        // Set noise texture
        let noiseImage  = UIImage(named: "art.scnassets/softNoise.png")!
        let noiseImageProperty = SCNMaterialProperty(contents: noiseImage)
        cloudMaterial.setValue(noiseImageProperty, forKey: "noiseTexture")

        let intImage  = UIImage(named: "art.scnassets/sharpNoise.png")!
        let intImageProperty = SCNMaterialProperty(contents: intImage)
        cloudMaterial.setValue(intImageProperty, forKey: "interferenceTexture")

        // Load volume textures
        if densityVolume == nil {
            densityVolume = loadVolumeTexture(named: "art.scnassets/densityVolume.ktx")
        }
        if noiseVolume == nil {
            noiseVolume = loadVolumeTexture(named: "art.scnassets/noiseVolume.ktx")
        }
        if let density = densityVolume {
            let prop = SCNMaterialProperty(contents: density)
            cloudMaterial.setValue(prop, forKey: "densityVolume")
        }
        if let noise = noiseVolume {
            let prop = SCNMaterialProperty(contents: noise)
            cloudMaterial.setValue(prop, forKey: "noiseVolume")
        }
        
        // Set up cloud map
        debugPlane = SCNNode(geometry: SCNPlane(width: 1, height: 1))
            // Offset the plane so that it's visible below the volume node
            debugPlane.position = SCNVector3Make(0, -1, 0)
            // Rotate it to match the orientation of the volume node's samples
            debugPlane.eulerAngles = SCNVector3Make(-Float.pi / 2, 0, 0)
            // Cull the front, so that it's only visible from below
            debugPlane.geometry?.firstMaterial?.cullMode = .front
        self.addChildNode(debugPlane)
        
        // Cloud density can be provided by an image or another source
        // Add your own implementation here if desired
    }
    
}
