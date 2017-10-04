//
//  MainViewController.swift
//  MultipleHDMMapView
//
//  Created by Tan Chung Shzen on 27.09.17.
//  Copyright © 2017 HDMI. All rights reserved.
//

import UIKit
import HDMMapCore
import CoreGraphics

class MainViewController: HDMMapViewController, HDMMapViewControllerDelegate {

    var feature = [HDMFeature] ()
    var featureId = [UInt64] ()
    var annotation = [HDMAnnotation] ()
    var nameArray = [String] ()
    var urlArray = [String] ()
    var url : String?
    var urlIndex : Int?
    var coordinateX = [Double] ()
    var coordinateY = [Double] ()
    var status : String?
    
    @IBOutlet weak var doneBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Mainview Did Load")
        self.mapView.set3DMode(false, animated: false)
        self.delegate = self
        self.mapView.tapEnabled = false
        self.view.addSubview(self.doneBtn)
        self.doneBtn.isHidden = true
        
        //receiver of deletegeofence
        NotificationCenter.default.addObserver(self, selector: #selector(self.deleteGeofence(_:)), name: NSNotification.Name(rawValue: "deleteGeofence"), object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if status == "create" {
            createGeofence()
        }
        
        let testdata = DataHandler()
        testdata.testCoordinates(){
            place in
            if !(self.url == nil) { self.updateGeofence()}
        
            self.feature.append((place?.feature)!)
            self.annotation.append((place?.annotation)!)
            self.nameArray.append((place?.place.name)!)
            self.urlArray.append((place?.place.url)!)
            
            DispatchQueue.main.async {
                self.mapView.add(place?.annotation)
            }
            self.mapView.add((place?.feature)!)
            self.featureId.append((place?.feature.featureId)!)
        }
        
        print("Mainview will Appear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("Mainview did Appear")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("Mainview did Disappear")
        self.url = nil
    }
    
    func mapViewController(_ controller: HDMMapViewController, tappedAt coordinate: HDMMapCoordinate, features: [HDMFeature]) {
        
        tapEffect(coordinate.x, coordinate.y)
        
        coordinateX.append(coordinate.x)
        coordinateY.append(coordinate.y)
        
        print(coordinateX.count)
    }
    
