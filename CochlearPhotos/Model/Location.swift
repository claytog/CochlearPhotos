//
//  CochlearPhotos
//
//  Created by Clayton on 20/12/19.
//  Copyright © 2019 Nomad Agency. All rights reserved.
//

import Foundation
import GRDB
import MapKit

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
    var distance: Double?
    var dateUpdated: Double?
    
    init(){
        name = ""
        lat = 0.0
        lng = 0.00
        locType = LocType.deflt.rawValue
        notes = ""
        distance = 0
        dateUpdated = Util.getEpoch()
    }
}
extension Location: FetchableRecord, PersistableRecord  {
    
    func toCL() -> CLLocationCoordinate2D {
        let latDeg: CLLocationDegrees = CLLocationDegrees(exactly: self.lat)!
        let lngDeg: CLLocationDegrees = CLLocationDegrees(exactly: self.lng)!
        let showLocCLLocation: CLLocationCoordinate2D = CLLocationCoordinate2D.init(latitude: latDeg, longitude: lngDeg)
        return showLocCLLocation
    }
    
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
                
               try db.execute(sql: "UPDATE location SET name=?, notes=?, dateUpdated=? WHERE name=?",
                arguments: [location.name,
                            location.notes,
                            Util.getEpoch(),
                            location.name]
                )
            }
        }catch{
            print(error.localizedDescription)
        }
    }
    
    class func updateDistance(location: Location){
        do{
            try DBManager.shared.dbMethod.write { db in
                
               try db.execute(sql: "UPDATE location SET distance=?, dateUpdated=? WHERE name=?",
                arguments: [location.distance,
                            Util.getEpoch(),
                            location.name]
                )
            }
        }catch{
            print(error.localizedDescription)
        }
    }
    
    class func insertLocation(location: Location){
        
        do{
            try DBManager.shared.dbMethod.write { db in
                
                try db.execute(sql: "REPLACE INTO location VALUES (?,?,?,?,?,?,?)",
                      arguments: [location.name,
                                  location.lat,
                                  location.lng,
                                  location.locType,
                                  location.notes,
                                  location.distance,
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
                                                    sql: "SELECT * FROM Location ORDER BY distance")
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


