//
//  API.swift
//  CochlearPhotos
//
//  Created by Clayton on 20/12/19.
//  Copyright © 2019 Nomad Agency. All rights reserved.
//

import Foundation
import Alamofire

class API {
    
    static let baseURL: String = Plist.get(key: "baseURL", fromPlist: "API")
    
    static var locations: String!{
        get {
            
            let locationsPath: String = Plist.get(key: "locationsPath", fromPlist: "API")
            
            return baseURL + locationsPath
        }
    }
    
    class func printDebug (operation: String, response: DataResponse<Any>){
        if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
               print(operation + " data: \(utf8Text)")
          }
    }
}