    func mapViewController(_ controller: HDMMapViewController, longPressedAt coordinate: HDMMapCoordinate, features: [HDMFeature]) {
        guard let f = features.first else {return}
        
        print("Selecting object with ID \(f.featureId)")

        if let index = self.featureId.index(of: f.featureId ){
        
            let alertController = UIAlertController(title: "Manage Geofence", message: "Do you wish to Update or Delete \(self.nameArray[index]) ?", preferredStyle: .alert)
            
            
            let updateAction = UIAlertAction(title: "Update", style: .default) { (_) in
                self.url = self.urlArray[index]
                self.updateGeofence()
            }
            
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
                
                let data = DataHandler()
                data.deletePlace(self.urlArray[index], (self.nameArray[index]))
                
                self.mapView.remove(self.annotation[index])
                self.mapView.remove(f)
                self.nameArray.remove(at: index)
                self.annotation.remove(at: index)
                self.feature.remove(at: index)
                
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
            
            alertController.addAction(updateAction)
            alertController.addAction(deleteAction)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func createGeofence(){
        let alertController = UIAlertController(title: "Add Geofence", message: "Tap Ok to start adding geofence", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Ok", style: .default) { (_) in
            //allow user to draw geofence
            self.mapView.tapEnabled = true
            
            self.doneBtn.isHidden = false
            
            
            self.navigationController?.navigationBar.isUserInteractionEnabled = false
        }
        
        alertController.addAction(confirmAction)
        
        //if statement to stop UIAlertcontroller from calling multiple times
        if !(self.navigationController?.visibleViewController?.isKind(of: UIAlertController.self))! {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func updateGeofence(){
            //obtain correct index
        let urlString = url as! String
        
        if let index = self.urlArray.index(of: urlString){
            
                urlIndex = index
                //alert user
                let alertController = UIAlertController(title: "Update Geofence", message: "Remove previous geofence to start update a new one?", preferredStyle: .alert)
                
                let confirmAction = UIAlertAction(title: "Yes", style: .default) { (_) in
                    self.mapView.remove(self.annotation[index])
                    self.mapView.remove(self.feature[index])
                    self.feature.remove(at: index)
                    //allow user to draw geofence
                    self.mapView.tapEnabled = true
                    self.doneBtn.isHidden = false
                    //self.navigationController?.navigationBar.isUserInteractionEnabled = false
                }
                
                let cancelAction = UIAlertAction(title: "No", style: .cancel) { (_) in
                   
                }
                
                alertController.addAction(confirmAction)
                alertController.addAction(cancelAction)
            
            //if statement to stop UIAlertcontroller from calling multiple times
            //if !(self.navigationController?.visibleViewController?.isKind(of: UIAlertController.self))! {
               self.present(alertController, animated: true, completion: nil)
            //}

            }
    }
    
    //receiver function - deletegeofence
    @objc func deleteGeofence(_ notification: NSNotification){
        if let name = notification.userInfo?["name"] as? String{
            print("name: \(name)")
            if let index = nameArray.index(of: name ){
                print("index: \(index)")
                self.mapView.remove(self.annotation[index])
                self.mapView.remove(self.feature[index])
                nameArray.remove(at: index)
                annotation.remove(at: index)
                feature.remove(at: index)
            }
        }
    }
    
    @IBAction func doneAction(_ sender: UIButton) {
        var points : [putPlace.Geofence.Points] = []
        var feat : HDMFeature
        //remember to assign new polygons to array
        let data = DataHandler()
        (feat,points) = data.drawPolygon(self.coordinateX,self.coordinateY)
        
        if status == "create"{
              self.doneBtn.isHidden = true
            //send points to CreateView
            let naviController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateViewController") as? CreateViewController
            
            naviController?.points = points
            naviController?.status = "load"
            self.navigationController?.pushViewController(naviController!, animated: true)
        }
        else if status == "update" {
        //assign new feature into feature array
        feature.insert(feat, at: urlIndex!)
            
        self.doneBtn.isHidden = true
        //send points to UpdateView
        let naviController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UpdateViewController") as? UpdateViewController
        
        naviController?.points = points
        naviController?.url = url!
        naviController?.status = "load"
        
        self.navigationController?.pushViewController(naviController!, animated: true)
        }
    }
    
    //    MARK:TAP effect
    func tapEffect(_ x: Double, _ y:Double) {
        var ui :UIImageView = UIImageView(frame: self.view.frame)
        //ui.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        self.view.addSubview(ui)
        self.view.bringSubview(toFront: ui)
        ui.isUserInteractionEnabled = false
        if(coordinateX.count >= 2) {
            UIGraphicsBeginImageContext(ui.frame.size)
            let ctx = UIGraphicsGetCurrentContext()
            print(ctx)
            ui.draw(CGRect(x: 0, y: 0, width: ui.frame.size.width, height: ui.frame.size.height))
            ctx?.saveGState()
            ctx?.setLineCap(.square)
            ctx?.setLineWidth(3.0)
            ctx?.setStrokeColor(UIColor.blue.cgColor)
            ctx?.beginPath()
            ctx?.move(to: CGPoint(x: coordinateX.last!, y: coordinateY.last!))
            print(coordinateX)
            print(coordinateY)
            print(x)
            print(y)
            ctx?.addLine(to: CGPoint(x: x, y: y))
            ctx?.strokePath()
            ctx?.restoreGState()
            ui.image = UIGraphicsGetImageFromCurrentImageContext()
            ui.alpha = 1.0
            UIGraphicsEndImageContext()
        }
        if(coordinateX.count > 4){
            ui.removeFromSuperview()
            ui.image = nil
        }
    }
}
