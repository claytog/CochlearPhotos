//
//  Plist.swift
//  CochlearPhotos
//
//  Created by Clayton on 20/12/19.
//  Copyright © 2019 Nomad Agency. All rights reserved.
//

import Foundation

class Plist{
    
    class func get(key: String, fromPlist: String)->String{
        
        var returnString: String = ""
        
        var nsDictionary: NSDictionary?
        if let path = Bundle.main.path(forResource: fromPlist, ofType: "plist") {
            nsDictionary = NSDictionary(contentsOfFile: path)
            
            if let val: Any = nsDictionary!.object(forKey: key) {
                
                returnString = val as! String
            }
        }
        return returnString
    }
}
