//
//  CoordinateHandler.swift
//  MultipleHDMMapView
//
//  Created by Lee Kuan Xin on 06.10.17.
//  Copyright © 2017 HDMI. All rights reserved.
//

import HDMMapCore
import CoreLocation

class CoordinateHandler {
    
    //var mapView: HDMMapView!
    
    // single Point conversion
    static func getCoordinateForTouch(_ touch: UITouch,_ mapView: HDMMapView)->(HDMMapCoordinate)   {
        var location: CGPoint = touch.location(in: mapView)
        location.x *= mapView.contentScaleFactor
        location.y *= mapView.contentScaleFactor
        let mapLocation: HDMLocation = mapView.getLocationOnMap(from: Float(location.x), screenPointY: Float(location.y))
        //let coordinate: CLLocationCoordinate2D = castToLatLong(coordXYZ: mapLocation.coordinate)
        //let coordinate: CLLocationCoordinate2D? = coordinator.convert(location, toCoordinateFrom: coordinator)
        return mapLocation.coordinate
    }
    
    static func getCoordinateForTouches(_ touches: [UITouch],_ mapView: HDMMapView)->([HDMMapCoordinate])   {
        var coordinates = [HDMMapCoordinate]()
        for touch in touches{
            coordinates.append(getCoordinateForTouch(touch, mapView))
        }
        return coordinates
    }
    
    static func getPointsForCoordinate(_ coordinates: [HDMMapCoordinate])->([HDMPoint])   {
        var points = [HDMPoint]()
        var point: HDMPoint
        for coordinate in coordinates{
            point = HDMPoint(coordinate)
            points.append(point)
        }
        return points
    }
    
    static func getHighestZ(_ points: [HDMPoint]) -> Double{
        var highestZ: Double = (points.first?.coordinate.z)!
        for point in points{
            if point.coordinate.z >= highestZ {
                highestZ = point.coordinate.z
            }
        }
        return highestZ
    }
    
    static func getHighestZ(_ coordinates: [HDMMapCoordinate]) -> Double{
        var highestZ: Double = coordinates.first!.z
        for coordinate in coordinates{
            if coordinate.z >= highestZ {
                highestZ = coordinate.z
            }
        }
        return highestZ
    }
    
    static func castToLatLong(coordXYZ: HDMMapCoordinate) -> (CLLocationCoordinate2D, Double) {
        let coordXY = CLLocationCoordinate2DMake(coordXYZ.x, coordXYZ.y)
        let coordZ = coordXYZ.z
        return (coordXY, coordZ)
    }
    
    static func castPointsToXY(pointsXY: [HDMPoint]) -> ([Double], [Double]) {
        var pointsX = [Double]()
        var pointsY = [Double]()
        for i in pointsXY {
            pointsX.append(Double(i.coordinate.x))
            pointsY.append(Double(i.coordinate.y))
        }
        return (pointsX, pointsY)
    }
}
