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
        // 垂直、水平を有効化
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
            let planeGeometry = ARSCNPlaneGeometry(device: device)! // メッシュ情報を保持する(Metalのみ)
            planeGeometry.update(from: planeAnchor.geometry)
            // 水平か垂直かで色を変更する
            let color: Any = planeAnchor.alignment == .horizontal ? UIColor.blue.withAlphaComponent(0.8) : UIColor.green.withAlphaComponent(0.8)
            // geometryの配列から一番前を取得
            guard let material = planeGeometry.materials.first else {
                fatalError()
            }
            // colorを再度キャストして追加
            if let program = color as? SCNProgram {
                material.program = program
            }else {
                material.diffuse.contents = color
            }
            // Nodeに追加
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
        for childNode in node.childNodes { // nodeを取得
            if childNode.geometry as? ARSCNPlaneGeometry != nil {
                let planeGeometry = childNode.geometry as! ARSCNPlaneGeometry
                planeGeometry.update(from: planeAnchor.geometry) // updeta
            }
        }
        
    }
}
