//
//  CochlearPhotos
//
//  Created by Clayton on 20/12/19.
//  Copyright © 2019 Nomad Agency. All rights reserved.
//

import Foundation
import GRDB

// MARK: - Location

enum LocType:String {
    
    case deflt = "default"
    case custom = "custom"
}

class Location: Codable {
    
    var name: String!
    var lat: Double!
    var lng: Double!
    
    var locType: String?
    var notes: String?
    var dateUpdated: Double?
    
    init(){
        name = ""
        lat = 0.0
        lng = 0.0
        locType = LocType.deflt.rawValue
        notes = ""
        dateUpdated = Util.getEpoch()
    }
}
extension Location: FetchableRecord, PersistableRecord  {
    
    class func insert(locationList: [Location]){
        
        do{
            for location in locationList {
                location.locType = LocType.deflt.rawValue
                try DBManager.shared.dbMethod.write { db in
                    
                    try location.insert(db)
                }
            }
        }catch{
            print(error.localizedDescription)
        }
    }
    
    class func updateLocation(location: Location){
        
        do{
            
            try DBManager.shared.dbMethod.write { db in
                
               try db.execute(sql: "REPLACE INTO location VALUES (?,?,?,?,?,?)",
                arguments: [location.name,
                            location.lat,
                            location.lng,
                            location.locType,
                            location.notes,
                            Util.getEpoch()]
                )
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


