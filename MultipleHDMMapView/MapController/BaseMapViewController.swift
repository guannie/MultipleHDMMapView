//
//  BaseMapViewController.swift
//  MultipleHDMMapView
//
//  Created by Lee Kuan Xin on 21.09.17.
//  Copyright © 2017 HDMI. All rights reserved.
//

import Foundation
import HDMMapCore

class BaseMapViewController:  HDMMapViewController, HDMMapViewControllerDelegate{
    
    private var mapViewController: HDMMapViewController?
    
    //MARK: Initialization and Deinit
    override init(){
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit{
        if  self.mapViewController?.delegate === self{
            self.delegate = nil
        }
    }
    
    //MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.autoresizesSubviews = true
        self.view.clipsToBounds = true
        self.mapView.set3DMode(false, animated: false)
        //self.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.mapViewController?.delegate = self
        self.mapViewController?.view.frame = CGRect(x:0, y:0, width:self.view.frame.size.width, height:self.view.frame.size.height)
        //        self.view = self.mapViewController?.view
        //      self.view.addSubview((self.mapViewController?.view)!)
        //self.addChildViewController(self.mapViewController!)
        
        
        //MARK: fortesting
//        var test:UIView = UIView.init()
//        var test2:UIView  = UIView.init()
//        test2.frame = CGRect(x:0, y:0, width:self.view.frame.size.width/2, height:self.view.frame.size.height/2)
//        test.backgroundColor = .red
//        test2.backgroundColor = .blue
//        self.view.addSubview(test)
//        self.view = test
 //       self.view.backgroundColor = .green
       // self.view.addSubview(test2)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.mapViewController?.removeFromParentViewController()
        self.mapViewController?.view.removeFromSuperview()
    }
    
    func configureMap(){}
    
    func setVisibleMapRegion(mapRegion: HDMMapRegion, animated animate:Bool){}
    
    //MARK: MapViewController Delegate
    func mapViewControllerDidStart(controller: HDMMapViewController){
        self.configureMap()
    }
    
    func mapViewControllerDidStart(_ controller: HDMMapViewController, error: NSError) {
        NSLog("Map start error: ", error)
    }
}
