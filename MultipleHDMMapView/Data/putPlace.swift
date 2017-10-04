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
        
        var shape: String?
        
        struct Points : Codable{
            var longitude: Double?
            var latitude: Double?
        }
        
        var points: [Points]?
    }
    
    struct Beacons : Codable{
        var id: String?
    }
    
    var geofence: Geofence?
    var beacons: [Beacons]?
    
    init(name: String? = nil, geofence: Geofence? = nil, beacons: [Beacons]? = nil){
        self.name = name
        self.geofence = geofence
        self.beacons = beacons
    }
    
}

