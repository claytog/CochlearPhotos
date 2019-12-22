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
}
