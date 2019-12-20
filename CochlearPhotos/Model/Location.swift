//
//  CochlearPhotos
//
//  Created by Clayton on 20/12/19.
//  Copyright © 2019 Nomad Agency. All rights reserved.
//

import Foundation
import GRDB

// MARK: - Location
class Location: Codable {
    
    let name: String!
    let lat: Double!
    let lng: Double!
    
    let locType: String?
    let notes: String?
    
    init(){
        name = ""
        lat = 0.0
        lng = 0.0
        locType = ""
        notes = ""
    }
}
extension Location: FetchableRecord, PersistableRecord  {
    
    class func insert(locationList: [Location]){
        
        do{
            for location in locationList {
                
                try DBManager.shared.dbMethod.write { db in
                    
                    try location.insert(db)
                }
            }
        }catch{
            print(error.localizedDescription)
        }
    }
    
    class func get(name: String)->Location!{
        
        var returnLocation: Location!
        do{
            try _ = DBManager.shared.dbMethod.read { db in
                
                returnLocation = try Location.fetchOne(db,
                                                sql: "SELECT * FROM Location WHERE name = ?",
                                                arguments: [name])
            }
        }catch{
            print(error.localizedDescription)
        }
        
        return returnLocation
    }
    
    class func getAll()->[Location]?{
        
        var returnArray: [Location] = []
        do{
            try _ = DBManager.shared.dbMethod.read { db in
                
                returnArray = try Location.fetchAll(db,
                                                    sql: "SELECT * FROM Location")
            }
            
        }catch{
            print(error.localizedDescription)
        }
        
        return returnArray
    }
    
    class func deleteAll(){
        do{
            
            try _ = DBManager.shared.dbMethod.write { db in
                
                try Location.deleteAll(db)
                
            }
        }catch{
            print(error.localizedDescription)
        }
    }
}


