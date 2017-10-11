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

    //variable to keep track of the geofence
    var feature : [HDMFeature] = []
    var emptyFeature = HDMFeature()
    var featureId : [UInt64] = []
    let emptyID = UInt64()
    var annotation : [HDMAnnotation?] = []
    var nameArray = [String] ()
    var urlArray = [String] ()
    var beaconName : [String] = []
    
    //variable for drawings and coordinates
    var coordinateX = [Double] ()
    var coordinateY = [Double] ()
    var tapLocation = [CGPoint] ()
    var canvasView: CanvasView!
    var drawPolygon: DrawPolygon!
    
    //standalone variables for specific usage
    var status : String? //to obtain status of the app's flow
    var url : String? //to obtain specific url from other classes
    var urlIndex : Int? //to act as a specific index for the array
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
    
    @IBOutlet weak var menuBtn: UIButton!
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue){
        if let origin = segue.source as? UpdateViewController {
            status = origin.status
            url = origin.urlMain
        }
        if let origin = segue.source as? CreateViewController {
            status = origin.status
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Mainview Did Load")
        self.delegate = self
        self.mapView.tapEnabled = false
        self.view.addSubview(self.menuBtn)
        self.drawStack.isHidden = true
        
        mapView.bringSubview(toFront: drawStack)
        
        //observer of confirmCreate
        NotificationCenter.default.addObserver(self, selector: #selector(self.confirmCreate(_:)), name: NSNotification.Name(rawValue: "confirmCreate"), object: nil)
        //observer of confirmUpdate
        NotificationCenter.default.addObserver(self, selector: #selector(self.confirmUpdate(_:)), name: NSNotification.Name(rawValue: "confirmUpdate"), object: nil)
        //observer of deletegeofence
        NotificationCenter.default.addObserver(self, selector: #selector(self.deleteGeofence(_:)), name: NSNotification.Name(rawValue: "deleteGeofence"), object: nil)
        //observer of alertController
        NotificationCenter.default.addObserver(self, selector: #selector(self.deleteGeofence(_:)), name: NSNotification.Name(rawValue: "alertError"), object: nil)
        
        //Import data from Gimbal Server
        let testdata = DataHandler()
        testdata.getBeacon(){
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
            self.getData(self.urlArray)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if status == "create" {createGeofence()}
        if status == "update" {updateGeofence()}
        mapView.reloadInputViews()
        
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
        self.mapView.tapEnabled = false
        self.coordinateX.removeAll()
        self.coordinateY.removeAll()
        if self.canvasView != nil{
            self.canvasView.removeFromSuperview()
            self.canvasView.image = nil
            self.canvasView = nil
            self.tapLocation.removeAll()
            self.view.removeGestureRecognizer(t)
        }

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
            //refresh tapCoordinates
            self.coordinateX.removeAll()
            self.coordinateY.removeAll()
            if self.canvasView != nil{
                self.canvasView.removeFromSuperview()
                self.canvasView.image = nil
                self.canvasView = nil
                self.tapLocation.removeAll()
            }
            
            self.drawStack.isHidden = false
            self.tapBtn.isHidden = false
            self.rectBtn.isHidden = false
            self.lineBtn.isHidden = false
            self.polyBtn.isHidden = false
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
                let alertController = UIAlertController(title: "Update Geofence", message: "Start updating geofence?", preferredStyle: .alert)
                
                let confirmAction = UIAlertAction(title: "Yes", style: .default) { (_) in
                    self.coordinateX.removeAll()
                    self.coordinateY.removeAll()
                    if self.canvasView != nil{
                        self.canvasView.removeFromSuperview()
                        self.canvasView.image = nil
                        self.canvasView = nil
                        self.tapLocation.removeAll()
                    }
                    
                    DispatchQueue.main.async {
                        self.mapView.remove(self.annotation[index])
                        self.mapView.remove(self.feature[index])
                    }
                    
                    //allow user to draw geofence
                    self.drawStack.isHidden = false
                    self.tapBtn.isHidden = false
                    self.rectBtn.isHidden = false
                    self.lineBtn.isHidden = false
                    self.polyBtn.isHidden = false
                    self.menuBtn.isHidden = true
                }
                
                alertController.addAction(confirmAction)
            
            //if statement to stop UIAlertcontroller from calling multiple times
            if !(self.navigationController?.visibleViewController?.isKind(of: UIAlertController.self))! {
               self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    //receiver function - confirmCreate
    @objc func confirmCreate(_ notification: NSNotification){
        if let name = notification.userInfo?["name"] as? String{
            
            let getData = DataHandler()
            getData.getBeacon(){
                place in
                if (name.isEqual(place?.place?.name)){
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
                    self.printVar()
                }
            }
        }
    }
    
    //receiver function - confirmUpdate
    @objc func confirmUpdate(_ notification: NSNotification){
        if let url = notification.userInfo?["url"] as? String{
            if let index = urlArray.index(of: url){
                
                let getData = DataHandler()
                getData.getBeacon(){
                    place in
                    
                    if (url == place?.place?.url){
                        self.nameArray[index] = (place?.place?.name)!
                        self.feature[index] = (place?.feature)!
                        self.annotation[index] = (place?.annotation)!
                        if !((place?.place?.beacons?.isEmpty)!){
                            for beacon in (place?.place?.beacons)! {
                                self.beaconName[index] = beacon.name!
                            }
                        } else {
                            self.beaconName[index] = ""
                        }
                        DispatchQueue.main.async {
                            self.mapView.add(place?.annotation)
                        }
                        self.mapView.add((place?.feature)!)
                        self.featureId[index] = (place?.feature?.featureId)!
                        self.printVar()
                    }
                }
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
    
    //receiver function - deletegeofence
    @objc func alertError(_ notification: NSNotification){
        let alertController = UIAlertController(title: "Error", message: "Error uploading to server, please try again.", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "OK", style: .default) { (_) in}
        
        alertController.addAction(confirmAction)
        
        //if statement to stop UIAlertcontroller from calling multiple times
        if !(self.navigationController?.visibleViewController?.isKind(of: UIAlertController.self))! {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    //get url from completion handler to be use in MAIN
    func getData(_ url : [String]){
        urlArray = url
    }
    
    //Used for keeping track of array counts and checking behaviour of the datasets after each operation
    func printVar(){
        print("feature:\(self.feature.count)")
        print("url:\(self.urlArray.count)")
        print("annotation:\(self.annotation.count)")
        print("beacon:\(self.beaconName.count)")
        print("fid:\(self.featureId.count)")
        print("name:\(self.nameArray.count)")
    }
    
    // Setup
    func setupAfterMapLoad() {
        // mapView.stopAllCameraAnimations()
        mapView.setFeatureStyle("poly", propertyName: "fill-color", value: "#e9bc00")
        mapView.reloadStyle()
        mapView.set3DMode(false, animated: false)
        //mapView.setRegion(HDMMapCoordinateRegionMake(49.418397, 8.675501, 0, 0.000213, 0.000213), animated: false)
        // Map is too small thus zoom region not big enough
         mapView.moveToFeature(withId: 19392, animated: false)
        
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
            // drawing gesture feedback
            var prev = tapLocation.first
            for i in tapLocation {
                canvasView.addSubview(canvasView.createPointer(on: i))
                canvasView.drawLineFrom(fromPoint: prev!, toPoint: i)
                prev = i
            }
            canvasView.drawLineFrom(fromPoint: prev!, toPoint: tapLocation.first!)  //Enclose the polygon
            } else {
                mapView.tapEnabled = false
                dismiss(animated: true, completion: nil)
            }
        }
    }

    @IBAction func tapAction(_ sender: UIButton) {
        let oriImage = #imageLiteral(resourceName: "tap")
        lineBtn.isHidden = true
        rectBtn.isHidden = true
        polyBtn.isHidden = true
        if !(t == nil){view.removeGestureRecognizer(t)}
        DispatchQueue.main.async {
            self.mapView.tapEnabled = true
            self.addGestureListener()
            self.gestureType = .tap
        }

        if(self.isDrawing == false) {
            prepareForDrawing(sender, gestureType)
        } else{
            var points : [putPlace.Geofence.Points] = []
            
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
                        self.canvasView.image = nil
                        self.canvasView = nil
                        self.tapLocation.removeAll()
                    }
                }
                
                alertController.addAction(confirmButton)
                
                if !(self.navigationController?.visibleViewController?.isKind(of: UIAlertController.self))! {
                    self.present(alertController, animated: true, completion: nil)
                }
            } else {
                //remember to assign new polygons to array
                let data = DataHandler()
                (points) = data.getPoints(self.coordinateX,self.coordinateY)
                
                if status == "create"{
                    prepareToEndDrawingTap(sender, gestureType, oriImage)
                    self.menuBtn.isHidden = false
                    
                    //send points to CreateView
                    let naviController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateViewController") as? CreateViewController
                    
                    naviController?.points = points
                    naviController?.status = "load"
                    
                    self.navigationController?.pushViewController(naviController!, animated: true)
                }
                else if status == "update" {
                    prepareToEndDrawingTap(sender, gestureType, oriImage)
                    self.menuBtn.isHidden = false
                    //send points to UpdateView
                    let naviController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UpdateViewController") as? UpdateViewController
                    
                    naviController?.points = points
                    naviController?.url = url!
                    naviController?.status = "load"
                    
                    self.navigationController?.pushViewController(naviController!, animated: true)
                    
                }
            }
        }
    }
    
    @IBAction func rectAction(_ sender: UIButton) {
        let oriImage = #imageLiteral(resourceName: "rect")
        lineBtn.isHidden = true
        tapBtn.isHidden = true
        polyBtn.isHidden = true
        mapView.tapEnabled = false
        if !(t == nil){view.removeGestureRecognizer(t)}
        gestureType = .rect
        if(self.isDrawing == false) {
            prepareForDrawing(sender, gestureType)
        } else if(checkPoints()){
            prepareToEndDrawing(sender, gestureType, oriImage)
        }
    }
    @IBAction func lineAction(_ sender: UIButton) {
        let oriImage = #imageLiteral(resourceName: "line")
        tapBtn.isHidden = true
        rectBtn.isHidden = true
        polyBtn.isHidden = true
        mapView.tapEnabled = false
        if !(t == nil){view.removeGestureRecognizer(t)}
        gestureType = .line
        if(self.isDrawing == false) {
            prepareForDrawing(sender, gestureType)
        } else if(checkPoints()) {
            prepareToEndDrawing(sender, gestureType, oriImage)
        }
    }
    @IBAction func polyAction(_ sender: UIButton) {
        let oriImage = #imageLiteral(resourceName: "poly")
        lineBtn.isHidden = true
        rectBtn.isHidden = true
        tapBtn.isHidden = true
        mapView.tapEnabled = false
        if !(t == nil){view.removeGestureRecognizer(t)}
        gestureType = .poly
        if(self.isDrawing == false) {
            prepareForDrawing(sender, gestureType)
        } else if(checkPoints()) {
            prepareToEndDrawing(sender, gestureType, oriImage)
        }
    }
    
    func prepareForDrawing(_ sender: UIButton, _ type: Gesture) {
        sender.self.setImage(#imageLiteral(resourceName: "done"), for: UIControlState.normal)
        sender.self.setTitle("Done", for: UIControlState.normal)
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        if ( type == .tap) {
        }else{
            drawPolygon = DrawPolygon(frame: frame)
            drawPolygon.setCurrentMap(mapView: mapView)
            drawPolygon.setGesture(type)
            self.view.addSubview(drawPolygon)
            drawPolygon.canvasView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        }
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
    
    func prepareToEndDrawingTap(_ sender: UIButton, _ type: Gesture, _ oriImage: UIImage) {
        sender.self.setImage(oriImage, for: UIControlState.normal)
        sender.self.setTitle("Draw", for: UIControlState.normal)
        self.isDrawing = false
        self.drawStack.isHidden = true
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
            (points) = data.getPoints(self.coordinateX , self.coordinateY)
            if status == "create"{
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
