//
//  DrawingGeoFenceViewController.swift
//  MultipleHDMMapView
//
//  Created by Lee Kuan Xin on 22.09.17.
//  Copyright © 2017 HDMI. All rights reserved.
//

import UIKit
import os.log

class DrawingGeoFenceViewController: UIViewController {

    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    
    //MARK: drawNavigation
    //configure view controller before it's presented
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            //            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        //Properties return from canvasView
        //let points = canvasView.points
        //let coordinate = canvasView.coordinate
        //geoFence = GeoFence(points: points, coordinate: coordinate)
    }
    
    
    
    //        @IBAction func unwindToPreviousScreen(_ sender: Any) {
    //            if let sourceViewController = (sender as AnyObject).sourceViewController as? ModificationMenuView {
    //
    //            }
    //            if let sourceViewController = sender.sourceViewController as? ModificationMenuView, meal = sourceViewController.meal {
    //            }
    //     }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        // add locations data
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
}
