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
    
    var mapViewController: HDMMapViewController?
    
    //MARK: Initialization and Deinit
//    override init(){
//        super.init()
//    }
    
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

        
        configureMap()
        //self.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.mapViewController?.delegate = self
        self.mapView.tapEnabled = true
        self.mapViewController?.view.frame = CGRect(x:0, y:0, width:self.view.frame.size.width, height:self.view.frame.size.height)
        self.mapViewController?.view.autoresizingMask = UIViewAutoresizing(rawValue: UIViewAutoresizing.RawValue(UInt8(UIViewAutoresizing.flexibleWidth.rawValue) | UInt8(UIViewAutoresizing.flexibleHeight.rawValue)))
        //self.view.addSubview((self.mapViewController?.view)!)
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
        super.viewWillAppear(animated)
        
        self.mapViewController?.removeFromParentViewController()
        self.mapViewController?.view.removeFromSuperview()
    }
    
    func configureMap(){
        //initialise the original location
        self.mapView.setRegion(HDMMapCoordinateRegionMake(49.418317, 8.675541, 0, 0.000255, 0.000255), animated: true)
        self.mapView.set3DMode(false, animated: false)
    }
    
    func setVisibleMapRegion(mapRegion: HDMMapRegion, animated animate:Bool){
        
    }
    
    func shouldAutorotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation) -> Bool
    {
        return true
    }
    
    //MARK: MapViewController Delegate
    func mapViewControllerWillStart(_ controller: HDMMapViewController){
        self.configureMap()
    }
    
}
