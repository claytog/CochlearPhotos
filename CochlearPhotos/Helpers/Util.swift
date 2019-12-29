//
//  Util.swift
//  CochlearPhotos
//
//  Created by Clayton on 22/12/19.
//  Copyright © 2019 Nomad Agency. All rights reserved.
//

import Foundation

class Util {

    static let shared: Util = Util()
    
    class func getEpoch()-> Double{
        
        return NSDate().timeIntervalSince1970
    }
    
    enum DistanceUnit: String {
        case km = "km"
        case m = "m"
    }
    /// Return the string representation of distance in metres as a Double.
    class func distanceToString(_ distance: Double!) -> String {
        let distanceInKm =  Double(round(distance)/1000)
        var unit: DistanceUnit = .km
        var distanceString = String(distanceInKm)
        switch distanceInKm {
        case 0..<1: // less than 1km show m
            distanceString = String(Int(round(distanceInKm * 1000)))
            unit = .m
        case 1..<10: // between 1 and 10km show 1 decimal place
            distanceString = String(format: "%.1f", distanceInKm)
        case 10... : // 10 and above show no decimal place
            distanceString = String(Int(round(distanceInKm)))
        default:
            distanceString = unit.rawValue
        }
        return distanceString + " " + unit.rawValue
    }
    
    private static let onboardKey: String = "onboard"
    
    class func isOnboard()->Bool{
        return UserDefaults.standard.bool(forKey: onboardKey)
    }
    
    class func onboard(isOnboard:Bool){
        UserDefaults.standard.setValue(isOnboard, forKey: onboardKey)
    }
}
