//
//  FirstViewController.swift
//  MultipleHDMMapView
//
//  Created by Lee Kuan Xin on 20.09.17.
//  Copyright © 2017 HDMI. All rights reserved.
//

import UIKit
import Foundation

protocol NotifyTouchEvents:class {
    func touchBegan(touch:UITouch)
    func touchEnded(touch:UITouch)
    func touchMoved(touch:UITouch)
}

class FirstViewController: UIViewController {

    
    //MARK: UIItems
    @IBOutlet weak var More: UIButton!
    @IBOutlet weak var Delete: UIButton!
    @IBOutlet weak var Add: UIButton!
    @IBOutlet weak var canvasView: CanvasView!
    
    var isMenuShow:Bool = true

    
    // TestItem
    var testView: UIView = UIView.init()
    //var canvasView: CanvasView = CanvasView()

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // set this view as delegate for the hdmmapview
        // this way we receive events for tapAtPoint etc.
        //self.mapView.set3DMode(false, animated: false)
        //self.delegate = self
        
        
        //self.view.bringSubview(toFront: ModificationMenuView)
        //self.view.bringSubview(toFront: More)
        //self.view.bringSubview(toFront: EditContainer)
        //setMenuToggle(isMenuShow)
        
        //add button to view
        //self.view.addSubview(drawRectButton)
        //self.view.addSubview(confirmButton)
        
        
        //self.confirmButton?.isHidden = true
        //disable user interaction when draw button is not click
        //self.mapView.tapEnabled = false
    
        // Mark: notes
        // Trying to add the view as a subview but failed
        //view.addSubview(HDMMapView.init(deepMap: DeepMap.init(file: "DeepMap")!))
        // Do any additional setup after loading the view, typically from a nib.
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}

