//
//  DrawPolygon.swift
//  mkmap
//
//  Created by Lee Kuan Xin on 02.10.17.
//  Copyright © 2017 HDMI. All rights reserved.
//

import UIKit
import HDMMapCore

struct LocationBounds {
    var minLatitude = 0.0
    var maxLatitude = 0.0
    var minLongitude = 0.0
    var maxLongitude = 0.0
}

enum gesture {
    case tap
    case rect
    case line
    case poly
}

class DrawPolygon: UIView {

    // MARK: Varibles
    var dragArea: UIView!
    var dragAreaBounds: CGRect = CGRect.zero
    var isDrawing: Bool!
    var firstPoint: CGPoint = CGPoint.zero
    var mapView: HDMMapView!
    var canvasView = CanvasView(frame: CGRect.zero)
    var gestureType: Int = 1
    
    // Accumulate coordinates
    var coordinates = [Any]()
    var renderCoordinates = [Any]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        canvasView.frame = frame
    }
 
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    
    func initialize() {
        isDrawing = false
        dragAreaBounds = CGRect(x: 0, y: 0, width: 0, height: 0)
        isUserInteractionEnabled = true
        isMultipleTouchEnabled = false
        //backgroundColor = UIColor.clear
        isOpaque = false
        autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    // Set mapViewInstance from calling class
    func setCurrentMap(mapView :HDMMapView) {
        self.mapView = mapView
    }
    
    func gesturePicker(_ type: Int = 1) {
        gestureType = type
    }
    
    
    // No matter how many point the function only create geofence/rect from first and last point
    func rectTwoPoint(_ coordinates: [HDMMapCoordinate]) -> [HDMPoint]? {
        if (coordinates.count < 2) {
            return nil
        }
        let z = CoordinateHandler.getHighestZ(coordinates)
        let coordinate1: HDMMapCoordinate = coordinates[0]
        let coordinate2 = HDMMapCoordinateMake(coordinates[0].x, (coordinates.last?.y)!, z)
        let coordinate3 = coordinates.last!
        let coordinate4 = HDMMapCoordinateMake((coordinates.last?.x)!, coordinates[0].y, z)
        let coordinate5: HDMMapCoordinate = coordinates[0]
        //var newCoords = [HDMMapCoordinate]()
        var points = [HDMPoint]()
        points.append(contentsOf: CoordinateHandler.getPointsForCoordinate([coordinate1, coordinate2, coordinate3, coordinate4, coordinate5]))
        return points
    }
    
    
    // prepare points for geofence/rect by taking max bounds
    func rectMaxSpan(_ coordinates: [HDMMapCoordinate]) -> [HDMPoint]? {
        if (coordinates.count < 2) {
            return nil
        }
        var bounds = LocationBounds()
        let z = CoordinateHandler.getHighestZ(coordinates)
        
        bounds.minLongitude = coordinates[0].x
        bounds.minLatitude = coordinates[0].y
        bounds.maxLongitude = coordinates[0].x
        bounds.maxLatitude = coordinates[0].y
        
        for coordinate in coordinates {
            if coordinate.x < bounds.minLongitude {bounds.minLongitude = coordinate.x}
            if coordinate.y < bounds.minLatitude {bounds.minLatitude = coordinate.y}
            if coordinate.x > bounds.maxLongitude {bounds.maxLongitude = coordinate.x}
            if coordinate.y > bounds.maxLatitude {bounds.maxLatitude = coordinate.y}
            print("polygon points")
            print(coordinate)
        }
        
        var coords = [HDMMapCoordinate]()
        coords.append(HDMMapCoordinateMake(bounds.minLongitude, bounds.minLatitude, z))
        coords.append(HDMMapCoordinateMake(bounds.maxLongitude, bounds.minLatitude, z))
        coords.append(HDMMapCoordinateMake(bounds.maxLongitude, bounds.maxLatitude, z))
        coords.append(HDMMapCoordinateMake(bounds.minLongitude, bounds.maxLatitude, z))
        coords.append(HDMMapCoordinateMake(bounds.minLongitude, bounds.minLatitude, z))
        
        print("final point")
        print(coords)
        var points = [HDMPoint]()
        points.append(contentsOf: CoordinateHandler.getPointsForCoordinate(coords))
        return points
    }
    
    func createGeoFence(points: [HDMPoint]) -> (HDMPolygonFeature){
        
        let poly: HDMPolygon = HDMPolygon(points: points)
        let z = CoordinateHandler.getHighestZ(points)
        print(z)
        let polyFeature: HDMPolygonFeature = HDMPolygonFeature(polygon: poly, featureType: "poly", zmin: Float(z+3), zmax: Float(z+3.1))
        mapView.add(polyFeature)
        print(polyFeature.featureId)
        return polyFeature
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //if(self.isDrawing == false) {
            self.isDrawing = true;
            coordinates.removeAll()
            canvasView.frame = self.frame
            canvasView.backgroundColor = canvasView.bgcColor
            self.addSubview(canvasView)
            //self.canvasView.backgroundColor = canvasView.bgcColor
            //print("Added")
            //canvasView.drawBegan(touches, with: event)
        //}
        //print("Not Added")
        let temp: HDMMapCoordinate = CoordinateHandler.getCoordinateForTouch(touches.first!, mapView)
        coordinates.append(temp)
        let curPoint = touches.first!.location(in: self)
        renderCoordinates.append(curPoint)
        //print("began")
        //print(temp)
        createDrag(touches.first!)
        //createDragArea(touches.first!)
        //createDragArea2(touches.first!)
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if(canvasView.firstPoint == nil){
                canvasView.touchesBegan(touches, with: event)
                let temp: HDMMapCoordinate = CoordinateHandler.getCoordinateForTouch(touches.first!, mapView)
                coordinates.append(temp)
                firstPoint = touch.location(in: self)
                
            }
            //canvasView.drawMoved(touches, with: event)
            canvasView.touchesMoved(touches, with: event)
            //let _: HDMMapCoordinate = CoordinateHandler.getCoordinateForTouch(touch, mapView)
            let curPoint = touches.first!.location(in: self)
            renderCoordinates.append(curPoint)
             createDrag(touches.first!)
            //createDragArea(touches.first!)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // get real world coordinates for later drawing on the map
        //let coordinate: CLLocationCoordinate2D = getCoordinateForTouch(touch)
        //coordinates.append(NSValue(mkCoordinate: coordinate))
        if touches.first != nil {
            //canvasView.drawEnded(touches, with: event)
           canvasView.touchesEnded(touches, with: event)
            let temp: HDMMapCoordinate = CoordinateHandler.getCoordinateForTouch(touches.first!, mapView)
            coordinates.append(temp)
            let curPoint = touches.first!.location(in: self)
            renderCoordinates.append(curPoint)
            //print(coordinates)
            //reset()
            createDrag(touches.first!)
            //createDragArea(touches.first!)
            renderPoly()
        }
    
    }
    
    func createDrag(_ touch: UITouch) {
        
        
        if dragArea != nil{
            
            dragArea.removeFromSuperview()
            dragArea = nil
            self.setNeedsDisplay()
        }
        let newDragPoints = renderMaxSpan(renderCoordinates as! [CGPoint])
        //print(newDragPoints)
        print(renderCoordinates)
        if renderCoordinates.count > 4{
            let height = abs(newDragPoints![3].y - newDragPoints![0].y)
            let width = abs(newDragPoints![1].x - newDragPoints![0].x)
//            dragAreaBounds.origin =  (newDragPoints![3])
            let oriX = newDragPoints![3].x
            let oriY = newDragPoints![3].y
            let aHeight = height
            let aWidth = width
            let area = UIView(frame: CGRect.init(x: oriX, y: oriY, width: aHeight, height: aWidth))
            area.backgroundColor = UIColor.blue
            //area.isOpaque = false
            area.alpha = 0.3
            //area.isUserInteractionEnabled = false
            dragArea = area
            self.addSubview(dragArea!)
            print("bound")
            print(dragArea.frame)
        }


        
        if dragArea == nil {
            let area = UIView(frame: dragAreaBounds)
            area.backgroundColor = UIColor.blue
            //area.isOpaque = false
            area.alpha = 0.3
            //area.isUserInteractionEnabled = false
            dragArea = area
            self.addSubview(dragArea!)
        }
//        else {
//            dragArea?.frame = dragAreaBounds
//        }
            //setNeedsDisplay()
    }
    
    func createDragArea(_ touch: UITouch) {
        //        if coordinates.count < 2 {
        //            return
        //        }
        //let location: CGPoint = touch.location(in: self)
        dragAreaBounds.origin = touch.location(in: self)
        dragAreaBounds.size.height = firstPoint.y - (dragAreaBounds.origin.y)
        dragAreaBounds.size.width = firstPoint.x - (dragAreaBounds.origin.x)
        if dragArea == nil {
            let area = UIView(frame: dragAreaBounds)
            area.backgroundColor = UIColor.blue
            //area.isOpaque = false
            area.alpha = 0.3
            //area.isUserInteractionEnabled = false
            dragArea = area
            self.addSubview(dragArea!)
        }
        else {
            dragArea?.frame = dragAreaBounds
        }
    }
    
    func dragPoly() {
        
    }
    
    func renderPoly() {
        canvasView.clear()
        let newPoints = renderTwoPoint(renderCoordinates as! [CGPoint])
        var prev = newPoints?.first
        for i in newPoints!{
            canvasView.drawLineFrom(fromPoint: prev!, toPoint: i )
            prev = i
        }
        renderCoordinates.removeAll()
    }
    
    
    // No matter how many point the function only create geofence/rect from first and last point
    func renderTwoPoint(_ coordinates: [CGPoint]) -> [CGPoint]? {
        if (coordinates.count < 2) {
            return nil
        }
        let coordinate1: CGPoint = coordinates[0]
        let coordinate2 = CGPoint(x: (coordinates.first?.x)!, y: (coordinates.last?.y)!)
        let coordinate3 = coordinates.last!
        let coordinate4 = CGPoint(x: (coordinates.last?.x)!, y: (coordinates.first?.y)!)
        //var newCoords = [HDMMapCoordinate]()
        var points = [CGPoint]()
        points.append(contentsOf: [coordinate1, coordinate2, coordinate3, coordinate4, coordinate1])
        return points
    }
    
    
    // prepare points for geofence/rect by taking max bounds
    func renderMaxSpan(_ coordinates: [CGPoint]) -> [CGPoint]? {
        if (coordinates.count < 2) {
            return nil
        }
        var bounds = LocationBounds()
        
        bounds.minLongitude = Double(coordinates[0].x)
        bounds.minLatitude = Double(coordinates[0].y)
        bounds.maxLongitude = Double(coordinates[0].x)
        bounds.maxLatitude = Double(coordinates[0].y)
        
        for coordinate in coordinates {
            if Double(coordinate.x) < bounds.minLongitude {bounds.minLongitude = Double(coordinate.x)}
            if Double(coordinate.y) < bounds.minLatitude {bounds.minLatitude = Double(coordinate.y)}
            if Double(coordinate.x) > bounds.maxLongitude {bounds.maxLongitude = Double(coordinate.x)}
            if Double(coordinate.y) > bounds.maxLatitude {bounds.maxLatitude = Double(coordinate.y)}
            //print("polygon points")
            //print(coordinate)
        }
        
        var coords = [CGPoint]()
        coords.append(CGPoint(x: bounds.minLongitude, y: bounds.minLatitude))
        coords.append(CGPoint(x: bounds.maxLongitude, y: bounds.minLatitude))
        coords.append(CGPoint(x: bounds.maxLongitude, y: bounds.maxLatitude))
        coords.append(CGPoint(x: bounds.minLongitude, y: bounds.maxLatitude))
        coords.append(CGPoint(x: bounds.minLongitude, y: bounds.minLatitude))
        
        //print("final point")
        //print(coords)
        return coords
    }
}

