//
//  MainViewController.swift
//  MultipleHDMMapView
//
//  Created by Tan Chung Shzen on 27.09.17.
//  Copyright © 2017 HDMI. All rights reserved.
//

import UIKit
import HDMMapCore




class MainViewController: HDMMapViewController, HDMMapViewControllerDelegate {

    var feature : [HDMFeature] = []
    var emptyFeature = HDMFeature()
    var featureId : [UInt64] = []
    let emptyID = UInt64()
    var annotation : [HDMAnnotation?] = []
    var nameArray = [String] ()
    var urlArray = [String] ()
    var beaconName : [String] = []
    var url : String?
    var urlIndex : Int?
    var coordinateX = [Double] ()
    var coordinateY = [Double] ()
    var tapLocation = [CGPoint] ()
    var status : String?
    
    
    var canvasView: CanvasView!
    var drawPolygon: DrawPolygon!
    var modeSelected: Bool = false
    var isDrawing: Bool = false
    var t: UIGestureRecognizer!
    var gestureType: Gesture = .tap

    // Draw Menu
    @IBOutlet weak var drawStack: UIStackView!
    @IBOutlet weak var tapBtn: UIButton!
    @IBOutlet weak var rectBtn: UIButton!
    @IBOutlet weak var lineBtn: UIButton!
    @IBOutlet weak var polyBtn: UIButton!
    
    @IBOutlet weak var doneBtn: UIButton!
    
    @IBOutlet weak var menuBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Mainview Did Load")
        self.delegate = self
        self.mapView.tapEnabled = false
        self.view.addSubview(self.doneBtn)
        self.view.addSubview(self.menuBtn)
        self.doneBtn.isHidden = true
        self.drawStack.isHidden = true
        
        mapView.bringSubview(toFront: drawStack)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if status == "create" {createGeofence()}
        let testdata = DataHandler()
        testdata.getCoordinates(){
            place in
        
            if (place?.feature == nil) {
                self.feature.append(self.emptyFeature)
                self.annotation.append(nil)
                self.nameArray.append((place?.place?.name)!)
                self.urlArray.append((place?.place?.url)!)
                self.featureId.append(self.emptyID)
                
                if !((place?.place?.beacons?.isEmpty)!){
                    for beacon in (place?.place?.beacons)! {
                        self.beaconName.append(beacon.name!)
                    }
                } else {
                    self.beaconName.append("")
                }
                
            } else {
                self.feature.append((place?.feature)!)
                self.annotation.append((place?.annotation)!)
                self.nameArray.append((place?.place?.name)!)
                self.urlArray.append((place?.place?.url)!)
                
                if !((place?.place?.beacons?.isEmpty)!){
                    for beacon in (place?.place?.beacons)! {
                        self.beaconName.append(beacon.name!)
                    }
                } else {
                    self.beaconName.append("")
                }
                
                DispatchQueue.main.async {
                    self.mapView.add(place?.annotation)
                }
                self.mapView.add((place?.feature)!)
                self.featureId.append((place?.feature?.featureId)!)
                
            }
            if self.status == "update" { self.updateGeofence()}
        }
        
        mapView.reloadInputViews()
        
