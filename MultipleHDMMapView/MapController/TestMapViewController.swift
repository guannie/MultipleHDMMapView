//
//  TestMapViewController.swift
//  MultipleHDMMapView
//
//  Created by Lee Kuan Xin on 22.09.17.
//  Copyright © 2017 HDMI. All rights reserved.
//

import UIKit
import HDMMapCore

class TestMapViewController: BaseMapViewController {

    @IBOutlet weak var switch3d: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var app = UIApplication.shared.delegate as? AppDelegate
        self.mapViewController = app?.mapViewController
        
        switch3d.setOn(false, animated: false);
        self.view.bringSubview(toFront: switch3d)
        self.mapViewController?.mapView.set3DMode(false, animated: true)
    }
    
    func mapViewControllerWillStart(_ controller: TestViewController) {
        
        // initialise the switch and append to the view
        self.view.bringSubview(toFront: switch3d)
        switch3d.setOn(false, animated: false);
    }
    
    
    func mapViewControllerDidStart(_ controller: TestViewController, error: Error?) {
        
        //initialise the original location
        self.mapView.setRegion(HDMMapCoordinateRegionMake(49.418317, 8.675541, 0, 0.000255, 0.000255), animated: true)
        self.mapView.set3DMode(false, animated: true)
    }
    
    @IBAction func switch3dAction(_ sender: Any) {
        if switch3d.isOn {
            self.mapView.set3DMode(true, animated: true)
        } else {
            self.mapView.set3DMode(false, animated: true)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
