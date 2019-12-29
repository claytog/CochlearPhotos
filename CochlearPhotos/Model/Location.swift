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
    var id: Int!
    var name: String!
    var lat: Double!
    var lng: Double!
    var locType: String?
    var notes: String?
    var distance: Double?
    var dateUpdated: Double?
    
    init(){
        id = 0
        name = ""
        lat = 0.0
        lng = 0.00
        locType = LocType.deflt.rawValue
        notes = ""
        distance = 0
        dateUpdated = Util.getEpoch()
    }
    
    init(locType: LocType, coordinate: CLLocationCoordinate2D){
        self.locType = locType.rawValue
        lat = coordinate.latitude
        lng = coordinate.longitude
    }
}
extension Location: FetchableRecord, PersistableRecord  {
    
    func toCL() -> CLLocationCoordinate2D {
        let latDeg: CLLocationDegrees = CLLocationDegrees(exactly: self.lat)!
        let lngDeg: CLLocationDegrees = CLLocationDegrees(exactly: self.lng)!
        return CLLocationCoordinate2D.init(latitude: latDeg, longitude: lngDeg)
    }
    
    func toLocAnnotation() -> LocAnnotation {
        return LocAnnotation(title: name, locationName: name, locationType: locType!, coordinate: toCL())
    }
    
    class func insert(locationList: [Location]){
        do{
            for location in locationList {
                location.locType = LocType.deflt.rawValue
                let existingLocation = get(name: location.name)
                if existingLocation == nil {
                    try DBManager.shared.dbMethod.write { db in
                        try location.insert(db)
                    }
                }
            }
        }catch{
            print(error.localizedDescription)
        }
    }
    
    class func updateLocation(location: Location){
        do{
            try DBManager.shared.dbMethod.write { db in
                
               try db.execute(sql: "UPDATE location SET name=?, notes=?, dateUpdated=? WHERE id=?",
                arguments: [location.name,
                            location.notes,
                            Util.getEpoch(),
                            location.id]
                )
            }
        }catch{
            print(error.localizedDescription)
        }
    }
    
    class func updateDistance(location: Location){
        do{
            try DBManager.shared.dbMethod.write { db in
                
               try db.execute(sql: "UPDATE location SET distance=?, dateUpdated=? WHERE id=?",
                arguments: [location.distance,
                            Util.getEpoch(),
                            location.id]
                )
            }
        }catch{
            print(error.localizedDescription)
        }
    }
    
    class func insertLocation(location: Location){
        do{
            try DBManager.shared.dbMethod.write { db in
                
                try db.execute(sql: "REPLACE INTO location VALUES (?,?,?,?,?,?,?,?)",
                      arguments: [nil,
                                  location.name,
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

    class func get(id: Int)->Location!{
        var returnLocation: Location!
        do{
            try _ = DBManager.shared.dbMethod.read { db in
                
                returnLocation = try Location.fetchOne(db,
                                                sql: "SELECT * FROM Location WHERE id = ?",
                                                arguments: [id])
            }
        }catch{
            print(error.localizedDescription)
        }
        
        return returnLocation
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


