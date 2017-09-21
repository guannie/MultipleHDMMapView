//
//  FirstViewController.swift
//  MultipleHDMMapView
//
//  Created by Lee Kuan Xin on 20.09.17.
//  Copyright © 2017 HDMI. All rights reserved.
//

import UIKit
import HDMMapCore

class FirstViewController: BaseMapViewController {

    @IBOutlet weak var MapView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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

