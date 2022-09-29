//
//  ViewController.swift
//  Reality Kit Ruler
//
//  Created by Ali Eldeeb on 9/29/22.
//

import UIKit
import RealityKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet weak var arView: ARView!
    var startAnchor: AnchorEntity?
    var endAnchor: AnchorEntity?
    var object: ModelEntity = ModelEntity()
    var entityList = [ModelEntity]()
    var distanceString: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
//        arView.addCoaching()
        arView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    
    func setup(){
        arView.automaticallyConfigureSession = true
        let configuraiton = ARWorldTrackingConfiguration()
        configuraiton.planeDetection = .horizontal
        configuraiton.environmentTexturing = .automatic
        arView.session.run(configuraiton)
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer){
        let tapLocation = sender.location(in: arView)
        let results = arView.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .horizontal)
        
        if let result = results.first{
            if startAnchor == nil{
                startAnchor = AnchorEntity(raycastResult: result)
                let object = createEntity()
                startAnchor?.addChild(object)
                entityList.append(object)
                guard let startAnchor = startAnchor else{return}
                arView.scene.addAnchor(startAnchor)
            }else if endAnchor == nil {
                endAnchor = AnchorEntity(raycastResult: result)
                object = createEntity()
                endAnchor?.addChild(object)
                entityList.append(object)
                guard let endAnchor = endAnchor else{return}
                arView.scene.addAnchor(endAnchor)
            }
            //we have added two anchors and each can have one entity, this makes it so the user can only measure two distances at a time
            if entityList.count >= 2{
                calculate()
                addDistanceText(distanceString, object)
            }
            

        }
    }
    
    func createEntity() -> ModelEntity{
        let object = ModelEntity(mesh: MeshResource.generateSphere(radius: 0.01), materials: [SimpleMaterial(color: .systemMint, isMetallic: true)])
        return object
    }
    
    
    
    func calculate(){
        let start = startAnchor!
        let end = endAnchor!
        let distance = (simd_distance(start.position, end.position)) * 100
        
        distanceString = String(format: "%.1f CM", distance) 
        
    }
    
    func addDistanceText(_ distanceString: String,_ entity: ModelEntity){
        let mesh = MeshResource.generateText(distanceString, extrusionDepth: 0.1, font: .systemFont(ofSize: 2), containerFrame: .zero, alignment: .left, lineBreakMode: .byTruncatingTail)
        let material = SimpleMaterial(color: .orange, isMetallic: true)
        let text = ModelEntity(mesh: mesh,materials: [material])
        text.scale = SIMD3<Float>(x: 0.015, y: 0.015, z: 0.045)
        entity.addChild(text)
        text.setPosition(simd_float3(-0.07,0.06,0), relativeTo: entity)
    }

}


//extension ARView: ARCoachingOverlayViewDelegate{
//    func addCoaching(){
//        let coachingOverlay = ARCoachingOverlayView()
//        //telling the coaching overlay to resize based on superview bounds so it can adjust if user switxhes b/w orientations
//        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        //The coaching goal you choose determines the particular instructions the coaching overlay presents to the user.
//        coachingOverlay.goal = .horizontalPlane
//        //The coaching overlay monitors your app's ARSession and reacts according to its tracking status. You don't need to set this property if you set sessionProvider instead.
//        coachingOverlay.session = self.session
//        self.addSubview(coachingOverlay)
//    }
//
//    public func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3){
//            coachingOverlayView.setActive(false, animated: true)
//        }
//    }
//}
