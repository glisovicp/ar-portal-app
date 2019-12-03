//
//  ViewController.swift
//  ARPortalApp
//
//  Created by Petar Glisovic on 12/3/19.
//  Copyright © 2019 Petar Glisovic. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    // MARK: - Outlets
    
    @IBOutlet var sceneView: ARSCNView!
    
    // MARK: - Lifecycle functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Setting plane detection to horizontal so that we are able to detect horizontal planes
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // called when touches are detected on the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            
            // Get location of where we touched on the 2D screen
            let touchLocation = touch.location(in: sceneView)
            
            // hitTest is performed to get the 3D coordinates corresponding to the 2D coordinates that we got from touching the screen. Taht 3D coordinate will only be considered when it is on the existing plane what we detected.
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if let hitResult = results.first {
                
                let boxScene = SCNScene(named: "art.scnassets/box.scn")
                
                if let boxNode = boxScene?.rootNode.childNode(withName: "box", recursively: true) {
                    
                    boxNode.position = SCNVector3(x: hitResult.worldTransform.columns.3.x, y: hitResult.worldTransform.columns.3.y + 0.15, z: hitResult.worldTransform.columns.3.z)
                    
                    // finally the box is added to the scene
                    sceneView.scene.rootNode.addChildNode(boxNode)
                }
            }
        }
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    // This is delegate method that is called when a horizontal plane is detected
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard anchor is ARPlaneAnchor else {
            return
        }
        
        // Anchors can be many types. As we are just dealing with horizontal plane detection we need to downcast anchor to ARPlaneAnchor
        let planeAnchor = anchor as! ARPlaneAnchor
        
        // Creating a plane geometry with the help of dimensions we got using plane anchor
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        
        // a node is basically a position
        let planeNode = SCNNode()
        
        // Setting the position of the plane geometry to the position we got using plane anchor.
        planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
        
        // When a plane is created, it is created in xy plane instead of xz plane, so we need to rotate it along x axis
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        
        // Create a material object
        let gridMaterial = SCNMaterial()
        
        // Set material as an image. A material can also be set to a color.
        gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
        
        // Assign the material to the plane
        plane.materials = [gridMaterial]
        
        // Assign the position to the plane
        planeNode.geometry = plane
        
        // Add the plane node in our scene
        node.addChildNode(planeNode)
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
