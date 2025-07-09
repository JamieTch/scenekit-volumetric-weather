//
//  ViewController.swift
//  mapbox-volumes
//
//  Created by Jim Martin on 7/31/18.
//  Copyright © 2018 Mapbox.
//
//  Create a SceneKit view with a 3D map of San Francisco
//  and volumetric clouds above it.
//

import UIKit
import SceneKit
class ViewController: UIViewController, SCNSceneRendererDelegate {
    
    var sceneView: SCNView = SCNView()
    private var scene: SCNScene = SCNScene()
    
    var cloudNode: CloudVolume!
    
    // San Francisco
    var minLat = 37.72
    var minLon = -122.521
    var maxLat = 37.835
    var maxLon = -122.378
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSceneView()
        createClouds()
    }
    
    // Set up sceneview with camera and lights
    func setupSceneView() {
        self.view.addSubview(sceneView)
        sceneView.frame = self.view.bounds
        
        sceneView.scene = scene
        sceneView.delegate = self
        sceneView.allowsCameraControl = true
        sceneView.showsStatistics = true
        sceneView.isPlaying = true
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 5)
        scene.rootNode.addChildNode(cameraNode)
        
        let lightNode = SCNNode()
        let light = SCNLight()
        light.type = .ambient
        light.intensity = 1000
        lightNode.light = light
        scene.rootNode.addChildNode(lightNode)
    }
    
    // Create clouds with same coordinates as terrain
    func createClouds() {
        cloudNode = CloudVolume(minLat:minLat, maxLat: maxLat,
                                minLon: minLon, maxLon: maxLon)
        cloudNode.scale = SCNVector3(x: 3.8, y: 0.2, z: 3.8) // Flatten the volume into a thin layer
        scene.rootNode.addChildNode(cloudNode)
    }
    
}
