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
    var entityList = [ModelEntity]()
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
                let object = createEntity()
                endAnchor?.addChild(object)
                entityList.append(object)
                guard let endAnchor = endAnchor else{return}
                arView.scene.addAnchor(endAnchor)
            }
            
            if entityList.count >= 2{
                calculate()
                //entityList = [ModelEntity]
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
        let a = (end.position.x) - (start.position.x)
        let b = (end.position.y) - (start.position.y)
        let c = (end.position.z) - (start.position.z)
        
        let distance = abs(sqrt(pow(a, 2) + pow(b, 2) + pow(c, 2))) * 100
        let distanceString = String(format: "%.2f", distance) + "CM"
        print(distanceString)
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
