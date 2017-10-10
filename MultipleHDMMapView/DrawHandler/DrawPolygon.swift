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

enum Gesture: Int {
    case tap = 0
    case rect = 1
    case line = 2
    case poly = 3
}

class DrawPolygon: UIView {

    // MARK: Varibles
    var dragArea: UIView!
    var dragAreaBounds: CGRect = CGRect.zero
    var isDrawing: Bool!
    var firstPoint: CGPoint = CGPoint.zero
    var mapView: HDMMapView!
    var canvasView = CanvasView(frame: CGRect.zero)
    var gestureType: Gesture = .tap
    
    // Accumulate coordinates
    var coordinates = [Any]() // coordinates for parser AKA. HDMMap
    var renderCoordinates = [Any]() // coordinates for visual feedback AKA. UIView
    
    
    // MARK: Initializer
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
    
    // MARK: Compulsary Variable
    // Set mapViewInstance from calling class
    func setCurrentMap(mapView :HDMMapView) {
        self.mapView = mapView
    }
    
    // Set the Gesture type
    func setGesture(_ type: Gesture) {
        self.gestureType = type
    }
    
    
    
    // MARK: Point Processor
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
    
    
    // MARK: Touch gesture
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //reset()
        //if(self.isDrawing == false) {
            self.isDrawing = true;
            coordinates.removeAll()
            canvasView.frame = self.frame
            canvasView.backgroundColor = canvasView.bgcColor
            self.addSubview(canvasView)
        //}
        appendingPoints(touches)
        createDrag(touches.first!)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if(canvasView.firstPoint == nil){
                canvasView.touchesBegan(touches, with: event)
                firstPoint = touch.location(in: self)
            }
            canvasView.touchesMoved(touches, with: event)
            appendingPoints(touches)
            createDrag(touches.first!)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first != nil {
            //canvasView.drawEnded(touches, with: event)
            canvasView.touchesEnded(touches, with: event)
            appendingPoints(touches)
            createDrag(touches.first!)
            renderPoly()
        }
    
    }
    
    func appendingPoints(_ touches: Set<UITouch>) {
        let temp: HDMMapCoordinate = CoordinateHandler.getCoordinateForTouch(touches.first!, mapView)
        coordinates.append(temp)
        
        let curPoint = touches.first!.location(in: self)
        renderCoordinates.append(curPoint)
        createDrag(touches.first!)
    }
    
    // MARK: Rendering drag feedback
    func createDrag(_ touch: UITouch) {
        switch gestureType {
        case .rect:
            pointDrag(touch)
        case .line:
            spanDrag(touch)
        default:
            break
        }
    }
    
    func pointDrag(_ touch: UITouch){
        if coordinates.count < 2 {
            return
        }
        let location: CGPoint = touch.location(in: self)
        dragAreaBounds.origin = location
        dragAreaBounds.size.height = firstPoint.y - (dragAreaBounds.origin.y)
        dragAreaBounds.size.width = firstPoint.x - (dragAreaBounds.origin.x)
        if dragArea == nil {
            let area = UIView(frame: dragAreaBounds)
            area.backgroundColor = UIColor.blue
            area.alpha = 0.3
            area.isUserInteractionEnabled = false
            dragArea = area
            self.addSubview(dragArea!)
        }
        else {
            dragArea?.frame = dragAreaBounds
        }
    }
    
    // Need to re-render each time value change
    func spanDrag(_ touch: UITouch) {
        // Always Make sure dragArea is not available
        if dragArea != nil{
            resetDrag()
        }
        let newDragPoints = renderMaxSpan(renderCoordinates as! [CGPoint])
        //print(newDragPoints)
        print(renderCoordinates)
        if renderCoordinates.count > 4{
            let oriX = newDragPoints![0].x
            let oriY = newDragPoints![0].y
            let width = abs(newDragPoints![1].x - newDragPoints![0].x)
            let height = abs(newDragPoints![3].y - newDragPoints![0].y)

            let area = UIView(frame: CGRect.init(x: oriX, y: oriY, width: width, height: height))
            area.backgroundColor = UIColor.blue
            area.alpha = 0.3
            area.isUserInteractionEnabled = false
            dragArea = area
            self.addSubview(dragArea!)
        }
    }
    
    func polyDrag() {
        
    }
    
    func resetDrag() {
        dragArea.removeFromSuperview()
        dragArea = nil
        self.setNeedsDisplay()
    }
    
    // MARK: Rendering Polygon Display
    func renderPoly() {
        // Make sure display is unavailable
        canvasView.clear()
        let renderPoints: [CGPoint] = renderCoordinates as! [CGPoint]
        var newPoints = [CGPoint]()
        switch gestureType {
            case .rect:
                newPoints = renderTwoPoint(renderPoints)!
            case .line:
                newPoints = renderMaxSpan(renderPoints)!
            case .poly:
                newPoints = renderCoordinates as! [CGPoint]
                newPoints.append(newPoints.first!)
            default:
                break
        }
        var prev = newPoints.first
        for i in newPoints{
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

