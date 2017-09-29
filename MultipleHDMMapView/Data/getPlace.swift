//
//  getPlace.swift
//  MultipleHDMMapView
//
//  Created by Tan Chung Shzen on 22.09.17.
//  Copyright © 2017 HDMI. All rights reserved.
//

import Foundation

struct getPlace : Codable{
    let id: String?
    var name: String?
    
    struct Geofence : Codable{
        var shape: String?
        var radius: Double?
        var center: Double?
        
        struct Points : Codable{
            var latitude: Double?
            var longitude: Double?
        }
        
        var points: [Points]?
        let source: String?
        let sourceId: String?
        let sourceVersion: String?
        let sourceIdType: String?
    }
    
    struct Beacons : Codable{
        var id: String?
        let factoryId: String?
        let name: String?
        
        struct Attributes : Codable{
            let location_from_beacon: String?
            var beaconkey1 : String?
            var beaconkey2 : String?
            
            enum CodingKeys : String, CodingKey{
                case location_from_beacon = "location from beacon"
                case beaconkey1 = "beacon key1"
                case beaconkey2 = "beacon key2"
            }
        }
        
        let attributes: Attributes?
    }
    
    var arrivalRssi: Int?
    var departureRssi: Int?
    
    struct Attributes : Codable{
        let location_from_place: String?
        var key1 : String?
        var key2 : String?
        enum CodingKeys : String, CodingKey{
            case key1
            case key2
            case location_from_place = "location from place"
        }
    }
    
    let geofence: Geofence?
    let beacons: [Beacons]?
    let attributes: Attributes?
    var url: String?
    
}
