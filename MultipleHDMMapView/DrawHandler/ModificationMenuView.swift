//
//  ModificationMenuView.swift
//  MultipleHDMMapView
//
//  Created by Lee Kuan Xin on 22.09.17.
//  Copyright © 2017 HDMI. All rights reserved.
//

import UIKit

class ModificationMenuView: UIViewController {

    @IBOutlet weak var Add: UIButton!
    @IBOutlet weak var Update: UIButton!
    @IBOutlet weak var Delete: UIButton!
    @IBOutlet weak var More: UIButton!
    @IBOutlet weak var OuterStackView: UIStackView!
    @IBOutlet weak var InnerStackView: UIStackView!
    
    
    var isMenuShow:Bool = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMenuToggle(isMenuShow)
        bringMostViewToFront()
        self.view.bringSubview(toFront: More)
    }
    
    
    
    //MARK: UIActions
    @IBAction func ShowHideMenu(_ sender: Any) {
        setMenuToggle(!isMenuShow)
    }
    @IBAction func AddGeoFence(_ sender: Any) {
        //self.view.bringSubview(toFront: canvasView)
        bringMostViewToFront()
    }
    
    
    func setMenuToggle(_ menuStatus: Bool){
        isMenuShow = menuStatus
        InnerStackView.isHidden = isMenuShow
        //UIView.animate(withDuration: 0.4, delay: 0, options: UIViewAnimationCurve, animations: (self.view.layoutIfNeeded()), completion: ())
        
    }
    func bringMostViewToFront(){
        self.view.bringSubview(toFront: More)
        self.view.bringSubview(toFront: InnerStackView)
    }
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
