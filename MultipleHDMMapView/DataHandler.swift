//
//  DataHandler.swift
//  MultipleHDMMapView
//
//  Created by Tan Chung Shzen on 22.09.17.
//  Copyright © 2017 HDMI. All rights reserved.
//

import UIKit
import HDMMapCore

class DataHandler : HDMMapViewController, HDMMapViewControllerDelegate {

    let headers = [
        "authorization": "Token token=d56d21be74f8c2256190b681ad43d9f8",
        "content-type": "application/json",
        "cache-control": "no-cache",
        "postman-token": "0017962a-2bc2-cbe3-c65b-38acad6be8da"
    ]
    
    func getPlaceId(completionHandler: @escaping ([String]?)-> Void) {
        
        var placeId : [String] = []
        let urlGimbal = "https://manager.gimbal.com/api/v2/places/"
        
        let url = URL(string: urlGimbal)
        
        var request = URLRequest(url: url!)
        
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = self.headers
        
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            guard error == nil else {
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                let places = try decoder.decode([Place].self, from: responseData)
                for place in places{
                    placeId.append(place.id)
                }
                completionHandler(placeId)
            } catch {
                print("error trying to convert data to JSON")
                print(error)
            }
        })
        
        task.resume()
    }
    
    func getCoordinates(completionHandler: @escaping (beaconData?) -> Void) {
        
        getPlaceId(){ (placeId) in
            
        for place in placeId!{
            var longitude : [Double] = []
            var latitude : [Double] = []
            
            
            let url = "https://manager.gimbal.com/api/v2/places/" + String(place)
            
            let request = NSMutableURLRequest(url: NSURL(string: url)! as URL,
                                              cachePolicy: .useProtocolCachePolicy,
                                              timeoutInterval: 10.0)
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = self.headers
            
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                
                guard let responseData = data else {
                    print("Error: did not receive data")
                    return
                }
                guard error == nil else {
                    return
                }
                
                let decoder = JSONDecoder()
                do {
                    var beacon = try decoder.decode(getPlace.self, from: responseData)
                    
                    beacon.url = String(place)
                    
                    if (beacon.geofence?.points != nil){
                        let arrays = beacon.geofence?.points
                        for array in arrays!{
                            longitude.append(array.longitude!)
                            latitude.append(array.latitude!)
                        }
                        
                        let coordinate = HDMMapCoordinateMake(longitude[0], latitude[0], 0)
                        
                        var ring0 : [Any] = []
                        
                        for (x,y) in zip(longitude,latitude){
                            ring0.append(HDMPoint.init(x, y: y, z: 0))
                        }
                        
                        ring0.append(HDMPoint.init(longitude[0], y: latitude[0], z: 0))
                        
                        let poly = HDMPolygon.init(points: ring0 as! [HDMPoint])
                        let myFeature: HDMFeature = HDMPolygonFeature.init(polygon: poly, featureType: "osm.building", zmin: 43, zmax: 44)
                        let annotation = HDMAnnotation(coordinate: coordinate)
                        annotation.title = beacon.name
                        
                        let gPlace = beaconData(place: beacon, feature: myFeature, annotation: annotation)
                        
                        completionHandler(gPlace)
                    } else {
                        
                        let gPlace = beaconData(place: beacon, feature: nil, annotation: nil)
                        
                        completionHandler(gPlace)
                    }
                    
                    
                } catch {
                    print("error trying to convert data to JSON")
                    print(error)
                }
            })
            
            dataTask.resume()
        }
        }
    }
    
    //MARK: Functions for Sending data to SERVER
    func drawPolygon(_ x: [Double], _ y: [Double]) -> (feature: HDMFeature, points: [putPlace.Geofence.Points]){
        //For Beacon
        var points : [putPlace.Geofence.Points] = []
        var ring0 = [Any] ()
        
        if x.count == 2 {
                
                points.append(putPlace.Geofence.Points(longitude: x[0], latitude: y[0]))
                points.append(putPlace.Geofence.Points(longitude: x[1], latitude: y[0]))
                points.append(putPlace.Geofence.Points(longitude: x[1], latitude: y[1]))
                points.append(putPlace.Geofence.Points(longitude: x[0], latitude: y[1]))
                ring0.append(HDMPoint.init(x[0], y: y[0], z:0))
                ring0.append(HDMPoint.init(x[1], y: y[0], z:0))
                ring0.append(HDMPoint.init(x[1], y: y[1], z:0))
                ring0.append(HDMPoint.init(x[0], y: y[1], z:0))
                
        }
        for (longitude,latitude) in zip(x,y){
            
            points.append(putPlace.Geofence.Points(longitude: longitude, latitude: latitude))
            ring0.append(HDMPoint.init(longitude, y:latitude, z:0))
            
        }
        
        ring0.append(HDMPoint.init(x[0], y: y[0], z: 0))
        
        let poly = HDMPolygon.init(points: ring0 as! [HDMPoint])
        let myFeature: HDMFeature = HDMPolygonFeature.init(polygon: poly, featureType: "osm.building", zmin: 43, zmax: 44)
        
        mapView.add(myFeature)
        
        return (myFeature,points)
    }
    
    func createPlace(_ create: putPlace){
        
        let postData = try! JSONEncoder().encode(create)
        
        print(String(data:postData, encoding: .utf8)!)
        let request = NSMutableURLRequest(url: NSURL(string: "https://manager.gimbal.com/api/v2/places/")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            
            if (error != nil) {
                print(error!)
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse!)
            }
        })
        
        dataTask.resume()
        
    }
    
    func updatePlace(_ updates: putPlace, _ url: String){
        
        let postData = try! JSONEncoder().encode(updates)
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://manager.gimbal.com/api/v2/places/" + String(url))! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        
        print(String(data:postData, encoding: .utf8)!)
        
        request.httpMethod = "PUT"
        request.allHTTPHeaderFields = self.headers
        request.httpBody = postData as Data
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error ?? "Fail to get error message")
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse ?? "Fail to get response")
            }
        })
        dataTask.resume()
    }
    
    func deletePlace(_ url: String, _ name: String){
        
        //sender to deletebeacon
        let data = ["name" : name]
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "deleteGeofence"), object: nil, userInfo: data)
        print(url)
        let request = NSMutableURLRequest(url: NSURL(string: "https://manager.gimbal.com/api/v2/places/" + String(url))! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "DELETE"
        request.allHTTPHeaderFields = self.headers
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (_, response, error) -> Void in
            if (error != nil) {
                print(error ?? "Fail to get error message")
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse ?? "Fail to get response")
            }
        })
        
        dataTask.resume()
        
    }
}
    

