//
//  ViewController.swift
//  RichPlaneDetection
//
//  Created by 福山帆士 on 2020/07/06.
//  Copyright © 2020 福山帆士. All rights reserved.
//

import ARKit

class ViewController: UIViewController {
    
    @IBOutlet var sceneView: ARSCNView!
    
    private let device = MTLCreateSystemDefaultDevice()! // Metal
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.scene = SCNScene()
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, SCNDebugOptions.showWireframe]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.vertical, .horizontal]
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
}

extension ViewController: ARSCNViewDelegate {
    
    // 平面検出
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { // 平面アンカー
            return
        }
        // animation
        if #available(iOS 11.3, *) {
            let planeGeometry = ARSCNPlaneGeometry(device: device)! // メッシュ情報を保持するクラス(Metalのみ)
            planeGeometry.update(from: planeAnchor.geometry)
            
            let color: Any = planeAnchor.alignment == .horizontal ? UIColor.blue.withAlphaComponent(0.8) : UIColor.green.withAlphaComponent(0.8)
            
            guard let material = planeGeometry.materials.first else {
                fatalError()
            }
            if let program = color as? SCNProgram {
                material.program = program
            }else {
                material.diffuse.contents = color
            }
            let planeNode = SCNNode(geometry: planeGeometry)
            DispatchQueue.main.async {
                node.addChildNode(planeNode)
            }
        }
    }
    
    // 平面更新
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            return
        }
        for childNode in node.childNodes {
            if childNode.geometry as? ARSCNPlaneGeometry != nil {
                if let planeGeometry = childNode.geometry as? ARSCNPlaneGeometry {
                    planeGeometry.update(from: planeAnchor.geometry)
                }
            }
        }
        
    }
}
