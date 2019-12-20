//
//  LocationsAPI.swift
//  CochlearPhotos
//
//  Created by Clayton on 20/12/19.
//  Copyright © 2019 Nomad Agency. All rights reserved.
//
import Foundation
import Alamofire

class LocationsAPI {
    
    class func get(completion : @escaping (Bool)->()){
        
        let url: String = API.locations
        print("Locations URI: " + url)
        let headers = [
            "Content-Type" : "application/json",
            "Accept-API-Version" : "resource=2.0, protocol=1.0"
        ]

        
        Alamofire.request (URL(string: url)!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseJSON { response in
                 API.printDebug(operation: "locationsAPI", response: response)
                if response.error != nil{
                    print("locations error 1: \(String(describing: response.error))") // HTTP URL response
                    
                    if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                        print("locations error 2: \(utf8Text)")
                    }
                }
                ParseJSON.parseLocations(jsonData: response.data!, completion: {_ in
                     completion(true)
                })
               
             
        }
    }
}

