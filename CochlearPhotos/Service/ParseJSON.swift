
import Foundation

class ParseJSON {

    class func parseLocations(jsonData: Data, completion : @escaping (Bool)->()){
        

        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
         if let utf8Text = String(data: jsonData, encoding: .utf8) { //DEBUG
         print("User Profile Data: \(utf8Text)")
         }
         
        
        if let locationList = try? decoder.decode(LocationList.self, from: jsonData as Data) {
                   
            Location.insert(locationList: locationList.locations)
                   
            completion(true)
        }

        
    }
    
}
