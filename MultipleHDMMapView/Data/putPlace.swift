//
//  putPlace.swift
//  MultipleHDMMapView
//
//  Created by Tan Chung Shzen on 22.09.17.
//  Copyright © 2017 HDMI. All rights reserved.
//

import Foundation

struct putPlace : Codable{
    
    var name: String?
    
    struct Geofence : Codable{
        
        var shape: String = "POLYGON"
        
        struct Points : Codable{
            var latitude: Double?
            var longitude: Double?
        }
        
        var points: [Points]?
    }
    
    struct Beacons : Codable{
        var id: String?
    }
    
    struct Attributes : Codable{
        var key1 : String?
        var key2 : String?
    }
    
    var geofence: Geofence?
    var beacons: [Beacons]?
    var attributes: Attributes?
    
    init(name: String? = nil, geofence: Geofence? = nil, beacons: [Beacons]? = nil, attributes: Attributes? = nil){
        self.name = name
        self.geofence = geofence
        self.beacons = beacons
        self.attributes = attributes
    }
    
}