        //receiver of deletegeofence
        NotificationCenter.default.addObserver(self, selector: #selector(self.deleteGeofence(_:)), name: NSNotification.Name(rawValue: "deleteGeofence"), object: nil)
        print("Mainview will Appear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("Mainview did Appear")
        view.bringSubview(toFront: drawStack)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("Mainview did Disappear")
        self.status = ""
    }
    
    func mapViewControllerDidStart(_ controller: HDMMapViewController, error: Error?) {
        setupAfterMapLoad()
    }
    
    func mapViewController(_ controller: HDMMapViewController, tappedAt coordinate: HDMMapCoordinate, features: [HDMFeature]) {
        
        coordinateX.append(coordinate.x)
        coordinateY.append(coordinate.y)
    
        print(coordinateX.count)
        
    }
    
    func mapViewController(_ controller: HDMMapViewController, longPressedAt coordinate: HDMMapCoordinate, features: [HDMFeature]) {
        guard let f = features.first else {return}
        
        print("Selecting object with ID \(f.featureId)")
        print(featureId)
        print(features)
        print(annotation)
        
        if let index = self.featureId.index(of: f.featureId ){
            
            let alertController = UIAlertController(title: "Manage Geofence", message: "Do you wish to Update or Delete \(self.nameArray[index]) ?", preferredStyle: .alert)
            
            let updateAction = UIAlertAction(title: "Update", style: .default) { (_) in
                self.url = self.urlArray[index]
                
                let naviController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UpdateViewController") as? UpdateViewController
                
                naviController?.name = self.nameArray[index]
                naviController?.url = self.url!
                naviController?.beaconId = self.beaconName[index]
                
                self.navigationController?.pushViewController(naviController!, animated: true)
            }
            
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
                
                let data = DataHandler()
                data.deletePlace(self.urlArray[index], (self.nameArray[index]))
                
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
            self.addGestureListener()
            self.doneBtn.isHidden = false
            self.drawStack.isHidden = false
            self.menuBtn.isHidden = true
            
            
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
        let urlString = url! as String
        
        if let index = self.urlArray.index(of: urlString){
          
                urlIndex = index
                //alert user
                let alertController = UIAlertController(title: "Update Geofence", message: "Remove previous geofence to start update a new one?", preferredStyle: .alert)
                
                let confirmAction = UIAlertAction(title: "Yes", style: .default) { (_) in
                    if !(self.annotation[index] == nil) {
                        self.mapView.remove(self.annotation[index])
                        self.mapView.remove(self.feature[index])
                    } else {
                    }
                    self.feature.remove(at: index)
                    //allow user to draw geofence
                    self.mapView.tapEnabled = true
                    self.doneBtn.isHidden = false
                    
                    self.menuBtn.isHidden = true
                    //self.navigationController?.navigationBar.isUserInteractionEnabled = false
                }
                
                let cancelAction = UIAlertAction(title: "No", style: .cancel) { (_) in
                   
                }
                
                alertController.addAction(confirmAction)
                alertController.addAction(cancelAction)
            
            //if statement to stop UIAlertcontroller from calling multiple times
            if !(self.navigationController?.visibleViewController?.isKind(of: UIAlertController.self))! {
               self.present(alertController, animated: true, completion: nil)
            }

            }
    }
    
    //receiver function - deletegeofence
    @objc func deleteGeofence(_ notification: NSNotification){
        if let name = notification.userInfo?["name"] as? String{
            if let index = nameArray.index(of: name ){
                if !(self.annotation[index] == nil){
                    self.mapView.remove(self.annotation[index])
                    self.mapView.remove(self.feature[index])
                    print(self.feature[index])
                }
                urlArray.remove(at: index)
                nameArray.remove(at: index)
                annotation.remove(at: index)
                feature.remove(at: index)
                featureId.remove(at: index)
                beaconName.remove(at: index)
            }
        }
    }
    
    @IBAction func doneAction(_ sender: UIButton) {
        var points : [putPlace.Geofence.Points] = []
        var feat : HDMFeature
        
        if self.coordinateX.count == 0 || self.coordinateX.count == 1{
            var message : String?
            if self.coordinateX.count == 0 {message = "You have not mark any points on the map"}
            else if self.coordinateX.count == 1 {message = "You have only selected one point on the map"}
            let alertController = UIAlertController(title: "Not Enough Points Selected", message: message, preferredStyle: .alert)
            
            let confirmButton = UIAlertAction(title: "OK", style: .default) { (_) in
                    self.coordinateX.removeAll()
                    self.coordinateY.removeAll()
                // making sure canvasView is empty
                if self.canvasView != nil{
                    self.canvasView.removeFromSuperview()
                    self.canvasView = nil
                }
            }
            
            alertController.addAction(confirmButton)
            
            if !(self.navigationController?.visibleViewController?.isKind(of: UIAlertController.self))! {
                self.present(alertController, animated: true, completion: nil)
            }
        } else {
            //remember to assign new polygons to array
            let data = DataHandler()
            (feat,points) = data.drawPolygon(self.coordinateX,self.coordinateY)
            
            if status == "create"{
                  self.doneBtn.isHidden = true
                self.menuBtn.isHidden = false
                //send points to CreateView
                let naviController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateViewController") as? CreateViewController
                
                naviController?.points = points
                naviController?.status = "load"
                //self.navigationController?.popViewController(animated: false)
                self.navigationController?.pushViewController(naviController!, animated: true)
            }
            else if status == "update" {
            //assign new feature into feature array
            self.feature.insert(feat, at: urlIndex!)
                
            self.doneBtn.isHidden = true
                self.menuBtn.isHidden = false
            //send points to UpdateView
            let naviController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UpdateViewController") as? UpdateViewController
            
            naviController?.points = points
            naviController?.url = url!
            naviController?.status = "load"
            //self.navigationController?.popViewController(animated: false)
            self.navigationController?.pushViewController(naviController!, animated: true)
            }
        }
    }
    
    // Setup
    func setupAfterMapLoad() {
        // mapView.stopAllCameraAnimations()
        mapView.setFeatureStyle("poly", propertyName: "fill-color", value: "#e9bc00")
        mapView.reloadStyle()
        mapView.set3DMode(false, animated: false)
        mapView.setRegion(HDMMapCoordinateRegionMake(49.418397, 8.675501, 0, 0.000213, 0.000213), animated: false)
        // Map is too small thus zoom region not big enough
         //mapView.moveToFeature(withId: 19392, animated: false)
        
        // For user interaction
        mapView.rotateEnabled = false
        mapView.tiltEnabled = false
        mapView.bringSubview(toFront: drawStack)
        addGestureListener()
    }
    
    // Gesture Listener for tap effect
    func addGestureListener(){
        //For gesture respond
        if mapView.tapEnabled == true {
            t = UITapGestureRecognizer(target: self, action: #selector(tapEffectHandler))
            view.addGestureRecognizer(t)
        }
    }
    

    //    MARK:TAP effect
    @objc func tapEffectHandler(gesture: UITapGestureRecognizer) {
        
        // handle touch up/tap event
        if gesture.state == .ended {
            // temp make sure the tap is lower than the menu bar
            if gesture.location(in: mapView).y > 65.0 {
            let tap = gesture.location(in: mapView)
                // check number of points to make sure the rendered list is the same before appending
                if tapLocation.count > coordinateX.count{
                    //tapLocation.removeAll()
                }
            tapLocation.append(tap)
            print(tapLocation)
            
            // making sure canvasView is empty
            if canvasView != nil{
                canvasView.removeFromSuperview()
                canvasView = nil
            }
            // initialize the canvasView
            canvasView = CanvasView(frame: self.mapView.frame)
            self.view.addSubview(canvasView)
            print("Here")
            // drawing gesture feedback
            var prev = tapLocation.first
            for i in tapLocation {
                canvasView.addSubview(canvasView.createPointer(on: i))
                canvasView.drawLineFrom(fromPoint: prev!, toPoint: i)
                prev = i
            }
            canvasView.drawLineFrom(fromPoint: prev!, toPoint: tapLocation.first!)  //Enclose the polygon
            self.view.bringSubview(toFront: doneBtn)
            } else {
                mapView.tapEnabled = false
                dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func tapAction(_ sender: UIButton) {
        let oriImage = #imageLiteral(resourceName: "tap")
        mapView.tapEnabled = true
        addGestureListener()
        gestureType = .tap
        doneBtn.isHidden = false
        view.bringSubview(toFront: doneBtn)
        if(self.isDrawing == false) {
            prepareForDrawing(sender, gestureType)
        } else if(checkPoints()){
            prepareToEndDrawing(sender, gestureType, oriImage)
        }
    }
    
    @IBAction func rectAction(_ sender: UIButton) {
        let oriImage = #imageLiteral(resourceName: "rect")
        mapView.tapEnabled = false
        view.removeGestureRecognizer(t)
        gestureType = .rect
        if(self.isDrawing == false) {
            prepareForDrawing(sender, gestureType)
        } else if(checkPoints()){
            prepareToEndDrawing(sender, gestureType, oriImage)
        }
    }
    @IBAction func lineAction(_ sender: UIButton) {
        let oriImage = #imageLiteral(resourceName: "line")
        mapView.tapEnabled = false
        view.removeGestureRecognizer(t)
        gestureType = .line
        if(self.isDrawing == false) {
            prepareForDrawing(sender, gestureType)
        } else if(checkPoints()) {
            prepareToEndDrawing(sender, gestureType, oriImage)
        }
    }
    @IBAction func polyAction(_ sender: UIButton) {
        let oriImage = #imageLiteral(resourceName: "poly")
        mapView.tapEnabled = false
        view.removeGestureRecognizer(t)
        gestureType = .poly
        if(self.isDrawing == false) {
            prepareForDrawing(sender, gestureType)
        } else if(checkPoints()) {
            prepareToEndDrawing(sender, gestureType, oriImage)
        }
    }
    
    func prepareForDrawing(_ sender: UIButton, _ type: Gesture) {
        doneBtn.isHidden = true
        sender.self.setImage(#imageLiteral(resourceName: "done"), for: UIControlState.normal)
        sender.self.setTitle("Done", for: UIControlState.normal)
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        drawPolygon = DrawPolygon(frame: frame)
        drawPolygon.setCurrentMap(mapView: mapView)
        drawPolygon.setGesture(type)
        self.view.addSubview(drawPolygon)
        drawPolygon.canvasView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        self.view.bringSubview(toFront: drawStack)
        self.isDrawing = true
    }
    func prepareToEndDrawing(_ sender: UIButton, _ type: Gesture, _ oriImage: UIImage) {
        sender.self.setImage(oriImage, for: UIControlState.normal)
        sender.self.setTitle("Draw", for: UIControlState.normal)
        drawPolygon.removeFromSuperview()
        drawFinished()
        drawPolygon = nil
        self.isDrawing = false
    }
    
    // Finish drawing saving values before navigation
    func drawFinished(){
        let polyPoint = drawPolygon.pointSelector()
        prepareForNavigation(polyPoint)
    }
    
    // MARK: Can be optimize
    func checkPoints() -> Bool{
        let coordinates: [HDMMapCoordinate] = drawPolygon.coordinates as! [HDMMapCoordinate]
        if coordinates.count == 0 || coordinates.count == 1{
            var message : String?
            if coordinates.count == 0 {message = "Oh no! you need to draw something!"}
            else if coordinates.count == 1 {message = "There is only one point on the map"}
            let alertController = UIAlertController(title: "Not Enough Points Selected", message: message, preferredStyle: .alert)
            
            let confirmButton = UIAlertAction(title: "OK", style: .default) { (_) in
                self.drawPolygon.clear()
            }
            print("Not success")
            alertController.addAction(confirmButton)
            
            if !(self.navigationController?.visibleViewController?.isKind(of: UIAlertController.self))! {
                self.present(alertController, animated: true, completion: nil)
            }
            return false
        }
        return true
    }
    
    func prepareForNavigation(_ cPoints: [HDMPoint]){
        var points : [putPlace.Geofence.Points] = []
        var feat : HDMFeature
        // Double Check
        if cPoints.count == 0 || cPoints.count == 1{
            var message : String?
            if cPoints.count == 0 {message = "You have not mark any points on the map"}
            else if cPoints.count == 1 {message = "You have only selected one point on the map"}
            let alertController = UIAlertController(title: "Not Enough Points Selected", message: message, preferredStyle: .alert)
            
            let confirmButton = UIAlertAction(title: "OK", style: .default) { (_) in
                // Add Action after complete
            }
            alertController.addAction(confirmButton)
            
            if !(self.navigationController?.visibleViewController?.isKind(of: UIAlertController.self))! {
                self.present(alertController, animated: true, completion: nil)
            }
        } else {
            //remember to assign new polygons to array
            let data = DataHandler()
            (self.coordinateX , self.coordinateY) = CoordinateHandler.castPointsToXY(pointsXY: cPoints)
            (feat,points) = data.drawPolygon(self.coordinateX , self.coordinateY)
            if status == "create"{
                self.doneBtn.isHidden = true
                self.drawStack.isHidden = true
                self.menuBtn.isHidden = false
                //send points to CreateView
                let naviController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateViewController") as? CreateViewController
                
                naviController?.points = points
                naviController?.status = "load"
                //self.navigationController?.popViewController(animated: false)
                self.navigationController?.pushViewController(naviController!, animated: true)
            }
            else if status == "update" {
                //assign new feature into feature array
                self.feature.insert(feat, at: urlIndex!)
                
                self.doneBtn.isHidden = true
                self.drawStack.isHidden = true
                self.menuBtn.isHidden = false
                //send points to UpdateView
                let naviController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UpdateViewController") as? UpdateViewController
                
                naviController?.points = points
                naviController?.url = url!
                naviController?.status = "load"
                //self.navigationController?.popViewController(animated: false)
                self.navigationController?.pushViewController(naviController!, animated: true)
            }
        }
    }
    
}
